import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../gen/fms.dart';
import '../../../headphones/headphones_base.dart';
import '../../../headphones/headphones_data_objects.dart';
import '../../app_settings.dart';
import '../disabled.dart';
import '../pretty_rounded_container_widget.dart';
import 'anc_button_widget.dart';
import 'battery_circle_widget.dart';

class HeadphonesControlsWidget extends StatelessWidget {
  final HeadphonesBase headphones;

  const HeadphonesControlsWidget({Key? key, required this.headphones})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // TODO: Display their alias here
        Expanded(
          flex: 4,
          child: Center(
            child: Text(
              headphones.alias ?? "FreeBuds 4i",
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w200),
            ),
          ),
        ),
        Expanded(
          flex: 20,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 64.0),
            child: Image.asset(
              'assets/app_icons/ic_launcher.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
        const Spacer(flex: 1),
        Row(
          children: [
            Expanded(child: _SleepModeSwitch(headphones)),
            const SizedBox(width: 16),
            Expanded(
              child: _SleepDisablable(child: _AutoPauseSwitch(headphones)),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _BatteryInfoRow(headphones),
        const SizedBox(height: 16.0),
        _SleepDisablable(child: _AncControlRow(headphones)),
      ],
    );
  }
}

class _BatteryInfoRow extends StatelessWidget {
  final HeadphonesBase headphones;

  const _BatteryInfoRow(this.headphones);

  @override
  Widget build(BuildContext context) {
    return PrettyRoundedContainerWidget(
      child: StreamBuilder<HeadphonesBatteryData>(
        initialData:
            HeadphonesBatteryData(null, null, null, false, false, false),
        stream: headphones.batteryData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text(":(");
          final b = snapshot.data!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BatteryCircleWidget(
                  b.levelLeft, b.lowestLevel, b.chargingLeft, "L"),
              BatteryCircleWidget(
                  b.levelRight, b.lowestLevel, b.chargingRight, "R"),
              BatteryCircleWidget(
                  b.levelCase, b.lowestLevel, b.chargingCase, "C"),
            ],
          );
        },
      ),
    );
  }
}

class _AncControlRow extends StatelessWidget {
  final HeadphonesBase headphones;

  const _AncControlRow(this.headphones);

  @override
  Widget build(BuildContext context) {
    return PrettyRoundedContainerWidget(
      child: StreamBuilder<HeadphonesAncMode>(
        stream: headphones.ancMode,
        builder: (context, snapshot) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              AncButtonWidget(
                icon: Fms.noise_control_on,
                isSelected: snapshot.data == HeadphonesAncMode.noiseCancel,
                onPressed: () =>
                    headphones.setAncMode(HeadphonesAncMode.noiseCancel),
              ),
              AncButtonWidget(
                icon: Fms.noise_control_off,
                isSelected: snapshot.data == HeadphonesAncMode.off,
                onPressed: () => headphones.setAncMode(HeadphonesAncMode.off),
              ),
              AncButtonWidget(
                icon: Fms.noise_aware,
                isSelected: snapshot.data == HeadphonesAncMode.awareness,
                onPressed: () =>
                    headphones.setAncMode(HeadphonesAncMode.awareness),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AutoPauseSwitch extends StatelessWidget {
  final HeadphonesBase headphones;

  const _AutoPauseSwitch(this.headphones);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PrettyRoundedContainerWidget(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(l.autoPause),
          StreamBuilder<bool>(
            stream: headphones.autoPause,
            builder: (context, snapshot) => Switch(
              value: snapshot.data ?? false,
              onChanged: headphones.setAutoPause,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepModeSwitch extends StatelessWidget {
  final HeadphonesBase headphones;

  const _SleepModeSwitch(this.headphones);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PrettyRoundedContainerWidget(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(l.sleepMode),
          StreamBuilder<bool>(
            stream: context.read<AppSettings>().sleepMode,
            builder: (context, snapshot) => Switch(
              value: snapshot.data ?? false,
              onChanged: (value) async {
                // TODO: move this logic somewhere else 🙏
                // currently have no idea where
                // maybe some "CoolModes" class 0_o
                // TODO 2: move this snackbar somewhere else too
                if (value) {
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text(l.sleepModeExplanation)),
                  );
                }
                final settings = context.read<AppSettings>();
                if (value) {
                  settings.setSleepModePreviousSettings(
                    await headphones.dumpSettings(),
                  );
                  await headphones.setAncMode(HeadphonesAncMode.off);
                  await headphones.setAutoPause(false);
                  // TODO: Disable gestures
                  // TODO #2 electric boogaloo: implement gestures
                } else {
                  await headphones.restoreSettings(
                    await settings.sleepModePreviousSettings.first,
                  );
                }
                settings.setSleepMode(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepDisablable extends StatelessWidget {
  final Widget child;

  const _SleepDisablable({required this.child});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // TODO: another reason to clean up the settings ;_;
    return StreamBuilder(
      initialData: false,
      stream: context.read<AppSettings>().sleepMode,
      builder: (_, snap) => Disabled(
        disabled: (snap.data ?? false),
        coveringWidget: Text(l.sleepModeOverlay),
        child: child,
      ),
    );
  }
}
