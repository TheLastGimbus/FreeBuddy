import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/headphones_base.dart';
import 'anc_card.dart';
import 'battery_card.dart';
import 'headphones_image.dart';

/// Main whole-screen widget with controls for headphones
///
/// It contains battery, anc buttons, button to settings etc - just give it
/// the [headphones] and all done ☺
///
/// ...in fact, it is built so simple that you can freely hot-swap the
/// headphones object - for example, if they disconnect for a moment,
/// you can give it [HeadphonesMockNever] object, and previous values will stay
/// because it won't override them
class HeadphonesControlsWidget extends StatelessWidget {
  final HeadphonesBase headphones;

  const HeadphonesControlsWidget({Key? key, required this.headphones})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    return Column(
      children: [
        Text(
          // TODO: This hardcode
          headphones.alias ?? 'FreeBuds 4i',
          style: tt.headlineMedium,
        ),
        HeadphonesImage(headphones),
        Align(
          alignment: Alignment.centerRight,
          child: _HeadphonesSettingsButton(headphones),
        ),
        // const SizedBox(height: 6),
        BatteryCard(headphones),
        AncCard(headphones),
      ],
    );
  }
}

/// Simple button leading to headphones settings page
class _HeadphonesSettingsButton extends StatelessWidget {
  final HeadphonesBase headphones;

  const _HeadphonesSettingsButton(this.headphones, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: t.cardTheme.margin ?? const EdgeInsets.all(4.0),
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, '/headphones_settings'),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_outlined, size: 20),
              const SizedBox(width: 4),
              Text(l.settings),
            ],
          ),
        ),
      ),
    );
  }
}
