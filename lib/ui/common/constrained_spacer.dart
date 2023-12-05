import 'package:flutter/widgets.dart';

class ConstrainedSpacer extends StatelessWidget {
  final BoxConstraints constraints;
  final int flex;

  const ConstrainedSpacer(
      {super.key, required this.constraints, this.flex = 1});

  @override
  Widget build(BuildContext context) =>
      Flexible(flex: flex, child: Container(constraints: constraints));
}
