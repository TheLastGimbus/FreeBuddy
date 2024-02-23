import 'package:rxdart/rxdart.dart';

/// Stuff that we need to know about concrete headphones model
///
/// For example, FreeBuds 4i would implement it like:
///
/// ```dart
/// class HuaweiFreeBuds4i implements HeadphonesModelInfo {
///   @override
///   String get vendor => "Huawei";
///
///   @override
///   String get name => "FreeBuds 4i";
/// }
/// ```
abstract class HeadphonesModelInfo {
  /// Name of the vendor - simple and concrete
  ///
  /// - Huawei - not HUAWEI nor huawei
  /// - Xiaomi - not redmi or some other bs
  /// - Samsung
  /// - etc
  ///
  /// Don't worry, we will not be basing any name-matching on that or anything,
  /// this is somewhat for debugging purposes etc
  String get vendor;

  /// Name of headphones, without the vendor. As close to what they are named
  /// like on the market as possible (sometimes it's FREEBUDS, sometimes
  /// Freebuds - but most often FreeBuds - stick to that 👍)
  String get name;

  /// Because image may change dynamically (detecting which color user has
  /// based on some magic commands), this must be a stream.
  ///
  /// The format of this string should be absolute - you can pass it directly
  /// to Image.asset and will work 👍
  ///
  /// All implementers should emit this *as fast as possible*, preferably
  /// at class creation with initial base color image, and emit another correct
  /// one when detected
  ///
  /// Preferably, set it already in base headphones abstract class and override
  /// it in implementations if this ever actually changes
  ///
  /// Thus, consumers (the UI) should trust that it will come quickly and not
  /// put any placeholders themselves
  ///
  /// ...yes, I don't like it either -_-. I thought this class is gonna be very
  /// static and hard-coded, but I don't have better idea for it
  // NOTE/WARNING: I'm not sure if I should... be closing this, or not?
  // Probably yes, but... you know what, I'll wait until it causes some issues👍
  ValueStream<String> get imageAssetPath;
}
