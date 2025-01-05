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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LRCBatteryLevels &&
          // TODO: Think if comparing for same runtime here is good idea
          // or if we don't just want it to be LRC, and don't really care
          // if it's something inheritant
          // This ma be important, because it may touch many other aspects
          // of this heavily-objective app ✨
          runtimeType == other.runtimeType &&
          levelLeft == other.levelLeft &&
          levelRight == other.levelRight &&
          levelCase == other.levelCase &&
          chargingLeft == other.chargingLeft &&
          chargingRight == other.chargingRight &&
          chargingCase == other.chargingCase;

  @override
  int get hashCode =>
      levelLeft.hashCode ^
      levelRight.hashCode ^
      levelCase.hashCode ^
      chargingLeft.hashCode ^
      chargingRight.hashCode ^
      chargingCase.hashCode;
}
