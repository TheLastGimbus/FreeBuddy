import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.pageAboutTitle)),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(l.privacyPolicyTitle, style: t.textTheme.headlineSmall),
            const SizedBox(height: 8.0),
            Text(l.privacyPolicyText),
            TextButton(
              onPressed: () => launchUrlString(l.privacyPolicyUrl,
                  mode: LaunchMode.externalApplication),
              child: Text(l.privacyPolicyUrlBtn),
            ),
            Container(
              height: 1.0,
              color: t.dividerColor,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/settings/about/licenses'),
              child: Text(l.pageAboutOpenSourceLicensesBtn),
            ),
          ],
        ),
      ),
    );
  }
}
