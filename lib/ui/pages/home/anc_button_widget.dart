import 'package:flutter/material.dart';

class AncButtonWidget extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onPressed;

  const AncButtonWidget({
    Key? key,
    required this.icon,
    required this.isSelected,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const p = 8.0;
    final child = Padding(
      // shit: google material symbols are not centered :/
      padding: const EdgeInsets.fromLTRB(p, p - 4, p, p),
      child: Icon(
        icon,
        size: 40,
      ),
    );
    return isSelected
        ? FilledButton(onPressed: onPressed, child: child)
        : ElevatedButton(onPressed: onPressed, child: child);
  }
}
