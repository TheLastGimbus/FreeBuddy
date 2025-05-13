import 'package:rxdart/rxdart.dart';

abstract class DualConnect {
  ValueStream<List<DualConnectDevice>> get dualConnectDevices;
  ValueStream<bool> get dualConnectionEnabled;

  void beginDualConnectEnumeration();

  Future<void> setDualConnectionEnabled(bool enabled);

  Future<void> changeDeviceConnectionStatus(
      DualConnectDevice device, bool connect);

  Future<void> setDeviceAutoConnect(DualConnectDevice device, bool enabled);

  Future<void> setDevicePreferred(DualConnectDevice device, bool enabled);

  Future<void> unpairDevice(DualConnectDevice device);

  void updateDeviceInList(DualConnectDevice device, {bool removed = false});
}

class DualConnectDevice {
  final String name;
  final bool autoConnect;
  final bool preferred;
  final String mac;
  final DCConnectionState connectionState;

  DualConnectDevice(
    this.name,
    this.autoConnect,
    this.preferred,
    this.mac,
    this.connectionState,
  );

  factory DualConnectDevice.empty() => DualConnectDevice(
        'Example',
        true,
        false,
        'FF:FF:FF:FF:FF:FF',
        DCConnectionState.connected,
      );

  List<int> get macAsBytes =>
      mac.split(':').map((e) => int.parse(e, radix: 16)).toList();
}

enum DCConnectionState {
  disconnected,
  connected,
  playing;
}

enum DualConnectCommand {
  connect(1),
  disconnect(2),
  unpair(3),
  enableAuto(4),
  disableAuto(5);

  final int value;

  const DualConnectCommand(this.value);
}
