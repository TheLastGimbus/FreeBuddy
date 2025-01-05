import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:app_settings/app_settings.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../../logger.dart';
import 'headphones_cubit_objects.dart';
import 'model_matching.dart';

class HeadphonesConnectionCubit extends Cubit<HeadphonesConnectionState> {
  final TheLastBluetooth _bluetooth;
  StreamChannel<Uint8List>? _connection;
  StreamSubscription? _btEnabledStream;
  StreamSubscription? _devStream;
  final Map<BluetoothDevice, StreamSubscription> _watchedKnownDevices = {};
  static const connectTries = 3;
  static const killOtherCubitTimeout = Duration(seconds: 3);
  static const _killUrself = "kill urself";

  /// indicating all "killing other cubits" is done and we can call _init()
  bool _warCrimesFinished = false;

  // I needed a way to tell (from background task) if app is currently running.
  // First idea was to then ask the cubit for some info (about battery etc)
  // But, looking at how fucked up this Port communication is, I will just
  // register/deregister this port name, and if background detects it, it just
  // skips 🤷
  //
  // UDPATE: LOOKS LIKE I CAN'T JUST REGEISTER, BECAUSE BLOC SUCKS ASS
  // I WILL HAVE FULL BLOWN PING HERE NOW
  // I could just implement whole fucking http server altoghether -_-
  // ...
  // Actaully............
  // I would probably need something like this for Linux Desktop anyway...
  // This might not be such a bad idea........
  // ...
  // Stop.
  static const pingReceivePortName = 'pingHeadphonesCubitPort';
  final _pingReceivePort = ReceivePort('dummyHeadphonesCubitPort');
  late final StreamSubscription _pingReceivePortSS;

  /// returns true if no port, and false if timeout
  static Future<bool> _checkUntilNoPort(Duration timeout) async {
    // do this one time already bc stream will start only after first period
    noPort() =>
        IsolateNameServer.lookupPortByName(
            HeadphonesConnectionCubit.pingReceivePortName) ==
        null;
    if (noPort()) return true;
    return await Stream.periodic(
      Duration(milliseconds: 50),
      (_) => noPort(),
    ).firstWhere((e) => e).timeout(timeout, onTimeout: () => false);
  }

  // This is so fucking embarrassing......
  // Race conditions??? FUCK YES
  /// Reason this exists vs just checking port is to make sure cubit is
  /// **running**, and not just... exising hang up somewhere, or forgot
  /// to de-register the port
  static Future<bool> cubitAlreadyRunningSomewhere(
      {Duration responseTimeout = const Duration(seconds: 1)}) async {
    final ping = IsolateNameServer.lookupPortByName(
        HeadphonesConnectionCubit.pingReceivePortName);
    if (ping == null) return false;
    final pong = ReceivePort(); // this is not right naming, i know
    ping.send(pong.sendPort);
    return await pong.first.timeout(responseTimeout, onTimeout: () => false);
  }

  /// returns true if cubit was killed or didn't exist, and false if it didn't
  /// kill itself when asked
  //(that is, port is still present - it **may** happen that it just forgot
  // to close it, but we have no way to know)
  static Future<bool> killOtherCubit() async {
    final ping = IsolateNameServer.lookupPortByName(
        HeadphonesConnectionCubit.pingReceivePortName);
    if (ping == null) {
      loggI.e("No cubit to kill :( (this probably means you're using "
          "this function WRONG, or something WEIRD happened)");
      return true;
    }
    ping.send(_killUrself);
    // wait until second cubit will deregister
    if (await _checkUntilNoPort(killOtherCubitTimeout)) {
      return true;
    } else {
      loggI.e("Cubit didn't kill itself as nicely asked :(");
      return false;
    }
  }

  // todo: make this professional
  static const sppUuid = "00001101-0000-1000-8000-00805f9b34fb";

  Future<void> connect() async {
    if (_connection != null) return;
    final connected = _watchedKnownDevices.keys
        .firstWhereOrNull((dev) => dev.isConnected.valueOrNull ?? false);
    if (connected != null) {
      _connect(connected, matchModel(connected)!);
    }
  }

  Future<void> _connect(BluetoothDevice dev, MatchedModel model) async {
    final placeholder = model.placeholder;
    emit(HeadphonesConnecting(placeholder));
    try {
      // when Ai Life takes over our socket, the connecting always succeeds at
      // 2'nd try 🤔
      for (var i = 0; i < connectTries; i++) {
        try {
          _connection = _bluetooth.connectRfcomm(dev, sppUuid);
          break;
        } catch (_) {
          loggI.w('Error when connecting socket: ${i + 1}/$connectTries tries');
          if (i + 1 >= connectTries) rethrow;
        }
      }
      emit(
        HeadphonesConnectedOpen(model.builder(_connection!, dev)),
      );
      await _connection!.stream.listen((event) {}).asFuture();
      // when device disconnects, future completes and we free the
      // hopefully this happens *before* next stream event with data 🤷
      // so that it nicely goes again and we emit HeadphonesDisconnected()
    } catch (e, s) {
      loggI.e("Error while connecting to socket", error: e, stackTrace: s);
    }
    await _connection?.sink.close();
    _connection = null;
    // if disconnected because of bluetooth, don't emit
    // this is because we made async gap when awaiting stream close
    if (!(_bluetooth.isEnabled.valueOrNull ?? false)) return;
    emit(
      (dev.isConnected.valueOrNull ?? false)
          ? HeadphonesConnectedClosed(placeholder)
          : HeadphonesDisconnected(placeholder),
    );
  }

  Future<void> _pairedDevicesHandle(Iterable<BluetoothDevice> devices) async {
    if (!(_bluetooth.isEnabled.valueOrNull ?? false)) {
      emit(const HeadphonesBluetoothDisabled());
      return;
    }

    final knownHeadphones = devices
        .map((dev) => (device: dev, match: matchModel(dev)))
        .where((m) => m.match != null);

    if (knownHeadphones.isEmpty) {
      emit(const HeadphonesNotPaired());
      return;
    }

    // "Add all devices that are in knownHp but not in _watched
    for (final hp in knownHeadphones) {
      if (!_watchedKnownDevices.containsKey(hp.device)) {
        _watchedKnownDevices[hp.device] =
            hp.device.isConnected.listen((connected) {
          if (connected) {
            if (_connection != null) return; // already connected, skip
            _connect(hp.device, hp.match!);
          } else {
            _connection?.sink.close();
            _connection = null;
            emit(HeadphonesDisconnected(hp.match!.placeholder));
          }
        });
      }
    }
    // "Remove any device from _watched that's not in knownHp"
    for (final dev in _watchedKnownDevices.keys) {
      if (!knownHeadphones.map((e) => e.device).contains(dev)) {
        _watchedKnownDevices[dev]!.cancel();
        _watchedKnownDevices.remove(dev);
      }
    }
  }

  HeadphonesConnectionCubit({required TheLastBluetooth bluetooth})
      : _bluetooth = bluetooth,
        super(const HeadphonesNotPaired()) {
    final rolex = Stopwatch()..start();
    _initInit().then(
      (_) => loggI.d("_initInit() took ${rolex.elapsedMilliseconds}ms"),
    );
  }

  /// THIS should be called ONLY ONCE
  // maybetodo: i'm wondering if to make this public, and not internally called
  // in constructor, but this would complicate di...
  Future<void> _initInit() async {
    // TODO: Some *tests* for this nightmare...
    if (await cubitAlreadyRunningSomewhere()) {
      loggI.w("Found already running cubit while init() - "
          "will wait $killOtherCubitTimeout and then kill it");
      if (await _checkUntilNoPort(killOtherCubitTimeout)) {
        loggI.i("Gone already, no need for war crimes 😇");
      } else {
        loggI.i("Killing other cubit...");
        // ### Important thoughts ###
        //
        // I think it's a good way to stop background tasks, because when cubit
        // closes, it closes all it's streams, thus all tasks waiting for
        // battery values or other shits will throw error/timeout that will be
        // try-catch'ed and nicely finish 👌
        //
        // But, leaving those notes here, in case, some day, they don't.
        if (!await killOtherCubit()) {
          loggI.f("Failed to kill other cubit 😵... well, anyway...");
        }
      }
    }

    // And *NOW* we can talk...
    // TODO: I mean, actually, it still sometimes hangs... but I think that's
    // a deep un-fixable-for-now fault of jni :///
    IsolateNameServer.removePortNameMapping(pingReceivePortName);
    IsolateNameServer.registerPortWithName(
        _pingReceivePort.sendPort, pingReceivePortName);
    _pingReceivePortSS = _pingReceivePort.listen((message) {
      // ping back
      if (message is SendPort) message.send(true);
      // kill urself
      if (message == _killUrself) {
        loggI.w("Killing myself bc other cubit asked to 😖");
        close();
      }
    });
    _warCrimesFinished = true;

    return _init();
  }

  Future<void> _init() async {
    if (_btEnabledStream != null) {
      loggI.w("_init() was already done and finished, but got called"
          "again. Weird.");
      return;
    }
    loggI.d("Starting init...");
    // last check in case it's a call from requestPermission()
    // this would prob mean user went through all permission asking stuff, and
    // _initInit() is stilllll running... 😵‍💫
    if (!_warCrimesFinished) {
      loggI.w("_init() called but _initInit() not finished 😵‍💫 - "
          "this isn't good, but we may survive this...");
      return;
    }
    // it's down here to be sure that we do have device connected so
    if (!await Permission.bluetoothConnect.isGranted) {
      emit(const HeadphonesNoPermission());
      return;
    }
    _bluetooth.init();
    _btEnabledStream = _bluetooth.isEnabled.listen((enabled) {
      if (!enabled) emit(const HeadphonesBluetoothDisabled());
    });
    // logic of connect() is so universal we can use it on every change
    _devStream = _bluetooth.pairedDevices.listen(_pairedDevicesHandle);
  }

  // TODO:
  Future<bool> enableBluetooth() async => false;

  Future<void> openBluetoothSettings() => AppSettings.openAppSettings(
      type: AppSettingsType.bluetooth, asAnotherTask: true);

  Future<void> requestPermission() async {
    await Permission.bluetoothConnect.request();
    await _init();
  }

  @override
  Future<void> close() async {
    await _connection?.sink.close();
    await _btEnabledStream?.cancel();
    await _devStream?.cancel();
    for (final sub in _watchedKnownDevices.values) {
      await sub.cancel();
    }
    await _pingReceivePortSS.cancel();
    _pingReceivePort.close();
    IsolateNameServer.removePortNameMapping(pingReceivePortName);
    super.close();
  }
}
