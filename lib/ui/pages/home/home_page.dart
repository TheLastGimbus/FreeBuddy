import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../headphones/cubit/headphones_cubit_objects.dart';
import '../../app_settings.dart';
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
        child: BlocBuilder<HeadphonesConnectionCubit, HeadphonesObject>(
          builder: (context, state) {
            if (state is HeadphonesConnectedOpen) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: HeadphonesControlsWidget(headphones: state),
              );
            } else if (state is HeadphonesConnectedClosed) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: ConnectedClosedWidget(),
              );
            } else if (state is HeadphonesConnecting) {
              return Text(l.pageHomeConnecting);
            } else if (state is HeadphonesDisconnected) {
              return Text(l.pageHomeDisconnected);
            } else if (state is HeadphonesNotPaired) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: NotPairedInfoWidget(),
              );
            } else if (state is HeadphonesBluetoothDisabled) {
              final cbt = context.read<HeadphonesConnectionCubit>();
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: BluetoothDisabledInfoWidget(
                  onEnable: () => cbt.enableBluetooth(),
                  onOpenSettings: () => cbt.openBluetoothSettings(),
                ),
              );
            } else {
              return Text(l.pageHomeUnknown);
            }
          },
        ),
      ),
    );
  }
}
