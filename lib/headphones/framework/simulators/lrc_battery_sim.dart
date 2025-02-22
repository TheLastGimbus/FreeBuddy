/// Here are all different mixins for simulating the battery
///
/// This case particularly shows how *genius* I am with all of those mixins 😌
/// You can easily emulate battery always full, or discharging slowly, etc

import 'package:rxdart/rxdart.dart';

import '../lrc_battery.dart';

/// This always shows battery as 100% full and not charging
mixin LRCBatteryAlwaysFullSim implements LRCBattery {
  @override
  ValueStream<LRCBatteryLevels> get lrcBattery => Stream.value(
        const LRCBatteryLevels(
          100,
          100,
          100,
          false,
          false,
          false,
        ),
      ).shareValue();
}

mixin LRCBatteryAlwaysFullSimPlaceholder implements LRCBattery {
  @override
  ValueStream<LRCBatteryLevels> get lrcBattery => BehaviorSubject();
}
