import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../headphones/framework/anc.dart';
import '../../../common/constrained_spacer.dart';

/// Card with anc controls
class AncCard extends StatelessWidget {
  final Anc anc;

  const AncCard(this.anc, {super.key});

  String getAncLevelTranslation(AncLevel level, AppLocalizations l) =>
      switch (level) {
        AncLevel.normal => l.ancCancelLevelNormal,
        AncLevel.comfort => l.ancCancelLevelComfort,
        AncLevel.ultra => l.ancCancelLevelUltra,
        AncLevel.dynamic => l.ancCancelLevelDynamic,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (anc.supportsAncLevel)
              StreamBuilder<AncLevel>(
                stream: anc.ancLevel,
                builder: (context, snapshot) {
                  final mode = anc.ancMode.valueOrNull;
                  if (mode != AncMode.noiseCancelling) {
                    return SizedBox.shrink();
                  }

                  final level = snapshot.data;
                  return Column(
                    children: [
                      DropdownMenu<AncLevel>(
                        width: double.infinity,
                        label: Text(l.ancNoiseCancel),
                        initialSelection: level,
                        dropdownMenuEntries: AncLevel.values
                            .map(
                              (e) => DropdownMenuEntry<AncLevel>(
                                label: getAncLevelTranslation(e, l),
                                value: e,
                              ),
                            )
                            .toList(),
                        onSelected: (g) => anc.setAncLevel(g!),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            StreamBuilder<AncMode>(
              stream: anc.ancMode,
              builder: (context, snapshot) {
                final mode = snapshot.data;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ConstrainedSpacer(
                        constraints: BoxConstraints(maxWidth: 32)),
                    _AncButton(
                      icon: Symbols.noise_control_on,
                      isSelected: mode == AncMode.noiseCancelling,
                      onPressed: () => anc.setAncMode(AncMode.noiseCancelling),
                    ),
                    const ConstrainedSpacer(
                        constraints: BoxConstraints(maxWidth: 32)),
                    _AncButton(
                      icon: Symbols.noise_control_off,
                      isSelected: mode == AncMode.off,
                      onPressed: () => anc.setAncMode(AncMode.off),
                    ),
                    const ConstrainedSpacer(
                        constraints: BoxConstraints(maxWidth: 32)),
                    _AncButton(
                      icon: Symbols.noise_aware,
                      isSelected: mode == AncMode.transparency,
                      onPressed: () => anc.setAncMode(AncMode.transparency),
                    ),
                    const ConstrainedSpacer(
                        constraints: BoxConstraints(maxWidth: 32)),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

/// Button for switching anc mode
///
/// TODO: Make this prettier (splash animation at least :/ )
class _AncButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onPressed;

  const _AncButton({
    required this.icon,
    required this.isSelected,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(
        icon,
        weight: isSelected ? 600 : 400,
        size: 42,
      ),
    );
    return isSelected
        ? FilledButton(onPressed: onPressed, child: child)
        : FilledButton.tonal(onPressed: onPressed, child: child);
  }
}
