import 'dart:async';
import 'dart:typed_data';

import 'package:stream_channel/stream_channel.dart';

import '../../../logger.dart';
import '../../headphones_connection_cubit.dart';
import '../../headphones_service/headphones_service_base.dart';
import '../mbb.dart';

class HeadphonesImplOtter implements HeadphonesConnectedOpen {
  final StreamChannel<Uint8List> connection;

  final _ancStreamCtrl = StreamController<HeadphonesAncMode>.broadcast();
  final _batteryStreamCtrl =
      StreamController<HeadphonesBatteryData>.broadcast();

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
    });
    _initRequestInfo();
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
    }
  }

  Future<void> _initRequestInfo() async {
    await _sendMbb(MbbCommand.requestBattery);
    await _sendMbb(MbbCommand.requestAnc);
  }

  // TODO: some .flush() for those two

  Future<void> _sendMbb(MbbCommand comm) async {
    connection.sink.add(comm.toPayload());
  }

  Future<void> sendCustomMbbCommand(MbbCommand comm) async {
    connection.sink.add(comm.toPayload());
  }

  @override
  Stream<HeadphonesAncMode> get ancMode => _ancStreamCtrl.stream;

  @override
  Stream<HeadphonesBatteryData> get batteryData => _batteryStreamCtrl.stream;

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
}
