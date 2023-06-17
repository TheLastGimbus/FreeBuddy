import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../app_settings.dart';
import '../../common/headphones_connection_ensuring_overlay.dart';
import 'controls/headphones_controls_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Looks like we need this future to wait for first frame to generate
    Future.microtask(_introCheck);
  }

  void _introCheck() async {
    // TODO: Get settings async then open intro if needed
    final settings = context.read<AppSettings>();
    if (!(await settings.seenIntroduction.first)) {
      // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
      // ignore: use_build_context_synchronously
      if (!context.mounted) return;
      // true from this route means all success and we can set the flag
      // false means user exited otherwise or smth - anyway, don't set the flag
      final success =
          await Navigator.of(context).pushNamed('/introduction') as bool?;
      if (success ?? false) {
        await settings.setSeenIntroduction(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: HeadphonesConnectionEnsuringOverlay(
        builder: (_, h) => HeadphonesControlsWidget(headphones: h),
      ),
    );
  }
}
