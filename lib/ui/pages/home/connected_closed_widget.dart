import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';

class ConnectedClosedWidget extends StatelessWidget {
  const ConnectedClosedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context);
    final tt = t.textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.pageHomeConnectedClosed,
          style: tt.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(l.pageHomeConnectedClosedDesc, textAlign: TextAlign.center),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () => context.read<HeadphonesConnectionCubit>().connect(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(l.pageHomeConnectedClosedConnect),
          ),
        ),
      ],
    );
  }
}
