import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:the_last_bluetooth/the_last_bluetooth.dart';

import 'headphones/cubit/headphones_connection_cubit.dart';
import 'ui/app_settings.dart';
import 'ui/pages/about/about_page.dart';
import 'ui/pages/home/home_page.dart';
import 'ui/pages/introduction/introduction.dart';
import 'ui/pages/settings/settings_page.dart';
import 'ui/theme/themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    Provider<AppSettings>(
      create: (context) =>
          SharedPreferencesAppSettings(StreamingSharedPreferences.instance),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<HeadphonesConnectionCubit>(
              create: (_) => HeadphonesConnectionCubit(
                  bluetooth: TheLastBluetooth.instance)),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      routes: {
        '/': (context) => const HomePage(),
        '/introduction': (context) => const FreebuddyIntroduction(),
        '/settings': (context) => const SettingsPage(),
        '/settings/about': (context) => const AboutPage(),
        '/settings/about/licenses': (context) => const LicensePage(),
      },
      initialRoute: '/',
    );
  }
}
