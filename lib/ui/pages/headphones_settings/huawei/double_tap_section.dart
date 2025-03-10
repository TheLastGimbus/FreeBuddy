import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/headphones_settings.dart';
import '../../../../headphones/huawei/settings.dart';
import '../../../common/list_tile_radio.dart';
import '../../../common/list_tile_switch.dart';
import '../../disabled.dart';

class DoubleTapSection extends StatelessWidget {
  final HeadphonesSettings settings;

  const DoubleTapSection(this.settings, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;

    return StreamBuilder(
      stream: settings.settings.map((s) {
        if (s is HuaweiFreeBudsSE2Settings || s is HuaweiFreeBuds4iSettings) {
          return (l: s.doubleTapLeft, r: s.doubleTapRight);
        } else {
          return (l: null, r: null);
        }
      }),
      initialData: (l: null, r: null),
      builder: (context, snap) {
        final dt = snap.data!;
        final enabled =
            (dt.l != DoubleTap.nothing || dt.r != DoubleTap.nothing);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTileSwitch(
              title: Text(l.pageHeadphonesSettingsDoubleTap),
              subtitle: Text(l.pageHeadphonesSettingsDoubleTapDesc),
              value: enabled,
              onChanged: (newVal) {
                final g = newVal ? DoubleTap.playPause : DoubleTap.nothing;
                final settingsValue = settings.settings.value;

                if (settingsValue != null) {
                  if (settingsValue is HuaweiFreeBudsSE2Settings) {
                    settings.setSettings(
                      settingsValue.copyWith(
                        doubleTapLeft: g,
                        doubleTapRight: g,
                      ),
                    );
                  } else if (settingsValue is HuaweiFreeBuds4iSettings) {
                    settings.setSettings(
                      settingsValue.copyWith(
                        doubleTapLeft: g,
                        doubleTapRight: g,
                      ),
                    );
                  }
                }
              },
            ),
            Disabled(
              disabled: !enabled,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: _DoubleTapSetting(
                        title: Text(
                          l.pageHeadphonesSettingsLeftBud,
                          style: tt.titleMedium,
                        ),
                        value: dt.l,
                        onChanged: enabled
                            ? (g) {
                                final settingsValue = settings.settings.value;
                                if (settingsValue != null) {
                                  if (settingsValue
                                      is HuaweiFreeBudsSE2Settings) {
                                    settings.setSettings(
                                      settingsValue.copyWith(doubleTapLeft: g),
                                    );
                                  } else if (settingsValue
                                      is HuaweiFreeBuds4iSettings) {
                                    settings.setSettings(
                                      settingsValue.copyWith(doubleTapLeft: g),
                                    );
                                  }
                                }
                              }
                            : null,
                      ),
                    ),
                    Expanded(
                      child: _DoubleTapSetting(
                        title: Text(
                          l.pageHeadphonesSettingsRightBud,
                          style: tt.titleMedium,
                        ),
                        value: dt.r,
                        onChanged: enabled
                            ? (g) {
                                final settingsValue = settings.settings.value;
                                if (settingsValue != null) {
                                  if (settingsValue
                                      is HuaweiFreeBudsSE2Settings) {
                                    settings.setSettings(
                                      settingsValue.copyWith(doubleTapRight: g),
                                    );
                                  } else if (settingsValue
                                      is HuaweiFreeBuds4iSettings) {
                                    settings.setSettings(
                                      settingsValue.copyWith(doubleTapRight: g),
                                    );
                                  }
                                }
                              }
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

class _DoubleTapSetting extends StatelessWidget {
  final Widget? title;
  final DoubleTap? value;
  final void Function(DoubleTap?)? onChanged;

  const _DoubleTapSetting({
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
            title: Text(l.pageHeadphonesSettingsDoubleTapPlayPause),
            value: DoubleTap.playPause,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapNextSong),
            value: DoubleTap.next,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapPrevSong),
            value: DoubleTap.previous,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapAssist),
            value: DoubleTap.voiceAssistant,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapNone),
            value: DoubleTap.nothing,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
