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
  final Set<HeadphonesAncMode>? holdBothToggledAncModes;

  const HeadphonesGestureSettings(
    this.doubleTapLeft,
    this.doubleTapRight,
    this.holdBothToggledAncModes,
  );
}

enum HeadphonesGestureDoubleTap {
  nothing(-1),
  voiceAssistant(0),
  playPause(1),
  next(2),
  previous(7);

  // this kinda mixes the protocol into pure abstraction layer 🤔
  // hmm.... i dont care 😎
  final int mbbValue;

  const HeadphonesGestureDoubleTap(this.mbbValue);
}

// TODO: Move this to mbb class
// class HeadphonesGestureHold {
//   final Set<HeadphonesAncMode> toggledModes;
//
//   const HeadphonesGestureHold(this.toggledModes);
//
//   int get mbbValue {
//     if (toggledModes.isEmpty) return 1;
//     if (toggledModes.length == 3) return 2;
//     if (toggledModes ==
//         {HeadphonesAncMode.noiseCancel, HeadphonesAncMode.awareness}) {
//       return 3;
//     }
//     if (toggledModes == {HeadphonesAncMode.off, HeadphonesAncMode.awareness}) {
//       return 4;
//     }
//     throw Exception("Unknown mbbValue for $toggledModes");
//   }
//
//   static HeadphonesGestureHold fromMbbValue(int mbbValue) {
//     switch (mbbValue) {
//       case 1:
//         return const HeadphonesGestureHold({});
//       case 2:
//         return HeadphonesGestureHold(HeadphonesAncMode.values.toSet());
//       case 3:
//         return const HeadphonesGestureHold(
//             {HeadphonesAncMode.noiseCancel, HeadphonesAncMode.awareness});
//       case 4:
//         return const HeadphonesGestureHold(
//             {HeadphonesAncMode.off, HeadphonesAncMode.awareness});
//       default:
//         throw Exception("Unknown mbbValue for $mbbValue");
//     }
//   }
// }
