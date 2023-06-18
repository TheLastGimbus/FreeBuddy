import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../headphones/cubit/headphones_connection_cubit.dart';
import '../../headphones/cubit/headphones_cubit_objects.dart';
import '../../headphones/headphones_base.dart';
import '../../headphones/headphones_mocks.dart';
import '../pages/disabled.dart';
import '../pages/home/bluetooth_disabled_info_widget.dart';
import '../pages/home/connected_closed_widget.dart';
import '../pages/home/disconnected_info_widget.dart';
import '../pages/home/no_permission_info_widget.dart';
import '../pages/home/not_paired_info_widget.dart';

/// This listens to [HeadphonesConnectionCubit] and (thorugh big-ass switch
/// machinery), decides whether to:
/// - show card about not having bluetooth granted/enabled
/// - show disabled widget from builder, covered with info about disconnection
/// - actually show the damn widget
///
/// When headphones are, for example, paired but not connected, it gives your
/// widget a [HeadphonesMockNever] object (so be aware of that!), prevents
/// user form tapping it and shows appropriate message 👍
///
/// This is ment to be used on pretty much every screens that requires connected
/// headphones
class HeadphonesConnectionEnsuringOverlay extends StatelessWidget {
  /// Build your widget of desire here - note that headphones may be Mock
  /// (as always 🙄)
  final Widget Function(BuildContext context, HeadphonesBase headphones)
      builder;

  const HeadphonesConnectionEnsuringOverlay({Key? key, required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    final l = AppLocalizations.of(context)!;
    return BlocBuilder<HeadphonesConnectionCubit, HeadphonesConnectionState>(
      builder: (context, state) => switch (state) {
        HeadphonesNoPermission() => const NoPermissionInfoWidget(),
        HeadphonesNotPaired() => const NotPairedInfoWidget(),
        HeadphonesBluetoothDisabled() => const BluetoothDisabledInfoWidget(),
        // We know that we *have* the headphones, but not necessary connected
        HeadphonesDisconnected() ||
        HeadphonesConnecting() ||
        HeadphonesConnectedClosed() ||
        HeadphonesConnectedOpen() =>
          Disabled(
            disabled: state is! HeadphonesConnectedOpen,
            coveringWidget: switch (state) {
              HeadphonesDisconnected() => const DisconnectedInfoWidget(),
              HeadphonesConnecting() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.pageHomeConnecting, style: tt.displaySmall),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ),
              HeadphonesConnectedClosed() => const ConnectedClosedWidget(),
              // Disabled() widget has a non-0ms transition so we need to swap
              // the overlay even when it's connected
              HeadphonesConnectedOpen() => const SizedBox(),
              _ => Text(l.pageHomeUnknown),
            },
            child: builder(
              context,
              state is HeadphonesConnectedOpen
                  ? state.headphones
                  : HeadphonesMockNever(),
            ),
          ),
        _ => Text(l.pageHomeUnknown),
      },
    );
  }
}
