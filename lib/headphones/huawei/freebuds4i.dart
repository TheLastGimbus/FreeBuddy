import 'package:rxdart/rxdart.dart';

import '../framework/anc.dart';
import '../framework/bluetooth_headphones.dart';
import '../framework/headphones_info.dart';
import '../framework/lrc_battery.dart';

/// Base abstract class of 4i's. It contains static info like vendor names etc,
/// but no logic whatsoever.
///
/// It makes both a solid ground for actual implementation (by defining what
/// features they implement), and some basic info for easy simulation
abstract base class HuaweiFreeBuds4i
    implements BluetoothHeadphones, HeadphonesModelInfo, LRCBattery, Anc {
  @override
  String get vendor => "Huawei";

  @override
  String get name => "FreeBuds 4i";

  // NOTE/WARNING: Again as in HeadphonesModelInfo - i'm not sure if it's safe
  // to just leave it like that, but I will 🥰🥰
  @override
  ValueStream<String> get imageAssetPath =>
      BehaviorSubject.seeded('assets/app_icons/ic_launcher.png');
}
