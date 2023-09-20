import 'dart:io';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

import 'di.dart' as di;
import 'headphones/cubit/headphones_connection_cubit.dart';
import 'headphones/cubit/headphones_cubit_objects.dart';
import 'platform_stuff/android/appwidgets/battery_appwidget.dart';
import 'platform_stuff/android/background/periodic.dart' as android_periodic;
import 'ui/app_settings.dart';
import 'ui/pages/about/about_page.dart';
import 'ui/pages/headphones_settings/headphones_settings_page.dart';
import 'ui/pages/home/home_page.dart';
import 'ui/pages/introduction/introduction.dart';
import 'ui/pages/settings/settings_page.dart';
import 'ui/theme/themes.dart';

void main() {
  final bind = WidgetsFlutterBinding.ensureInitialized();
  // This is so that we try to connect to headphones under splash screen
  // This will make it more smooth to the user
  FlutterNativeSplash.preserve(widgetsBinding: bind);
  if (!kIsWeb && Platform.isAndroid) {
    // this is async, so it won't block runApp
    android_periodic.init();
  }
  runApp(const MyAppWrapper());
}

// Big ass ugly-as-fuck wrapper because:
// https://github.com/felangel/bloc/issues/2040#issuecomment-1726472426
class MyAppWrapper extends StatefulWidget {
  const MyAppWrapper({super.key});

  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper>
    with WidgetsBindingObserver {
  final _btBlock = di.getHeadphonesCubit();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // ...and this removes splash if we either connected or 1 second passed
    _btBlock.stream
        .firstWhere((e) => e is HeadphonesConnectedOpen)
        .timeout(
          const Duration(seconds: 1),
          onTimeout: () => HeadphonesNotPaired(), // just placeholder
        )
        .then((_) => FlutterNativeSplash.remove());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AppSettings>(
      create: (context) =>
          SharedPreferencesAppSettings(StreamingSharedPreferences.instance),
      child: MultiBlocProvider(
        providers: [BlocProvider.value(value: _btBlock)],
        // don't know if this is good place to put this, but seems right
        // maybe convert this to multi listener with advanced "listenWhen" logic
        // this would make it a nice single place to know what launches when 🤔
        child:
            BlocListener<HeadphonesConnectionCubit, HeadphonesConnectionState>(
          listener: batteryHomeWidgetHearBloc,
          // Should this be *here* or somewhere special? Idk, okay for now 🤷
          listenWhen: (p, c) => !kIsWeb && Platform.isAndroid,
          child: const MyApp(),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      await _btBlock.close();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() async {
    await _btBlock.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: lightTheme(lightDynamic),
        darkTheme: darkTheme(darkDynamic),
        themeMode: ThemeMode.system,
        routes: {
          '/': (context) => const HomePage(),
          '/headphones_settings': (context) => const HeadphonesSettingsPage(),
          '/introduction': (context) => const FreebuddyIntroduction(),
          '/settings': (context) => const SettingsPage(),
          '/settings/about': (context) => const AboutPage(),
          '/settings/about/licenses': (context) => const LicensePage(),
        },
        initialRoute: '/',
      ),
    );
  }
}
