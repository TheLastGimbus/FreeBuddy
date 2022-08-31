import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../headphones_connection_cubit.dart';
import '../mbb.dart';
import 'headphones_service_base.dart';

class HeadphonesConnectedPlugin implements HeadphonesConnected {
  final BluetoothConnection connection;

  final _ancStreamCtrl = StreamController<HeadphonesAncMode>.broadcast();

  HeadphonesConnectedPlugin(this.connection,
      {required Future<dynamic> Function() onDone}) {
    connection.input!.listen(
      (event) {
        final comm = MbbCommand.fromPayload(event);
        print(comm);

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
      },
      onDone: () async => await onDone(),
      onError: (e) async => await onDone(),
    );
  }

  @override
  Stream<HeadphonesAncMode> get ancMode => _ancStreamCtrl.stream;

  @override
  Stream<HeadphonesBatteryData> get batteryData => throw UnimplementedError();

  @override
  Future<void> setAncMode(HeadphonesAncMode mode) async {
    late Uint8List payload;
    switch (mode) {
      case HeadphonesAncMode.noiseCancel:
        payload = MbbCommand.ancNoiseCancel.toPayload();
        break;
      case HeadphonesAncMode.off:
        payload = MbbCommand.ancOff.toPayload();
        break;
      case HeadphonesAncMode.awareness:
        payload = MbbCommand.ancAware.toPayload();
        break;
    }
    connection.output.add(payload);
    await connection.output.allSent;
  }
}
