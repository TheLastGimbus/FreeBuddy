import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../../logger.dart';
import '../huawei/otter/headphones_impl_otter.dart';
import '../huawei/otter/otter_constants.dart';
import 'headphones_cubit_objects.dart';

class HeadphonesConnectionCubit extends Cubit<HeadphonesConnectionState> {
  final TheLastBluetooth _bluetooth;
  BluetoothConnection? _connection;
  StreamSubscription? _btStream;
  StreamSubscription? _devStream;
  bool _btEnabledCache = false;
  static const connectTries = 3;

  // todo: make this professional
  static const sppUuid = "00001101-0000-1000-8000-00805f9b34fb";

  // quic test
  final _free5iReg = RegExp(r'^(?=(HUAWEI FreeBuds 5i))', caseSensitive: true);

  Future<void> connect() async => _connect(await _bluetooth.pairedDevices);

  Future<void> _connect(List<BluetoothDevice> devices) async {
    if (!await _bluetooth.isEnabled()) {
      emit(HeadphonesBluetoothDisabled());
      return;
    }
    if (_connection != null) return; // already connected and working, skip
    final otter = devices.firstWhereOrNull(
      (d) =>
          OtterConst.btDevNameRegex.hasMatch(d.name) ||
          _free5iReg.hasMatch(d.name),
    );
    if (otter == null) {
      emit(HeadphonesNotPaired());
      return;
    }
    if (!otter.isConnected) {
      // not connected to device at all
      emit(HeadphonesDisconnected());
      return;
    }
    emit(HeadphonesConnecting());
    try {
      // when Ai Life takes over our socket, the connecting always succeeds at
      // 2'nd try 🤔
      for (var i = 0; i < connectTries; i++) {
        try {
          _connection = await _bluetooth.connectRfcomm(otter, sppUuid);
        } on PlatformException catch (_) {
          logg.w('Error when connecting socket: ${i + 1}/$connectTries tries');
          if (i + 1 >= connectTries) rethrow;
        }
      }
      emit(HeadphonesConnectedOpen(
          HeadphonesImplOtter(_connection!.io, otter.alias)));
      await _connection!.io.stream.listen((event) {}).asFuture();
      // when device disconnects, future completes and we free the
      // hopefully this happens *before* next stream event with data 🤷
      // so that it nicely goes again and we emit HeadphonesDisconnected()
    } on PlatformException catch (e, s) {
      logg.e("PlatformError while connecting to socket", e, s);
    }
    await _connection?.io.sink.close();
    _connection = null;
    // if disconnected because of bluetooth, don't emit
    // this is because we made async gap when awaiting stream close
    if (!_btEnabledCache) return;
    emit(
      ((await _bluetooth.pairedDevices)
                  .firstWhereOrNull(
                      (d) => OtterConst.btDevNameRegex.hasMatch(d.name))
                  ?.isConnected ??
              false)
          ? HeadphonesConnectedClosed()
          : HeadphonesDisconnected(),
    );
  }

  HeadphonesConnectionCubit({required TheLastBluetooth bluetooth})
      : _bluetooth = bluetooth,
        super(HeadphonesNotPaired()) {
    _init();
  }

  Future<void> _init() async {
    // it's down here to be sure that we do have device connected so
    if (!await Permission.bluetoothConnect.isGranted) {
      emit(HeadphonesNoPermission());
      return;
    }
    _btStream = _bluetooth.adapterInfoStream.listen((event) {
      _btEnabledCache = event.isEnabled;
      if (!event.isEnabled) emit(HeadphonesBluetoothDisabled());
    });
    // logic of connect() is so universal we can use it on every change
    _devStream = _bluetooth.pairedDevicesStream.listen(_connect);
  }

  // TODO:
  Future<bool> enableBluetooth() async => false;

  Future<void> openBluetoothSettings() =>
      AppSettings.openBluetoothSettings(asAnotherTask: true);

  Future<void> requestPermission() async {
    await Permission.bluetoothConnect.request();
    await _init();
  }

  @override
  Future<void> close() async {
    await _btStream?.cancel();
    await _devStream?.cancel();
    super.close();
  }
}
