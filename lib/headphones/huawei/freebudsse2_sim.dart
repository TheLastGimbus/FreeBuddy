import 'package:rxdart/rxdart.dart';

import '../simulators/bluetooth_headphones_sim.dart';
import '../simulators/lrc_battery_sim.dart';
import 'freebudsse2.dart';
import 'settings.dart';

final class HuaweiFreeBudsSE2Sim extends HuaweiFreeBudsSE2
    with BluetoothHeadphonesSim, LRCBatteryAlwaysFullSim {
  // ehhhhhh...

  final _settingsCtrl = BehaviorSubject<HuaweiFreeBudsSE2Settings>.seeded(
    const HuaweiFreeBudsSE2Settings(
      doubleTapLeft: DoubleTap.playPause,
      doubleTapRight: DoubleTap.playPause,
    ),
  );

  @override
  ValueStream<HuaweiFreeBudsSE2Settings> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(HuaweiFreeBudsSE2Settings newSettings) async {
    _settingsCtrl.add(
      _settingsCtrl.value.copyWith(
        doubleTapLeft: newSettings.doubleTapLeft,
        doubleTapRight: newSettings.doubleTapRight,
      ),
    );
  }
}

/// Class to use as placeholder for Disabled() widget
// this is not done with mixins because we may want to fill it with
// last-remembered values in future, and we will pretty much override
// all of this
//
// ...or not. I just don't know yet 🤷
final class HuaweiFreeBudsSE2SimPlaceholder extends HuaweiFreeBudsSE2
    with BluetoothHeadphonesSimPlaceholder, LRCBatteryAlwaysFullSimPlaceholder {
  const HuaweiFreeBudsSE2SimPlaceholder();

  @override
  ValueStream<HuaweiFreeBudsSE2Settings> get settings => BehaviorSubject();

  @override
  Future<void> setSettings(HuaweiFreeBudsSE2Settings newSettings) async {}
}
