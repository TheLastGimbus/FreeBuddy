package com.lastgimbus.the.freebuddy

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.appwidget.*
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextDefaults
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlin.math.max


class BatteryWidget : GlanceAppWidget() {
    // TODO: Fuck with this a bit more
    companion object {
        private val SMALL_SQUARE = DpSize(100.dp, 100.dp)
        private val HORIZONTAL_RECTANGLE = DpSize(220.dp, 100.dp)
        private val VERTICAL_RECTANGLE = DpSize(100.dp, 180.dp)
        private val BIG_SQUARE = DpSize(200.dp, 200.dp)
    }

    override val sizeMode = SizeMode.Responsive(
        setOf(
            SMALL_SQUARE,
            HORIZONTAL_RECTANGLE,
            VERTICAL_RECTANGLE,
            BIG_SQUARE,
        )
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {

        provideContent {
            GlanceTheme {
                val sp = HomeWidgetPlugin.getData(LocalContext.current)
                val left = sp.getInt("left", 0)
                val right = sp.getInt("right", 0)
                val case = sp.getInt("case", 0)
                val size = LocalSize.current
                val barColor = ColorProvider(R.color.battery_widget_bar_color)
                val barBackground = ColorProvider(R.color.battery_widget_bar_background)
                val textStyle = TextDefaults.defaultTextStyle.copy(
                    color = ColorProvider(R.color.battery_widget_text_color),
                    fontWeight = FontWeight.Medium, fontSize = 16.sp
                )

                // TODO: Implement all cases here

                if (size.height < VERTICAL_RECTANGLE.height) {
                    Row(
                        modifier = GlanceModifier.fillMaxSize().appWidgetBackground()
                            .background(GlanceTheme.colors.background)
                            .cornerRadius(R.dimen.batteryWidgetBackgroundRadius)
                    ) {
                        @Composable
                        fun BatteryBox(progress: Float, text: String) {
                            Box(
                                modifier = GlanceModifier
                                    .defaultWeight()
                                    .fillMaxHeight()
                                    .padding(R.dimen.batteryWidgetPadding),
                                contentAlignment = Alignment.Center
                            ) {
                                LinearProgressIndicator(
                                    modifier = GlanceModifier
                                        .cornerRadius(R.dimen.batteryWidgetInnerRadius)
                                        .fillMaxSize(),
                                    progress = progress,
                                    color = barColor,
                                    backgroundColor = barBackground
                                )
                                Text(text, style = textStyle)
                            }

                        }
                        if (size.width <= SMALL_SQUARE.width) {
                            val b = max(left, right)
                            BatteryBox(b / 100f, "Buds • $b%")
                        } else {
                            BatteryBox(left / 100f, "Left • $left%")
                            BatteryBox(right / 100f, "Right • $right%")
                            BatteryBox(case / 100f, "Case • $case%")
                        }


                    }
                } else {
                    Column(
                        modifier = GlanceModifier
                            .fillMaxSize()
                            .appWidgetBackground()
                            .background(GlanceTheme.colors.background)
                            .cornerRadius(R.dimen.batteryWidgetBackgroundRadius)
                    ) {
                        @Composable
                        fun BatteryBox(progress: Float, text: String) {
                            Box(
                                modifier = GlanceModifier
                                    .defaultWeight()
                                    .padding(R.dimen.batteryWidgetPadding),
                                contentAlignment = Alignment.Center
                            ) {
                                LinearProgressIndicator(
                                    modifier = GlanceModifier
                                        .cornerRadius(R.dimen.batteryWidgetInnerRadius)
                                        .fillMaxSize(),
                                    progress = progress,
                                    color = barColor,
                                    backgroundColor = barBackground
                                )
                                Text(text, style = textStyle)
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

}