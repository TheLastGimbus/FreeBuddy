import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../headphones_mocks.dart';
import 'headphones_connection_cubit.dart';
import 'headphones_cubit_objects.dart';

class HeadphonesMockCubit extends Cubit<HeadphonesConnectionState>
    implements HeadphonesConnectionCubit {
  HeadphonesMockCubit()
      : super(HeadphonesConnectedOpen(HeadphonesMockPrettyFake()));

  @override
  Future<void> connect() async {}

  @override
  Future<bool> enableBluetooth() async => false;

  @override
  Future<void> openBluetoothSettings() async {}
}
