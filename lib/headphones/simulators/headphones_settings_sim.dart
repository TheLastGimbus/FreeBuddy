import 'package:rxdart/rxdart.dart';

import '../framework/headphones_settings.dart';

mixin HeadphonesSettingsSim<T> implements HeadphonesSettings<T> {
  // No initial data... since we can't know it nor pass it to mixins...
  // I thought about making some abstract class for all settings, that would
  // require .default()... decided to hold up now... but in future, maybe :)
  final _settingsCtrl = BehaviorSubject<T>();

  @override
  ValueStream<T> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(T newSettings) async =>
      _settingsCtrl.add(newSettings);
}
