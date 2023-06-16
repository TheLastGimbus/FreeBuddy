import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../../../../gen/fms.dart';
import '../../../../headphones/headphones_base.dart';
import '../../../../headphones/headphones_data_objects.dart';
import '../../../common/constrained_spacer.dart';

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
        _HeadphonesImageCard(headphones),
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

class _HeadphonesImageCard extends StatelessWidget {
  final HeadphonesBase headphones;

  const _HeadphonesImageCard(this.headphones, {Key? key}) : super(key: key);

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
          child: _BatteryIndicator(
            level: level,
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
        );
    return StreamBuilder(
      stream: headphones.batteryData,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  batteryBox('Left', data?.levelLeft, data?.chargingLeft),
                  const SizedBox(width: 8),
                  batteryBox('Right', data?.levelRight, data?.chargingRight),
                  const SizedBox(width: 8),
                  batteryBox('Case', data?.levelCase, data?.chargingCase),
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
///
/// Give it headphones an it will do the rest
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
                  icon: mode == HeadphonesAncMode.noiseCancel
                      ? Fms.noise_control_on_700
                      : Fms.noise_control_on,
                  isSelected: mode == HeadphonesAncMode.noiseCancel,
                  onPressed: () =>
                      headphones.setAncMode(HeadphonesAncMode.noiseCancel),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: mode == HeadphonesAncMode.off
                      ? Fms.noise_control_off_700
                      : Fms.noise_control_off,
                  isSelected: mode == HeadphonesAncMode.off,
                  onPressed: () => headphones.setAncMode(HeadphonesAncMode.off),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: mode == HeadphonesAncMode.awareness
                      ? Fms.noise_aware_700
                      : Fms.noise_aware,
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

class _HeadphonesSettingsButton extends StatelessWidget {
  final HeadphonesBase headphones;

  const _HeadphonesSettingsButton(this.headphones, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: t.cardTheme.margin ?? const EdgeInsets.all(4.0),
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, '/gesture_settings'),
        child: const Padding(
          padding: EdgeInsets.all(2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.settings_outlined, size: 20),
              SizedBox(width: 4),
              Text('Settings'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Android12-Google-Battery-Widget-style vertical progress bar
///
/// https://9to5google.com/2022/03/07/google-pixel-battery-widget/
/// https://9to5google.com/2022/09/29/pixel-battery-widget-time/
class _BatteryBar extends StatelessWidget {
  final double? value;

  const _BatteryBar({Key? key, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    // TODO: Maybe move this advanced color stuff somewhere else someday
    final color = Hct.fromInt(t.colorScheme.primary.value);
    final palette = TonalPalette.of(color.hue, color.chroma);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: RotatedBox(
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
    );
  }
}

class _BatteryIndicator extends StatelessWidget {
  final int? level;
  final Widget? child;

  const _BatteryIndicator({Key? key, this.level, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final value = level != null ? level! / 100 : null;
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        _BatteryBar(value: value),
        Center(child: child),
      ],
    );
  }
}

class _AncButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onPressed;

  const _AncButton({
    Key? key,
    required this.icon,
    required this.isSelected,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      // shit: google material symbols are not centered :/
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 6),
      child: Icon(icon, size: 42),
    );
    return isSelected
        ? FilledButton(onPressed: onPressed, child: child)
        : FilledButton.tonal(onPressed: onPressed, child: child);
  }
}
