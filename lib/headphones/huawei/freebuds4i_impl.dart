// ignore: implementation_imports
import 'package:rxdart/src/streams/value_stream.dart';

import 'freebuds4i.dart';

final class HuaweiFreeBuds4iImpl extends HuaweiFreeBuds4i {
  @override
  // TODO: implement batteryLevel
  ValueStream<int> get batteryLevel => throw UnimplementedError();

  @override
  // TODO: implement bluetoothAlias
  ValueStream<String> get bluetoothAlias => throw UnimplementedError();

  @override
  // TODO: implement bluetoothName
  String get bluetoothName => throw UnimplementedError();

  @override
  // TODO: implement macAddress
  String get macAddress => throw UnimplementedError();
}
