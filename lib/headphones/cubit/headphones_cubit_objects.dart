import '../headphones_service/headphones_service_base.dart';

abstract class HeadphonesObject {}

class HeadphonesBluetoothDisabled extends HeadphonesObject {}

class HeadphonesNotPaired extends HeadphonesObject {}

class HeadphonesDisconnected extends HeadphonesObject {}

class HeadphonesConnecting extends HeadphonesObject {}

/// Base class for interacting with headphones. UI/other logic shout *not*
/// care what underlying class is implementing it so we can test nicely with
/// mocks
///
/// All data - about battery, modes, settings etc should be a separate stream,
/// so we can nicely use [StreamBuildes]s everywhere
///
/// Moreover, all of those streams should be implemented with
/// [rxdart](https://pub.dev/packages/rxdart#rx-observables-vs-dart-streams)'s
/// [BehaviorSubject]s, so latest value is always available for all listeners
// (Previously, there were often grayed out values because we had to wait for
// stream to emit again)
abstract class HeadphonesConnectedOpen extends HeadphonesObject {
  Stream<HeadphonesBatteryData> get batteryData;

  Stream<HeadphonesAncMode> get ancMode;

  Future<void> setAncMode(HeadphonesAncMode mode);

  Stream<bool> get autoPause;

  Future<void> setAutoPause(bool enabled);

  // TODO: We're duplicating this between impl and mock
  // for now it's fine, but in future we should replace with some clever stuff
  // like doing this on level of abstract class
  Future<String> dumpSettings();

  Future<void> restoreSettings(String settings);
}

class HeadphonesConnectedClosed extends HeadphonesObject {}
