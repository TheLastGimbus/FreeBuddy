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
    const circleSize = 36.0;
    final t = Theme.of(context);
    final tt = t.textTheme;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(8.0),
          width: circleSize,
          height: circleSize,
          child: Stack(
            children: [
              Center(child: Text(textInCircle, style: tt.labelLarge!)),
              SizedBox(
                width: circleSize,
                height: circleSize,
                child: CircularProgressIndicator(
                  value: (level ?? altLevel) / 100,
                  backgroundColor: t.colorScheme.shadow.withAlpha(50),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    // TODO: decide nice color here
                    level == null
                        ? t.colorScheme.shadow.withAlpha(120)
                        : t.colorScheme.primary,
                  ),
                  strokeWidth: 6.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${level ?? ' - '}%${isCharging ? ' +' : ''}',
          style: tt.subtitle1,
        ),
      ],
    );
  }
}
