import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../logger.dart';
import 'headphones_service/headphones_service_base.dart';
import 'headphones_service/headphones_service_bluetooth.dart';
import 'otter_constants.dart';

class HeadphonesConnectionCubit extends Cubit<HeadphonesObject> {
  final FlutterBluetoothSerial bluetooth;
  BluetoothConnection? _connection;

  StreamSubscription? _connectingStream;

  void _setupTryConnectingStream() {
    _connectingStream = loopStream((computationCount) async {
      // TODO: Pause and resume stream based on that
      if (!((await bluetooth.isEnabled) ?? false)) {
        emit(HeadphonesBluetoothDisabled());
        return;
      }
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
        emit(HeadphonesConnectedPlugin(
          _connection!,
          onDone: () async {
            logg.d('headphones done!');
            await _connection!.finish();
            _connection!.dispose();
            _connection = null;
            emit(HeadphonesDisconnected());
            await Future.delayed(const Duration(seconds: 1));
            _connectingStream?.resume();
          },
        ));
        _connectingStream?.pause();
      } on StateError catch (_) {
      } on PlatformException catch (e, s) {
        await _connection?.finish();
        _connection?.dispose();
        _connection = null;
        logg.e('Platform error in connection loop', e, s);
        emit(HeadphonesDisconnected());
      }
      if (_connection == null) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }).listen((_) {});
  }

  HeadphonesConnectionCubit({required this.bluetooth})
      : super(HeadphonesNotPaired()) {
    _setupTryConnectingStream();
  }

  Future<bool> enableBluetooth() async =>
      (await bluetooth.requestEnable()) ?? false;

  Future<void> openBluetoothSettings() =>
      AppSettings.openBluetoothSettings(asAnotherTask: true);
}

abstract class HeadphonesObject {}

class HeadphonesBluetoothDisabled extends HeadphonesObject {}

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
  late StreamController ctrl;
  loop() async {
    while (true) {
      if (!run) break;
      try {
        ctrl.add(await computation(computationCount++));
      } catch (e, s) {
        ctrl.addError(e, s);
      }
    }
  }

  ctrl = StreamController(
    onListen: () {
      run = true;
      loop();
    },
    onPause: () => run = false,
    onResume: () {
      if (!run) {
        run = true;
        loop();
      }
    },
    onCancel: () {
      run = false;
      ctrl.close();
    },
  );

  return ctrl.stream;
}
