import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../headphones/framework/anc.dart';
import '../../../../../headphones/framework/headphones_settings.dart';
import '../../../../../headphones/huawei/settings.dart';
import '../../../../common/list_tile_checkbox.dart';
import '../../../../common/list_tile_switch.dart';
import '../../../disabled.dart';

class HoldSection extends StatelessWidget {
  final HeadphonesSettings<HuaweiFreeBuds5iSettings> headphones;

  const HoldSection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.settings
          .map((s) => (holdBoth: s.holdBoth, anc: s.holdBothToggledAncModes)),
      initialData: (holdBoth: null, anc: null),
      builder: (context, snap) {
        final gs = snap.data!;
        final enabled = gs.holdBoth == Hold.cycleAnc;
        return Column(
          children: [
            ListTileSwitch(
              title: Text(l.pageHeadphonesSettingsHold),
              subtitle: Text(l.pageHeadphonesSettingsHoldDesc),
              value: enabled,
              onChanged: (newVal) => headphones.setSettings(
                HuaweiFreeBuds5iSettings(
                  holdBoth: newVal ? Hold.cycleAnc : Hold.nothing,
                ),
              ),
            ),
            Disabled(
              disabled: !enabled,
              child: _HoldSettingsCard(
                enabledModes: MapEntry(gs.holdBoth, gs.anc),
                onChanged: (m) => headphones.setSettings(
                  HuaweiFreeBuds5iSettings(
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
  final MapEntry<Hold?, Set<AncMode>?> enabledModes;
  final void Function(MapEntry<Hold?, Set<AncMode>?>)? onChanged;

  const _HoldSettingsCard({required this.enabledModes, this.onChanged});

  bool checkboxChecked(AncMode mode) =>
      enabledModes.value?.contains(mode) ?? false;

  bool checkboxEnabled(bool enabled) => (enabledModes.key == Hold.cycleAnc &&
      onChanged != null &&
      enabledModes.value != null &&
      // either all modes are enabled, or this is the disabled one
      (enabledModes.value!.length > 2 || !enabled));

  Widget modeCheckbox(String title, String desc, AncMode mode) {
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
              AncMode.noiseCancelling,
            ),
            modeCheckbox(
              l.ancOff,
              l.ancOffDesc,
              AncMode.off,
            ),
            modeCheckbox(
              l.ancAwareness,
              l.ancAwarenessDesc,
              AncMode.transparency,
            ),
          ],
        ),
      ),
    );
  }
}
