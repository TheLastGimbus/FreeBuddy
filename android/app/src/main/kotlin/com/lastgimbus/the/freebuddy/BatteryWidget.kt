package com.lastgimbus.the.freebuddy

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.*
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextDefaults
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlin.math.max


class BatteryWidget : GlanceAppWidget() {
    // TODO: Preview layout/image
    companion object {
        private val SMALL_SQUARE = DpSize(60.dp, 60.dp)
        private val HORIZONTAL_RECTANGLE = DpSize(220.dp, 60.dp)
        private val VERTICAL_RECTANGLE = DpSize(80.dp, 160.dp)
        private val BIG_SQUARE = DpSize(180.dp, 180.dp)
    }

    override val sizeMode = SizeMode.Responsive(
        setOf(
            SMALL_SQUARE,
            VERTICAL_RECTANGLE,
            HORIZONTAL_RECTANGLE,
            BIG_SQUARE,
        )
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        // TODO: Icons/charging
        provideContent {
            GlanceTheme {
                val sp = HomeWidgetPlugin.getData(LocalContext.current)
                val left = sp.getInt("left", -1)
                val right = sp.getInt("right", -1)
                val case = sp.getInt("case", -1)
                val size = LocalSize.current
                val barColor = ColorProvider(R.color.battery_widget_bar_color)
                val barBackground = ColorProvider(R.color.battery_widget_bar_background)
                val textStyle = TextDefaults.defaultTextStyle.copy(
                    color = ColorProvider(R.color.battery_widget_text_color),
                    fontWeight = FontWeight.Medium, fontSize = 16.sp,
                    textAlign = TextAlign.Center,
                )

                @Composable
                fun BatteryBox(passGlanceModifier: GlanceModifier, level: Int, label: String) {
                    Box(
                        // this must be passed  here because for some reason the .defaultWeight() is context aware??
                        modifier = passGlanceModifier,
                        contentAlignment = Alignment.Center
                    ) {
                        LinearProgressIndicator(
                            modifier = GlanceModifier
                                .cornerRadius(R.dimen.batteryWidgetInnerRadius)
                                .fillMaxSize(),
                            progress = max(0f, level / 100f),
                            color = barColor,
                            backgroundColor = barBackground
                        )
                        Text("$label • ${if (level >= 0) "$level%" else "-"}", style = textStyle)
                    }
                }

                Box(
                    modifier = GlanceModifier
                        .fillMaxSize()
                        .appWidgetBackground()
                        .clickable(actionStartActivity(activity = MainActivity::class.java))
                        .background(GlanceTheme.colors.background)
                        .cornerRadius(R.dimen.batteryWidgetBackgroundRadius)
                        .padding(R.dimen.batteryWidgetPadding)
                ) {
                    if (size.height < VERTICAL_RECTANGLE.height) {
                        Row(modifier = GlanceModifier.fillMaxSize()) {
                            // this must be passed  here because for some reason the .defaultWeight() is context aware??
                            val mod = GlanceModifier.defaultWeight().fillMaxHeight()
                            if (size.width <= SMALL_SQUARE.width) {
                                BatteryBox(mod, max(left, right), "Buds")
                            } else {
                                BatteryBox(mod, left, "Left")
                                Spacer(modifier = GlanceModifier.size(R.dimen.batteryWidgetPadding))
                                BatteryBox(mod, right, "Right")
                                Spacer(modifier = GlanceModifier.size(R.dimen.batteryWidgetPadding))
                                BatteryBox(mod, case, "Case")
                            }
                        }
                    } else {
                        Column(modifier = GlanceModifier.fillMaxSize()) {
                            // this must be passed  here because for some reason the .defaultWeight() is context aware??
                            val mod = GlanceModifier.defaultWeight() // no .fillMaxHeight()!
                            BatteryBox(mod, left, "Left")
                            Spacer(modifier = GlanceModifier.size(R.dimen.batteryWidgetPadding))
                            BatteryBox(mod, right, "Right")
                            Spacer(modifier = GlanceModifier.size(R.dimen.batteryWidgetPadding))
                            BatteryBox(mod, case, "Case")
                        }
                    }
                }
            }
        }
    }

}