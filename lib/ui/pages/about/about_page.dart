import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  // I wanted to add "copy on long press" here, but recognizer can detect only
  // one :sob:
  TextSpan _link(String text, [String? url]) {
    return TextSpan(
      text: text,
      style: const TextStyle(color: Colors.blue),
      recognizer: TapGestureRecognizer()
        ..onTap = () =>
            launchUrlString(url ?? text, mode: LaunchMode.externalApplication),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    final tt = t.textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.pageAboutTitle)),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(child: Text(l.pageAboutMeHeader, style: tt.headlineLarge)),
            const SizedBox(height: 4.0),
            Text(l.pageAboutMeBio),
            const SizedBox(height: 4.0),
            Text(l.pageAboutMeAnyQuestions),
            const SizedBox(height: 4.0),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: "Email 📧: "),
                  _link("mateusz.soszynski.2003@gmail.com",
                      "mailto:mateusz.soszynski.2003@gmail.com"),
                  const TextSpan(text: "\n"),
                  const TextSpan(text: "Twitter 🐦: "),
                  _link("@TheLastGimbus", "https://twitter.com/TheLastGimbus"),
                  const TextSpan(text: "\n"),
                  const TextSpan(text: "Reddit: "),
                  _link("/u/TheLastGimbus",
                      "https://www.reddit.com/u/TheLastGimbus"),
                ],
                style: tt.bodyLarge,
              ),
            ),
            const SizedBox(height: 4.0),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: l.pageAboutMeOpenSource),
                  _link("https://github.com/TheLastGimbus/FreeBuddy/"),
                  const TextSpan(text: "\n"),
                  TextSpan(text: l.pageAboutMeBlog),
                  _link("https://the.lastgimbus.com/blog/"),
                ],
                style: tt.bodyMedium,
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              height: 1.0,
              color: t.dividerColor,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(l.privacyPolicyTitle, style: t.textTheme.headlineSmall),
            const SizedBox(height: 4.0),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: l.privacyPolicyText),
                  const TextSpan(text: "\n\n"),
                  _link(l.privacyPolicyUrl),
                ],
                style: tt.bodyMedium,
              ),
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
