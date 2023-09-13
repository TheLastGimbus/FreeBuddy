package com.lastgimbus.the.freebuddy

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.appwidget.*
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextDefaults
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetPlugin


class BatteryWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val sp = HomeWidgetPlugin.getData(context)
        val left = sp.getInt("left", 0)
        val right = sp.getInt("right", 0)
        val case = sp.getInt("case", 0)

        provideContent {
            GlanceTheme {
                val barColor = ColorProvider(R.color.battery_widget_bar_color)
                val barBackground = ColorProvider(R.color.battery_widget_bar_background)
                val textStyle = TextDefaults.defaultTextStyle.copy(
                    color = ColorProvider(R.color.battery_widget_text_color),
                    fontWeight = FontWeight.Medium, fontSize = 16.sp
                )

                Row(
                    modifier = GlanceModifier.fillMaxSize().appWidgetBackground()
                        .background(GlanceTheme.colors.background)
                ) {
                    @Composable
                    fun BatteryBox(progress: Float, text: String) {
                        Box(
                            modifier = GlanceModifier.defaultWeight().fillMaxHeight().padding(4.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            LinearProgressIndicator(
                                modifier = GlanceModifier.cornerRadius(16.dp).fillMaxHeight().fillMaxWidth(),
                                progress = progress,
                                color = barColor,
                                backgroundColor = barBackground
                            )
                            Text(
                                text,
                                style = textStyle
                            )
                        }

                    }

                    BatteryBox(left / 100f, "Left • $left%")
                    BatteryBox(right / 100f, "Right • $right%")
                    BatteryBox(case / 100f, "Case • $case%")

                }
            }
        }
    }

}