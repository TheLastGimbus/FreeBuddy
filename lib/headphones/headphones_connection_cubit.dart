import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../logger.dart';
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
      BluetoothDevice? otter;
      try {
        otter =
            devices.firstWhere((d) => Otter.btDevNameRegex.hasMatch(d.name));
      } on StateError catch (_) {}
      emit(otter == null ? HeadphonesNotPaired() : HeadphonesDisconnected());
      if (otter != null && !otter.isConnected) return;
      emit(HeadphonesConnecting());
      _connection = await bluetooth.connectRfcomm(otter!, sppUuid);
      emit(HeadphonesConnectedPlugin(_connection!));
      logg.d(
          "connected to otter: isBroadcast: ${_connection!.io.stream.isBroadcast}");
      // todo: detect disconnection and only then run this loop
    });
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

abstract class HeadphonesConnected extends HeadphonesObject {
  Stream<HeadphonesBatteryData> get batteryData;

  Stream<HeadphonesAncMode> get ancMode;

  Future<void> setAncMode(HeadphonesAncMode mode);
}
