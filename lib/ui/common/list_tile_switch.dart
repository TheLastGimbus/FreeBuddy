import 'package:flutter/material.dart';

class ListTileSwitch extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ListTileSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      trailing: IgnorePointer(
        child: Switch(
          value: value,
          onChanged: onChanged != null ? (_) {} : null,
        ),
      ),
    );
  }
}
