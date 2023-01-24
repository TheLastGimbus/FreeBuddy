import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../../logger.dart';
import '../headphones_connection_cubit.dart';
import '../mbb.dart';
import 'headphones_service_base.dart';

class HeadphonesConnectedOpenPlugin implements HeadphonesConnectedOpen {
  final BluetoothConnection connection;

  final _ancStreamCtrl = StreamController<HeadphonesAncMode>.broadcast();
  final _batteryStreamCtrl =
      StreamController<HeadphonesBatteryData>.broadcast();

  HeadphonesConnectedOpenPlugin(this.connection) {
    connection.io.stream.listen(
      (event) {
        List<MbbCommand>? comms;
        try {
          comms = MbbCommand.fromPayload(event);
        } catch (e, s) {
          logg.e("MBB parsing error", e, s);
        }
        if (comms == null) return;
        for (final comm in comms) {
          logg.v("Received mbb comm: $comm");

          if (comm.serviceId == 43 &&
              comm.commandId == 42 &&
              listEquals(comm.dataBytes.sublist(0, 2), [1, 2])) {
            late HeadphonesAncMode newMode;
            // TODO: Add some constants for this globally
            // because 0 1 and 2 seem to be constant bytes representing the modes
            switch (comm.dataBytes[3]) {
              case 1:
                newMode = HeadphonesAncMode.noiseCancel;
                break;
              case 0:
                newMode = HeadphonesAncMode.off;
                break;
              case 2:
                newMode = HeadphonesAncMode.awareness;
                break;
            }
            _ancStreamCtrl.add(newMode);
          }
          if (comm.serviceId == 1 &&
              (comm.commandId == 39 || comm.commandId == 8) &&
              comm.dataBytes.length == 13) {
            final b = comm.dataBytes.sublist(5, 8);
            _batteryStreamCtrl.add(HeadphonesBatteryData(
              b[0] == 0 ? null : b[0],
              b[1] == 0 ? null : b[1],
              b[2] == 0 ? null : b[2],
              comm.dataBytes[10] == 1,
              comm.dataBytes[11] == 1,
              comm.dataBytes[12] == 1,
            ));
          }
        }
      },
    );
    _initRequestInfo();
  }

  Future<void> _initRequestInfo() async {
    await _sendMbb(MbbCommand.requestBattery);
    await _sendMbb(MbbCommand.requestAnc);
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

  // TODO: some .flush() for those two

  Future<void> _sendMbb(MbbCommand comm) async {
    connection.io.sink.add(comm.toPayload());
  }

  Future<void> sendCustomMbbCommand(MbbCommand comm) async {
    connection.io.sink.add(comm.toPayload());
  }
}
