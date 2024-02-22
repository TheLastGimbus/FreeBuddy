import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/headphones_connection_ensuring_overlay.dart';

class HeadphonesSettingsPage extends StatelessWidget {
  const HeadphonesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.pageHeadphonesSettingsTitle)),
      body: Center(
        child: HeadphonesConnectionEnsuringOverlay(
          builder: (_, h) {
            return ListView(
              children: [
                // TODO MIGRATION: hp settings not yet implemented
                const Text('HP Settings not yet implemented'),
                // AutoPauseSection(headphones: h),
                // const Divider(indent: 16, endIndent: 16),
                // DoubleTapSection(headphones: h),
                // const Divider(indent: 16, endIndent: 16),
                // HoldSection(headphones: h),
                // const SizedBox(height: 64),
              ],
            );
          },
        ),
      ),
    );
  }
}
