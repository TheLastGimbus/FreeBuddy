import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../../headphones/framework/bluetooth_headphones.dart';
import '../../../../headphones/framework/headphones_info.dart';
import '../../../../headphones/framework/lrc_battery.dart';
import '../../../../headphones/headphones_base.dart';
import '../../../../headphones/huawei/freebuds4i.dart';
import '../../../theme/layouts.dart';
import 'anc_card.dart';
import 'battery_card.dart';
import 'headphones_image.dart';

/// Main whole-screen widget with controls for headphones
///
/// It contains battery, anc buttons, button to settings etc - just give it
/// the [headphones] and all done ☺
///
/// ...in fact, it is built so simple that you can freely hot-swap the
/// headphones object - for example, if they disconnect for a moment,
/// you can give it [HeadphonesMockNever] object, and previous values will stay
/// because it won't override them
class HeadphonesControlsWidget extends StatelessWidget {
  final BluetoothHeadphones headphones;

  const HeadphonesControlsWidget({super.key, required this.headphones});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tt = t.textTheme;
    // TODO MIGRATION: Whole big ass branching here in detecting whether hp
    // support different features
    if (headphones is HuaweiFreeBuds4i) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: WindowSizeClass.of(context) == WindowSizeClass.compact
            ? Column(
                children: [
                  StreamBuilder(
                    stream: headphones.bluetoothAlias,
                    builder: (_, snap) => Text(
                      snap.data ?? headphones.bluetoothName,
                      style: tt.headlineMedium,
                    ),
                  ),
                  HeadphonesImage(headphones as HeadphonesModelInfo),
                  // TODO MIGRATION: hp settings not yet implemented
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: _HeadphonesSettingsButton(headphones),
                  // ),
                  BatteryCard(headphones as LRCBattery),
                  AncCard(headphones as Anc),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        StreamBuilder(
                          stream: headphones.bluetoothAlias,
                          builder: (_, snap) => Text(
                            snap.data ?? headphones.bluetoothName,
                            style: tt.headlineMedium,
                          ),
                        ),
                        HeadphonesImage(headphones as HeadphonesModelInfo),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // TODO MIGRATION: hp settings not yet implemented
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: _HeadphonesSettingsButton(headphones),
                          // ),
                          BatteryCard(headphones as LRCBattery),
                          AncCard(headphones as Anc),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      );
    } else {
      return const Text("no i dupa");
    }
  }
}

/// Simple button leading to headphones settings page
class _HeadphonesSettingsButton extends StatelessWidget {
  final HeadphonesBase headphones;

  const _HeadphonesSettingsButton(this.headphones);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    return Padding(
      // TODO: Move this to theme stuff some day
      padding: t.cardTheme.margin ?? const EdgeInsets.all(4.0),
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, '/headphones_settings'),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_outlined, size: 20),
              const SizedBox(width: 4),
              Text(l.settings),
            ],
          ),
        ),
      ),
    );
  }
}
