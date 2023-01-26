import 'package:flutter/material.dart';

/// Wrap this in a widget that you want to disable
/// It will make it half-opaque and stop pointer events 👍
///
/// You can also add [coveringWidget] that will be placed at the center above
/// the [child] so that you can show user why it's disabled
class Disabled extends StatelessWidget {
  final Widget child;

  /// Aww, fuck it
  final bool disabled;
  final Widget? coveringWidget;

  const Disabled(
      {super.key,
      required this.child,
      this.disabled = false,
      this.coveringWidget});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return disabled
        ? AbsorbPointer(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(opacity: 0.45, child: child),
                if (coveringWidget != null)
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: t.colorScheme.background,
                          spreadRadius: 14,
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: coveringWidget!,
                  ),
              ],
            ),
          )
        : child;
  }
}
