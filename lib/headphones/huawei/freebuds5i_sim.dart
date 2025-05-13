import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
import '../simulators/anc_sim.dart';
import '../simulators/bluetooth_headphones_sim.dart';
import '../simulators/dual_connect_sim.dart';
import '../simulators/lrc_battery_sim.dart';
import 'freebuds5i.dart';
import 'settings.dart';

final class HuaweiFreeBuds5iSim extends HuaweiFreeBuds5i
    with
        BluetoothHeadphonesSim,
        LRCBatteryAlwaysFullSim,
        DualConnectSim,
        AncSim {
  // ehhhhhh...

  final _settingsCtrl = BehaviorSubject<HuaweiFreeBuds5iSettings>.seeded(
    const HuaweiFreeBuds5iSettings(
      doubleTapLeft: DoubleTap.playPause,
      doubleTapRight: DoubleTap.playPause,
      tripleTapLeft: TripleTap.previous,
      tripleTapRight: TripleTap.next,
      holdBoth: Hold.cycleAnc,
      holdBothToggledAncModes: {
        AncMode.noiseCancelling,
        AncMode.off,
        AncMode.transparency,
      },
      swipe: Swipe.adjustVolume,
      autoPause: true,
      eqPreset: EqPreset.defaultEq,
    ),
  );

  @override
  ValueStream<HuaweiFreeBuds5iSettings> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(HuaweiFreeBuds5iSettings newSettings) async {
    _settingsCtrl.add(
      _settingsCtrl.value.copyWith(
        doubleTapLeft: newSettings.doubleTapLeft,
        doubleTapRight: newSettings.doubleTapRight,
        tripleTapLeft: newSettings.tripleTapLeft,
        tripleTapRight: newSettings.tripleTapRight,
        holdBoth: newSettings.holdBoth,
        holdBothToggledAncModes: newSettings.holdBothToggledAncModes,
        swipe: newSettings.swipe,
        autoPause: newSettings.autoPause,
        eqPreset: newSettings.eqPreset,
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
final class HuaweiFreeBuds5iSimPlaceholder extends HuaweiFreeBuds5i
    with
        BluetoothHeadphonesSimPlaceholder,
        LRCBatteryAlwaysFullSimPlaceholder,
        DualConnectSimPlaceholder,
        AncSimPlaceholder {
  const HuaweiFreeBuds5iSimPlaceholder();

  @override
  ValueStream<HuaweiFreeBuds5iSettings> get settings => BehaviorSubject();

  @override
  Future<void> setSettings(HuaweiFreeBuds5iSettings newSettings) async {}
}
