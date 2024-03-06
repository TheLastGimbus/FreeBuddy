import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart' as tlb;

import '../framework/anc.dart';
import '../framework/lrc_battery.dart';
import 'freebuds3i.dart';
import 'settings.dart';

final class HuaweiFreeBuds3iImpl extends HuaweiFreeBuds3i {
  final tlb.BluetoothDevice _bluetoothDevice;

  /// Bluetooth serial port that we communicate over
  final StreamChannel<Uint8List> _rfcomm;

  HuaweiFreeBuds3iImpl(this._rfcomm, this._bluetoothDevice) {
    throw UnimplementedError();
  }

  @override
  // TODO: implement macAddress
  String get macAddress => throw UnimplementedError();

  @override
  // TODO: implement bluetoothName
  String get bluetoothName => throw UnimplementedError();

  @override
  // TODO: implement bluetoothAlias
  ValueStream<String> get bluetoothAlias => throw UnimplementedError();

  @override
  // TODO: implement batteryLevel
  ValueStream<int> get batteryLevel => throw UnimplementedError();

  @override
  // TODO: implement lrcBattery
  ValueStream<LRCBatteryLevels> get lrcBattery => throw UnimplementedError();

  @override
  // TODO: implement ancMode
  ValueStream<AncMode> get ancMode => throw UnimplementedError();

  @override
  Future<void> setAncMode(AncMode mode) {
    // TODO: implement setAncMode
    throw UnimplementedError();
  }

  @override
  // TODO: implement settings
  ValueStream<HuaweiFreeBuds3iSettings> get settings =>
      throw UnimplementedError();

  @override
  Future<void> setSettings(HuaweiFreeBuds3iSettings newSettings) {
    // TODO: implement setSettings
    throw UnimplementedError();
  }
}
