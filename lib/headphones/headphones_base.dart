import 'dart:convert';

import 'package:rxdart/rxdart.dart';

import 'headphones_data_objects.dart';

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
abstract class HeadphonesBase {
  // TODO: Stream/whatever - this doesn't self update
  String? get alias;

  ValueStream<HeadphonesBatteryData> get batteryData;

  ValueStream<HeadphonesAncMode> get ancMode;

  Future<void> setAncMode(HeadphonesAncMode mode);

  ValueStream<bool> get autoPause;

  Future<void> setAutoPause(bool enabled);

  ValueStream<HeadphonesGestureSettings> get gestureSettings;

  Future<void> setGestureSettings(HeadphonesGestureSettings settings);

  /// Dumps all settings to JSON/whatever-you-like stream
  /// (format shouldn't matter because only place where this string should be
  /// parsed is [restoreSettings])
  ///
  /// Use this when using something like sleep mode, where you want to change
  /// multiple settings, then restore previous ones when disabling
  Future<String> dumpSettings() async => json.encode({
        'ancMode': ancMode.valueOrNull?.index,
        'autoPause': autoPause.valueOrNull,
      });

  /// Restore all settings from string got from [dumpSettings]
  ///
  /// Missing data/keys shouldn't bother this function
  Future<void> restoreSettings(String settings) async {
    // TODO: This is missing gesture settings, but we don't use this for now
    final json = jsonDecode(settings) as Map;
    for (final i in json.entries) {
      if (i.value == null) continue;
      if (i.key == 'ancMode') {
        await setAncMode(HeadphonesAncMode.values[i.value]);
      } else if (i.key == 'autoPause') {
        await setAutoPause(i.value);
      }
    }
  }
}
