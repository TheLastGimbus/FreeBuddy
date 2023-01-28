import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../huawei/otter/headphones_impl_otter.dart';
import '../huawei/otter/otter_constants.dart';
import 'headphones_cubit_objects.dart';

class HeadphonesConnectionCubit extends Cubit<HeadphonesConnectionState> {
  final TheLastBluetooth _bluetooth;
  BluetoothConnection? _connection;
  StreamSubscription? _devStream;

  // todo: make this professional
  static const sppUuid = "00001101-0000-1000-8000-00805f9b34fb";

  Future<void> connect() async => _connect(await _bluetooth.pairedDevices);

  Future<void> _connect(List<BluetoothDevice> devices) async {
    if (!await _bluetooth.isEnabled()) {
      emit(HeadphonesBluetoothDisabled());
      return;
    }
    if (_connection != null) return; // already connected and working, skip
    final otter = devices
        .firstWhereOrNull((d) => OtterConst.btDevNameRegex.hasMatch(d.name));
    if (otter == null) emit(HeadphonesNotPaired());
    if (!(otter?.isConnected ?? false)) {
      // not connected to device at all
      emit(HeadphonesDisconnected());
      return;
    }
    emit(HeadphonesConnecting());
    try {
      _connection = await _bluetooth.connectRfcomm(otter!, sppUuid);
      emit(HeadphonesConnectedOpen(HeadphonesImplOtter(_connection!.io)));
      await _connection!.io.stream.listen((event) {}).asFuture();
      // when device disconnects, future completes and we free the
      // hopefully this happens *before* next stream event with data 🤷
      // so that it nicely goes again and we emit HeadphonesDisconnected()
    } on PlatformException catch (_) {
    } finally {
      await _connection?.io.sink.close();
      _connection = null;
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
  }

  HeadphonesConnectionCubit({required TheLastBluetooth bluetooth})
      : _bluetooth = bluetooth,
        super(HeadphonesNotPaired()) {
    // logic of connect() is so universal we can use it on every change
    _devStream = _bluetooth.pairedDevicesStream.listen(_connect);
  }

  // TODO:
  Future<bool> enableBluetooth() async => false;

  Future<void> openBluetoothSettings() =>
      AppSettings.openBluetoothSettings(asAnotherTask: true);

  @override
  Future<void> close() async {
    await _devStream?.cancel();
    super.close();
  }
}
