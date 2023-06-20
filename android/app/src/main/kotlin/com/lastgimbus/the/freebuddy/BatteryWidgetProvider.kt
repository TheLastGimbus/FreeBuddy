package com.lastgimbus.the.freebuddy

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class BatteryWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        appWidgetIds.forEach { appWidgetId ->
            val sp = HomeWidgetPlugin.getData(context)
            val left = sp.getInt("left", -1)
            val right = sp.getInt("right", -1)
            val case = sp.getInt("case", -1)

            // Get the layout for the widget and attach an on-click listener
            // to the button.
            val views: RemoteViews = RemoteViews(
                context.packageName,
                R.layout.battery_widget
            ).apply {
                setTextViewText(R.id.batteryInfoText, "Left: $left% • Right: $right% • Case: $case%")
            }
            // Tell the AppWidgetManager to perform an update on the current
            // widget.
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}