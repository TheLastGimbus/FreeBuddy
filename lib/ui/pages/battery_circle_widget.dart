import 'package:flutter/material.dart';

// TODO: Make this animated
class BatteryCircleWidget extends StatelessWidget {
  final int? level;
  final int altLevel;
  final bool isCharging;
  final String textInCircle;

  const BatteryCircleWidget(
    this.level,
    this.altLevel,
    this.isCharging,
    this.textInCircle, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: add this somewhere fancy in theme
    const grayColor = Color(0xffdcdcdc);
    const circleSize = 36.0;
    final th = Theme.of(context);
    final tt = th.textTheme;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(8.0),
          width: circleSize,
          height: circleSize,
          child: Stack(
            children: [
              Center(
                child: Text(
                  textInCircle,
                  style: TextStyle(
                      color: Colors.black.withAlpha(120), fontSize: 20),
                ),
              ),
              SizedBox(
                width: circleSize,
                height: circleSize,
                child: CircularProgressIndicator(
                  value: (level ?? altLevel) / 100,
                  backgroundColor: grayColor.withAlpha(140),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    level == null ? grayColor : th.colorScheme.primary,
                  ),
                  strokeWidth: 6.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${level ?? ' - '}%',
          style: tt.subtitle1,
        ),
      ],
    );
  }
}
