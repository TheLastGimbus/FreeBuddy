import 'package:rxdart/rxdart.dart';

/// This class indicates that given headphones have some on-device settings
///
/// Since pretty much *every* model can have this completely different, I have
/// NO IDEA what to put here. Sure, they often have double tap - but it can be
/// double, triple, or hold, and can change music, or anc, or equalizer... 🤯🤯
///
/// Current idea: *all* settings of given model will exist as a single big
/// data class that will be streamed/set from here. Good? Good.
abstract class HeadphonesSettings<T> {
  /// Model specific. Not type, not vendor - each model can emit it's own class
  ///
  /// Yes I know. I'm sorry
  ValueStream<T> get settings;

  Future<void> setSettings(T newSettings);
}
