package com.lastgimbus.the.freebuddy

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.appwidget.*
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.Text
import androidx.glance.text.TextDefaults
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlin.math.max
import kotlin.math.min


class BatteryWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val sp = HomeWidgetPlugin.getData(context)
        val left = sp.getInt("left", 0)
        val right = sp.getInt("right", 0)
        val case = sp.getInt("case", 0)

        fun Color.lighten(amount: Float): Color {
            return Color(
                red = max(0f, min(1f, this.red + amount)),
                green = max(0f, min(1f, this.green + amount)),
                blue = max(0f, min(1f, this.blue + amount)),
                alpha = this.alpha
            )
        }

        fun ColorProvider.lighten(amount: Float): ColorProvider {
            return ColorProvider(this.getColor(context).lighten(amount))
        }

        provideContent {
            GlanceTheme {
                // i had a whole big fuckery here
                // tldr - colors switch nice an intant when switching dark theme
                // problem is, they switch on android-style-xml basis - and if we set these programatically, it will not
                // do this until next update. Currently, it's not so tragic, and we can wait until this happens
                // ...altought it's a very non perfect situation -_-
                // cause i do not want to set these inside xml's because they won't work with dynamic coloring
                // ...and i want dynamic colors but juuuuust a bit brighter etc
                val isDark = GlanceTheme.colors.background.getColor(context).luminance() < 0.5f
                val barColor =
                    if (isDark) GlanceTheme.colors.primaryContainer else GlanceTheme.colors.primary.lighten(0.4f)
                val barBackground = if (isDark) GlanceTheme.colors.onPrimary else GlanceTheme.colors.primaryContainer
                val textStyle = TextDefaults.defaultTextStyle.copy(color = GlanceTheme.colors.onPrimaryContainer)

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