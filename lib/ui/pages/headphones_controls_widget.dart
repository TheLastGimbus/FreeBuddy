import 'package:flutter/material.dart';

import '../../headphones/headphones_connection_cubit.dart';
import '../../headphones/headphones_service/headphones_service_base.dart';

class HeadphonesControlsWidget extends StatelessWidget {
  final HeadphonesConnected headphones;

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
            'sluchaweczki.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: StreamBuilder<HeadphonesBatteryData>(
            initialData:
                HeadphonesBatteryData(null, null, null, false, false, false),
            stream: headphones.batteryData,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text(":(");
              final b = snapshot.data!;

              batteryCircle(int? level, int altLevel, bool isCharging) =>
                  Column(
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value: (level ?? altLevel) / 100,
                          // gayed out if value is null
                          valueColor: AlwaysStoppedAnimation<Color>(
                            level == null
                                ? const Color(0xffe5e5e5)
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Text(
                        '${level ?? ' - '}%',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  );

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  batteryCircle(b.levelLeft, b.lowestLevel, b.chargingLeft),
                  batteryCircle(b.levelRight, b.lowestLevel, b.chargingRight),
                  batteryCircle(b.levelCase, b.lowestLevel, b.chargingCase),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: StreamBuilder<HeadphonesAncMode>(
            stream: headphones.ancMode,
            builder: (context, snapshot) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ancButton(
                    icon: Icons.hearing_disabled,
                    isSelected: snapshot.data == HeadphonesAncMode.noiseCancel,
                    onPressed: () =>
                        headphones.setAncMode(HeadphonesAncMode.noiseCancel),
                  ),
                  ancButton(
                    icon: Icons.highlight_off,
                    isSelected: snapshot.data == HeadphonesAncMode.off,
                    onPressed: () =>
                        headphones.setAncMode(HeadphonesAncMode.off),
                  ),
                  ancButton(
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

  Widget ancButton({
    required IconData icon,
    required bool isSelected,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(
            isSelected ? Colors.blue : Colors.grey),
        shape: MaterialStateProperty.all<CircleBorder>(const CircleBorder()),
      ),
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
