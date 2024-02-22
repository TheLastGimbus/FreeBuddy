import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../headphones/_old/headphones_base.dart';
import '../../common/list_tile_switch.dart';

class AutoPauseSection extends StatelessWidget {
  final HeadphonesBase headphones;

  const AutoPauseSection({super.key, required this.headphones});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return StreamBuilder(
      stream: headphones.autoPause,
      initialData: headphones.autoPause.valueOrNull ?? false,
      builder: (_, snapshot) {
        return ListTileSwitch(
          title: Text(l.autoPause),
          subtitle: Text(l.autoPauseDesc),
          value: snapshot.data!,
          onChanged: (newVal) => headphones.setAutoPause(newVal),
        );
      },
    );
  }
}
