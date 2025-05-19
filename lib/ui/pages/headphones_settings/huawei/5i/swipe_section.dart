import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../headphones/framework/headphones_settings.dart';
import '../../../../../headphones/huawei/settings.dart';
import '../../../../common/list_tile_switch.dart';

class SwipeSection extends StatelessWidget {
  final HeadphonesSettings<HuaweiFreeBuds5iSettings> headphones;

  const SwipeSection(this.headphones, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.settings.map((s) => s.swipe),
      initialData: false,
      builder: (_, snap) {
        return ListTileSwitch(
          title: Text(l.swipe),
          subtitle: Text(l.swipeDesc),
          value: (snap.data ?? Swipe.nothing) == Swipe.adjustVolume,
          onChanged: (newVal) => headphones.setSettings(
            HuaweiFreeBuds5iSettings(
              swipe: newVal ? Swipe.adjustVolume : Swipe.nothing,
            ),
          ),
        );
      },
    );
  }
}
