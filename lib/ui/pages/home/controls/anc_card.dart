import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../headphones/headphones_base.dart';
import '../../../../headphones/headphones_data_objects.dart';
import '../../../common/constrained_spacer.dart';

/// Card with anc controls
class AncCard extends StatelessWidget {
  final HeadphonesBase headphones;

  const AncCard(this.headphones, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HeadphonesAncMode>(
      stream: headphones.ancMode,
      builder: (context, snapshot) {
        final mode = snapshot.data;
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: Symbols.noise_control_on,
                  isSelected: mode == HeadphonesAncMode.noiseCancel,
                  onPressed: () =>
                      headphones.setAncMode(HeadphonesAncMode.noiseCancel),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: Symbols.noise_control_off,
                  isSelected: mode == HeadphonesAncMode.off,
                  onPressed: () => headphones.setAncMode(HeadphonesAncMode.off),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: Symbols.noise_aware,
                  isSelected: mode == HeadphonesAncMode.awareness,
                  onPressed: () =>
                      headphones.setAncMode(HeadphonesAncMode.awareness),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
              ],
            ),
          ),
        );
      },
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
    Key? key,
    required this.icon,
    required this.isSelected,
    this.onPressed,
  }) : super(key: key);

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
