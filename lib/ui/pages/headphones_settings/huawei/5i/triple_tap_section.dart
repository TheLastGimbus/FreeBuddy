import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../headphones/framework/headphones_settings.dart';
import '../../../../../headphones/huawei/settings.dart';
import '../../../../common/list_tile_radio.dart';
import '../../../../common/list_tile_switch.dart';
import '../../../disabled.dart';

class TripleTapSection extends StatelessWidget {
  final HeadphonesSettings<HuaweiFreeBuds5iSettings> headphones;

  const TripleTapSection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.settings
          .map((s) => (l: s.tripleTapLeft, r: s.tripleTapRight)),
      initialData: (l: null, r: null),
      builder: (context, snap) {
        final dt = snap.data!;
        final enabled =
            (dt.l != TripleTap.nothing || dt.r != TripleTap.nothing);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTileSwitch(
              title: Text(l.pageHeadphonesSettingsTripleTap),
              subtitle: Text(l.pageHeadphonesSettingsTripleTapDesc),
              value: enabled,
              onChanged: (newVal) {
                headphones.setSettings(
                  HuaweiFreeBuds5iSettings(
                    tripleTapLeft:
                        newVal ? TripleTap.previous : TripleTap.nothing,
                    tripleTapRight: newVal ? TripleTap.next : TripleTap.nothing,
                  ),
                );
              },
            ),
            Disabled(
              disabled: !enabled,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: _TripleTapSetting(
                        title: Text(
                          l.pageHeadphonesSettingsLeftBud,
                          style: tt.titleMedium,
                        ),
                        value: dt.l,
                        onChanged: enabled
                            ? (g) => headphones.setSettings(
                                  HuaweiFreeBuds5iSettings(tripleTapLeft: g),
                                )
                            : null,
                      ),
                    ),
                    Expanded(
                      child: _TripleTapSetting(
                        title: Text(
                          l.pageHeadphonesSettingsRightBud,
                          style: tt.titleMedium,
                        ),
                        value: dt.r,
                        onChanged: enabled
                            ? (g) => headphones.setSettings(
                                  HuaweiFreeBuds5iSettings(tripleTapRight: g),
                                )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TripleTapSetting extends StatelessWidget {
  final Widget? title;
  final TripleTap? value;
  final void Function(TripleTap?)? onChanged;

  const _TripleTapSetting({
    required this.value,
    this.onChanged,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
              child: title!,
            ),
            const Divider(indent: 32, endIndent: 32),
          ],
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapNextSong),
            value: TripleTap.next,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapPrevSong),
            value: TripleTap.previous,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapNone),
            value: TripleTap.nothing,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
