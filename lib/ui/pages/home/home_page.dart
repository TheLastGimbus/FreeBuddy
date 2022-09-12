import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/headphones_connection_cubit.dart';
import 'bluetooth_disabled_info_widget.dart';
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
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: Center(
        child: BlocBuilder<HeadphonesConnectionCubit, HeadphonesObject>(
          builder: (context, state) {
            if (state is HeadphonesConnected) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: HeadphonesControlsWidget(headphones: state),
              );
            } else if (state is HeadphonesConnecting) {
              return const Text("connecting");
            } else if (state is HeadphonesDisconnected) {
              return const Text("disconnected");
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
              return const Text("unknown :(");
            }
          },
        ),
      ),
    );
  }
}
