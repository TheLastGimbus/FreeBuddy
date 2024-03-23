import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:crclib/catalog.dart';

import '../_old/headphones_data_objects.dart';

/// Helper class for Mbb protocol used to communicate with headphones
class MbbUtils {
  // plus 3 magic bytes + 2 command bytes
  static int getLengthFromLengthByte(int lengthByte) => lengthByte + 3 + 2;

  /// Get Crc16Xmodem checksum of [data] as Uin8List of two bytes
  static Uint8List checksum(List<int> data) {
    final crc = Crc16Xmodem().convert(data);
    // NOTE: There was a fat-ass bug here: crc didn't pad the first number with
    // 0, so every time byte was like this, whole message was rejected :/
    //
    // Because of this, app couldn't get info about gestures when left bud was
    // "play/pause" and right was "voice assist" - it was just blank :/
    //
    // Why I'm saying this - we need some unit tests for all of this
    // even at those early stages
    final str = crc.toRadixString(16).padLeft(4, '0');
    final hexes = [str.substring(0, 2), str.substring(2)];
    final bytes = hexes.map((hex) => int.parse(hex, radix: 16));
    return Uint8List.fromList(bytes.toList());
  }

  /// Checks if checksums are alright
  static bool verifyChecksum(Uint8List payload) {
    final sum = checksum(payload.sublist(0, payload.length - 2));
    return sum[0] == payload[payload.length - 2] &&
        sum[1] == payload[payload.length - 1];
  }

  /// Will return exception if anything wrong. Otherwise does nothing.
  static Exception? verifyIntegrity(Uint8List payload) {
    // 3 magic bytes, 1 length, 1 service, 1 command, 2 checksum
    if (payload.length < 3 + 1 + 1 + 1 + 2) {
      return Exception("Payload $payload is too short");
    }
    if (!payload.sublist(0, 2).elementsEqual([90, 0]) || payload[3] != 0) {
      return Exception("Payload $payload has invalid magic bytes");
    }
    if (payload.length - 6 + 1 != payload[2]) {
      return Exception("Length data from $payload doesn't match length byte");
    }
    if (!verifyChecksum(payload)) {
      return Exception("Checksum from $payload doesn't match");
    }
    return null;
  }
}

/// Helper class to contain info about single command
/// Also parses it and generates payload
class MbbCommand {
  final int serviceId;
  final int commandId;
  final Map<int, List<int>> args;

  const MbbCommand(this.serviceId, this.commandId, this.args);

  @override
  String toString() => 'MbbCommand(serviceId: $serviceId, '
      'commandId: $commandId, dataArgs: $args)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MbbCommand &&
          runtimeType == other.runtimeType &&
          serviceId == other.serviceId &&
          commandId == other.commandId &&
          args.elementsEqual(other.args);

  @override
  int get hashCode => serviceId.hashCode ^ commandId.hashCode ^ args.hashCode;

  /// Convert to binary data to be sent to headphones
  Uint8List toPayload() {
    final data = <int>[];
    args.forEach((key, value) {
      data.add(key);
      data.add(value.length);
      data.addAll(value);
    });
    final dataBytes = Uint8List.fromList(data);
    final byteLength = dataBytes.length + 2 + 1; // +2->checksums +1->*because*
    assert(byteLength <= 255);
    final bytesList = [
      90, // Magic bytes
      0, //
      byteLength,
      0, // another magic byte (i think)
      serviceId,
      commandId,
      ...dataBytes, // Make sure they are >0 and <256
    ];
    return Uint8List.fromList(bytesList..addAll(MbbUtils.checksum(bytesList)));
  }

  static List<MbbCommand> fromPayload(
    Uint8List payload, {
    bool verify = true,
    bool smartDivide = true,
  }) {
    final divided = <Uint8List>[];
    if (smartDivide) {
      while (payload.length >= 8) {
        divided.add(
            payload.sublist(0, MbbUtils.getLengthFromLengthByte(payload[2])));
        payload = payload.sublist(MbbUtils.getLengthFromLengthByte(payload[2]));
      }
    } else {
      divided.add(payload);
    }
    if (divided.isEmpty) {
      if (verify) {
        throw Exception("No commands found in payload");
      } else {
        return [];
      }
    }
    final cmds = <MbbCommand>[];
    for (final divPay in divided) {
      if (verify) {
        final e = MbbUtils.verifyIntegrity(divPay);
        if (e != null) throw e;
      }
      final serviceId = divPay[4];
      final commandId = divPay[5];
      final dataBytes = divPay.sublist(6, divPay.length - 2);

      final args = <int, List<int>>{};
      var offset = 0;
      while (offset < dataBytes.length) {
        final argId = dataBytes[offset];
        final argLength = dataBytes[offset + 1];
        // TODO: Check if argLength is valid and not too big
        final argData = dataBytes.sublist(offset + 2, offset + 2 + argLength);
        offset += 2 + argLength;
        args[argId] = argData;
      }
      cmds.add(MbbCommand(serviceId, commandId, args));
    }
    return cmds;
  }
}

mixin mbbTools {
  fromMbbValue(int mbbValue, Map commandMap)=>
    commandMap.keys.firstWhere((k) => commandMap[k] == mbbValue);
}

abstract class GenericHeadphoneCommands with mbbTools{
  Map<HeadphonesGestureDoubleTap, int> get doubleTapCommands;

  Map<HeadphonesGestureHold, int> get holdCommands;

  Set<HeadphonesAncMode> gestureHoldFromMbbValue(int mbbValue);

  MbbCommand get ancNoiseCancel;

  MbbCommand get ancOff;

  MbbCommand get ancAware;

  MbbCommand get requestBattery;

  MbbCommand get requestAnc;

  MbbCommand get requestAutoPause;

  MbbCommand get autoPauseOn;

  MbbCommand get autoPauseOff;

  MbbCommand get requestGestureDoubleTap;

  dynamic gestureDoubleTapLeft(HeadphonesGestureDoubleTap left);

  dynamic gestureDoubleTapRight(HeadphonesGestureDoubleTap right);

  MbbCommand get requestGestureHold;

  dynamic gestureHold(HeadphonesGestureHold gestureHold);

  MbbCommand get requestGestureHoldToggledAncModes;

  dynamic gestureHoldToggledAncModes(Set<HeadphonesAncMode> toggledModes);
}

class Freebuds3iCommands extends GenericHeadphoneCommands {
  @override
  var doubleTapCommands = {
    HeadphonesGestureDoubleTap.nothing: 255,
    HeadphonesGestureDoubleTap.voiceAssistant: 0,
    HeadphonesGestureDoubleTap.playPause: 1,
    HeadphonesGestureDoubleTap.next: 4,
    HeadphonesGestureDoubleTap.previous: 8
  };
  @override
  var holdCommands = {
    HeadphonesGestureHold.nothing: 255,
    /*
    * This is not ideal. Setting this to 5 means that whenever the user turns ON the "hold to change",
    * all the 3 ANC modes will be set, instead of remembering whatever user had set before turning "hold to change" off.
    * There seems to exist an unused positional argument "1" that can be set with 43 22 and read with 43 23 respectively,
    * so that it could be used to save user's settings and restore them. This needs more looking into, however.
    * */
    HeadphonesGestureHold.cycleAnc: 5,
  };

  @override
  var ancNoiseCancel = const MbbCommand(43, 4, {
    1: [1, 255]
  });
  @override
  var ancOff = const MbbCommand(43, 4, {
    1: [0, 0]
  });
  @override
  var ancAware = const MbbCommand(43, 4, {
    1: [2, 255]
  });
  @override
  var requestBattery = const MbbCommand(1, 8, {});
  @override
  var requestAnc = const MbbCommand(43, 5, {});

  //Freebuds 3i doesn't seem to support auto pause, and this should never get sent,
  //but just in case it does, send an opcode that doesn't do anything.
  //should investigate the possibility of getting autopause to work sometime.
  @override
  var requestAutoPause = const MbbCommand(43, 17, {});
  @override
  var autoPauseOn = const MbbCommand(43, 17, {});
  @override
  var autoPauseOff = const MbbCommand(43, 17, {});

  @override
  var requestGestureDoubleTap = const MbbCommand(1, 32, {});

  @override
  dynamic gestureDoubleTapLeft(HeadphonesGestureDoubleTap left) =>
      MbbCommand(1, 31, {
        1: [doubleTapCommands[left]!],
      });

  @override
  dynamic gestureDoubleTapRight(HeadphonesGestureDoubleTap right) =>
      MbbCommand(1, 31, {
        2: [doubleTapCommands[right]!],
      });

  @override
  var requestGestureHold = const MbbCommand(43, 23, {});

  @override
  dynamic gestureHold(HeadphonesGestureHold gestureHold) =>
      MbbCommand(43, 22, {
        2: [holdCommands[gestureHold]!],
      });

  @override
  var requestGestureHoldToggledAncModes = const MbbCommand(43, 23, {});

  @override
  dynamic gestureHoldToggledAncModes(Set<HeadphonesAncMode> toggledModes) {
    int? mbbValue;
    const se = SetEquality();
    if (![2, 3].contains(toggledModes.length)) {
      throw Exception(
          "toggledModes must have 2 or 3 elements, not ${toggledModes
              .length}}");
    }
    if (toggledModes.length == 3) mbbValue = 5;
    if (se.equals(
        toggledModes, {HeadphonesAncMode.off, HeadphonesAncMode.noiseCancel})) {
      mbbValue = 3;
    }
    if (se.equals(toggledModes,
        {HeadphonesAncMode.noiseCancel, HeadphonesAncMode.awareness})) {
      mbbValue = 6;
    }
    if (se.equals(
        toggledModes, {HeadphonesAncMode.off, HeadphonesAncMode.awareness})) {
      mbbValue = 9;
    }
    if (mbbValue == null) throw Exception("Unknown mbbValue for $toggledModes");
    return MbbCommand(43, 22, {
      //first positional argument should (could?) be used to remember the last used modi after disabling/enabling hold gestures.
      1: [mbbValue],
      //second positional argument sets the actual mode.
      2: [mbbValue]
    });
  }

  @override
  Set<HeadphonesAncMode> gestureHoldFromMbbValue(int mbbValue) {
    switch (mbbValue) {
      case 3:
        return const {HeadphonesAncMode.off, HeadphonesAncMode.noiseCancel};
      case 5:
        return HeadphonesAncMode.values.toSet();
      case 6:
        return const {
          HeadphonesAncMode.noiseCancel,
          HeadphonesAncMode.awareness
        };
      case 9:
        return const {HeadphonesAncMode.off, HeadphonesAncMode.awareness};
      case 255:
        return {};
      default:
        throw Exception("Unknown mbbValue for $mbbValue");
    }
  }
}

class Freebuds4iCommands extends GenericHeadphoneCommands {
  @override
  var doubleTapCommands = {
    HeadphonesGestureDoubleTap.nothing: 255,
    HeadphonesGestureDoubleTap.voiceAssistant: 0,
    HeadphonesGestureDoubleTap.playPause: 1,
    HeadphonesGestureDoubleTap.next: 2,
    HeadphonesGestureDoubleTap.previous: 7
  };
  @override
  var holdCommands = {
    HeadphonesGestureHold.nothing: 255,
    HeadphonesGestureHold.cycleAnc: 10,
  };

  @override
  var ancNoiseCancel = const MbbCommand(43, 4, {
    1: [1, 255]
  });
  @override
  var ancOff = const MbbCommand(43, 4, {
    1: [0, 0]
  });
  @override
  var ancAware = const MbbCommand(43, 4, {
    1: [2, 255]
  });
  @override
  var requestBattery = const MbbCommand(1, 8, {});
  @override
  var requestAnc = const MbbCommand(43, 42, {});
  @override
  var requestAutoPause = const MbbCommand(43, 17, {});
  @override
  var autoPauseOn = const MbbCommand(43, 16, {
    1: [1]
  });
  @override
  var autoPauseOff = const MbbCommand(43, 16, {
    1: [0]
  });
  @override
  var requestGestureDoubleTap = const MbbCommand(1, 32, {});

  @override
  dynamic gestureDoubleTapLeft(HeadphonesGestureDoubleTap left) =>
      MbbCommand(1, 31, {
        1: [doubleTapCommands[left]!],
      });

  @override
  dynamic gestureDoubleTapRight(HeadphonesGestureDoubleTap right) =>
      MbbCommand(1, 31, {
        2: [doubleTapCommands[right]!],
      });

  @override
  var requestGestureHold = const MbbCommand(43, 23, {});

  @override
  dynamic gestureHold(HeadphonesGestureHold gestureHold) => MbbCommand(43, 22, {
        1: [holdCommands[gestureHold]!],
      });

  @override
  var requestGestureHoldToggledAncModes = const MbbCommand(43, 25, {});

  @override
  dynamic gestureHoldToggledAncModes(Set<HeadphonesAncMode> toggledModes) {
    int? mbbValue;
    const se = SetEquality();
    if (![2, 3].contains(toggledModes.length)) {
      throw Exception(
          "toggledModes must have 2 or 3 elements, not ${toggledModes.length}}");
    }
    if (toggledModes.length == 3) mbbValue = 2;
    if (se.equals(
        toggledModes, {HeadphonesAncMode.off, HeadphonesAncMode.noiseCancel})) {
      mbbValue = 0;
    }
    if (se.equals(toggledModes,
        {HeadphonesAncMode.noiseCancel, HeadphonesAncMode.awareness})) {
      mbbValue = 3;
    }
    if (se.equals(
        toggledModes, {HeadphonesAncMode.off, HeadphonesAncMode.awareness})) {
      mbbValue = 4;
    }
    if (mbbValue == null) throw Exception("Unknown mbbValue for $toggledModes");
    return MbbCommand(43, 24, {
      1: [mbbValue],
      2: [mbbValue]
    });
  }

  @override
  Set<HeadphonesAncMode> gestureHoldFromMbbValue(int mbbValue) {
  switch (mbbValue) {
    case 2:
      return HeadphonesAncMode.values.toSet();
    case 3:
      return const {HeadphonesAncMode.off, HeadphonesAncMode.noiseCancel};
    case 5:
      return const {HeadphonesAncMode.off, HeadphonesAncMode.awareness};
    case 6:
      return const {HeadphonesAncMode.noiseCancel, HeadphonesAncMode.awareness};
    case 255:
      return {};
    default:
      throw Exception("Unknown mbbValue for $mbbValue");
  }
  }
}

extension _ListUtils on List {
  bool elementsEqual(List other) {
    return const ListEquality().equals(this, other);
  }
}

extension _MapUtils on Map {
  bool elementsEqual(Map other) {
    return const MapEquality().equals(this, other);
  }
}
