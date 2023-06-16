import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../../../../gen/fms.dart';
import '../../../../headphones/headphones_base.dart';
import '../../../../headphones/headphones_data_objects.dart';
import '../../../common/constrained_spacer.dart';

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
        _HeadphonesImage(headphones),
        Align(
          alignment: Alignment.centerRight,
          child: _HeadphonesSettingsButton(headphones),
        ),
        // const SizedBox(height: 6),
        _BatteryCard(headphones),
        _AncCard(headphones),
      ],
    );
  }
}

// ##### Key cards #####

/// Image of the headphones (non-card)
///
/// Selects the correct image for given model
///
/// ...well, in the future :D
class _HeadphonesImage extends StatelessWidget {
  final HeadphonesBase headphones;

  const _HeadphonesImage(this.headphones, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Switch image based on headphones
    return Expanded(child: Image.asset('assets/app_icons/ic_launcher.png'));
  }
}

/// Android12-Google-Battery-Widget-style battery card
///
/// https://9to5google.com/2022/03/07/google-pixel-battery-widget/
/// https://9to5google.com/2022/09/29/pixel-battery-widget-time/
class _BatteryCard extends StatelessWidget {
  final HeadphonesBase headphones;

  const _BatteryCard(this.headphones, {Key? key}) : super(key: key);

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
              height: 64,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
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

/// Card with anc controls
class _AncCard extends StatelessWidget {
  final HeadphonesBase headphones;

  const _AncCard(this.headphones, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HeadphonesAncMode>(
      stream: headphones.ancMode,
      builder: (context, snapshot) {
        final mode = snapshot.data;
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: Fms.noise_control_on,
                  iconSelected: Fms.noise_control_on_700,
                  isSelected: mode == HeadphonesAncMode.noiseCancel,
                  onPressed: () =>
                      headphones.setAncMode(HeadphonesAncMode.noiseCancel),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: Fms.noise_control_off,
                  iconSelected: Fms.noise_control_off_700,
                  isSelected: mode == HeadphonesAncMode.off,
                  onPressed: () => headphones.setAncMode(HeadphonesAncMode.off),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: Fms.noise_aware,
                  iconSelected: Fms.noise_aware_700,
                  isSelected: mode == HeadphonesAncMode.awareness,
                  onPressed: () =>
                      headphones.setAncMode(HeadphonesAncMode.awareness),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ##### Small items #####

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
        onPressed: () => Navigator.pushNamed(context, '/gesture_settings'),
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

/// Button for switching anc mode
///
/// TODO: Make this prettier (splash animation at least :/ )
class _AncButton extends StatelessWidget {
  final IconData icon;

  /// If non-null, this will be used when button is selected
  final IconData? iconSelected;
  final bool isSelected;
  final VoidCallback? onPressed;

  const _AncButton({
    Key? key,
    required this.icon,
    this.iconSelected,
    required this.isSelected,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      // shit: google material symbols are not centered :/
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 6),
      child: Icon(
        (isSelected && iconSelected != null) ? iconSelected : icon,
        size: 42,
      ),
    );
    return isSelected
        ? FilledButton(onPressed: onPressed, child: child)
        : FilledButton.tonal(onPressed: onPressed, child: child);
  }
}
