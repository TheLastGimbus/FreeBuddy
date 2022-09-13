import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/settings/about'),
              child: const Text('About app'),
            )
          ],
        ),
      ),
    );
  }
}
