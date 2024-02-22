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

class HeadphonesGestureSettings {
  final HeadphonesGestureDoubleTap? doubleTapLeft;
  final HeadphonesGestureDoubleTap? doubleTapRight;
  final HeadphonesGestureHold? holdBoth;
  final Set<HeadphonesAncMode>? holdBothToggledAncModes;

  const HeadphonesGestureSettings({
    this.doubleTapLeft,
    this.doubleTapRight,
    this.holdBoth,
    this.holdBothToggledAncModes,
  });

  HeadphonesGestureSettings copyWith({
    HeadphonesGestureDoubleTap? doubleTapLeft,
    HeadphonesGestureDoubleTap? doubleTapRight,
    HeadphonesGestureHold? holdBoth,
    Set<HeadphonesAncMode>? holdBothToggledAncModes,
  }) =>
      HeadphonesGestureSettings(
        doubleTapLeft: doubleTapLeft ?? this.doubleTapLeft,
        doubleTapRight: doubleTapRight ?? this.doubleTapRight,
        holdBoth: holdBoth ?? this.holdBoth,
        holdBothToggledAncModes:
            holdBothToggledAncModes ?? this.holdBothToggledAncModes,
      );
}

enum HeadphonesGestureDoubleTap {
  nothing(255), // should be -1 but our implementation doesn't see negative
  voiceAssistant(0),
  playPause(1),
  next(2),
  previous(7);

  // this kinda mixes the protocol into pure abstraction layer 🤔
  // hmm.... i dont care 😎
  final int mbbValue;

  const HeadphonesGestureDoubleTap(this.mbbValue);

  static fromMbbValue(int mbbValue) => HeadphonesGestureDoubleTap.values
      .firstWhere((e) => e.mbbValue == mbbValue);
}

enum HeadphonesGestureHold {
  nothing(255), // should be -1 but our implementation doesn't see negative
  cycleAnc(10);

  final int mbbValue;

  const HeadphonesGestureHold(this.mbbValue);

  static fromMbbValue(int mbbValue) =>
      HeadphonesGestureHold.values.firstWhere((e) => e.mbbValue == mbbValue);
}

// TODO: Move this to mbb class or smth
extension MbbStuff on Set<HeadphonesAncMode> {
  int get mbbValue {
    if (isEmpty) return 1;
    if (length == 3) return 2;
    if (this == {HeadphonesAncMode.noiseCancel, HeadphonesAncMode.awareness}) {
      return 3;
    }
    if (this == {HeadphonesAncMode.off, HeadphonesAncMode.awareness}) {
      return 4;
    }
    throw Exception("Unknown mbbValue for $this");
  }
}

Set<HeadphonesAncMode> gestureHoldFromMbbValue(int mbbValue) {
  switch (mbbValue) {
    // For some reason this is also 0 not 1 🤷
    case 0:
    case 1:
      return const {HeadphonesAncMode.off, HeadphonesAncMode.noiseCancel};
    case 2:
      return HeadphonesAncMode.values.toSet();
    case 3:
      return const {HeadphonesAncMode.noiseCancel, HeadphonesAncMode.awareness};
    case 4:
      return const {HeadphonesAncMode.off, HeadphonesAncMode.awareness};
    case 255:
      return {};
    default:
      throw Exception("Unknown mbbValue for $mbbValue");
  }
}
