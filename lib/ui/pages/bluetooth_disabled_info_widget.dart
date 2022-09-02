import 'package:flutter/material.dart';

import 'pretty_rounded_container_widget.dart';

class BluetoothDisabledInfoWidget extends StatelessWidget {
  final VoidCallback? onEnable;
  final VoidCallback? onOpenSettings;

  const BluetoothDisabledInfoWidget(
      {Key? key, this.onEnable, this.onOpenSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PrettyRoundedContainerWidget(
      child: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Bluetooth is disabled :/"),
            ),
            TextButton(
              onPressed: onEnable,
              child: const Text("Enable"),
            ),
            TextButton(
              onPressed: onOpenSettings,
              child: const Text("Open bluetooth settings to enable"),
            ),
          ],
        ),
      ),
    );
  }
}
