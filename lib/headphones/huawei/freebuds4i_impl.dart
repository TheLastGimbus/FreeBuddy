import 'dart:async';

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
  final StreamChannel<MbbCommand> _mbb;

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

  HuaweiFreeBuds4iImpl(this._mbb, this._bluetoothDevice) {
    // hope this will nicely play with closing, idk honestly
    final aliasStreamSub = _bluetoothDevice.alias
        .listen((alias) => _bluetoothAliasCtrl.add(alias));
    _bluetoothAliasCtrl.onCancel = () => aliasStreamSub.cancel();

    _mbb.stream.listen(
      (e) {
        try {
          _evalMbbCommand(e);
        } catch (e, s) {
          logg.e(e, stackTrace: s);
        }
      },
      onError: logg.onError,
      onDone: () {
        _watchdogStreamSub.cancel();

        // close all streams
        _batteryLevelCtrl.close();
        _bluetoothAliasCtrl.close();
        _bluetoothNameCtrl.close();
        _lrcBatteryCtrl.close();
        _ancModeCtrl.close();
        _settingsCtrl.close();
      },
    );
    _initRequestInfo();
    _watchdogStreamSub =
        Stream.periodic(const Duration(seconds: 3)).listen((_) {
      if ([
        batteryLevel.valueOrNull,
        // no alias because it's okay to be null 👍
        lrcBattery.valueOrNull,
        ancMode.valueOrNull,
        settings.valueOrNull,
      ].any((e) => e == null)) {
        _initRequestInfo();
      }
    });
  }

  void _evalMbbCommand(MbbCommand cmd) {
    final lastSettings =
        _settingsCtrl.valueOrNull ?? const HuaweiFreeBuds4iSettings();
    switch (cmd.args) {
      // # AncMode
      case {1: [_, var ancModeCode, ...]} when cmd.isAbout(_Cmd.getAnc):
        final mode =
            AncMode.values.firstWhereOrNull((e) => e.mbbCode == ancModeCode);
        if (mode != null) _ancModeCtrl.add(mode);
        break;
      // # BatteryLevels
      case {2: var level, 3: var status}
          when cmd.serviceId == 1 &&
              (cmd.commandId == 39 || cmd.commandId == 8):
        _lrcBatteryCtrl.add(LRCBatteryLevels(
          level[0] == 0 ? null : level[0],
          level[1] == 0 ? null : level[1],
          level[2] == 0 ? null : level[2],
          status[0] == 1,
          status[1] == 1,
          status[2] == 1,
        ));
        break;
      // # Settings(autoPause)
      case {1: [var autoPauseCode, ...]} when cmd.isAbout(_Cmd.getAutoPause):
        _settingsCtrl.add(lastSettings.copyWith(autoPause: autoPauseCode == 1));
        break;
      // # Settings(gestureDoubleTap)
      case {1: [var leftCode, ...], 2: [var rightCode, ...]}
          when cmd.isAbout(_Cmd.getGestureDoubleTap):
        _settingsCtrl.add(
          lastSettings.copyWith(
            doubleTapLeft:
                DoubleTap.values.firstWhereOrNull((e) => e.mbbCode == leftCode),
            doubleTapRight: DoubleTap.values
                .firstWhereOrNull((e) => e.mbbCode == rightCode),
          ),
        );
        break;
      // # Settings(hold)
      case {1: [var holdCode, ...]} when cmd.isAbout(_Cmd.getGestureHold):
        _settingsCtrl.add(
          lastSettings.copyWith(
            holdBoth:
                Hold.values.firstWhereOrNull((e) => e.mbbCode == holdCode),
          ),
        );
        break;
      // # Settings(holdModes)
      case {1: [var modesCode, ...]}
          when cmd.isAbout(_Cmd.getGestureHoldToggledAncModes):
        _settingsCtrl.add(
          lastSettings.copyWith(
            holdBothToggledAncModes:
                _Cmd.gestureHoldToggledAncModesFromMbbValue(modesCode),
          ),
        );
        break;
    }
  }

  Future<void> _initRequestInfo() async {
    _mbb.sink.add(_Cmd.getBattery);
    _mbb.sink.add(_Cmd.getAnc);
    _mbb.sink.add(_Cmd.getAutoPause);
    _mbb.sink.add(_Cmd.getGestureDoubleTap);
    _mbb.sink.add(_Cmd.getGestureHold);
    _mbb.sink.add(_Cmd.getGestureHoldToggledAncModes);
  }

  @override
  ValueStream<int> get batteryLevel => _bluetoothDevice.battery;

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
  Future<void> setAncMode(AncMode mode) async => _mbb.sink.add(_Cmd.anc(mode));

  @override
  ValueStream<AncLevel> get ancLevel => throw UnimplementedError();

  @override
  Future<void> setAncLevel(AncLevel level) {
    throw UnimplementedError();
  }

  @override
  bool get supportsAncLevel => false;

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
      _mbb.sink.add(_Cmd.gestureDoubleTap(left: newSettings.doubleTapLeft!));
      _mbb.sink.add(_Cmd.getGestureDoubleTap);
    }
    if ((newSettings.doubleTapRight ?? prev.doubleTapRight) !=
        prev.doubleTapRight) {
      _mbb.sink.add(_Cmd.gestureDoubleTap(right: newSettings.doubleTapRight!));
      _mbb.sink.add(_Cmd.getGestureDoubleTap);
    }
    if ((newSettings.holdBoth ?? prev.holdBoth) != prev.holdBoth) {
      _mbb.sink.add(_Cmd.gestureHold(newSettings.holdBoth!));
      _mbb.sink.add(_Cmd.getGestureHold);
      _mbb.sink.add(_Cmd.getGestureHoldToggledAncModes);
    }
    if ((newSettings.holdBothToggledAncModes ?? prev.holdBothToggledAncModes) !=
        prev.holdBothToggledAncModes) {
      _mbb.sink.add(_Cmd.gestureHoldToggledAncModes(
          newSettings.holdBothToggledAncModes!));
      _mbb.sink.add(_Cmd.getGestureHold);
      _mbb.sink.add(_Cmd.getGestureHoldToggledAncModes);
    }
    if ((newSettings.autoPause ?? prev.autoPause) != prev.autoPause) {
      _mbb.sink.add(_Cmd.autoPause(newSettings.autoPause!));
      _mbb.sink.add(_Cmd.getAutoPause);
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

  static MbbCommand gestureDoubleTap({DoubleTap? left, DoubleTap? right}) =>
      MbbCommand(1, 31, {
        if (left != null) 1: [left.mbbCode],
        if (right != null) 2: [right.mbbCode],
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
      _ => null,
    };
  }

  static MbbCommand gestureHoldToggledAncModes(Set<AncMode> toggledModes) {
    int? mbbValue;
    const se = SetEquality();
    // can't really do that with pattern matching because it's a Set
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

  static MbbCommand autoPause(bool enabled) => MbbCommand(43, 16, {
        1: [enabled ? 1 : 0]
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
