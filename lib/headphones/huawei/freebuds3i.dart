import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
import '../framework/bluetooth_headphones.dart';
import '../framework/headphones_info.dart';
import '../framework/headphones_settings.dart';
import '../framework/lrc_battery.dart';
import 'settings.dart';

abstract base class HuaweiFreeBuds3i
    implements
        BluetoothHeadphones,
        HeadphonesModelInfo,
        LRCBattery,
        Anc,
        HeadphonesSettings<HuaweiFreeBuds3iSettings> {
  const HuaweiFreeBuds3i();

  @override
  String get vendor => "Huawei";

  @override
  String get name => "FreeBuds 3i";

// TODO: Make their own icon
  @override
  ValueStream<String> get imageAssetPath =>
      BehaviorSubject.seeded('assets/headphones/huawei/freebuds3i.png');

  // As I said everywhere else - i have no good idea where to put this stuff :/
  // This will be a bit of chaos for now 👍👍
  static final idNameRegex =
      RegExp(r'^(?=(HUAWEI FreeBuds 3i))', caseSensitive: true);
}
