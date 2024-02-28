import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/src/bluetooth_device.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../../logger.dart';
import '../huawei/freebuds4i.dart';
import '../huawei/freebuds4i_impl.dart';
import '../huawei/freebuds4i_sim.dart';
import 'headphones_cubit_objects.dart';

class HeadphonesConnectionCubit extends Cubit<HeadphonesConnectionState> {
  final TheLastBluetooth _bluetooth;
  StreamChannel<Uint8List>? _connection;
  StreamSubscription? _btEnabledStream;
  StreamSubscription? _devStream;
  static const connectTries = 3;

  // I needed a way to tell (from background task) if app is currently running.
  // First idea was to then ask the cubit for some info (about battery etc)
  // But, looking at how fucked up this Port communication is, I will just
  // register/deregister this port name, and if background detects it, it just
  // skips 🤷
  //
  // UDPATE: LOOKS LIKE I CAN'T JUST REGEISTER, BECAUSE BLOC SUCKS ASS
  // I WILL HAVE FULL BLOWN PING HERE NOW
  // I could just implement whole fucking http server altoghether -_-
  // ...
  // Actaully............
  // I would probably need something like this for Linux Desktop anyway...
  // This might not be such a bad idea........
  // ...
  // Stop.
  static const pingReceivePortName = 'pingHeadphonesCubitPort';
  final _pingReceivePort = ReceivePort('dummyHeadphonesCubitPort');
  late final StreamSubscription _pingReceivePortSS;

  // This is so fucking embarrassing......
  // Race conditions??? FUCK YES
  static Future<bool> cubitAlreadyRunningSomewhere() async {
    final ping = IsolateNameServer.lookupPortByName(
        HeadphonesConnectionCubit.pingReceivePortName);
    if (ping == null) return false;
    final pong = ReceivePort(); // this is not right naming, i know
    ping.send(pong.sendPort);
    return await pong.first.timeout(
      const Duration(milliseconds: 50),
      onTimeout: () => false,
    ) as bool;
  }

  // todo: make this professional
  static const sppUuid = "00001101-0000-1000-8000-00805f9b34fb";

  Future<void> connect() async => _connect(_bluetooth.pairedDevices.value);

  // TODO/MIGRATION: This whole big-ass connection/detection loop 🤯
  // for example, all placeholders assume we have 4i... not good
  Future<void> _connect(Iterable<BluetoothDevice> devices) async {
    if (!(_bluetooth.isEnabled.valueOrNull ?? false)) {
      emit(const HeadphonesBluetoothDisabled());
      return;
    }
    if (_connection != null) return; // already connected and working, skip
    final otter = devices.firstWhereOrNull(
        (d) => HuaweiFreeBuds4i.idNameRegex.hasMatch(d.name.value));
    if (otter == null) {
      emit(const HeadphonesNotPaired());
      return;
    }
    if (!(otter.isConnected.valueOrNull ?? false)) {
      // not connected to device at all
      emit(const HeadphonesDisconnected(HuaweiFreeBuds4iSimPlaceholder()));
      return;
    }
    emit(const HeadphonesConnecting(HuaweiFreeBuds4iSimPlaceholder()));
    try {
      // when Ai Life takes over our socket, the connecting always succeeds at
      // 2'nd try 🤔
      for (var i = 0; i < connectTries; i++) {
        try {
          _connection = _bluetooth.connectRfcomm(otter, sppUuid);
          break;
        } catch (_) {
          logg.w('Error when connecting socket: ${i + 1}/$connectTries tries');
          if (i + 1 >= connectTries) rethrow;
        }
      }
      emit(HeadphonesConnectedOpen(HuaweiFreeBuds4iImpl(_connection!, otter)));
      await _connection!.stream.listen((event) {}).asFuture();
      // when device disconnects, future completes and we free the
      // hopefully this happens *before* next stream event with data 🤷
      // so that it nicely goes again and we emit HeadphonesDisconnected()
    } catch (e, s) {
      logg.e("Error while connecting to socket", error: e, stackTrace: s);
    }
    await _connection?.sink.close();
    _connection = null;
    // if disconnected because of bluetooth, don't emit
    // this is because we made async gap when awaiting stream close
    if (!(_bluetooth.isEnabled.valueOrNull ?? false)) return;
    emit(
      ((_bluetooth.pairedDevices.value
                  .firstWhereOrNull((d) =>
                      HuaweiFreeBuds4i.idNameRegex.hasMatch(d.name.value))
                  ?.isConnected
                  .valueOrNull) ??
              false)
          ? const HeadphonesConnectedClosed(HuaweiFreeBuds4iSimPlaceholder())
          : const HeadphonesDisconnected(HuaweiFreeBuds4iSimPlaceholder()),
    );
  }

  HeadphonesConnectionCubit({required TheLastBluetooth bluetooth})
      : _bluetooth = bluetooth,
        super(const HeadphonesNotPaired()) {
    IsolateNameServer.removePortNameMapping(pingReceivePortName);
    IsolateNameServer.registerPortWithName(
        _pingReceivePort.sendPort, pingReceivePortName);
    _pingReceivePortSS = _pingReceivePort.listen((message) {
      // ping back
      if (message is SendPort) message.send(true);
    });
    _init();
  }

  Future<void> _init() async {
    // it's down here to be sure that we do have device connected so
    if (!await Permission.bluetoothConnect.isGranted) {
      emit(const HeadphonesNoPermission());
      return;
    }
    _bluetooth.init();
    _btEnabledStream = _bluetooth.isEnabled.listen((enabled) {
      if (!enabled) emit(const HeadphonesBluetoothDisabled());
    });
    // logic of connect() is so universal we can use it on every change
    _devStream = _bluetooth.pairedDevices.listen(_connect);
  }

  // TODO:
  Future<bool> enableBluetooth() async => false;

  Future<void> openBluetoothSettings() => AppSettings.openAppSettings(
      type: AppSettingsType.bluetooth, asAnotherTask: true);

  Future<void> requestPermission() async {
    await Permission.bluetoothConnect.request();
    await _init();
  }

  @override
  Future<void> close() async {
    await _pingReceivePortSS.cancel();
    _pingReceivePort.close();
    IsolateNameServer.removePortNameMapping(pingReceivePortName);
    await _connection?.sink.close();
    await _btEnabledStream?.cancel();
    await _devStream?.cancel();
    super.close();
  }
}
