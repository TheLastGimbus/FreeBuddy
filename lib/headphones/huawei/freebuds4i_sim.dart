import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
import '../framework/lrc_battery.dart';
import '../simulators/anc_sim.dart';
import '../simulators/bluetooth_headphones_sim.dart';
import '../simulators/headphones_settings_sim.dart';
import '../simulators/lrc_battery_sim.dart';
import 'freebuds4i.dart';
import 'settings.dart';

final class HuaweiFreeBuds4iSim extends HuaweiFreeBuds4i
    with
        BluetoothHeadphonesSim,
        LRCBatteryAlwaysFullSim,
        AncSim,
        HeadphonesSettingsSim<HuaweiFreeBuds4iSettings> {}

/// Class to use as placeholder for Disabled() widget
// this is not done with mixins because we may want to fill it with
// last-remembered values in future, and we will pretty much override
// all of this
//
// ...or not. I just don't know yet 🤷
final class HuaweiFreeBuds4iSimPlaceholder extends HuaweiFreeBuds4i {
  const HuaweiFreeBuds4iSimPlaceholder();

  @override
  ValueStream<AncMode> get ancMode => BehaviorSubject();

  @override
  ValueStream<int> get batteryLevel => BehaviorSubject();

  @override
  ValueStream<String> get bluetoothAlias => BehaviorSubject();

  @override
  String get bluetoothName => '${super.vendor} ${super.name}';

  @override
  ValueStream<LRCBatteryLevels> get lrcBattery => BehaviorSubject();

  @override
  String get macAddress => '';

  @override
  Future<void> setAncMode(AncMode mode) async {}

  @override
  ValueStream<HuaweiFreeBuds4iSettings> get settings => BehaviorSubject();

  @override
  Future<void> setSettings(newSettings) async {}
}
