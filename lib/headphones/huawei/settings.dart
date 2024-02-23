import '../framework/anc.dart';

class HuaweiFreeBuds4iSettings {
  // hey hey hay, not only settings are gonna be duplicate spaghetti shithole,
  // but all the fields are gonna be nullable too!
  final DoubleTap? doubleTapLeft;
  final DoubleTap? doubleTapRight;
  final Hold? holdBoth;
  final Set<AncMode>? holdBothToggledAncModes;

  final bool? autoPause;

  const HuaweiFreeBuds4iSettings({
    this.doubleTapLeft,
    this.doubleTapRight,
    this.holdBoth,
    this.holdBothToggledAncModes,
    this.autoPause,
  });

  // don't want to use codegen *yet*
  HuaweiFreeBuds4iSettings copyWith({
    DoubleTap? doubleTapLeft,
    DoubleTap? doubleTapRight,
    Hold? holdBoth,
    Set<AncMode>? holdBothToggledAncModes,
    bool? autoPause,
  }) =>
      HuaweiFreeBuds4iSettings(
        doubleTapLeft: doubleTapLeft ?? this.doubleTapLeft,
        doubleTapRight: doubleTapRight ?? this.doubleTapRight,
        holdBoth: holdBoth ?? this.holdBoth,
        holdBothToggledAncModes:
            holdBothToggledAncModes ?? this.holdBothToggledAncModes,
        autoPause: autoPause ?? this.autoPause,
      );
}

// i don't have idea how to public/privatise those and how to name them
// let's assume that any screen/logic that uses them at all is already
// model-specific so generic names are okay

enum DoubleTap {
  nothing,
  voiceAssistant,
  playPause,
  next,
  previous;
}

enum Hold {
  nothing,
  cycleAnc;
}
