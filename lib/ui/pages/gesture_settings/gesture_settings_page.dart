import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/headphones_data_objects.dart';

class GestureSettingsPage extends StatefulWidget {
  const GestureSettingsPage({Key? key}) : super(key: key);

  @override
  State<GestureSettingsPage> createState() => _GestureSettingsPageState();
}

class _GestureSettingsPageState extends State<GestureSettingsPage> {
  // TODO: Replace this with real stuff
  var valLeft = 0;
  var valRight = 0;
  Set<HeadphonesAncMode> modes = {};

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Settings'),
      ),
      body: ListView(
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
                    value: valLeft,
                    onChanged: (v) => setState(() => valLeft = v!)),
              ),
              Expanded(
                child: _DoubleTapSetting(
                  title: const Text('Right bud'),
                  value: valRight,
                  onChanged: (v) => setState(() => valRight = v!),
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
            enabledModes: modes,
            onChanged: (m) => setState(() => modes = m),
          ),
        ],
      ),
    );
  }
}

class _DoubleTapSetting extends StatelessWidget {
  final Widget? title;
  final int value;
  final void Function(int?)? onChanged;

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
            value: 0,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('Next song'),
          trailing: Radio(
            value: 1,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('Previous song'),
          trailing: Radio(
            value: 2,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('Voice assistant'),
          trailing: Radio(
            value: 3,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
        ListTile(
          title: const Text('None'),
          trailing: Radio(
            value: 4,
            groupValue: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _HoldSettings extends StatelessWidget {
  final Set<HeadphonesAncMode> enabledModes;
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
            value: enabledModes.contains(HeadphonesAncMode.noiseCancel),
            onChanged: onChanged != null
                ? (val) {
                    onChanged!(
                      val!
                          ? (enabledModes..add(HeadphonesAncMode.noiseCancel))
                          : (enabledModes
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
            value: enabledModes.contains(HeadphonesAncMode.off),
            onChanged: onChanged != null
                ? (val) {
                    onChanged!(
                      val!
                          ? (enabledModes..add(HeadphonesAncMode.off))
                          : (enabledModes..remove(HeadphonesAncMode.off)),
                    );
                  }
                : null,
          ),
        ),
        ListTile(
          title: const Text('Awareness'),
          subtitle: const Text('Allows you to hear your surroundings'),
          trailing: Checkbox(
            value: enabledModes.contains(HeadphonesAncMode.awareness),
            onChanged: onChanged != null
                ? (val) {
                    onChanged!(
                      val!
                          ? (enabledModes..add(HeadphonesAncMode.awareness))
                          : (enabledModes..remove(HeadphonesAncMode.awareness)),
                    );
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
