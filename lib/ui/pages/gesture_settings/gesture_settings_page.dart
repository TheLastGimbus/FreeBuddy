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
      appBar: AppBar(
        title: const Text('Gesture Settings'),
      ),
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
      initialData: const HeadphonesGestureSettings(null, null, null),
      builder: (context, snap) {
        final data = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Double tap',
              style: tt.titleMedium,
            ),
            Text(
              'Tap a bud twice to:',
              style: tt.labelMedium,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _DoubleTapSetting(
                    title: const Text('Left bud'),
                    value: data.doubleTapLeft,
                    onChanged: (v) => headphones.setGestureSettings(
                      HeadphonesGestureSettings(
                        v,
                        data.doubleTapRight,
                        data.holdBothToggledAncModes,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _DoubleTapSetting(
                    title: const Text('Right bud'),
                    value: data.doubleTapRight,
                    onChanged: (v) => headphones.setGestureSettings(
                      HeadphonesGestureSettings(
                        data.doubleTapLeft,
                        v,
                        data.holdBothToggledAncModes,
                      ),
                    ),
                  ),
                )
              ],
            ),
            const Divider(height: 32),
            Text(
              'Touch and hold',
              style: tt.titleMedium,
            ),
            Text(
              'Holding a bud will toggle these ANC modes:',
              style: tt.labelMedium,
            ),
            _HoldSettings(
              enabledModes: data.holdBothToggledAncModes,
              onChanged: (m) => headphones.setGestureSettings(
                HeadphonesGestureSettings(
                  data.doubleTapLeft,
                  data.doubleTapRight,
                  m,
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
    final t = Theme.of(context);
    final tt = t.textTheme;
    return Column(
      children: [
        if (title != null) title!,
        ListTile(
          title: const Text('Play/Pause'),
          trailing: Radio(
            value: HeadphonesGestureDoubleTap.playPause,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('Next song'),
          trailing: Radio(
            value: HeadphonesGestureDoubleTap.next,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('Previous song'),
          trailing: Radio(
            value: HeadphonesGestureDoubleTap.previous,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('Voice assistant'),
          trailing: Radio(
            value: HeadphonesGestureDoubleTap.voiceAssistant,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('None'),
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
  final Set<HeadphonesAncMode>? enabledModes;
  final void Function(Set<HeadphonesAncMode>)? onChanged;

  const _HoldSettings({Key? key, required this.enabledModes, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Noise canceling'),
          subtitle: const Text('Reduces noise around you'),
          trailing: Checkbox(
            value:
                enabledModes?.contains(HeadphonesAncMode.noiseCancel) ?? false,
            onChanged: (onChanged != null && enabledModes != null)
                ? (val) {
                    onChanged!(
                      val!
                          ? ({...enabledModes!, HeadphonesAncMode.noiseCancel})
                          : ({...enabledModes!}
                            ..remove(HeadphonesAncMode.noiseCancel)),
                    );
                  }
                : null,
          ),
        ),
        ListTile(
          title: const Text('Off'),
          subtitle: const Text('Turns ANC off'),
          trailing: Checkbox(
            value: enabledModes?.contains(HeadphonesAncMode.off) ?? false,
            onChanged: (onChanged != null && enabledModes != null)
                ? (val) {
                    onChanged!(
                      val!
                          ? ({...enabledModes!, HeadphonesAncMode.off})
                          : ({...enabledModes!}..remove(HeadphonesAncMode.off)),
                    );
                  }
                : null,
          ),
        ),
        ListTile(
          title: const Text('Awareness'),
          subtitle: const Text('Allows you to hear your surroundings'),
          trailing: Checkbox(
            value: enabledModes?.contains(HeadphonesAncMode.awareness) ?? false,
            onChanged: (onChanged != null && enabledModes != null)
                ? (val) {
                    onChanged!(
                      val!
                          ? ({...enabledModes!, HeadphonesAncMode.awareness})
                          : ({...enabledModes!}
                            ..remove(HeadphonesAncMode.awareness)),
                    );
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
