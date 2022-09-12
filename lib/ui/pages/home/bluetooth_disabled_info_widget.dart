import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../pretty_rounded_container_widget.dart';

class BluetoothDisabledInfoWidget extends StatelessWidget {
  final VoidCallback? onEnable;
  final VoidCallback? onOpenSettings;

  const BluetoothDisabledInfoWidget(
      {Key? key, this.onEnable, this.onOpenSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PrettyRoundedContainerWidget(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(l.pageHomeBluetoothDisabled),
            ),
            TextButton(
              onPressed: onEnable,
              child: Text(l.pageHomeBluetoothDisabledEnable),
            ),
            TextButton(
              onPressed: onOpenSettings,
              child: Text(l.pageHomeBluetoothDisabledEnableOpenSettings),
            ),
          ],
        ),
      ),
    );
  }
}
