import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../gen/fms.dart';
import '../../../headphones/headphones_base.dart';
import '../../../headphones/headphones_data_objects.dart';
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
    final l = AppLocalizations.of(context)!;
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
            Expanded(
              child: PrettyRoundedContainerWidget(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/gesture_settings'),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(l.pageGestureSettingsTitle),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AutoPauseSwitch(headphones),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        _BatteryInfoRow(headphones),
        const SizedBox(height: 16.0),
        _AncControlRow(headphones),
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
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
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
