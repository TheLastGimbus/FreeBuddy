enum HeadphonesConnectionState {
  connected,
  connecting,
  disconnected,
  disconnecting,
  notPaired,
}

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

abstract class HeadphonesServiceBase {
  Future<void> init();

  Stream<HeadphonesConnectionState> get connectionState;

  Future<void> dispose();
}
