import 'package:flutter/material.dart';

import '../../../gen/fms.dart';
import '../../../headphones/headphones_connection_cubit.dart';
import '../../../headphones/headphones_service/headphones_service_base.dart';
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
            Expanded(
              child: PrettyRoundedContainerWidget(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text('More settings\n(coming soon)'),
                    IconButton(onPressed: null, icon: Icon(Icons.settings)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrettyRoundedContainerWidget(
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
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        PrettyRoundedContainerWidget(
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
        ),
        const SizedBox(height: 16.0),
        PrettyRoundedContainerWidget(
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
                    onPressed: () =>
                        headphones.setAncMode(HeadphonesAncMode.off),
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
        ),
      ],
    );
  }
}
