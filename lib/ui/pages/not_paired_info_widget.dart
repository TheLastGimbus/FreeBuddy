import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

class NotPairedInfoWidget extends StatelessWidget {
  const NotPairedInfoWidget({Key? key}) : super(key: key);

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
      padding: const EdgeInsets.all(8.0),
      child: Center(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("You don't have Freebuds 4i paired to your phone :/"),
          ),
          TextButton(
            child: const Text("Open bluetooth settings to pair"),
            onPressed: () {
              AppSettings.openBluetoothSettings(asAnotherTask: true);
            },
          ),
        ],
      )),
    );
  }
}
