import 'package:flutter/material.dart';

import '../../headphones/headphones_connection_cubit.dart';

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
          // TODO: actual functionality
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ancButton(icon: Icons.hearing_disabled, isSelected: false),
              ancButton(icon: Icons.highlight_off, isSelected: true),
              ancButton(icon: Icons.hearing, isSelected: false),
            ],
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
