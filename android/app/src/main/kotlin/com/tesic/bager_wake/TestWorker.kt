package com.tesic.bager_wake

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

/**
 * Lane C: an ordinary WorkManager job, the mechanism chat and sync apps rely on. It is the
 * weakest of the three by design — the system is free to defer it to a maintenance window even
 * on stock Android, and OEM killers drop it first. That contrast against the alarm lanes is the
 * measurement.
 */
class TestWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        val app = applicationContext
        TestStore.recordLaneFired(app, TestStore.LANE_WORK_MANAGER)
        TestNotifications.postLaneFired(app, TestStore.LANE_WORK_MANAGER)
        return Result.success()
    }

    companion object {
        const val UNIQUE_WORK_NAME = "bager_wake_delivery_test"
    }
}
