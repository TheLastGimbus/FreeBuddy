import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../pretty_rounded_container_widget.dart';

class ConnectedClosedWidget extends StatelessWidget {
  const ConnectedClosedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PrettyRoundedContainerWidget(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(l.pageHomeConnectedClosed),
            ),
            TextButton(
              onPressed: () =>
                  context.read<HeadphonesConnectionCubit>().connect(),
              child: Text(l.pageHomeConnectedClosedConnect),
            ),
          ],
        ),
      ),
    );
  }
}
