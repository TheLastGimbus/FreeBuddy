import 'package:flutter/material.dart';

import '../../headphones/headphones_connection_cubit.dart';
import '../../headphones/headphones_service/headphones_service_base.dart';

class HeadphonesControlsWidget extends StatelessWidget {
  final HeadphonesConnected headphones;

  const HeadphonesControlsWidget({Key? key, required this.headphones})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          StreamBuilder<HeadphonesBatteryData>(
            stream: headphones.batteryData,
            builder: (context, snapshot) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Letft: ${snapshot.data?.levelLeft ?? "unknown"}"
                      "${snapshot.data?.chargingLeft ?? false ? "\n🔌" : ""}"),
                  Text("Right: ${snapshot.data?.levelRight ?? "unknown"}"
                      "${snapshot.data?.chargingRight ?? false ? "\n🔌" : ""}"),
                  Text("Case: ${snapshot.data?.levelCase ?? "unknown"}"
                      "${snapshot.data?.chargingCase ?? false ? "\n🔌" : ""}"),
                ],
              );
            },
          ),
          // TODO: actual functionality
          StreamBuilder<HeadphonesAncMode>(
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
          )
        ],
      ),
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
