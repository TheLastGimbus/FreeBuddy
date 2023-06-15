import 'package:flutter/material.dart';

// Maybe make a check for platform version, but honestly this is nice
bool get useMaterial3 => true;

/// This allows us to override both themes
ThemeData _customize(ThemeData theme) {
  final tt = theme.textTheme;
  return theme.copyWith(
    textTheme: tt.copyWith(
      // Display
      displaySmall: tt.displaySmall!.copyWith(
        fontSize: 24,
      ),
      displayMedium: tt.displayMedium!.copyWith(
        color: tt.bodyMedium!.color,
      ),
      // Body
      bodyMedium: tt.bodyMedium!.copyWith(
        fontSize: 15.0,
      ),
      bodyLarge: tt.bodyLarge!.copyWith(
        fontSize: 17.0,
      ),
      // Headlines
      headlineSmall: tt.headlineSmall!.copyWith(
        fontSize: 20.0,
      ),
      headlineMedium: tt.headlineMedium!.copyWith(
        color: tt.bodyMedium!.color,
        fontSize: 28.0,
      ),
      headlineLarge: tt.headlineLarge!.copyWith(
        color: tt.bodyMedium!.color,
        fontSize: 32.0,
      ),
    ),
  );
}

ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
  return _customize(ThemeData.light(useMaterial3: useMaterial3)).copyWith(
    colorScheme: dynamicColorScheme,
    // TODO: Do something about this shadow...
    // colorScheme: _light.colorScheme.copyWith(
    //   shadow: const Color(0x80808080),
    // ),
  );
}

ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
  return _customize(ThemeData.dark(useMaterial3: useMaterial3)).copyWith(
    colorScheme: dynamicColorScheme,
    // colorScheme: _dark.colorScheme.copyWith(
    //     // Leaving this so you see how you can customize colors individually
    //     ),
  );
}
