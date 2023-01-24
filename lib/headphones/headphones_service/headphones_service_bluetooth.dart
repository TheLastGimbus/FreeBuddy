import 'dart:async';

import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../../logger.dart';
import '../headphones_connection_cubit.dart';
import '../huawei/mbb.dart';
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
              comm.args.containsKey(1)) {
            late HeadphonesAncMode newMode;
            // TODO: Add some constants for this globally
            // because 0 1 and 2 seem to be constant bytes representing the modes
            switch (comm.args[1]?[1] ?? -1) {
              case 1:
                newMode = HeadphonesAncMode.noiseCancel;
                break;
              case 0:
                newMode = HeadphonesAncMode.off;
                break;
              case 2:
                newMode = HeadphonesAncMode.awareness;
                break;
              default:
                logg.e("Unknown ANC mode: ${comm.args[1]}");
                continue;
            }
            _ancStreamCtrl.add(newMode);
          }
          if (comm.serviceId == 1 &&
              (comm.commandId == 39 || comm.commandId == 8) &&
              comm.args.length == 3) {
            final level = comm.args[2];
            final status = comm.args[3];
            if (level == null || status == null) {
              logg.e("Battery data is missing level or status");
              continue;
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
