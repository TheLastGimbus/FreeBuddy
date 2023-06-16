import 'package:flutter/material.dart';

class ListTileRadio<T> extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final ValueChanged<T>? onChanged;
  final T value;
  final T? groupValue;

  const ListTileRadio(
      {Key? key,
      this.title,
      this.subtitle,
      this.onChanged,
      required this.value,
      this.groupValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      subtitle: subtitle,
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
