package com.tesic.bager_wake

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

/**
 * The test's notifications are the visible half of the measurement: the user is meant to see
 * which lanes actually landed on the lock screen and which never showed up.
 */
object TestNotifications {
    const val CHANNEL_ID = "delivery_test"

    private val laneNotificationIds = mapOf(
        TestStore.LANE_ALARM_CLOCK to 7101,
        TestStore.LANE_EXACT_IDLE to 7102,
        TestStore.LANE_WORK_MANAGER to 7103,
    )

    /**
     * Created eagerly at app start rather than on first test, so the dashboard's
     * notification check has a real channel to read instead of reporting "unavailable".
     */
    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            ?: return
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        val channel = NotificationChannel(
            CHANNEL_ID,
            context.getString(R.string.channel_name),
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = context.getString(R.string.channel_description)
        }
        manager.createNotificationChannel(channel)
    }

    /**
     * Posting can fail (permission revoked, channel blocked) — that must not stop the fire time
     * from being recorded, because the lane genuinely did fire. Delivery and display are two
     * separate findings and the app reports them separately.
     */
    fun postLaneFired(context: Context, lane: String) {
        ensureChannel(context)
        val title = context.getString(R.string.test_notification_title)
        val body = context.getString(
            R.string.test_notification_body,
            context.getString(laneLabelRes(lane)),
        )
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_popup_reminder)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .build()
        try {
            NotificationManagerCompat.from(context)
                .notify(laneNotificationIds[lane] ?: 7100, notification)
        } catch (t: Throwable) {
            // Recording the fire time already happened; a blocked notification is itself a
            // finding the dashboard surfaces, not an error to crash on.
        }
    }

    private fun laneLabelRes(lane: String): Int = when (lane) {
        TestStore.LANE_ALARM_CLOCK -> R.string.lane_alarm_clock
        TestStore.LANE_EXACT_IDLE -> R.string.lane_exact_idle
        else -> R.string.lane_work_manager
    }
}
