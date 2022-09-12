import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../pretty_rounded_container_widget.dart';

class NotPairedInfoWidget extends StatelessWidget {
  const NotPairedInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PrettyRoundedContainerWidget(
      child: Center(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(l.pageHomeNotPaired),
          ),
          TextButton(
            child: Text(l.pageHomeNotPairedPairOpenSettings),
            onPressed: () {
              AppSettings.openBluetoothSettings(asAnotherTask: true);
            },
          ),
        ],
          )),
    );
  }
}
