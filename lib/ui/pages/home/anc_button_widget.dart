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
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(
            isSelected ? Colors.blue : Colors.grey),
        shape: MaterialStateProperty.all<CircleBorder>(const CircleBorder()),
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 32),
    );
  }
}
