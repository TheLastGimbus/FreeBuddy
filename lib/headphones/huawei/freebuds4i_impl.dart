import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';

import '../framework/anc.dart';
import '../framework/lrc_battery.dart';
import 'freebuds4i.dart';

final class HuaweiFreeBuds4iImpl extends HuaweiFreeBuds4i {
  /// Bluetooth serial port that we communicate over
  final StreamChannel<Uint8List> _rfcomm;

  // * stream controllers
  final _batteryLevelCtrl = BehaviorSubject<int>();
  final _bluetoothAliasCtrl = BehaviorSubject<String>();
  final _bluetoothNameCtrl = BehaviorSubject<String>();
  final _lrcBatteryCtrl = BehaviorSubject<LRCBatteryLevels>();
  final _ancModeCtrl = BehaviorSubject<AncMode>();

  // stream controllers *

  HuaweiFreeBuds4iImpl(this._rfcomm) {
    _rfcomm.stream.listen((event) {}, onDone: () {
      // close all streams
      _batteryLevelCtrl.close();
      _bluetoothAliasCtrl.close();
      _bluetoothNameCtrl.close();
      _lrcBatteryCtrl.close();
      _ancModeCtrl.close();
    });
  }

  @override
  // TODO: implement batteryLevel
  ValueStream<int> get batteryLevel => throw UnimplementedError();

  @override
  // TODO: implement bluetoothAlias
  ValueStream<String> get bluetoothAlias => throw UnimplementedError();

  @override
  // TODO: implement bluetoothName
  String get bluetoothName => throw UnimplementedError();

  @override
  // TODO: implement macAddress
  String get macAddress => throw UnimplementedError();

  @override
  // TODO: implement batteryData
  ValueStream<LRCBatteryLevels> get lrcBattery => throw UnimplementedError();

  @override
  // TODO: implement ancMode
  ValueStream<AncMode> get ancMode => throw UnimplementedError();

  @override
  Future<void> setAncMode(AncMode mode) {
    // TODO: implement setAncMode
    throw UnimplementedError();
  }
}
