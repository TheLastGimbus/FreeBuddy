import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import 'headphones_service/headphones_service_base.dart';
import 'headphones_service/headphones_service_bluetooth.dart';
import 'otter_constants.dart';

class HeadphonesConnectionCubit extends Cubit<HeadphonesObject> {
  final TheLastBluetooth bluetooth;
  BluetoothConnection? _connection;

  // todo: make this professional
  static const sppUuid = "00001101-0000-1000-8000-00805f9b34fb";

  void _setupTryConnectingStream() {
    bluetooth.adapterInfoStream.listen((adapterInfo) {
      if (!adapterInfo.isEnabled) {
        emit(HeadphonesBluetoothDisabled());
      }
    });
    bluetooth.pairedDevicesStream.listen((devices) async {
      if (!await bluetooth.isEnabled()) {
        emit(HeadphonesBluetoothDisabled());
        return;
      }
      if (_connection != null) return; // already connected and working, skip
      BluetoothDevice? otter;
      try {
        otter =
            devices.firstWhere((d) => Otter.btDevNameRegex.hasMatch(d.name));
      } on StateError catch (_) {}
      if (otter == null) emit(HeadphonesNotPaired());
      if (!(otter?.isConnected ?? false)) {
        // not connected to device at all
        emit(HeadphonesDisconnected());
        return;
      }
      emit(HeadphonesConnecting());
      try {
        _connection = await bluetooth.connectRfcomm(otter!, sppUuid);
        emit(HeadphonesConnectedOpenPlugin(_connection!));
        await _connection!.io.stream.listen((event) {}).asFuture();
        // when device disconnects, future completes and we free the
        // hopefully this happens *before* next stream event with data 🤷
        // so that it nicely goes again and we emit HeadphonesDisconnected()
      } on PlatformException catch (_) {
      } finally {
        await _connection?.io.sink.close();
        _connection = null;
        emit(HeadphonesConnectedClosed());
      }
    });
  }

  Future<bool> connect([List<BluetoothDevice>? devices]) async {
    devices ??= await bluetooth.pairedDevices;
    if (_connection != null) {
      // already connected and working, skip
      emit(HeadphonesConnectedOpenPlugin(_connection!));
      return true;
    }
    BluetoothDevice? otter;
    try {
      otter = devices.firstWhere((d) => Otter.btDevNameRegex.hasMatch(d.name));
    } on StateError catch (_) {}
    if (otter == null) emit(HeadphonesNotPaired());
    if (!(otter?.isConnected ?? false)) {
      emit(HeadphonesDisconnected());
      return false;
    }
    emit(HeadphonesConnecting());
    try {
      _connection = await bluetooth.connectRfcomm(otter!, sppUuid);
      emit(HeadphonesConnectedOpenPlugin(_connection!));
      return true;
    } on PlatformException catch (_) {
      emit(HeadphonesConnectedClosed());
      return false;
    }
  }

  HeadphonesConnectionCubit({required this.bluetooth})
      : super(HeadphonesNotPaired()) {
    _setupTryConnectingStream();
  }

  // TODO:
  Future<bool> enableBluetooth() async => false;

  Future<void> openBluetoothSettings() =>
      AppSettings.openBluetoothSettings(asAnotherTask: true);
}

abstract class HeadphonesObject {}

class HeadphonesBluetoothDisabled extends HeadphonesObject {}

class HeadphonesNotPaired extends HeadphonesObject {}

class HeadphonesDisconnected extends HeadphonesObject {}

class HeadphonesConnecting extends HeadphonesObject {}

abstract class HeadphonesConnectedOpen extends HeadphonesObject {
  Stream<HeadphonesBatteryData> get batteryData;

  Stream<HeadphonesAncMode> get ancMode;

  Future<void> setAncMode(HeadphonesAncMode mode);
}

class HeadphonesConnectedClosed extends HeadphonesObject {}
