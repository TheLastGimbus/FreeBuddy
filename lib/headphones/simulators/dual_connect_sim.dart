import 'package:rxdart/rxdart.dart';

import '../framework/dual_connect.dart';

mixin DualConnectSim implements DualConnect {
  @override
  void beginDualConnectEnumeration() {}

  @override
  Future<void> setDualConnectionEnabled(bool enabled) async {}

  @override
  Future<void> changeDeviceConnectionStatus(
      DualConnectDevice device, bool connect) async {}

  @override
  Future<void> setDeviceAutoConnect(
      DualConnectDevice device, bool enabled) async {}

  @override
  Future<void> setDevicePreferred(
      DualConnectDevice device, bool enabled) async {}

  @override
  Future<void> unpairDevice(DualConnectDevice device) async {}

  @override
  ValueStream<List<DualConnectDevice>> get dualConnectDevices =>
      ValueConnectableStream(
        Stream.value(
          [DualConnectDevice.empty()],
        ),
      );

  @override
  void updateDeviceInList(DualConnectDevice device, {bool removed = false}) {}

  @override
  ValueStream<bool> get dualConnectionEnabled =>
      ValueConnectableStream(Stream.value(false));
}

mixin DualConnectSimPlaceholder implements DualConnect {
  @override
  void beginDualConnectEnumeration() {}

  @override
  Future<void> setDualConnectionEnabled(bool enabled) async {}

  @override
  Future<void> changeDeviceConnectionStatus(
      DualConnectDevice device, bool connect) async {}

  @override
  Future<void> setDeviceAutoConnect(
      DualConnectDevice device, bool enabled) async {}

  @override
  Future<void> setDevicePreferred(
      DualConnectDevice device, bool enabled) async {}

  @override
  Future<void> unpairDevice(DualConnectDevice device) async {}

  @override
  ValueStream<List<DualConnectDevice>> get dualConnectDevices =>
      ValueConnectableStream(
        Stream.value(
          [DualConnectDevice.empty()],
        ),
      );

  @override
  void updateDeviceInList(DualConnectDevice device, {bool removed = false}) {}

  @override
  ValueStream<bool> get dualConnectionEnabled =>
      ValueConnectableStream(Stream.value(false));
}
