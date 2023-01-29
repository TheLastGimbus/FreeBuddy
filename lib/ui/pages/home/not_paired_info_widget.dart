import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../pretty_rounded_container_widget.dart';

class NotPairedInfoWidget extends StatelessWidget {
  const NotPairedInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PrettyRoundedContainerWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(l.pageHomeNotPaired, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: Text(l.pageHomeNotPairedPairOpenSettings),
            onPressed: () => context
                .read<HeadphonesConnectionCubit>()
                .openBluetoothSettings(),
          ),
          const SizedBox(height: 16),
          TextButton(
            child: Text(l.pageHomeNotPairedPairOpenDemo),
            onPressed: () => launchUrlString(
              'https://freebuddy-web-demo.netlify.app/',
              mode: LaunchMode.externalApplication,
            ),
          )
        ],
      ),
    );
  }
}
