import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../headphones/cubit/headphones_cubit_objects.dart';
import '../../../headphones/headphones_base.dart';
import '../../../headphones/headphones_mocks.dart';
import '../../app_settings.dart';
import '../disabled.dart';
import 'bluetooth_disabled_info_widget.dart';
import 'connected_closed_widget.dart';
import 'headphones_controls_widget.dart';
import 'not_paired_info_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Looks like we need this future to wait for first frame to generate
    Future.microtask(_introCheck);
  }

  void _introCheck() async {
    // TODO: Get settings async then open intro if needed
    final settings = context.read<AppSettings>();
    if (!(await settings.seenIntroduction.first)) {
      // https://dart-lang.github.io/linter/lints/use_build_context_synchronously.html
      // ignore: use_build_context_synchronously
      if (!context.mounted) return;
      // true from this route means all success and we can set the flag
      // false means user exited otherwise or smth - anyway, don't set the flag
      final success =
          await Navigator.of(context).pushNamed('/introduction') as bool?;
      if (success ?? false) {
        await settings.setSeenIntroduction(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              BlocBuilder<HeadphonesConnectionCubit, HeadphonesConnectionState>(
            builder: (context, state) {
              if (state is! HeadphonesNotPaired &&
                  state is! HeadphonesBluetoothDisabled)
              // We know that we *have* the headphones, but not connected
              {
                Widget? overlay;
                HeadphonesBase? h;
                if (state is HeadphonesDisconnected) {
                  // TODO: Add a button to bt settings
                  overlay = Text(l.pageHomeDisconnected);
                } else if (state is HeadphonesConnecting) {
                  // TODO: Cool animation
                  overlay = Text(l.pageHomeConnecting);
                } else if (state is HeadphonesConnectedClosed) {
                  overlay = const ConnectedClosedWidget();
                } else if (state is HeadphonesConnectedOpen) {
                  h = state.headphones;
                }
                // TODO: maybe little more fade and gray out?
                return Disabled(
                  disabled: h == null,
                  // TODO: Bigger text
                  coveringWidget: overlay,
                  // Looks like, because it's same widget tree, the non-null
                  // headphones get cached (?) and we see last battery level
                  // when they get disconnected
                  // ...
                  // I actually like this! Official "feature, not a bug"
                  child: HeadphonesControlsWidget(
                    headphones: h ?? HeadphonesMockNever(),
                  ),
                );
              }
              // We're not sure we have headphones - don't display them pretty
              else if (state is HeadphonesNotPaired) {
                return const NotPairedInfoWidget();
              } else if (state is HeadphonesBluetoothDisabled) {
                return const BluetoothDisabledInfoWidget();
              } else {
                return Text(l.pageHomeUnknown);
              }
            },
          ),
        ),
      ),
    );
  }
}
