import 'package:flutter/widgets.dart';

class ConstrainedSpacer extends StatelessWidget {
  final BoxConstraints constraints;
  final int flex;

  const ConstrainedSpacer({Key? key, required this.constraints, this.flex = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Flexible(flex: flex, child: Container(constraints: constraints));
}
