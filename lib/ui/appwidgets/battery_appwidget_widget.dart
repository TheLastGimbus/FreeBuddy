import 'package:flutter/material.dart';

import '../../headphones/headphones_base.dart';
import '../pages/home/controls/battery_card.dart';

class BatteryAppwidgetWidget extends StatelessWidget {
  final double width;
  final double height;
  final HeadphonesBase headphones;

  const BatteryAppwidgetWidget(
      {super.key,
      required this.width,
      required this.height,
      required this.headphones});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: BatteryCard(headphones),
    );
  }
}
