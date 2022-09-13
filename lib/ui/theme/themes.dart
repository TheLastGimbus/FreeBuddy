import 'package:flutter/material.dart';

// Maybe make a check for platform version, but honestly this is nice
bool get useMaterial3 => true;

ThemeData get _light => ThemeData.light(useMaterial3: useMaterial3);

ThemeData get _dark => ThemeData.dark(useMaterial3: useMaterial3);

// TODO: Some way to merge overriding this two both
ThemeData get lightTheme {
  return _light.copyWith(
    textTheme: _light.textTheme.copyWith(
      bodyMedium: _light.textTheme.bodyMedium!.copyWith(
        fontSize: 15.0,
      ),
      bodyLarge: _light.textTheme.bodyLarge!.copyWith(
        fontSize: 17.0,
      ),
      headlineLarge: _light.textTheme.headlineLarge!.copyWith(
        color: _light.textTheme.bodyMedium!.color,
      ),
    ),
  );
}

ThemeData get darkTheme {
  return _dark.copyWith(
    textTheme: _dark.textTheme.copyWith(
      bodyMedium: _dark.textTheme.bodyMedium!.copyWith(
        fontSize: 15.0,
      ),
      bodyLarge: _dark.textTheme.bodyLarge!.copyWith(
        fontSize: 17.0,
      ),
      headlineLarge: _dark.textTheme.headlineLarge!.copyWith(
        color: _dark.textTheme.bodyMedium!.color,
      ),
    ),
  );
}
