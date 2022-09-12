import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'headphones/headphones_connection_cubit.dart';
import 'ui/pages/home/home_page.dart';
import 'ui/pages/settings/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/': (context) => MultiBlocProvider(
              providers: [
                BlocProvider<HeadphonesConnectionCubit>(
                    create: (_) => HeadphonesConnectionCubit(
                        bluetooth: FlutterBluetoothSerial.instance)),
              ],
              child: const HomePage(),
            ),
        '/settings': (context) => const SettingsPage(),
        '/settings/licenses': (context) => const LicensePage(),
      },
      initialRoute: '/',
    );
  }
}
