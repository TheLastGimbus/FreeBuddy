import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../headphones/headphones_mocks.dart';
import '../disabled.dart';
import 'headphones_controls_widget.dart';

class ConnectedClosedWidget extends StatelessWidget {
  const ConnectedClosedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Disabled(
      disabled: true,
      coveringWidget: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
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
      // coveringWidget: Text('dupa'),
      child: HeadphonesControlsWidget(
        headphones: HeadphonesMockNever(),
      ),
    );
  }
}
