import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart' as tlb;

import '../../logger.dart';
import '../framework/anc.dart';
import '../framework/lrc_battery.dart';
import 'freebuds4i.dart';
import 'mbb.dart';
import 'settings.dart';

final class HuaweiFreeBuds4iImpl extends HuaweiFreeBuds4i {
  final tlb.BluetoothDevice _bluetoothDevice;

  /// Bluetooth serial port that we communicate over
  final StreamChannel<Uint8List> _rfcomm;

  // * stream controllers
  final _batteryLevelCtrl = BehaviorSubject<int>();
  final _bluetoothAliasCtrl = BehaviorSubject<String>();
  final _bluetoothNameCtrl = BehaviorSubject<String>();
  final _lrcBatteryCtrl = BehaviorSubject<LRCBatteryLevels>();
  final _ancModeCtrl = BehaviorSubject<AncMode>();
  final _settingsCtrl = BehaviorSubject<HuaweiFreeBuds4iSettings>();

  // stream controllers *

  /// This watches if we are still missing any info and re-requests it
  late StreamSubscription _watchdogStreamSub;

  HuaweiFreeBuds4iImpl(this._rfcomm, this._bluetoothDevice) {
    // hope this will nicely play with closing, idk honestly
    final aliasStreamSub = _bluetoothDevice.alias
        .listen((alias) => _bluetoothAliasCtrl.add(alias));
    _bluetoothAliasCtrl.onCancel = () => aliasStreamSub.cancel();

    _rfcomm.stream.listen((event) {
      List<MbbCommand>? commands;
      try {
        commands = MbbCommand.fromPayload(event);
      } catch (e, s) {
        logg.e("mbb parsing error", error: e, stackTrace: s);
      }
      for (final cmd in commands ?? <MbbCommand>[]) {
        // FILTER THE SHIT OUT
        if (cmd.serviceId == 10 && cmd.commandId == 13) return;
        try {
          _evalMbbCommand(cmd);
        } on RangeError catch (e, s) {
          logg.e('Error while parsing mbb cmd - (probably missing bytes)',
              error: e, stackTrace: s);
        }
      }
    }, onDone: () {
      // close all streams
      _batteryLevelCtrl.close();
      _bluetoothAliasCtrl.close();
      _bluetoothNameCtrl.close();
      _lrcBatteryCtrl.close();
      _ancModeCtrl.close();
      _settingsCtrl.close();

      _watchdogStreamSub.cancel();
    });
    _initRequestInfo();
    _watchdogStreamSub =
        Stream.periodic(const Duration(seconds: 3)).listen((_) {
      if ([
        batteryLevel.valueOrNull,
        // no alias because it's okay to be null 👍
        lrcBattery.valueOrNull,
        ancMode.valueOrNull,
      ].any((e) => e == null)) {
        _initRequestInfo();
      }
    });
  }

  // TODO: Do something smart about this for @starw1nd_ :)
  // TODO: Decide how we treat exceptions here
  void _evalMbbCommand(MbbCommand cmd) {
    // TODO/MISSING: Gesture settings
    // final lastGestures = _gestureSettingsStreamCtrl.valueOrNull ??
    //     const HeadphonesGestureSettings();
    if (cmd.isAbout(_Cmd.getAnc) && cmd.args.containsKey(1)) {
      // 0 1 and 2 seem to be constant bytes representing the modes
      _ancModeCtrl.add(switch (cmd.args[1]![1]) {
        1 => AncMode.noiseCancelling,
        0 => AncMode.off,
        2 => AncMode.transparency,
        _ => throw "Unknown ANC mode: ${cmd.args[1]}",
      });
    } else if (cmd.serviceId == 1 &&
        (cmd.commandId == 39 || cmd.commandId == 8) &&
        cmd.args.length >= 3) {
      final level = cmd.args[2];
      final status = cmd.args[3];
      if (level == null || status == null) {
        logg.e("Battery data is missing level or status");
        return;
      }
      _lrcBatteryCtrl.add(LRCBatteryLevels(
        level[0] == 0 ? null : level[0],
        level[1] == 0 ? null : level[1],
        level[2] == 0 ? null : level[2],
        status[0] == 1,
        status[1] == 1,
        status[2] == 1,
      ));
    } else if (cmd.serviceId == 43 &&
        cmd.commandId == 17 &&
        cmd.args.containsKey(1)) {
      // TODO/MISSING: Auto pause settings
      // _autoPauseStreamCtrl.add(cmd.args[1]![0] == 1);
    } else if (cmd.serviceId == 1 && cmd.commandId == 32) {
      // TODO/MISSING: Gesture settings
      // _gestureSettingsStreamCtrl.add(
      //   lastGestures.copyWith(
      //     doubleTapLeft: cmd.args[1] != null
      //         ? HeadphonesGestureDoubleTap.fromMbbValue(cmd.args[1]![0])
      //         : lastGestures.doubleTapLeft,
      //     doubleTapRight: cmd.args[2] != null
      //         ? HeadphonesGestureDoubleTap.fromMbbValue(cmd.args[2]![0])
      //         : lastGestures.doubleTapRight,
      //   ),
      // );
    } else if ((cmd.serviceId == 43 && cmd.commandId == 23)) {
      // TODO/MISSING: Gesture settings
      // _gestureSettingsStreamCtrl.add(
      //   lastGestures.copyWith(
      //     holdBoth: (cmd.args[1] != null)
      //         ? HeadphonesGestureHold.fromMbbValue(cmd.args[1]![0])
      //         : lastGestures.holdBoth,
      //   ),
      // );
    } else if (cmd.serviceId == 43 && cmd.commandId == 25) {
      // TODO/MISSING: Gesture settings
      // _gestureSettingsStreamCtrl.add(
      //   lastGestures.copyWith(
      //     holdBothToggledAncModes: (cmd.args[1] != null)
      //         ? gestureHoldFromMbbValue(cmd.args[1]![0])
      //         : lastGestures.holdBothToggledAncModes,
      //   ),
      // );
    }
  }

  Future<void> _initRequestInfo() async {
    await _sendMbb(_Cmd.getBattery);
    await _sendMbb(_Cmd.getAnc);
    // TODO/MISSING: Settings
    // await _sendMbb(MbbCommand.requestAutoPause);
    // await _sendMbb(MbbCommand.requestGestureDoubleTap);
    // await _sendMbb(MbbCommand.requestGestureHold);
    // await _sendMbb(MbbCommand.requestGestureHoldToggledAncModes);
  }

  // TODO: some .flush() for this
  Future<void> _sendMbb(MbbCommand comm) async {
    logg.t("⬆ Sending mbb cmd: $comm");
    _rfcomm.sink.add(comm.toPayload());
  }

  // TODO: Get this from basic bluetooth object (when we actually have those)
  // but this is fairly good for now
  @override
  ValueStream<int> get batteryLevel => _lrcBatteryCtrl.stream
      .map((l) => max(l.levelLeft ?? -1, l.levelRight ?? -1))
      .where((b) => b >= 0)
      .shareValue();

  // i could pass btDevice.alias directly here, but Headphones take care
  // of closing everything
  @override
  ValueStream<String> get bluetoothAlias => _bluetoothAliasCtrl.stream;

  // huh, my past self thought that names will not change... and my future
  // (implementing TLB) thought otherwise 🤷🤷
  @override
  String get bluetoothName => _bluetoothDevice.name.valueOrNull ?? "Unknown";

  @override
  String get macAddress => _bluetoothDevice.mac;

  @override
  ValueStream<LRCBatteryLevels> get lrcBattery => _lrcBatteryCtrl.stream;

  @override
  ValueStream<AncMode> get ancMode => _ancModeCtrl.stream;

  @override
  Future<void> setAncMode(AncMode mode) => _sendMbb(_Cmd.anc(mode));

  @override
  ValueStream<HuaweiFreeBuds4iSettings> get settings => _settingsCtrl.stream;

  @override
  Future<void> setSettings(newSettings) {
    // TODO: implement setSettings
    throw UnimplementedError();
  }
}

/// This is just a holder for magic numbers
/// This isn't very pretty, or eliminates all of the boilerplate... but i
/// feel like nothing will so let's love it as it is <3
///
/// All elements names plainly like "noiseCancel" or "and" mean "set..X",
/// and getters actually have "get" in their names
abstract class _Cmd {
  static const getBattery = MbbCommand(1, 8);

  static const getAnc = MbbCommand(43, 42);

  static MbbCommand anc(AncMode mode) => switch (mode) {
        AncMode.noiseCancelling => const MbbCommand(43, 4, {
            1: [1, 255]
          }),
        AncMode.off => const MbbCommand(43, 4, {
            1: [0, 0]
          }),
        AncMode.transparency => const MbbCommand(43, 4, {
            1: [2, 255]
          }),
      };

  static const doubleTapMagic = {
    DoubleTap.nothing: 255,
    DoubleTap.voiceAssistant: 0,
    DoubleTap.playPause: 1,
    DoubleTap.next: 2,
    DoubleTap.previous: 7
  };
  static const getGestureDoubleTap = MbbCommand(1, 32);

  static MbbCommand gestureDoubleTapLeft(DoubleTap left) => MbbCommand(1, 31, {
        1: [doubleTapMagic[left]!]
      });

  static MbbCommand gestureDoubleTapRight(DoubleTap right) =>
      MbbCommand(1, 31, {
        2: [doubleTapMagic[right]!],
      });

  static const holdMagic = {
    Hold.nothing: 255,
    Hold.cycleAnc: 10,
  };

  static const getGestureHold = MbbCommand(43, 23);

  static MbbCommand gestureHold(Hold gestureHold) => MbbCommand(43, 22, {
        1: [holdMagic[gestureHold]!],
      });

  static const getGestureHoldToggledAncModes = MbbCommand(43, 25);

  static Set<AncMode> gestureHoldFromMbbValue(int mbbValue) {
    switch (mbbValue) {
      case 2:
        return AncMode.values.toSet();
      case 3:
        return const {AncMode.off, AncMode.noiseCancelling};
      case 5:
        return const {AncMode.off, AncMode.transparency};
      case 6:
        return const {AncMode.noiseCancelling, AncMode.transparency};
      case 255:
        return {};
      default:
        throw Exception("Unknown mbbValue for $mbbValue");
    }
  }

  static MbbCommand gestureHoldToggledAncModes(Set<AncMode> toggledModes) {
    int? mbbValue;
    const se = SetEquality();
    if (![2, 3].contains(toggledModes.length)) {
      throw Exception(
          "toggledModes must have 2 or 3 elements, not ${toggledModes.length}}");
    }
    if (toggledModes.length == 3) mbbValue = 2;
    if (se.equals(toggledModes, {AncMode.off, AncMode.noiseCancelling})) {
      mbbValue = 0;
    }
    if (se.equals(
        toggledModes, {AncMode.noiseCancelling, AncMode.transparency})) {
      mbbValue = 3;
    }
    if (se.equals(toggledModes, {AncMode.off, AncMode.transparency})) {
      mbbValue = 4;
    }
    if (mbbValue == null) throw Exception("Unknown mbbValue for $toggledModes");
    return MbbCommand(43, 24, {
      1: [mbbValue],
      2: [mbbValue]
    });
  }

  static const getAutoPause = MbbCommand(43, 17);
  static const autoPauseOn = MbbCommand(43, 16, {
    1: [1]
  });

  static const autoPauseOff = MbbCommand(43, 16, {
    1: [0]
  });
}
