import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'headphones_service/headphones_service_base.dart';
import 'headphones_service/headphones_service_bluetooth.dart';
import 'otter_constants.dart';

class HeadphonesConnectionCubit extends Cubit<HeadphonesObject> {
  final FlutterBluetoothSerial bluetooth;
  BluetoothConnection? _connection;

  StreamSubscription? _connectingStream;

  void _setupTryConnectingStream() {
    _connectingStream = loopStream((computationCount) async {
      final devs = await bluetooth.getBondedDevices();
      emit(
        devs.any((d) => Otter.btMacRegex.hasMatch(d.address))
            ? HeadphonesDisconnected()
            : HeadphonesNotPaired(),
      );
      try {
        final otter = devs.firstWhere((d) =>
            Otter.btMacRegex.hasMatch(d.address) &&
            d.isBonded &&
            d.isConnected);

        emit(HeadphonesConnecting());
        _connection = await BluetoothConnection.toAddress(otter.address);
        _connection!.input!.listen(
          (event) {
            print('dev input: $event');
          },
          onDone: () async {
            print('headphones done!');
            _connection!.dispose();
            _connection = null;
            emit(HeadphonesDisconnected());
            _connectingStream?.resume();
          },
        );
        emit(_connection == null
            ? HeadphonesDisconnected()
            : HeadphonesConnectedPlugin(_connection!));
        _connectingStream?.pause();
      } on StateError catch (_) {}
      if (_connection == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }).listen((_) {});
  }

  HeadphonesConnectionCubit({required this.bluetooth})
      : super(HeadphonesNotPaired()) {
    _setupTryConnectingStream();
  }
}

abstract class HeadphonesObject {}

class HeadphonesNotPaired extends HeadphonesObject {}

class HeadphonesDisconnected extends HeadphonesObject {}

class HeadphonesConnecting extends HeadphonesObject {}

abstract class HeadphonesConnected extends HeadphonesObject {
  Stream<HeadphonesBatteryData> get batteryData;

  Stream<HeadphonesAncMode> get ancMode;

  Future<void> setAncMode(HeadphonesAncMode mode);
}

/// Stream that keeps executing [computation] in a loop, while giving control
/// to pause and close it :rainbow:
///
/// It's key difference between, for example, [Stream.periodic] is that it
/// waits for (async) computation to complete before starting again
///
/// Will emit whatever is returned by [computation]
Stream loopStream<T>(Future<T> Function(int computationCount) computation) {
  var computationCount = 0;
  var run = false;
  final ctrl = StreamController();
  ctrl.onListen = () {
    run = true;
    loop() async {
      while (true) {
        if (!run) break;
        ctrl.add(await computation(computationCount++));
      }
    }

    ctrl.onPause = () => run = false;
    ctrl.onResume = () {
      if (!run) {
        run = true;
        loop();
      }
    };
    ctrl.onCancel = () {
      run = false;
      ctrl.close();
    };

    loop();
  };

  return ctrl.stream;
}
