import 'package:flutter/material.dart';

class PrettyRoundedContainerWidget extends StatelessWidget {
  final Widget child;

  const PrettyRoundedContainerWidget({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: t.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: t.colorScheme.shadow,
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }
}
