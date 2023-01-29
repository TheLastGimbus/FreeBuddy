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

    smallSpace() => const SizedBox(height: 6.0);

    newline() => const TextSpan(text: "\n");

    Widget divider() => Column(
          children: [
            const SizedBox(height: 6.0),
            Container(
              height: 1.0,
              color: t.dividerColor,
              margin: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            const SizedBox(height: 6.0),
          ],
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.pageAboutTitle)),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Center(child: Text(l.pageAboutMeHeader, style: tt.headlineLarge)),
            smallSpace(),
            Text(l.pageAboutMeBio),
            smallSpace(),
            Text(l.pageAboutMeAnyQuestions),
            smallSpace(),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: "Discord 🎮: "),
                  _link("FreeBuddy server", "https://discord.gg/fYS98UE5Cu"),
                  newline(),
                  const TextSpan(text: "Email 📧: "),
                  _link("4i05wllh@anonaddy.me", "mailto:4i05wllh@anonaddy.me"),
                ],
                style: tt.bodyLarge,
              ),
            ),
            smallSpace(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: l.pageAboutMeOpenSource),
                  newline(),
                  _link("https://github.com/TheLastGimbus/FreeBuddy/"),
                  // TODO: Actually write a blog
                  // newline(),
                  // TextSpan(text: l.pageAboutMeBlog),
                  // _link("https://the.lastgimbus.com/blog/"),
                ],
              ),
            ),
            divider(),
            Text(l.pageAboutMentionsHeader, style: tt.headlineMedium),
            smallSpace(),
            Text(l.pageAboutMentionsPeopleHeader, style: tt.headlineSmall),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: " - ${l.pageAboutMentionsPeopleStreet}"),
                  newline(),
                  TextSpan(text: " - ${l.pageAboutMentionsPeopleHuawei}"),
                ],
              ),
            ),
            smallSpace(),
            Text(l.pageAboutMentionsTechHeader, style: tt.headlineSmall),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: " - Flutter 🐦"),
                  newline(),
                  const TextSpan(text: " - Wireshark 🦈"),
                ],
              ),
            ),
            divider(),
            Text(l.privacyPolicyTitle, style: t.textTheme.headlineSmall),
            smallSpace(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: l.privacyPolicyText),
                  newline(),
                  _link(l.privacyPolicyUrl),
                ],
              ),
            ),
            divider(),
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
