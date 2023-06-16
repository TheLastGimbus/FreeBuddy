import 'package:flutter/material.dart';

class ListTileCheckbox extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ListTileCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      trailing: IgnorePointer(
        child: Checkbox(
          value: value,
          onChanged: onChanged != null ? (_) {} : null,
        ),
      ),
    );
  }
}
