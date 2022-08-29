import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../headphones_connection_cubit.dart';
import 'headphones_service_base.dart';

class HeadphonesConnectedPlugin implements HeadphonesConnected {
  final BluetoothConnection connection;

  HeadphonesConnectedPlugin(this.connection);

  @override
  Stream<HeadphonesAncMode> get ancMode => throw UnimplementedError();

  @override
  Stream<HeadphonesBatteryData> get batteryData => throw UnimplementedError();

  @override
  Future<void> setAncMode(HeadphonesAncMode mode) {
    throw UnimplementedError();
  }
}
