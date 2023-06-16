import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/headphones_base.dart';
import '../../../headphones/headphones_data_objects.dart';
import '../../common/list_tile_radio.dart';
import '../../common/list_tile_switch.dart';
import '../disabled.dart';

class DoubleTapSection extends StatelessWidget {
  final HeadphonesBase headphones;

  const DoubleTapSection({Key? key, required this.headphones})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;
    return StreamBuilder<HeadphonesGestureSettings>(
      stream: headphones.gestureSettings,
      initialData: headphones.gestureSettings.valueOrNull ??
          const HeadphonesGestureSettings(),
      builder: (context, snapshot) {
        final gs = snapshot.data!;
        final enabled =
            (gs.doubleTapLeft != HeadphonesGestureDoubleTap.nothing ||
                gs.doubleTapRight != HeadphonesGestureDoubleTap.nothing);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTileSwitch(
              title: Text(l.pageHeadphonesSettingsDoubleTap),
              subtitle: Text(l.pageHeadphonesSettingsDoubleTapDesc),
              value: enabled,
              onChanged: (newVal) {
                final g = newVal
                    ? HeadphonesGestureDoubleTap.playPause
                    : HeadphonesGestureDoubleTap.nothing;
                headphones.setGestureSettings(
                  HeadphonesGestureSettings(
                    doubleTapLeft: g,
                    doubleTapRight: g,
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
                      child: _DoubleTapSetting(
                        title: Text(
                          l.pageHeadphonesSettingsLeftBud,
                          // TODO: Make this titleMedium larger maybe? for whole app
                          style: tt.titleMedium,
                        ),
                        value: gs.doubleTapLeft,
                        onChanged: enabled
                            ? (g) => headphones.setGestureSettings(
                                  HeadphonesGestureSettings(doubleTapLeft: g),
                                )
                            : null,
                      ),
                    ),
                    Expanded(
                      child: _DoubleTapSetting(
                        title: Text(
                          l.pageHeadphonesSettingsRightBud,
                          style: tt.titleMedium,
                        ),
                        value: gs.doubleTapRight,
                        onChanged: enabled
                            ? (g) => headphones.setGestureSettings(
                                  HeadphonesGestureSettings(doubleTapRight: g),
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

class _DoubleTapSetting extends StatelessWidget {
  final Widget? title;
  final HeadphonesGestureDoubleTap? value;
  final void Function(HeadphonesGestureDoubleTap?)? onChanged;

  const _DoubleTapSetting({
    Key? key,
    required this.value,
    this.onChanged,
    this.title,
  }) : super(key: key);

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
            value: HeadphonesGestureDoubleTap.playPause,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapNextSong),
            value: HeadphonesGestureDoubleTap.next,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapPrevSong),
            value: HeadphonesGestureDoubleTap.previous,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapAssist),
            value: HeadphonesGestureDoubleTap.voiceAssistant,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
          ListTileRadio(
            title: Text(l.pageHeadphonesSettingsDoubleTapNone),
            value: HeadphonesGestureDoubleTap.nothing,
            dense: true,
            groupValue: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
