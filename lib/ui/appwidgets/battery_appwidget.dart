import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:screenshot/screenshot.dart';

import '../../headphones/cubit/headphones_cubit_objects.dart';
import '../../headphones/headphones_data_objects.dart';
import 'battery_appwidget_widget.dart';

// no better idea for this yet - that's fine
StreamSubscription<HeadphonesBatteryData>? _headphonesBatteryStreamSub;

@pragma("vm:entry-point")
void updateBatteryAppwidget() {
}

void batteryHomeWidgetHearBloc(BuildContext context,
    HeadphonesConnectionState headphonesConnectionState) async {
  if (headphonesConnectionState is! HeadphonesConnectedOpen) {
    await _headphonesBatteryStreamSub?.cancel();
    _headphonesBatteryStreamSub = null;
  } else {
    _headphonesBatteryStreamSub =
        headphonesConnectionState.headphones.batteryData.listen((event) async {
      await HomeWidget.saveWidgetData<int?>('left', event.levelLeft);
      await HomeWidget.saveWidgetData<int?>('right', event.levelRight);
      await HomeWidget.saveWidgetData<int?>('case', event.levelCase);
      await HomeWidget.updateWidget(
        name: 'BatteryWidgetProvider',
        androidName: 'BatteryWidgetProvider',
        qualifiedAndroidName:
            'com.lastgimbus.the.freebuddy.BatteryWidgetProvider',
      );
    });
  }
}
