import 'package:flutter/material.dart';

import '../../../../gen/fms.dart';
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
                  icon: Fms.noise_control_on,
                  iconSelected: Fms.noise_control_on_700,
                  isSelected: mode == HeadphonesAncMode.noiseCancel,
                  onPressed: () =>
                      headphones.setAncMode(HeadphonesAncMode.noiseCancel),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: Fms.noise_control_off,
                  iconSelected: Fms.noise_control_off_700,
                  isSelected: mode == HeadphonesAncMode.off,
                  onPressed: () => headphones.setAncMode(HeadphonesAncMode.off),
                ),
                const ConstrainedSpacer(
                    constraints: BoxConstraints(maxWidth: 32)),
                _AncButton(
                  icon: Fms.noise_aware,
                  iconSelected: Fms.noise_aware_700,
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

  /// If non-null, this will be used when button is selected
  final IconData? iconSelected;
  final bool isSelected;
  final VoidCallback? onPressed;

  const _AncButton({
    Key? key,
    required this.icon,
    this.iconSelected,
    required this.isSelected,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      // shit: google material symbols are not centered :/
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 6),
      child: Icon(
        (isSelected && iconSelected != null) ? iconSelected : icon,
        size: 42,
      ),
    );
    return isSelected
        ? FilledButton(onPressed: onPressed, child: child)
        : FilledButton.tonal(onPressed: onPressed, child: child);
  }
}
