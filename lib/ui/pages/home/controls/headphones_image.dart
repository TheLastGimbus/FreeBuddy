import 'package:flutter/material.dart';

import '../../../../headphones/framework/headphones_info.dart';

class HeadphonesImage extends StatelessWidget {
  final HeadphonesModelInfo modelInfo;

  const HeadphonesImage(this.modelInfo, {super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: StreamBuilder(
          stream: modelInfo.imageAssetPath,
          builder: (_, snap) => snap.data != null
              ? Image.asset(
                  snap.data!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  color: textColor,
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
