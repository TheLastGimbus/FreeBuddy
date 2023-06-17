import 'package:flutter/cupertino.dart';

/// Helper enum to quickly determine current size
///
/// You're probably wondering what are "window size classes" - it's a
/// opinionated and very convenient way to put all different screen sizes into
/// three categories, determined by screen width:
/// - compact - typical vertical phone
/// - medium - small tablet/foldable or horizontal phone
/// - expanded - big tablet/computer
///
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowSizeClass {
  compact,
  medium,
  expanded;

  static WindowSizeClass of(BuildContext context) =>
      switch (MediaQuery.of(context).size.width) {
        < 600 => WindowSizeClass.compact,
        >= 600 && < 840 => WindowSizeClass.medium,
        >= 840 => WindowSizeClass.expanded,
        // 🤷
        _ => WindowSizeClass.compact,
      };
  // TODO: @override compareTo
}
