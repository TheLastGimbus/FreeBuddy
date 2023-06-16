import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/headphones_base.dart';
import '../../../headphones/headphones_data_objects.dart';
import '../../common/list_tile_checkbox.dart';
import '../../common/list_tile_switch.dart';
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
        final gs = snapshot.data!;
        final enabled = gs.holdBoth == HeadphonesGestureHold.cycleAnc;
        return Column(
          children: [
            ListTileSwitch(
              title: Text(l.pageHeadphonesSettingsHold),
              subtitle: Text(l.pageHeadphonesSettingsHoldDesc),
              value: enabled,
              onChanged: (newVal) => headphones.setGestureSettings(
                HeadphonesGestureSettings(
                  holdBoth: newVal
                      ? HeadphonesGestureHold.cycleAnc
                      : HeadphonesGestureHold.nothing,
                ),
              ),
            ),
            Disabled(
              disabled: !enabled,
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
    return ListTileCheckbox(
      title: Text(title),
      subtitle: Text(desc),
      value: checked,
      onChanged: checkboxEnabled(checked)
          ? (val) {
              onChanged!(
                MapEntry(
                  enabledModes.key,
                  val
                      ? ({...enabledModes.value!, mode})
                      : ({...enabledModes.value!}..remove(mode)),
                ),
              );
            }
          : null,
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
