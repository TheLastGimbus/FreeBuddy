import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/framework/headphones_settings.dart';
import '../../../headphones/huawei/settings.dart';
import '../../common/headphones_connection_ensuring_overlay.dart';

import 'huawei/4i/exports.dart' as fb4i;
import 'huawei/5i/exports.dart' as fb5i;

class HeadphonesSettingsPage extends StatelessWidget {
  const HeadphonesSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.pageHeadphonesSettingsTitle)),
      body: Center(
        child: HeadphonesConnectionEnsuringOverlay(
          builder: (_, h) =>
              ListView(children: widgetsForModel(h as HeadphonesSettings, l)),
        ),
      ),
    );
  }
}

// this is shitty. and we don't want this. not here.
// ...
// but i have no better idea for now :)))))
List<Widget> widgetsForModel(HeadphonesSettings settings, AppLocalizations l) {
  if (settings is HeadphonesSettings<HuaweiFreeBuds4iSettings>) {
    return [
      fb4i.AutoPauseSection(settings),
      const Divider(indent: 16, endIndent: 16),
      fb4i.DoubleTapSection(settings),
      const Divider(indent: 16, endIndent: 16),
      fb4i.HoldSection(settings),
      const SizedBox(height: 64),
    ];
  } else if (settings is HeadphonesSettings<HuaweiFreeBuds5iSettings>) {
    return [
      fb5i.EqualizerSection(settings),
      const Divider(indent: 16, endIndent: 16),
      fb5i.AutoPauseSection(settings),
      const Divider(indent: 16, endIndent: 16),
      fb5i.LowLatencySection(settings),
      ExpansionTile(
        title: Text(l.pageHeadphonesSettingsGestures),
        children: [
          fb5i.DoubleTapSection(settings),
          const Divider(indent: 16, endIndent: 16),
          fb5i.TripleTapSection(settings),
          const Divider(indent: 16, endIndent: 16),
          fb5i.HoldSection(settings),
          const Divider(indent: 16, endIndent: 16),
          fb5i.SwipeSection(settings),
        ],
      ),
      const SizedBox(height: 64),
    ];
  } else {
    throw "You shouldn't be on this screen if you don't have settings!";
  }
}
