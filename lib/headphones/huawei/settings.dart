import '../framework/anc.dart';

class HuaweiFreeBuds5iSettings {
  // hey hey hay, not only settings are gonna be duplicate spaghetti shithole,
  // but all the fields are gonna be nullable too!
  final DoubleTap? doubleTapLeft;
  final DoubleTap? doubleTapRight;
  final TripleTap? tripleTapLeft;
  final TripleTap? tripleTapRight;
  final Hold? holdBoth;
  final Set<AncMode>? holdBothToggledAncModes;
  final Swipe? swipe;

  final bool? autoPause;
  final bool? lowLatency;
  final EqPreset? eqPreset;
  final bool? soundQualityMode;

  const HuaweiFreeBuds5iSettings({
    this.doubleTapLeft,
    this.doubleTapRight,
    this.tripleTapLeft,
    this.tripleTapRight,
    this.holdBoth,
    this.holdBothToggledAncModes,
    this.swipe,
    this.autoPause,
    this.lowLatency,
    this.eqPreset,
    this.soundQualityMode,
  });

  // don't want to use codegen *yet*
  HuaweiFreeBuds5iSettings copyWith({
    DoubleTap? doubleTapLeft,
    DoubleTap? doubleTapRight,
    TripleTap? tripleTapLeft,
    TripleTap? tripleTapRight,
    Hold? holdBoth,
    Set<AncMode>? holdBothToggledAncModes,
    Swipe? swipe,
    bool? autoPause,
    bool? lowLatency,
    EqPreset? eqPreset,
    bool? soundQualityMode,
  }) =>
      HuaweiFreeBuds5iSettings(
        doubleTapLeft: doubleTapLeft ?? this.doubleTapLeft,
        doubleTapRight: doubleTapRight ?? this.doubleTapRight,
        tripleTapLeft: tripleTapLeft ?? this.tripleTapLeft,
        tripleTapRight: tripleTapRight ?? this.tripleTapRight,
        holdBoth: holdBoth ?? this.holdBoth,
        holdBothToggledAncModes:
            holdBothToggledAncModes ?? this.holdBothToggledAncModes,
        swipe: swipe ?? this.swipe,
        autoPause: autoPause ?? this.autoPause,
        lowLatency: lowLatency ?? this.lowLatency,
        eqPreset: eqPreset ?? this.eqPreset,
        soundQualityMode: soundQualityMode ?? this.soundQualityMode,
      );
}

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

class HuaweiFreeBuds3iSettings {
  // hey hey hay, not only settings are gonna be duplicate spaghetti shithole,
  // but all the fields are gonna be nullable too!
  final DoubleTap? doubleTapLeft;
  final DoubleTap? doubleTapRight;

  // those are luckily same as 4i
  final Hold? holdBoth;
  final Set<AncMode>? holdBothToggledAncModes;

  // They do have auto-pause... but it's not settable from app 🤷
  // but we may find it some day! That's why I'm commenting it out
  // final bool? autoPause;

  const HuaweiFreeBuds3iSettings({
    this.doubleTapLeft,
    this.doubleTapRight,
    this.holdBoth,
    this.holdBothToggledAncModes,
    // this.autoPause,
  });

  // don't want to use codegen *yet*
  HuaweiFreeBuds3iSettings copyWith({
    DoubleTap? doubleTapLeft,
    DoubleTap? doubleTapRight,
    Hold? holdBoth,
    Set<AncMode>? holdBothToggledAncModes,
    // bool? autoPause,
  }) =>
      HuaweiFreeBuds3iSettings(
        doubleTapLeft: doubleTapLeft ?? this.doubleTapLeft,
        doubleTapRight: doubleTapRight ?? this.doubleTapRight,
        holdBoth: holdBoth ?? this.holdBoth,
        holdBothToggledAncModes:
            holdBothToggledAncModes ?? this.holdBothToggledAncModes,
        // autoPause: autoPause ?? this.autoPause,
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

enum TripleTap {
  nothing,
  next,
  previous;
}

enum Hold {
  nothing,
  cycleAnc;
}

enum Swipe {
  nothing,
  adjustVolume;
}

enum EqPreset {
  defaultEq,
  hardBassEq,
  trebleEq,
  voicesEq;
}
