import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../headphones/framework/headphones_settings.dart';
import '../../../../../headphones/huawei/settings.dart';
import '../../../../common/list_tile_radio.dart';

class EqualizerSection extends StatelessWidget {
  final HeadphonesSettings<HuaweiFreeBuds5iSettings> headphones;

  const EqualizerSection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.settings.map((s) => s.eqPreset),
      initialData: EqPreset.defaultEq,
      builder: (context, snap) {
        final dt = snap.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EqPresetSetting(
              title: Text(
                l.pageHeadphonesSettingsEqualizer,
                style: tt.bodyLarge,
              ),
              value: dt,
              onChanged: (g) => headphones.setSettings(
                HuaweiFreeBuds5iSettings(eqPreset: g),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EqPresetSetting extends StatelessWidget {
  final Widget? title;
  final EqPreset? value;
  final void Function(EqPreset?)? onChanged;

  const _EqPresetSetting({
    required this.value,
    this.onChanged,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 0, 6),
            child: title!,
          ),
        ],
        Row(
          children: [
            Expanded(
              child: ListTileRadio(
                title: Text(l.pageHeadphonesSettingsEqualizerDefault),
                value: EqPreset.defaultEq,
                dense: true,
                groupValue: value,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: ListTileRadio(
                title: Text(l.pageHeadphonesSettingsEqualizerHardBass),
                value: EqPreset.hardBassEq,
                dense: true,
                groupValue: value,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ListTileRadio(
                title: Text(l.pageHeadphonesSettingsEqualizerTreble),
                value: EqPreset.trebleEq,
                dense: true,
                groupValue: value,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: ListTileRadio(
                title: Text(l.pageHeadphonesSettingsEqualizerVoices),
                value: EqPreset.voicesEq,
                dense: true,
                groupValue: value,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
