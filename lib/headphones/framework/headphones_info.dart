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
}
