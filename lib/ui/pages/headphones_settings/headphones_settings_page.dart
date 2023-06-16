import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/headphones_connection_ensuring_overlay.dart';
import 'auto_pause_section.dart';
import 'double_tap_section.dart';
import 'hold_section.dart';

class HeadphonesSettingsPage extends StatelessWidget {
  const HeadphonesSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.pageHeadphonesSettingsTitle)),
      body: HeadphonesConnectionEnsuringOverlay(
        builder: (_, h) {
          return ListView(
            children: [
              AutoPauseSection(headphones: h),
              const Divider(indent: 16, endIndent: 16),
              DoubleTapSection(headphones: h),
              const Divider(indent: 16, endIndent: 16),
              HoldSection(headphones: h),
              const SizedBox(height: 64),
            ],
          );
        },
      ),
    );
  }
}
