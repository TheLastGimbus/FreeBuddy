import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FreebuddyIntroduction extends StatelessWidget {
  const FreebuddyIntroduction({Key? key}) : super(key: key);

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
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;

    smallSpace() => const SizedBox(height: 6.0);

    newline() => const TextSpan(text: "\n");

    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Welcome to FreeBuddy 👋',
                  style: tt.displayMedium, textAlign: TextAlign.center),
              const Spacer(flex: 20),
              // Rich text with introduction and link to privacy policy
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text:
                          'FreeBuddy is open source app for your headphones 🎧'),
                  newline(),
                  newline(),
                  TextSpan(
                      text: 'Currently supported are:\n - Huawei Freebuds 4i'),
                  newline(),
                  newline(),
                  TextSpan(
                      text:
                          "This app doesn't collect any emails, identifiers, or any personal data 🎉 You can read more about it here: "),
                  _link("Privacy Policy", l.privacyPolicyUrl),
                  WidgetSpan(
                    child: Icon(
                      Icons.open_in_new,
                      size: tt.bodyMedium!.fontSize,
                      color: Colors.blue,
                    ),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  newline(),
                  newline(),
                  TextSpan(
                      text:
                          'If you have any questions, feel free to contact me 💌 Look at "Settings->About" for my socials!'),
                ], style: tt.bodyMedium),
              ),
              const Spacer(flex: 10),
              Row(
                children: [
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('Okay!')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
