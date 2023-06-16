import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/headphones_base.dart';
import '../../../headphones/headphones_data_objects.dart';
import '../disabled.dart';

class HoldSection extends StatelessWidget {
  final HeadphonesBase headphones;

  const HoldSection({Key? key, required this.headphones}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder<HeadphonesGestureSettings>(
      stream: headphones.gestureSettings,
      initialData: headphones.gestureSettings.valueOrNull ??
          const HeadphonesGestureSettings(),
      builder: (context, snapshot) {
        return Column(
          children: [
            ListTile(
              title: Text('Touch and hold'),
              subtitle: Text('Holding a bud will toggle these anc modes:'),
              onTap: () => headphones.setGestureSettings(
                HeadphonesGestureSettings(
                  holdBoth:
                      snapshot.data!.holdBoth != HeadphonesGestureHold.cycleAnc
                          ? HeadphonesGestureHold.cycleAnc
                          : HeadphonesGestureHold.nothing,
                ),
              ),
              trailing: IgnorePointer(
                child: Switch(
                  value:
                      snapshot.data!.holdBoth == HeadphonesGestureHold.cycleAnc,
                  // Tile does that
                  onChanged: (_) {},
                ),
              ),
            ),
            Disabled(
              disabled:
                  !(snapshot.data!.holdBoth == HeadphonesGestureHold.cycleAnc),
              child: _HoldSettingsCard(
                enabledModes: MapEntry(snapshot.data!.holdBoth,
                    snapshot.data!.holdBothToggledAncModes),
                onChanged: (m) => headphones.setGestureSettings(
                  HeadphonesGestureSettings(
                    holdBoth: m.key,
                    holdBothToggledAncModes: m.value,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HoldSettingsCard extends StatelessWidget {
  final MapEntry<HeadphonesGestureHold?, Set<HeadphonesAncMode>?> enabledModes;
  final void Function(
      MapEntry<HeadphonesGestureHold?, Set<HeadphonesAncMode>?>)? onChanged;

  const _HoldSettingsCard(
      {Key? key, required this.enabledModes, this.onChanged})
      : super(key: key);

  bool checkboxChecked(HeadphonesAncMode mode) =>
      enabledModes.value?.contains(mode) ?? false;

  bool checkboxEnabled(bool enabled) =>
      (enabledModes.key == HeadphonesGestureHold.cycleAnc &&
          onChanged != null &&
          enabledModes.value != null &&
          // either all modes are enabled, or this is the disabled one
          (enabledModes.value!.length > 2 || !enabled));

  Widget modeCheckbox(String title, String desc, HeadphonesAncMode mode) {
    final checked = checkboxChecked(mode);
    return ListTile(
      title: Text(title),
      subtitle: Text(desc),
      trailing: Checkbox(
        value: checked,
        onChanged: checkboxEnabled(checked)
            ? (val) {
                onChanged!(
                  MapEntry(
                    enabledModes.key,
                    val!
                        ? ({...enabledModes.value!, mode})
                        : ({...enabledModes.value!}..remove(mode)),
                  ),
                );
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        child: Column(
          children: [
            modeCheckbox(
              l.ancNoiseCancel,
              l.ancNoiseCancelDesc,
              HeadphonesAncMode.noiseCancel,
            ),
            modeCheckbox(
              l.ancOff,
              l.ancOffDesc,
              HeadphonesAncMode.off,
            ),
            modeCheckbox(
              l.ancAwareness,
              l.ancAwarenessDesc,
              HeadphonesAncMode.awareness,
            ),
          ],
        ),
      ),
    );
  }
}
