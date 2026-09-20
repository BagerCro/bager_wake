package com.tesic.bager_wake

import android.app.Activity
import android.app.AlarmManager
import android.app.AppOpsManager
import android.app.PendingIntent
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.os.SystemClock
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.UUID
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/**
 * Schedules three delivery lanes of deliberately different strength and reports, per lane,
 * whether it fired and how late.
 *
 * Outcomes are computed at read time from recorded timestamps rather than being frozen when a
 * lane is declared dead. A lane the OEM killed often fires hours later the moment the user
 * unlocks the phone; recomputing means that shows up as "very late" — which is the truth —
 * instead of staying stuck on "never arrived".
 */
class TestEnginePlugin private constructor(
    private val context: Context,
) : MethodChannel.MethodCallHandler {

    private val ioExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val CHANNEL_NAME = "com.tesic.bager_wake/test_engine"

        private const val REQUEST_CODE_ALARM_CLOCK = 8101
        private const val REQUEST_CODE_EXACT_IDLE = 8102
        private const val REQUEST_CODE_SHOW_INTENT = 8103

        /** Alarm lanes are meant to be exact; anything past this is a real delay. */
        private const val EXACT_TOLERANCE_MS = 60_000L

        /**
         * WorkManager's initial delay is a minimum, not a promise — even stock Android defers
         * jobs to a maintenance window. Judging it by the alarm lanes' standard would report a
         * healthy phone as broken.
         */
        private const val WORK_TOLERANCE_MS = 5 * 60_000L

        /** A lane is only called dead once the scheduled moment is comfortably past. */
        private const val NEVER_FIRED_GRACE_MS = 2 * 60_000L

        /** Spacing between lanes; see [laneSchedulesFor] for why they can't share a moment. */
        private const val MAX_LANE_GAP_MS = 5 * 60_000L

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val plugin = TestEnginePlugin(activity.applicationContext)
            TestNotifications.ensureChannel(activity.applicationContext)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                .setMethodCallHandler(plugin)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "canRun" -> result.success(canRun())
            "start" -> start(call, result)
            "currentRun" -> runAsync(result) { currentRunPayload() }
            "collectResults" -> runAsync(result) { collectPayload() }
            "cancel" -> runAsync(result) { cancelRun(); null }
            "armRebootProbe" -> runAsync(result) { TestStore.armRebootProbe(context); null }
            "rebootProbe" -> runAsync(result) { rebootProbePayload() }
            "history" -> runAsync(result) { historyPayload() }
            else -> result.notImplemented()
        }
    }

    private fun runAsync(result: MethodChannel.Result, block: () -> Any?) {
        ioExecutor.execute {
            val value = try {
                Result.success(block())
            } catch (t: Throwable) {
                Result.failure(t)
            }
            mainHandler.post {
                value.fold(
                    onSuccess = { result.success(it) },
                    onFailure = {
                        result.error(
                            "test_engine_error",
                            it.message ?: it.javaClass.simpleName,
                            null,
                        )
                    },
                )
            }
        }
    }

    /** Lanes A and B cannot be scheduled at all without the exact-alarm permission. */
    private fun canRun(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return false
        return try {
            am.canScheduleExactAlarms()
        } catch (t: Throwable) {
            false
        }
    }

    private fun start(call: MethodCall, result: MethodChannel.Result) {
        val windowSeconds = call.argument<Int>("windowSeconds")
        if (windowSeconds == null || windowSeconds <= 0) {
            result.error("bad_args", "windowSeconds must be a positive integer", null)
            return
        }
        if (!canRun()) {
            result.error(
                "exact_alarms_denied",
                "Exact alarms are not permitted, so the alarm lanes cannot be scheduled",
                null,
            )
            return
        }
        ioExecutor.execute {
            val payload = try {
                // Whatever was in flight is preserved rather than dropped, so a forgotten run
                // still shows up in history.
                TestStore.archiveCurrent(context)
                val now = System.currentTimeMillis()
                val schedules = laneSchedulesFor(now, windowSeconds)
                val run = TestStore.startRun(
                    context,
                    UUID.randomUUID().toString(),
                    windowSeconds,
                    schedules,
                )
                scheduleAlarmLanes(schedules)
                scheduleWorkLane(schedules.getValue(TestStore.LANE_WORK_MANAGER) - now)
                Result.success(computePayload(run, archiveIfComplete = false))
            } catch (t: Throwable) {
                Result.failure(t)
            }
            mainHandler.post {
                payload.fold(
                    onSuccess = { result.success(it) },
                    onFailure = {
                        result.error("start_failed", it.message ?: it.javaClass.simpleName, null)
                    },
                )
            }
        }
    }

    private fun lanePendingIntent(lane: String, requestCode: Int): PendingIntent {
        val intent = Intent(context, LaneReceiver::class.java)
            .setAction("com.tesic.bager_wake.LANE_$lane")
            .putExtra(LaneReceiver.EXTRA_LANE, lane)
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /**
     * The lanes must not share a trigger moment, or they contaminate each other: the system
     * leaves Doze shortly *before* a setAlarmClock alarm fires, which would wake the device in
     * time to rescue the two weaker lanes and report a throttled phone as healthy.
     *
     * Since interference only travels forward in time, they run weakest-first — WorkManager,
     * then the exact alarm, then the alarm clock last. Each lane is therefore judged on a device
     * state that none of the later lanes has touched.
     */
    private fun laneSchedulesFor(now: Long, windowSeconds: Int): Map<String, Long> {
        val windowMs = windowSeconds * 1000L
        val gap = minOf(MAX_LANE_GAP_MS, windowMs / 3)
        return mapOf(
            TestStore.LANE_WORK_MANAGER to now + windowMs - 2 * gap,
            TestStore.LANE_EXACT_IDLE to now + windowMs - gap,
            TestStore.LANE_ALARM_CLOCK to now + windowMs,
        )
    }

    private fun scheduleAlarmLanes(schedules: Map<String, Long>) {
        val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            ?: throw IllegalStateException("AlarmManager is not available on this device")

        val showIntent = PendingIntent.getActivity(
            context,
            REQUEST_CODE_SHOW_INTENT,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        am.setAlarmClock(
            AlarmManager.AlarmClockInfo(
                schedules.getValue(TestStore.LANE_ALARM_CLOCK),
                showIntent,
            ),
            lanePendingIntent(TestStore.LANE_ALARM_CLOCK, REQUEST_CODE_ALARM_CLOCK),
        )
        am.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            schedules.getValue(TestStore.LANE_EXACT_IDLE),
            lanePendingIntent(TestStore.LANE_EXACT_IDLE, REQUEST_CODE_EXACT_IDLE),
        )
    }

    private fun scheduleWorkLane(delayMs: Long) {
        val request = OneTimeWorkRequestBuilder<TestWorker>()
            .setInitialDelay(delayMs.coerceAtLeast(0L), TimeUnit.MILLISECONDS)
            .build()
        WorkManager.getInstance(context).enqueueUniqueWork(
            TestWorker.UNIQUE_WORK_NAME,
            ExistingWorkPolicy.REPLACE,
            request,
        )
    }

    private fun cancelRun() {
        val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
        am?.cancel(lanePendingIntent(TestStore.LANE_ALARM_CLOCK, REQUEST_CODE_ALARM_CLOCK))
        am?.cancel(lanePendingIntent(TestStore.LANE_EXACT_IDLE, REQUEST_CODE_EXACT_IDLE))
        try {
            WorkManager.getInstance(context).cancelUniqueWork(TestWorker.UNIQUE_WORK_NAME)
        } catch (t: Throwable) {
            // Cancelling work that was already killed is not an error worth surfacing.
        }
        TestStore.markCancelled(context)
        TestStore.archiveCurrent(context)
    }

    private fun currentRunPayload(): Map<String, Any?>? {
        val run = TestStore.currentRun(context) ?: return null
        val payload = computePayload(run, archiveIfComplete = false)
        val lanes = payload["lanes"] as? List<*> ?: return null
        val stillRunning = lanes.any {
            (it as? Map<*, *>)?.get("outcome") == "pending"
        }
        return if (stillRunning) payload else null
    }

    /**
     * Returns the run in flight, or the most recent finished one, so the results screen still
     * has something to show after a run completes and is archived.
     */
    private fun collectPayload(): Map<String, Any?>? {
        val current = TestStore.currentRun(context)
        if (current != null) return computePayload(current, archiveIfComplete = true)
        val history = TestStore.historyArray(context)
        if (history.length() == 0) return null
        val newest = history.optJSONObject(history.length() - 1) ?: return null
        return computePayload(newest, archiveIfComplete = false)
    }

    private fun historyPayload(): List<Map<String, Any?>> {
        val history = TestStore.historyArray(context)
        val out = mutableListOf<Map<String, Any?>>()
        for (i in history.length() - 1 downTo 0) {
            val run = history.optJSONObject(i) ?: continue
            out.add(computePayload(run, archiveIfComplete = false))
        }
        return out
    }

    private fun rebootProbePayload(): Map<String, Any?>? {
        val probe = TestStore.rebootProbe(context) ?: return null
        return mapOf(
            "armedAt" to probe.optLong("armedAt"),
            "bootReceivedAt" to
                if (probe.has("bootReceivedAt")) probe.optLong("bootReceivedAt") else null,
        )
    }

    private fun computePayload(run: JSONObject, archiveIfComplete: Boolean): Map<String, Any?> {
        val now = System.currentTimeMillis()
        val cancelled = run.optBoolean("cancelled", false)
        val rebooted = detectReboot(run, now)
        val lanesJson = run.optJSONObject("lanes") ?: JSONObject()

        val lanes = TestStore.ALL_LANES.map { lane ->
            val entry = lanesJson.optJSONObject(lane)
            val scheduledFor = entry?.optLong("scheduledFor") ?: 0L
            val firedAt = if (entry != null && entry.has("firedAt")) entry.optLong("firedAt") else null
            mapOf(
                "lane" to lane,
                "outcome" to outcomeFor(lane, firedAt, scheduledFor, now, cancelled, rebooted),
                "scheduledFor" to scheduledFor,
                "firedAt" to firedAt,
            )
        }

        val complete = lanes.none { it["outcome"] == "pending" }
        if (archiveIfComplete && complete) {
            TestStore.archiveCurrent(context)
        }

        return mapOf(
            "id" to run.optString("id"),
            "startedAt" to run.optLong("startedAt"),
            "windowSeconds" to run.optInt("windowSeconds"),
            "lanes" to lanes,
            "screenUnlockedDuringTest" to screenWokeDuringRun(run, now),
            "rebootedDuringTest" to rebooted,
        )
    }

    private fun outcomeFor(
        lane: String,
        firedAt: Long?,
        scheduledFor: Long,
        now: Long,
        cancelled: Boolean,
        rebooted: Boolean,
    ): String {
        if (firedAt != null) {
            val tolerance =
                if (lane == TestStore.LANE_WORK_MANAGER) WORK_TOLERANCE_MS else EXACT_TOLERANCE_MS
            return if (firedAt - scheduledFor <= tolerance) "firedOnTime" else "firedLate"
        }
        if (cancelled) return "cancelled"
        // Android drops pending alarms across a reboot, so an unfired alarm lane after a restart
        // says nothing about this phone's behaviour. Reporting it as "never arrived" would be a
        // false accusation; WorkManager persists across reboot and is still a valid reading.
        if (rebooted && lane != TestStore.LANE_WORK_MANAGER) return "cancelled"
        if (now < scheduledFor + NEVER_FIRED_GRACE_MS) return "pending"
        return "neverFired"
    }

    private fun detectReboot(run: JSONObject, now: Long): Boolean {
        if (run.optBoolean("rebootFlaggedByReceiver", false)) return true
        val startedAt = run.optLong("startedAt", 0L)
        val startedElapsed = run.optLong("startedElapsed", -1L)
        if (startedElapsed < 0 || startedAt <= 0) return false
        val elapsedNow = SystemClock.elapsedRealtime()
        // elapsedRealtime keeps counting through deep sleep and only resets on reboot, so it
        // running backwards — or lagging the wall clock — means the device was restarted. This
        // is the fallback for exactly the case that matters: autostart is off, so BootReceiver
        // never ran to flag it.
        if (elapsedNow < startedElapsed) return true
        val wallDelta = now - startedAt
        val elapsedDelta = elapsedNow - startedElapsed
        return wallDelta - elapsedDelta > 60_000L
    }

    /**
     * Doze only engages with the screen off, so a run the user interrupted by picking up the
     * phone is not a clean reading. Returns null when usage access is not granted — unknown is
     * reported as unknown, never as "no".
     */
    private fun screenWokeDuringRun(run: JSONObject, now: Long): Boolean? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return null
        if (!hasUsageAccess()) return null
        val startedAt = run.optLong("startedAt", 0L)
        if (startedAt <= 0) return null
        val end = minOf(now, run.optLong("endsAt", now))
        if (end <= startedAt) return null
        return try {
            val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return null
            val events = usm.queryEvents(startedAt, end)
            val event = UsageEvents.Event()
            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (event.eventType == UsageEvents.Event.SCREEN_INTERACTIVE) return true
            }
            false
        } catch (t: Throwable) {
            null
        }
    }

    private fun hasUsageAccess(): Boolean = try {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
        val mode = when {
            appOps == null -> AppOpsManager.MODE_ERRORED
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q ->
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    context.packageName,
                )
            else -> @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName,
            )
        }
        mode == AppOpsManager.MODE_ALLOWED
    } catch (t: Throwable) {
        false
    }
}
