import 'dart:typed_data';

import 'package:stream_channel/stream_channel.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import '../framework/bluetooth_headphones.dart';
import '../huawei/freebuds4i.dart';
import '../huawei/freebuds4i_impl.dart';
import '../huawei/freebuds4i_sim.dart';

typedef HeadphonesBuilder = BluetoothHeadphones Function(
    StreamChannel<Uint8List> io, BluetoothDevice device);

typedef MatchedModel = ({
  HeadphonesBuilder builder,
  BluetoothHeadphones placeholder
});

MatchedModel? matchModel(BluetoothDevice matchedDevice) {
  final name = matchedDevice.name.value;
  return switch (name) {
    _ when HuaweiFreeBuds4i.idNameRegex.hasMatch(name) => (
        builder: (io, dev) => HuaweiFreeBuds4iImpl(io, dev),
        placeholder: const HuaweiFreeBuds4iSimPlaceholder(),
      ),
    _ => null,
  };
}
