// left right case battery
import 'package:rxdart/rxdart.dart';

abstract class LRCBattery {
  ValueStream<LRCBatteryLevels> get lrcBattery;
}

class LRCBatteryLevels {
  final int? levelLeft;
  final int? levelRight;
  final int? levelCase;
  final bool chargingLeft;
  final bool chargingRight;
  final bool chargingCase;

  const LRCBatteryLevels(
    this.levelLeft,
    this.levelRight,
    this.levelCase,
    this.chargingLeft,
    this.chargingRight,
    this.chargingCase,
  );
}
