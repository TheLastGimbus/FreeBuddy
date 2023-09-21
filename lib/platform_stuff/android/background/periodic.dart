/// Stuff that happens periodically, like 15 or 60 minute intervals
///
/// Right now it is small and simple enough to have everything in one file

import 'package:rxdart/rxdart.dart';
import 'package:workmanager/workmanager.dart';

import '../../../di.dart' as di;
import '../../../headphones/cubit/headphones_connection_cubit.dart';
import '../../../headphones/cubit/headphones_cubit_objects.dart';
import '../../../logger.dart';
import '../appwidgets/battery_appwidget.dart';

/// Currently existing tasks
/// - "ROUTINE_UPDATE" - this will run every 15 minute, connect to headphones,
///   get their battery and set widgets/send notifications etc
// maybe move them to some special class/enum/smth??

const commonTimeout = Duration(seconds: 10);

const taskIdRoutineUpdate = "freebuddy.routine_update";

Future<bool> routineUpdateCallback() async {
  // i think this function is still "dependency injection" safe
  // ...but it's not wise to keep remembering what is and what isn't, is it?
  if (await HeadphonesConnectionCubit.cubitAlreadyRunningSomewhere()) {
    logg.d("Not updating stuff from ROUTINE_UPDATE "
        "because cubit is already running");
    return true;
  }
  // NOT_SURE: Also use real/mock logic here?? idk, but if you want,
  // feel free to make some proper DI for this to be shared in UI and here
  final cubit = di.getHeadphonesCubit();
  try {
    final headphones = await cubit.stream
        .debounceTime(const Duration(seconds: 1))
        .firstWhere((e) => e is! HeadphonesConnecting)
        .timeout(commonTimeout);
    if (headphones is! HeadphonesConnectedOpen) {
      logg.d("Not updating stuff from ROUTINE_UPDATE because: "
          "${headphones.toString()}");
      return true;
    }
    final batteryData =
        await headphones.headphones.batteryData.first.timeout(commonTimeout);
    logg.d("udpating widget from bgn: $batteryData");
    await updateBatteryHomeWidget(batteryData);
    await cubit.close(); // remember to close cubit to deregister port name
    return true;
  } catch (e) {
    await cubit.close(); // remember to close cubit to deregister port name
    rethrow;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  // this $task is a name, not id?? wtf??
  Workmanager().executeTask((task, inputData) {
    logg.d("Running periodic task $task"
        "${inputData != null ? " - input data: $inputData" : ""}");
    try {
      return switch (task) {
        taskIdRoutineUpdate => routineUpdateCallback().timeout(commonTimeout),
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
    initialDelay: const Duration(minutes: 5),
    existingWorkPolicy: ExistingWorkPolicy.keep,
    backoffPolicy: BackoffPolicy.linear,
  );
}
