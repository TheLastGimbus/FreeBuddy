import 'package:flutter/material.dart';

class ListTileRadio<T> extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final ValueChanged<T>? onChanged;
  final T value;
  final T? groupValue;
  final bool? dense;

  const ListTileRadio({
    super.key,
    this.title,
    this.subtitle,
    this.onChanged,
    required this.value,
    this.groupValue,
    this.dense,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
      dense: dense,
      onTap: onChanged != null
          ? () {
              onChanged!(value);
            }
          : null,
      trailing: IgnorePointer(
        child: Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged != null ? (_) {} : null,
        ),
      ),
    );
  }
}
