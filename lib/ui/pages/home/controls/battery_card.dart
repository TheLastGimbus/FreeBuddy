import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../../../../gen/fms.dart';
import '../../../../headphones/headphones_base.dart';

/// Android12-Google-Battery-Widget-style battery card
///
/// https://9to5google.com/2022/03/07/google-pixel-battery-widget/
/// https://9to5google.com/2022/09/29/pixel-battery-widget-time/
class BatteryCard extends StatelessWidget {
  final HeadphonesBase headphones;

  const BatteryCard(this.headphones, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    // Don't feel like exporting this anywhere 🤷
    batteryBox(String text, int? level, bool? charging) => Expanded(
          child: _BatteryContainer(
            value: level != null ? level / 100 : null,
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('$text • ${level ?? '-'}%', textAlign: TextAlign.center),
                  if (charging ?? false)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 1),
                      child: Icon(
                        Fms.charger_filled,
                        size: 20,
                        color: t.colorScheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
    return StreamBuilder(
      stream: headphones.batteryData,
      builder: (context, snapshot) {
        final b = snapshot.data;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: 86,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // TODO: Maybe make them boxes (but with some max size)
                  batteryBox(l.leftBudShort, b?.levelLeft, b?.chargingLeft),
                  const SizedBox(width: 8),
                  batteryBox(l.rightBudShort, b?.levelRight, b?.chargingRight),
                  const SizedBox(width: 8),
                  batteryBox(l.caseShort, b?.levelCase, b?.chargingCase),
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

  const _BatteryContainer({Key? key, this.value, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    // TODO: Maybe move this advanced color stuff somewhere else someday
    final color = Hct.fromInt(t.colorScheme.primary.value);
    final palette = TonalPalette.of(color.hue, color.chroma);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          RotatedBox(
            quarterTurns: -1,
            child: LinearProgressIndicator(
              value: value,
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
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
