/// Stuff that happens periodically, like 15 or 60 minute intervals
///
/// Right now it is small and simple enough to have everything in one file

import 'package:workmanager/workmanager.dart';

import '../../../headphones/headphones_data_objects.dart';
import '../../../logger.dart';
import '../appwidgets/battery_appwidget.dart';

/// Currently existing tasks
/// - "ROUTINE_UPDATE" - this will run every 15 minute, connect to headphones,
///   get their battery and set widgets/send notifications etc
// maybe move them to some special class/enum/smth??

const taskIdRoutineUpdate = "freebuddy.routine_update";

Future<bool> routineUpdateCallback() async {
  // TODO: Get battery from real headphones
  // final batteryData = await HeadphonesMockPrettyFake()
  //     .batteryData
  //     .first
  //     .timeout(const Duration(seconds: 10));
  final batteryData = HeadphonesBatteryData(2, 1, 3, false, true, false);
  logg.d("udpating widget from bgn: $batteryData");
  await updateBatteryHomeWidget(batteryData);
  return true;
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  // this $task is a name, not id?? wtf??
  Workmanager().executeTask((task, inputData) {
    logg.d("Running periodic task $task"
        "${inputData != null ? " - input data: $inputData" : ""}");
    try {
      return switch (task) {
        taskIdRoutineUpdate => routineUpdateCallback(),
        String() => throw Exception("No such task named $task"),
      };
    } catch (e, s) {
      logg.e("Periodic task $task failed", error: e, stackTrace: s);
      return Future.value(false);
    }
  });
}

/// Init all workmanager stuff
/// this is async so run this safely in main() before runApp()
// remember to not put anything too heavy here, we want fassst app launch
Future<void> init() async {
  await Workmanager().initialize(
    callbackDispatcher,
    // If enabled it will post a notification whenever the task is running
    // disabling for now because android 13 permission 🙃
    isInDebugMode: false,
  );
  await Workmanager().cancelAll(); // just in case 🤷
  await Workmanager().registerPeriodicTask(
    taskIdRoutineUpdate, // this doesnt get exposed in executeTask()
    taskIdRoutineUpdate, // ...so pass it here too 🙃
    frequency: const Duration(minutes: 15),
    initialDelay: Duration(minutes: 1),
    existingWorkPolicy: ExistingWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.linear,
  );
}
