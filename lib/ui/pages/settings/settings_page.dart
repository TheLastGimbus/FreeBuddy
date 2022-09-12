import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Privacy policy (not really but is required):',
                style: t.textTheme.headlineSmall),
            const SizedBox(height: 8.0),
            const Text(
              '''This app does not collect any personal information about you. I do not store emails, identifiers, or anything like that, on any server, because I don’t even have one, and this app doesn't have internet access!

The app also doesn’t use Firebase Analytics, or any other service that would collect your data.

If you have any questions, you can contact me at: 4i05wllh@anonaddy.me

Thanks for reading, and enjoy using the app :)''',
            ),
            TextButton(
              onPressed: () => launchUrlString(
                  'https://the.lastgimbus.com/empty-privacy-policy/',
                  mode: LaunchMode.externalApplication),
              child: const Text('Click here to read the same "privacy policy"'),
            ),
            Container(
              height: 1.0,
              color: t.dividerColor,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/settings/licenses'),
              child: const Text('Open Source licenses'),
            ),
          ],
        ),
      ),
    );
  }
}
