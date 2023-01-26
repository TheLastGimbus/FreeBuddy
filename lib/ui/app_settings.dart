// TODO: Refactor this pice of shit ;_;
// I need to write like 10 lines for every new settings, and it's probably not
// working correctly. Use rxdart or smth
import 'package:async/async.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

abstract class AppSettings {
  Stream<bool> get seenIntroduction;

  Future<bool> setSeenIntroduction(bool value);

  Stream<bool> get sleepMode;

  Future<bool> setSleepMode(bool value);

  Stream<String> get sleepModePreviousSettings;

  Future<bool> setSleepModePreviousSettings(String value);
}

enum _Prefs {
  seenIntroduction('seenIntroduction', false),
  sleepMode('sleepMode', false),
  sleepModePreviousSettings('sleepModePreviousSettings', '');

  const _Prefs(this.key, this.defaultValue);

  final String key;
  final dynamic defaultValue;
}

// TODO: Improve everything here with rxdart or something
class SharedPreferencesAppSettings implements AppSettings {
  SharedPreferencesAppSettings(this.preferences);

  final Future<StreamingSharedPreferences> preferences;

  Future<Preference<bool>> get _seenIntroduction =>
      preferences.then((p) => p.getBool(_Prefs.seenIntroduction.key,
          defaultValue: _Prefs.seenIntroduction.defaultValue));

  Future<Preference<bool>> get _sleepMode =>
      preferences.then((p) => p.getBool(_Prefs.sleepMode.key,
          defaultValue: _Prefs.sleepMode.defaultValue));

  Future<Preference<String>> get _sleepModePreviousSettings =>
      preferences.then((p) => p.getString(_Prefs.sleepModePreviousSettings.key,
          defaultValue: _Prefs.sleepModePreviousSettings.defaultValue));

  @override
  Stream<bool> get seenIntroduction => LazyStream(() => _seenIntroduction);

  @override
  Future<bool> setSeenIntroduction(bool value) =>
      _seenIntroduction.then((v) => v.setValue(value));

  @override
  Stream<bool> get sleepMode => LazyStream(() => _sleepMode);

  @override
  Future<bool> setSleepMode(bool value) =>
      _sleepMode.then((v) => v.setValue(value));

  @override
  Stream<String> get sleepModePreviousSettings =>
      LazyStream(() => _sleepModePreviousSettings);

  @override
  Future<bool> setSleepModePreviousSettings(String value) =>
      _sleepModePreviousSettings.then((v) => v.setValue(value));
}
