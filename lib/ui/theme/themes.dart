import 'package:flutter/material.dart';

// Maybe make a check for platform version, but honestly this is nice
bool get useMaterial3 => true;

ThemeData get _light => ThemeData.light(useMaterial3: useMaterial3);

ThemeData get _dark => ThemeData.dark(useMaterial3: useMaterial3);

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

ThemeData get lightTheme {
  return _customize(_light).copyWith(
    colorScheme: _light.colorScheme.copyWith(
        // Leaving this so you see how you can customize colors individually
        // primary: const Color(0xFF1E88E5),
        // secondary: const Color(0xFF1E88E5),
        ),
  );
}

ThemeData get darkTheme {
  return _customize(_dark).copyWith(
    colorScheme: _dark.colorScheme.copyWith(
        // Leaving this so you see how you can customize colors individually
        // primary: const Color(0xFF1E88E5),
        // secondary: const Color(0xFF1E88E5),
        ),
  );
}
