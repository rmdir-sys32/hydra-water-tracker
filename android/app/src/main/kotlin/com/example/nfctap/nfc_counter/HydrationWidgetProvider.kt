package com.example.nfctap.nfc_counter

import android.appwidget.AppWidgetManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import kotlin.math.min

class HydrationWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val amount = widgetData.getInt("today_total_ml", 0)
        val goal = widgetData.getInt("daily_goal_ml", 2000)
        val progress = if (goal > 0) min(amount.toFloat() / goal, 1f) else 0f
        val openAppIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            },
            PendingIntent.FLAG_UPDATE_CURRENT or
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_IMMUTABLE
                } else {
                    0
                },
        )

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.hydration_widget)
            views.setImageViewBitmap(
                R.id.hydration_widget_image,
                renderWidget(amount, goal, progress),
            )
            views.setOnClickPendingIntent(R.id.hydration_widget_image, openAppIntent)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun renderWidget(amount: Int, goal: Int, progress: Float): Bitmap {
        val size = 360
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val center = size / 2f
        val ringBounds = RectF(38f, 38f, size - 38f, size - 38f)

        val background = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(48, 255, 255, 255)
        }
        canvas.drawCircle(center, center, 142f, background)

        val track = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(70, 255, 255, 255)
            style = Paint.Style.STROKE
            strokeWidth = 18f
        }
        canvas.drawArc(ringBounds, -90f, 360f, false, track)

        val progressPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.rgb(13, 148, 136)
            style = Paint.Style.STROKE
            strokeWidth = 18f
            strokeCap = Paint.Cap.ROUND
        }
        canvas.drawArc(ringBounds, -90f, progress * 360f, false, progressPaint)

        val amountPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textAlign = Paint.Align.CENTER
            textSize = 58f
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }
        canvas.drawText(amount.toString(), center, 185f, amountPaint)

        val labelPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.argb(190, 255, 255, 255)
            textAlign = Paint.Align.CENTER
            textSize = 26f
        }
        canvas.drawText("ml  •  ${(progress * 100).toInt()}%", center, 225f, labelPaint)
        canvas.drawText("of $goal ml", center, 258f, labelPaint)

        return bitmap
    }
}
