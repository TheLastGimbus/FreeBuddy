import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:rxdart/rxdart.dart';

import '../../../headphones/cubit/headphones_cubit_objects.dart';
import '../../../headphones/headphones_data_objects.dart';
import '../../../logger.dart';

// no better idea for this yet - that's fine
StreamSubscription<HeadphonesBatteryData>? _headphonesBatteryStreamSub;

void batteryHomeWidgetHearBloc(BuildContext context,
    HeadphonesConnectionState headphonesConnectionState) async {
  if (headphonesConnectionState is! HeadphonesConnectedOpen) {
    await _headphonesBatteryStreamSub?.cancel();
    _headphonesBatteryStreamSub = null;
  } else {
    _headphonesBatteryStreamSub = headphonesConnectionState
        .headphones.batteryData
        .throttleTime(const Duration(seconds: 1),
            trailing: true, leading: false)
        .listen((event) async {
      logg.d("Updating widget from UI listener: $event");
      await updateBatteryHomeWidget(event);
    });
  }
}

// this is separate so we can use it from f.e. background stuff
Future<void> updateBatteryHomeWidget(HeadphonesBatteryData batteryData) async {
  await HomeWidget.saveWidgetData<int?>('left', batteryData.levelLeft);
  await HomeWidget.saveWidgetData<int?>('right', batteryData.levelRight);
  await HomeWidget.saveWidgetData<int?>('case', batteryData.levelCase);
  await HomeWidget.updateWidget(
    name: 'BatteryWidgetReceiver',
    androidName: 'BatteryWidgetReceiver',
    qualifiedAndroidName: 'com.lastgimbus.the.freebuddy.BatteryWidgetReceiver',
  );
}
