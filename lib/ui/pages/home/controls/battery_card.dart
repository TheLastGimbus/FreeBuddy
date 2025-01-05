import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../gen/freebuddy_icons.dart';
import '../../../../headphones/framework/lrc_battery.dart';

/// Android12-Google-Battery-Widget-style battery card
///
/// https://9to5google.com/2022/03/07/google-pixel-battery-widget/
/// https://9to5google.com/2022/09/29/pixel-battery-widget-time/
class BatteryCard extends StatelessWidget {
  final LRCBattery lrcBattery;

  const BatteryCard(this.lrcBattery, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;

    // Don't feel like exporting this anywhere 🤷
    batteryBox(IconData icon, String text, int? level, bool? charging) =>
        Expanded(
          child: _BatteryContainer(
            value: level != null ? level / 100 : null,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // runAlignment: WrapAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: t.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(text, style: tt.bodyMedium),
                  const Spacer(),
                  Text('${level ?? '-'}%', style: tt.bodyMedium),
                  const SizedBox(width: 8),
                  if (charging ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                      child: Icon(
                        Symbols.charger,
                        fill: 1,
                        size: 24,
                        color: t.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
    return StreamBuilder(
      stream: lrcBattery.lrcBattery,
      builder: (context, snapshot) {
        final b = snapshot.data;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: 152,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  batteryBox(
                    FreebuddyIcons.leftEarbud,
                    l.leftBudShort,
                    b?.levelLeft,
                    b?.chargingLeft,
                  ),
                  const SizedBox(height: 2),
                  batteryBox(
                    FreebuddyIcons.rightEarbud,
                    l.rightBudShort,
                    b?.levelRight,
                    b?.chargingRight,
                  ),
                  const SizedBox(height: 2),
                  batteryBox(
                    FreebuddyIcons.earbudsCase,
                    l.caseShort,
                    b?.levelCase,
                    b?.chargingCase,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Android12-Google-Battery-Widget-style vertical progress bar/container (?)
///
/// (without anything inside - feel free to use it for something else)
///
/// https://9to5google.com/2022/03/07/google-pixel-battery-widget/
/// https://9to5google.com/2022/09/29/pixel-battery-widget-time/
class _BatteryContainer extends StatelessWidget {
  final double? value;
  final Widget? child;

  const _BatteryContainer({this.value, this.child});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    // TODO: Maybe move this advanced color stuff somewhere else someday
    // yep... well but like... what else i'm supposed to??
    // ignore: deprecated_member_use
    final color = Hct.fromInt(t.colorScheme.primary.value);
    final palette = TonalPalette.of(color.hue, color.chroma);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          LinearProgressIndicator(
            value: value ?? 0,
            color: Color(
              palette.get(
                t.colorScheme.brightness == Brightness.dark ? 25 : 80,
              ),
            ),
            backgroundColor: Color(
              palette.get(
                t.colorScheme.brightness == Brightness.dark ? 10 : 90,
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
