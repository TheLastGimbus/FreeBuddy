import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../gen/fms.dart';
import '../../../headphones/cubit/headphones_cubit_objects.dart';
import '../../../headphones/headphones_service/headphones_service_base.dart';
import '../../app_settings.dart';
import '../disabled.dart';
import '../pretty_rounded_container_widget.dart';
import 'anc_button_widget.dart';
import 'battery_circle_widget.dart';

class HeadphonesControlsWidget extends StatelessWidget {
  final HeadphonesConnectedOpen headphones;

  const HeadphonesControlsWidget({Key? key, required this.headphones})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            'assets/sluchaweczki.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
        ),
        Row(
          children: [
            Expanded(child: _SleepModeSwitch(headphones)),
            const SizedBox(width: 16),
            // TODO: another reason to clean up the settings ;_;
            StreamBuilder(
              initialData: false,
              stream: context.read<AppSettings>().sleepMode,
              builder: (_, snap) => Disabled(
                disabled: (snap.data ?? false),
                coveringWidget: const Text('Sleep mode 😴'),
                child: _AutoPauseSwitch(headphones),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _BatteryInfoRow(headphones),
        const SizedBox(height: 16.0),
        StreamBuilder(
          initialData: false,
          stream: context.read<AppSettings>().sleepMode,
          builder: (_, snap) => Disabled(
            disabled: (snap.data ?? false),
            coveringWidget: const Text('Sleep mode 😴'),
            child: _AncControlRow(headphones),
          ),
        ),
      ],
    );
  }
}

class _BatteryInfoRow extends StatelessWidget {
  final HeadphonesConnectedOpen headphones;

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
  final HeadphonesConnectedOpen headphones;

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
  final HeadphonesConnectedOpen headphones;

  const _AutoPauseSwitch(this.headphones);

  @override
  Widget build(BuildContext context) {
    return PrettyRoundedContainerWidget(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text("Auto pause"),
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
  final HeadphonesConnectedOpen headphones;

  const _SleepModeSwitch(this.headphones);

  @override
  Widget build(BuildContext context) {
    return PrettyRoundedContainerWidget(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('Sleep mode'),
          StreamBuilder<bool>(
            stream: context.read<AppSettings>().sleepMode,
            builder: (context, snapshot) => Switch(
              value: snapshot.data ?? false,
              onChanged: (value) async {
                // TODO: move this logic somewhere else 🙏
                // currently have no idea where
                // maybe some "CoolModes" class 0_o
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
