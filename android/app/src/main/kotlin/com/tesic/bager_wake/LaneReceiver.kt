package com.tesic.bager_wake

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Fires for the two AlarmManager lanes. Everything here must finish well inside the ~10s a
 * receiver gets, and it does: one synchronous preference write plus a notification. No wake
 * lock is taken — the system already holds one for the duration of onReceive, and holding our
 * own would be exactly the kind of battery behaviour Play flags.
 */
class LaneReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val lane = intent.getStringExtra(EXTRA_LANE) ?: return
        TestStore.recordLaneFired(context.applicationContext, lane)
        TestNotifications.postLaneFired(context.applicationContext, lane)
    }

    companion object {
        const val EXTRA_LANE = "lane"
    }
}
