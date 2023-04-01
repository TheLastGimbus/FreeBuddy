import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../headphones/cubit/headphones_cubit_objects.dart';
import '../../../headphones/headphones_base.dart';
import '../../../headphones/headphones_data_objects.dart';
import '../../../headphones/headphones_mocks.dart';
import '../disabled.dart';

class GestureSettingsPage extends StatefulWidget {
  const GestureSettingsPage({Key? key}) : super(key: key);

  @override
  State<GestureSettingsPage> createState() => _GestureSettingsPageState();
}

class _GestureSettingsPageState extends State<GestureSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.pageGestureSettingsTitle)),
      body: BlocBuilder<HeadphonesConnectionCubit, HeadphonesConnectionState>(
        builder: (_, state) {
          // state = HeadphonesNoPermission();
          HeadphonesBase? h;
          if (state is HeadphonesConnectedOpen) {
            h = state.headphones;
          } else {}
          return Disabled(
            disabled: state is! HeadphonesConnectedOpen,
            coveringWidget: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                l.pageHomeDisconnected,
                style: tt.displaySmall,
                textAlign: TextAlign.center,
              ),
            ),
            child: _ActualSettings(headphones: h ?? HeadphonesMockNever()),
          );
        },
      ),
    );
  }
}

class _ActualSettings extends StatelessWidget {
  final HeadphonesBase headphones;

  const _ActualSettings({Key? key, required this.headphones}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;
    return StreamBuilder<HeadphonesGestureSettings>(
      stream: headphones.gestureSettings,
      initialData: const HeadphonesGestureSettings(),
      builder: (context, snap) {
        final data = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l.pageGestureSettingsDoubleTap,
              style: tt.titleMedium,
            ),
            Text(
              l.pageGestureSettingsDoubleTapDesc,
              style: tt.labelMedium,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _DoubleTapSetting(
                    title: Text(l.pageGestureSettingsLeftBud),
                    value: data.doubleTapLeft,
                    onChanged: (v) => headphones.setGestureSettings(
                      HeadphonesGestureSettings(doubleTapLeft: v),
                    ),
                  ),
                ),
                // TODO: Put divider between them once this gets closed:
                // https://github.com/flutter/flutter/issues/27293
                Expanded(
                  child: _DoubleTapSetting(
                    title: Text(l.pageGestureSettingsRightBud),
                    value: data.doubleTapRight,
                    onChanged: (v) => headphones.setGestureSettings(
                      HeadphonesGestureSettings(doubleTapRight: v),
                    ),
                  ),
                )
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // this lets text break
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.pageGestureSettingsHold,
                        style: tt.titleMedium,
                      ),
                      Text(
                        l.pageGestureSettingsHoldDesc,
                        style: tt.labelMedium,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: data.holdBoth == HeadphonesGestureHold.cycleAnc,
                  onChanged: (newVal) {
                    headphones.setGestureSettings(
                      HeadphonesGestureSettings(
                        holdBoth: newVal
                            ? HeadphonesGestureHold.cycleAnc
                            : HeadphonesGestureHold.nothing,
                      ),
                    );
                  },
                ),
              ],
            ),
            _HoldSettings(
              enabledModes:
                  MapEntry(data.holdBoth, data.holdBothToggledAncModes),
              onChanged: (m) => headphones.setGestureSettings(
                HeadphonesGestureSettings(
                  holdBoth: m.key,
                  holdBothToggledAncModes: m.value,
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
    return Column(
      children: [
        if (title != null) title!,
        ListTile(
          title: Text(l.pageGestureSettingsDoubleTapPlayPause),
          trailing: Radio(
            value: HeadphonesGestureDoubleTap.playPause,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: Text(l.pageGestureSettingsDoubleTapNextSong),
          trailing: Radio(
            value: HeadphonesGestureDoubleTap.next,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: Text(l.pageGestureSettingsDoubleTapPrevSong),
          trailing: Radio(
            value: HeadphonesGestureDoubleTap.previous,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: Text(l.pageGestureSettingsDoubleTapAssist),
          trailing: Radio(
            value: HeadphonesGestureDoubleTap.voiceAssistant,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: Text(l.pageGestureSettingsDoubleTapNone),
          trailing: Radio(
            value: HeadphonesGestureDoubleTap.nothing,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _HoldSettings extends StatelessWidget {
  final MapEntry<HeadphonesGestureHold?, Set<HeadphonesAncMode>?> enabledModes;
  final void Function(
      MapEntry<HeadphonesGestureHold?, Set<HeadphonesAncMode>?>)? onChanged;

  const _HoldSettings({Key? key, required this.enabledModes, this.onChanged})
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
    return Column(
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
    );
  }
}
