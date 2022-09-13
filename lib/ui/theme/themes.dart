import 'package:flutter/material.dart';

// Maybe make a check for platform version, but honestly this is nice
bool get useMaterial3 => true;

ThemeData get lightTheme => ThemeData.light(useMaterial3: useMaterial3);

ThemeData get darkTheme => ThemeData.dark(useMaterial3: useMaterial3);
