import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:stream_channel/stream_channel.dart';

import '../../../logger.dart';
import '../../headphones_base.dart';
import '../../headphones_data_objects.dart';
import '../mbb.dart';

class HeadphonesImplOtter extends HeadphonesBase {
  final StreamChannel<Uint8List> connection;

  final _batteryStreamCtrl = BehaviorSubject<HeadphonesBatteryData>();
  final _ancStreamCtrl = BehaviorSubject<HeadphonesAncMode>();
  final _autoPauseStreamCtrl = BehaviorSubject<bool>();

  /// This watches if we are still missing any info and re-requests it
  late StreamSubscription _watchdogStreamSub;

  HeadphonesImplOtter(this.connection) {
    connection.stream.listen((event) {
      List<MbbCommand>? commands;
      try {
        commands = MbbCommand.fromPayload(event);
      } catch (e, s) {
        logg.e("mbb parsing error", e, s);
      }
      for (final cmd in commands ?? []) {
        logg.v("Received mbb cmd: $cmd");
        try {
          _evalMbbCommand(cmd);
        } on RangeError catch (e, s) {
          logg.e(
              'Error while parsing mbb cmd - (probably missing bytes)', e, s);
        }
      }
    }, onDone: () async {
      _batteryStreamCtrl.close();
      _ancStreamCtrl.close();
      _autoPauseStreamCtrl.close();
      _watchdogStreamSub.cancel();
    });
    _initRequestInfo();
    _watchdogStreamSub =
        Stream.periodic(const Duration(seconds: 3)).listen((_) {
      if ([batteryData.valueOrNull, ancMode.valueOrNull, autoPause.valueOrNull]
          .any((e) => e == null)) {
        _initRequestInfo();
      }
    });
  }

  void _evalMbbCommand(MbbCommand cmd) {
    if (cmd.serviceId == 43 && cmd.commandId == 42 && cmd.args.containsKey(1)) {
      late HeadphonesAncMode newMode;
      // TODO: Add some constants for this globally
      // because 0 1 and 2 seem to be constant bytes representing the modes
      final modeByte = cmd.args[1]![1];
      if (modeByte == 1) {
        newMode = HeadphonesAncMode.noiseCancel;
      } else if (modeByte == 0) {
        newMode = HeadphonesAncMode.off;
      } else if (modeByte == 2) {
        newMode = HeadphonesAncMode.awareness;
      } else {
        logg.e("Unknown ANC mode: ${cmd.args[1]}");
        return;
      }
      _ancStreamCtrl.add(newMode);
    } else if (cmd.serviceId == 1 &&
        (cmd.commandId == 39 || cmd.commandId == 8) &&
        cmd.args.length >= 3) {
      final level = cmd.args[2];
      final status = cmd.args[3];
      if (level == null || status == null) {
        logg.e("Battery data is missing level or status");
        return;
      }
      _batteryStreamCtrl.add(HeadphonesBatteryData(
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
      _autoPauseStreamCtrl.add(cmd.args[1]![0] == 1);
    }
  }

  Future<void> _initRequestInfo() async {
    await _sendMbb(MbbCommand.requestBattery);
    await _sendMbb(MbbCommand.requestAnc);
    await _sendMbb(MbbCommand.requestAutoPause);
  }

  // TODO: some .flush() for this
  Future<void> _sendMbb(MbbCommand comm) async {
    connection.sink.add(comm.toPayload());
  }

  @override
  ValueStream<HeadphonesBatteryData> get batteryData =>
      _batteryStreamCtrl.stream;

  @override
  ValueStream<HeadphonesAncMode> get ancMode => _ancStreamCtrl.stream;

  @override
  Future<void> setAncMode(HeadphonesAncMode mode) async {
    late MbbCommand comm;
    switch (mode) {
      case HeadphonesAncMode.noiseCancel:
        comm = MbbCommand.ancNoiseCancel;
        break;
      case HeadphonesAncMode.off:
        comm = MbbCommand.ancOff;
        break;
      case HeadphonesAncMode.awareness:
        comm = MbbCommand.ancAware;
        break;
    }
    await _sendMbb(comm);
  }

  @override
  ValueStream<bool> get autoPause => _autoPauseStreamCtrl.stream;

  @override
  Future<void> setAutoPause(bool enabled) async {
    await _sendMbb(enabled ? MbbCommand.autoPauseOn : MbbCommand.autoPauseOff);
    await _sendMbb(MbbCommand.requestAutoPause);
  }
}