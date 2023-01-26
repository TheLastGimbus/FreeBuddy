import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../headphones_service/headphones_service_base.dart';
import 'headphones_connection_cubit.dart';
import 'headphones_cubit_objects.dart';

class HeadphonesMockCubit extends Cubit<HeadphonesObject>
    implements HeadphonesConnectionCubit {
  HeadphonesMockCubit() : super(HeadphonesMock());

  @override
  Future<void> connect() async {}

  @override
  Future<bool> enableBluetooth() async => false;

  @override
  Future<void> openBluetoothSettings() async {}
}

class HeadphonesMock implements HeadphonesConnectedOpen {
  final _batteryData = BehaviorSubject<HeadphonesBatteryData>();
  final _ancMode = BehaviorSubject<HeadphonesAncMode>();
  final _autoPause = BehaviorSubject<bool>();

  HeadphonesMock() {
    Stream.periodic(
      const Duration(seconds: 1),
      (i) => HeadphonesBatteryData(
        ((i * 1.0 - 100).abs() % 100).round(),
        ((i * 1.1 - 100).abs() % 100).round(),
        ((i * 0.7 - 100).abs() % 100).round(),
        i % 35 < 10,
        (i + 6) % 35 < 10,
        i % 15 < 10,
      ),
    ).listen(_batteryData.add);
    _batteryData.add(HeadphonesBatteryData(100, 100, 100, true, true, true));
    _ancMode.add(HeadphonesAncMode.off);
    _autoPause.add(false);
  }

  @override
  Stream<HeadphonesBatteryData> get batteryData => _batteryData.stream;

  @override
  Stream<HeadphonesAncMode> get ancMode => _ancMode.stream;

  @override
  Future<void> setAncMode(HeadphonesAncMode mode) async => _ancMode.add(mode);

  @override
  Stream<bool> get autoPause => _autoPause.stream;

  @override
  Future<void> setAutoPause(bool enabled) async => _autoPause.add(enabled);

  @override
  Future<String> dumpSettings() async => json.encode({
        'ancMode': _ancMode.value.index,
        'autoPause': _autoPause.value,
      });

  @override
  Future<void> restoreSettings(String settings) async {
    final json = jsonDecode(settings) as Map;
    for (final i in json.entries) {
      if (i.key == 'ancMode') {
        await setAncMode(HeadphonesAncMode.values[i.value]);
      } else if (i.key == 'autoPause') {
        await setAutoPause(i.value);
      }
    }
  }
}
