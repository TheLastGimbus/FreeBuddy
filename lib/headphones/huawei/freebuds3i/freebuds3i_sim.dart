import 'package:rxdart/rxdart.dart';

import '../../framework/anc.dart';
import '../../framework/simulators/anc_sim.dart';
import '../../framework/simulators/bluetooth_headphones_sim.dart';
import '../../framework/simulators/lrc_battery_sim.dart';
import '../settings.dart';
import 'freebuds3i.dart';

final class HuaweiFreeBuds3iSim extends HuaweiFreeBuds3i
    with BluetoothHeadphonesSim, LRCBatteryAlwaysFullSim, AncSim {
  // ehhhhhh...

  final _settingsCtrl = BehaviorSubject<HuaweiFreeBuds3iSettings>.seeded(
    const HuaweiFreeBuds3iSettings(
      doubleTapLeft: DoubleTap.playPause,
      doubleTapRight: DoubleTap.playPause,
      holdBoth: Hold.cycleAnc,
      holdBothToggledAncModes: {
        AncMode.noiseCancelling,
        AncMode.off,
        AncMode.transparency,
      },
    ),
  );

  @override
  ValueStream<HuaweiFreeBuds3iSettings> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(HuaweiFreeBuds3iSettings newSettings) async {
    _settingsCtrl.add(
      _settingsCtrl.value.copyWith(
        doubleTapLeft: newSettings.doubleTapLeft,
        doubleTapRight: newSettings.doubleTapRight,
        holdBoth: newSettings.holdBoth,
        holdBothToggledAncModes: newSettings.holdBothToggledAncModes,
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
final class HuaweiFreeBuds3iSimPlaceholder extends HuaweiFreeBuds3i
    with
        BluetoothHeadphonesSimPlaceholder,
        LRCBatteryAlwaysFullSimPlaceholder,
        AncSimPlaceholder {
  const HuaweiFreeBuds3iSimPlaceholder();

  @override
  ValueStream<HuaweiFreeBuds3iSettings> get settings => BehaviorSubject();

  @override
  Future<void> setSettings(HuaweiFreeBuds3iSettings newSettings) async {}
}
