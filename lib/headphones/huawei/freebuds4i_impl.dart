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
    final lastSettings =
        _settingsCtrl.valueOrNull ?? const HuaweiFreeBuds4iSettings();
    // todo: try pattern matching here
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
        logg.w("Battery data is missing level or status");
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
    } else if (cmd.isAbout(_Cmd.getAutoPause) && cmd.args.containsKey(1)) {
      _settingsCtrl.add(lastSettings.copyWith(autoPause: cmd.args[1]![0] == 1));
    } else if (cmd.isAbout(_Cmd.getGestureDoubleTap)) {
      _settingsCtrl.add(
        lastSettings.copyWith(
          doubleTapLeft: cmd.args[1] != null
              ? DoubleTap.values
                  .firstWhereOrNull((e) => e.mbbCode == cmd.args[1]![0])
              : lastSettings.doubleTapLeft,
          doubleTapRight: cmd.args[2] != null
              ? DoubleTap.values
                  .firstWhereOrNull((e) => e.mbbCode == cmd.args[2]![0])
              : lastSettings.doubleTapRight,
        ),
      );
    } else if (cmd.isAbout(_Cmd.getGestureHold)) {
      _settingsCtrl.add(
        lastSettings.copyWith(
          holdBoth: cmd.args[1] != null
              ? Hold.values
                  .firstWhereOrNull((e) => e.mbbCode == cmd.args[1]![0])
              : lastSettings.holdBoth,
        ),
      );
    } else if (cmd.isAbout(_Cmd.getGestureHoldToggledAncModes)) {
      _settingsCtrl.add(
        lastSettings.copyWith(
          holdBothToggledAncModes: cmd.args[1] != null
              ? _Cmd.gestureHoldToggledAncModesFromMbbValue(cmd.args[1]![0])
              : lastSettings.holdBothToggledAncModes,
        ),
      );
    }
  }

  Future<void> _initRequestInfo() async {
    await _sendMbb(_Cmd.getBattery);
    await _sendMbb(_Cmd.getAnc);
    await _sendMbb(_Cmd.getAutoPause);
    await _sendMbb(_Cmd.getGestureDoubleTap);
    await _sendMbb(_Cmd.getGestureHold);
    await _sendMbb(_Cmd.getGestureHoldToggledAncModes);
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
  Future<void> setSettings(newSettings) async {
    final prev = _settingsCtrl.valueOrNull ?? const HuaweiFreeBuds4iSettings();
    // this is VERY much a boilerplate
    // ...and, bloat...
    // and i don't think there is a need to export it somewhere else 🤷,
    // or make some other abstraction for it - maybe some day
    if ((newSettings.doubleTapLeft ?? prev.doubleTapLeft) !=
        prev.doubleTapLeft) {
      await _sendMbb(_Cmd.gestureDoubleTapLeft(newSettings.doubleTapLeft!));
      await _sendMbb(_Cmd.getGestureDoubleTap);
    }
    if ((newSettings.doubleTapRight ?? prev.doubleTapRight) !=
        prev.doubleTapRight) {
      await _sendMbb(_Cmd.gestureDoubleTapRight(newSettings.doubleTapRight!));
      await _sendMbb(_Cmd.getGestureDoubleTap);
    }
    if ((newSettings.holdBoth ?? prev.holdBoth) != prev.holdBoth) {
      await _sendMbb(_Cmd.gestureHold(newSettings.holdBoth!));
      await _sendMbb(_Cmd.getGestureHold);
      await _sendMbb(_Cmd.getGestureHoldToggledAncModes);
    }
    if ((newSettings.holdBothToggledAncModes ?? prev.holdBothToggledAncModes) !=
        prev.holdBothToggledAncModes) {
      await _sendMbb(_Cmd.gestureHoldToggledAncModes(
          newSettings.holdBothToggledAncModes!));
      await _sendMbb(_Cmd.getGestureHold);
      await _sendMbb(_Cmd.getGestureHoldToggledAncModes);
    }
    if ((newSettings.autoPause ?? prev.autoPause) != prev.autoPause) {
      await _sendMbb(
          newSettings.autoPause! ? _Cmd.autoPauseOn : _Cmd.autoPauseOff);
      await _sendMbb(_Cmd.getAutoPause);
    }
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

  static MbbCommand anc(AncMode mode) => MbbCommand(43, 4, {
        1: [mode.mbbCode, mode == AncMode.off ? 0 : 255]
      });

  static const getGestureDoubleTap = MbbCommand(1, 32);

  static MbbCommand gestureDoubleTapLeft(DoubleTap left) => MbbCommand(1, 31, {
        1: [left.mbbCode]
      });

  static MbbCommand gestureDoubleTapRight(DoubleTap right) =>
      MbbCommand(1, 31, {
        2: [right.mbbCode]
      });

  static const getGestureHold = MbbCommand(43, 23);

  static MbbCommand gestureHold(Hold gestureHold) => MbbCommand(43, 22, {
        1: [gestureHold.mbbCode]
      });

  static const getGestureHoldToggledAncModes = MbbCommand(43, 25);

  static Set<AncMode>? gestureHoldToggledAncModesFromMbbValue(int mbbValue) {
    return switch (mbbValue) {
      1 => const {AncMode.off, AncMode.noiseCancelling},
      2 => AncMode.values.toSet(),
      3 => const {AncMode.noiseCancelling, AncMode.transparency},
      4 => const {AncMode.off, AncMode.transparency},
      255 => {},
      _ => null,
    };
  }

  static MbbCommand gestureHoldToggledAncModes(Set<AncMode> toggledModes) {
    int? mbbValue;
    const se = SetEquality();
    if (se.equals(toggledModes, {AncMode.off, AncMode.noiseCancelling})) {
      mbbValue = 1;
    }
    if (toggledModes.length == 3) mbbValue = 2;
    if (se.equals(
        toggledModes, {AncMode.noiseCancelling, AncMode.transparency})) {
      mbbValue = 3;
    }
    if (se.equals(toggledModes, {AncMode.off, AncMode.transparency})) {
      mbbValue = 4;
    }
    if (mbbValue == null) {
      logg.w("Unknown mbbValue for $toggledModes"
          " - setting as 2 for 'all of them' as a recovery");
      mbbValue = 2;
    }
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

extension _FB4iAncMode on AncMode {
  int get mbbCode => switch (this) {
        AncMode.noiseCancelling => 1,
        AncMode.off => 0,
        AncMode.transparency => 2,
      };
}

extension _FB4iDoubleTap on DoubleTap {
  int get mbbCode => switch (this) {
        DoubleTap.nothing => 255,
        DoubleTap.voiceAssistant => 0,
        DoubleTap.playPause => 1,
        DoubleTap.next => 2,
        DoubleTap.previous => 7
      };
}

extension _FB4iHold on Hold {
  int get mbbCode => switch (this) {
        Hold.nothing => 255,
        Hold.cycleAnc => 10,
      };
}
