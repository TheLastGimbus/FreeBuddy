package com.lastgimbus.the.freebuddy

import android.Manifest
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.work.Data
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import be.tramckrijte.workmanager.BackgroundWorker

/**
 * This reacts to a new bluetooth device being connected (literally any)
 *
 * That's why it then filters out to only AUDIO_VIDEO devices, and (currently):
 * - launches one-off workmanager work to update the widget
 */
class BluetoothDeviceConnectedReceiver : BroadcastReceiver() {
    companion object {
        const val TAG = "BtDevConnReceiver"
        const val TASK_ID_ROUTINE_UPDATE = "freebuddy.routine_update"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            BluetoothDevice.ACTION_ACL_CONNECTED -> {
                val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                } else {
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }
                if (device == null) {
                    Log.wtf(TAG, "device is null!!")
                    return
                }
                Log.d(TAG, "Connected to dev: $device ; Class: ${device.bluetoothClass.majorDeviceClass}")
                if (ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    Log.i(TAG, "No BLUETOOTH_CONNECT permission :(")
                    return
                }
                if (device.bluetoothClass.majorDeviceClass != BluetoothClass.Device.Major.AUDIO_VIDEO
                ) {
                    Log.v(TAG, "$device is not AUDIO_VIDEO, skipping...")
                    return
                }
                Log.i(TAG, "Scheduling one time work to update widget n stuff...")
                // this is stuff imported from be.tramckrijte.workmanager
                val oneOffTaskRequest = OneTimeWorkRequest.Builder(BackgroundWorker::class.java)
                    .setInputData(
                        Data.Builder()
                            .putString(BackgroundWorker.DART_TASK_KEY, TASK_ID_ROUTINE_UPDATE)
                            .putBoolean(BackgroundWorker.IS_IN_DEBUG_MODE_KEY, false)
                            .build()
                    )
                    .build()
                WorkManager.getInstance(context).enqueue(oneOffTaskRequest)
            }
        }
    }
}