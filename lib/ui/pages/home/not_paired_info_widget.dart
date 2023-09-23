import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';

class NotPairedInfoWidget extends StatelessWidget {
  const NotPairedInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    final tt = t.textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.pageHomeNotPaired,
              style: tt.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
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
      ),
    );
  }
}
