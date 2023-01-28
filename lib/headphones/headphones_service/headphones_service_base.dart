import 'dart:math';

// Potentially, some day, make cubit emit this enum + headphones object to use.
// It could emit fake headphones on "not paired" or "last known state"
// headphoens on "disconnected"
// commenting it now since it collides with headphones_base.dart
// enum HeadphonesConnectionState {
//   connected,
//   connecting,
//   disconnected,
//   disconnecting,
//   notPaired,
// }

class HeadphonesBatteryData {
  final int? levelLeft;
  final int? levelRight;
  final int? levelCase;
  final bool chargingLeft;
  final bool chargingRight;
  final bool chargingCase;

  HeadphonesBatteryData(
    this.levelLeft,
    this.levelRight,
    this.levelCase,
    this.chargingLeft,
    this.chargingRight,
    this.chargingCase,
  );

  int get lowestLevel => min(levelLeft ?? 100, levelLeft ?? 100);

  @override
  String toString() => 'BatteryData(levelLeft: $levelLeft, '
      'levelRight: $levelRight, levelCase: $levelCase, '
      'chargingLeft: $chargingLeft, chargingRight: $chargingRight, '
      'chargingCase: $chargingCase)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeadphonesBatteryData &&
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

enum HeadphonesAncMode {
  noiseCancel,
  off,
  awareness,
}
