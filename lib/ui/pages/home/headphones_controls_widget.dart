import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../headphones/headphones_connection_cubit.dart';
import '../../../headphones/headphones_service/headphones_service_base.dart';
import '../../../headphones/huawei/mbb.dart';
import '../../../headphones/huawei/otter/headphones_impl_otter.dart';
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
        if (kDebugMode && headphones is HeadphonesImplOtter)
          TextButton(
            onPressed: () {
              (headphones as HeadphonesImplOtter).sendCustomMbbCommand(
                const MbbCommand(1, 8, {}),
              );
            },
            child: const Text("custom"),
          ),
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
                    icon: Icons.hearing_disabled,
                    isSelected: snapshot.data == HeadphonesAncMode.noiseCancel,
                    onPressed: () =>
                        headphones.setAncMode(HeadphonesAncMode.noiseCancel),
                  ),
                  AncButtonWidget(
                    icon: Icons.highlight_off,
                    isSelected: snapshot.data == HeadphonesAncMode.off,
                    onPressed: () =>
                        headphones.setAncMode(HeadphonesAncMode.off),
                  ),
                  AncButtonWidget(
                    icon: Icons.hearing,
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
