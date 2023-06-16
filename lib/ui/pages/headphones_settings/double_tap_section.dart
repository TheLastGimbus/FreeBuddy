import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/headphones_base.dart';
import '../../../headphones/headphones_data_objects.dart';
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(l.pageHeadphonesSettingsDoubleTap),
              subtitle: Text(l.pageHeadphonesSettingsDoubleTapDesc),
              onTap: () {
                if (snapshot.data!.doubleTapLeft !=
                        HeadphonesGestureDoubleTap.nothing ||
                    snapshot.data!.doubleTapRight !=
                        HeadphonesGestureDoubleTap.nothing) {
                  headphones.setGestureSettings(const HeadphonesGestureSettings(
                    doubleTapLeft: HeadphonesGestureDoubleTap.nothing,
                    doubleTapRight: HeadphonesGestureDoubleTap.nothing,
                  ));
                } else {
                  headphones.setGestureSettings(const HeadphonesGestureSettings(
                    doubleTapLeft: HeadphonesGestureDoubleTap.playPause,
                    doubleTapRight: HeadphonesGestureDoubleTap.playPause,
                  ));
                }
              },
              trailing: IgnorePointer(
                child: Switch(
                  value: snapshot.data!.doubleTapLeft !=
                          HeadphonesGestureDoubleTap.nothing ||
                      snapshot.data!.doubleTapRight !=
                          HeadphonesGestureDoubleTap.nothing,
                  // Tile does that
                  onChanged: (_) {},
                ),
              ),
            ),
            Disabled(
              disabled: !(snapshot.data!.doubleTapLeft !=
                      HeadphonesGestureDoubleTap.nothing ||
                  snapshot.data!.doubleTapRight !=
                      HeadphonesGestureDoubleTap.nothing),
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
                        value: snapshot.data!.doubleTapLeft,
                        onChanged: (gesture) => headphones.setGestureSettings(
                          HeadphonesGestureSettings(doubleTapLeft: gesture),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _DoubleTapSetting(
                        title: Text(
                          l.pageHeadphonesSettingsRightBud,
                          style: tt.titleMedium,
                        ),
                        value: snapshot.data!.doubleTapRight,
                        onChanged: (gesture) => headphones.setGestureSettings(
                          HeadphonesGestureSettings(doubleTapRight: gesture),
                        ),
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

  const _DoubleTapSetting(
      {Key? key, required this.value, this.onChanged, this.title})
      : super(key: key);

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
          ListTile(
            title: Text(l.pageHeadphonesSettingsDoubleTapPlayPause),
            trailing: Radio(
              value: HeadphonesGestureDoubleTap.playPause,
              groupValue: value,
              onChanged: onChanged,
            ),
          ),
          ListTile(
            title: Text(l.pageHeadphonesSettingsDoubleTapNextSong),
            trailing: Radio(
              value: HeadphonesGestureDoubleTap.next,
              groupValue: value,
              onChanged: onChanged,
            ),
          ),
          ListTile(
            title: Text(l.pageHeadphonesSettingsDoubleTapPrevSong),
            trailing: Radio(
              value: HeadphonesGestureDoubleTap.previous,
              groupValue: value,
              onChanged: onChanged,
            ),
          ),
          ListTile(
            title: Text(l.pageHeadphonesSettingsDoubleTapAssist),
            trailing: Radio(
              value: HeadphonesGestureDoubleTap.voiceAssistant,
              groupValue: value,
              onChanged: onChanged,
            ),
          ),
          ListTile(
            title: Text(l.pageHeadphonesSettingsDoubleTapNone),
            trailing: Radio(
              value: HeadphonesGestureDoubleTap.nothing,
              groupValue: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
