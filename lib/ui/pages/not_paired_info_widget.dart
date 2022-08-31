import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

import 'pretty_rounded_container_widget.dart';

class NotPairedInfoWidget extends StatelessWidget {
  const NotPairedInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrettyRoundedContainerWidget(
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
