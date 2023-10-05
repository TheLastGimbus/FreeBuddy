import 'package:flutter/widgets.dart';

import '../../../../headphones/headphones_base.dart';

/// Image of the headphones (non-card)
///
/// Selects the correct image for given model
///
/// ...well, in the future :D
class HeadphonesImage extends StatelessWidget {
  final HeadphonesBase headphones;
  final String assetPath; 

  const HeadphonesImage(this.headphones, this.assetPath, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Switch image based on headphones
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }
}
