import '../headphones_service/headphones_service_base.dart';

abstract class HeadphonesObject {}

class HeadphonesBluetoothDisabled extends HeadphonesObject {}

class HeadphonesNotPaired extends HeadphonesObject {}

class HeadphonesDisconnected extends HeadphonesObject {}

class HeadphonesConnecting extends HeadphonesObject {}

abstract class HeadphonesConnectedOpen extends HeadphonesObject {
  Stream<HeadphonesBatteryData> get batteryData;

  Stream<HeadphonesAncMode> get ancMode;

  Future<void> setAncMode(HeadphonesAncMode mode);

  Stream<bool> get autoPause;

  Future<void> setAutoPause(bool enabled);
}

class HeadphonesConnectedClosed extends HeadphonesObject {}
