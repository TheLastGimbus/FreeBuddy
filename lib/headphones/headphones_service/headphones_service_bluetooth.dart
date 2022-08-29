import 'dart:async';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../otter_constants.dart';
import 'headphones_service_base.dart';

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

class HeadphonesServiceBluetooth implements HeadphonesServiceBase {
  final bluetooth = FlutterBluetoothSerial.instance;
  BluetoothConnection? _connection;

  StreamSubscription? _connectingStream;
  final List<StreamSubscription> _streamSubs = [];

  final _connectionStateCtrl =
      StreamController<HeadphonesConnectionState>.broadcast();

  void _setupTryConnectingStream() {
    _connectingStream = loopStream((computationCount) async {
      final devs = await bluetooth.getBondedDevices();
      if (devs.any((d) => Otter.btMacRegex.hasMatch(d.address))) {
        _connectionStateCtrl.sink.add(HeadphonesConnectionState.disconnected);
      } else {
        _connectionStateCtrl.sink.add(HeadphonesConnectionState.notPaired);
      }
      try {
        final otter = devs.firstWhere((d) =>
            Otter.btMacRegex.hasMatch(d.address) &&
            d.isBonded &&
            d.isConnected);

        _connectionStateCtrl.sink.add(HeadphonesConnectionState.connecting);
        _connection = await BluetoothConnection.toAddress(otter.address);
        _connection!.input!.listen(
          (event) {
            print('dev input: $event');
          },
          onDone: () async {
            print('done!');
            _connection!.dispose();
            _connection = null;
            _connectionStateCtrl.sink
                .add(HeadphonesConnectionState.disconnected);
            _connectingStream?.resume();
          },
        );
        _connectionStateCtrl.sink.add(_connection == null
            ? HeadphonesConnectionState.disconnected
            : HeadphonesConnectionState.connected);
        _connectingStream?.pause();
      } on StateError catch (_) {}
      if (_connection == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }).listen((_) {});
  }

  @override
  Future<void> init() async {
    _streamSubs.add(bluetooth.onStateChanged().listen((event) {
      print('onStateChanged: $event');
    }));
    _setupTryConnectingStream();
  }

  @override
  Stream<HeadphonesAncMode> get ancMode => throw UnimplementedError();

  @override
  Stream<HeadphonesBatteryData> get batteryData => throw UnimplementedError();

  @override
  Stream<HeadphonesConnectionState> get connectionState =>
      _connectionStateCtrl.stream.distinct();

  @override
  Future<void> setAncMode(HeadphonesAncMode mode) {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {
    await _connectingStream?.cancel();
    _connection?.dispose();
    for (final sub in _streamSubs) {
      await sub.cancel();
    }
    _streamSubs.removeRange(0, _streamSubs.length);
  }
}
