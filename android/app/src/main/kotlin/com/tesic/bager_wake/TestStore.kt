package com.tesic.bager_wake

import android.content.Context
import android.os.SystemClock
import org.json.JSONArray
import org.json.JSONObject

/**
 * Persistence for delivery-test runs, owned entirely by the native side.
 *
 * It deliberately does not go through the Flutter shared_preferences plugin: the lanes fire
 * when the Flutter engine is usually dead — that is the exact condition under test — so a
 * receiver has to be able to record a fire time with nothing but a Context.
 */
object TestStore {
    private const val PREFS = "bager_wake_test_engine"
    private const val KEY_CURRENT = "current_run"
    private const val KEY_HISTORY = "history"
    private const val KEY_REBOOT_PROBE = "reboot_probe"
    private const val HISTORY_LIMIT = 30

    const val LANE_ALARM_CLOCK = "alarmClock"
    const val LANE_EXACT_IDLE = "exactIdle"
    const val LANE_WORK_MANAGER = "workManager"

    val ALL_LANES = listOf(LANE_ALARM_CLOCK, LANE_EXACT_IDLE, LANE_WORK_MANAGER)

    private val lock = Any()

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun currentRun(context: Context): JSONObject? = synchronized(lock) {
        val raw = prefs(context).getString(KEY_CURRENT, null) ?: return null
        return try {
            JSONObject(raw)
        } catch (t: Throwable) {
            null
        }
    }

    /**
     * [laneSchedules] carries a separate trigger time per lane. They are deliberately staggered
     * rather than simultaneous — see the scheduling comment in TestEnginePlugin.
     */
    fun startRun(
        context: Context,
        id: String,
        windowSeconds: Int,
        laneSchedules: Map<String, Long>,
    ): JSONObject = synchronized(lock) {
        val run = JSONObject().apply {
            put("id", id)
            put("startedAt", System.currentTimeMillis())
            // elapsedRealtime survives deep sleep but resets on reboot, so comparing its delta
            // against the wall-clock delta is how a reboot mid-run is detected even when the
            // boot receiver never runs (which is itself the autostart signal we're after).
            put("startedElapsed", SystemClock.elapsedRealtime())
            put("windowSeconds", windowSeconds)
            put("endsAt", laneSchedules.values.maxOrNull() ?: System.currentTimeMillis())
            put("cancelled", false)
            put("rebootFlaggedByReceiver", false)
            put("lanes", JSONObject().apply {
                ALL_LANES.forEach { lane ->
                    put(lane, JSONObject().put("scheduledFor", laneSchedules[lane] ?: 0L))
                }
            })
        }
        prefs(context).edit().putString(KEY_CURRENT, run.toString()).commit()
        run
    }

    /**
     * Called from a receiver or worker the moment a lane fires. Uses commit(), not apply():
     * the process is frequently killed immediately afterwards, and an async write would be lost.
     */
    fun recordLaneFired(context: Context, lane: String) {
        synchronized(lock) {
            val run = currentRun(context) ?: return
            val lanes = run.optJSONObject("lanes") ?: return
            val entry = lanes.optJSONObject(lane) ?: JSONObject()
            if (entry.has("firedAt")) return
            entry.put("firedAt", System.currentTimeMillis())
            entry.put("firedElapsed", SystemClock.elapsedRealtime())
            lanes.put(lane, entry)
            run.put("lanes", lanes)
            prefs(context).edit().putString(KEY_CURRENT, run.toString()).commit()
        }
    }

    fun flagRebootDuringRun(context: Context) {
        synchronized(lock) {
            val run = currentRun(context) ?: return
            run.put("rebootFlaggedByReceiver", true)
            prefs(context).edit().putString(KEY_CURRENT, run.toString()).commit()
        }
    }

    fun markCancelled(context: Context) {
        synchronized(lock) {
            val run = currentRun(context) ?: return
            run.put("cancelled", true)
            prefs(context).edit().putString(KEY_CURRENT, run.toString()).commit()
        }
    }

    /** Moves the current run into history. Safe to call when there is nothing in flight. */
    fun archiveCurrent(context: Context) {
        synchronized(lock) {
            val run = currentRun(context) ?: return
            val history = historyArray(context)
            history.put(run)
            val trimmed = if (history.length() > HISTORY_LIMIT) {
                JSONArray().also { out ->
                    for (i in history.length() - HISTORY_LIMIT until history.length()) {
                        out.put(history.get(i))
                    }
                }
            } else {
                history
            }
            prefs(context).edit()
                .putString(KEY_HISTORY, trimmed.toString())
                .remove(KEY_CURRENT)
                .commit()
        }
    }

    fun historyArray(context: Context): JSONArray = synchronized(lock) {
        val raw = prefs(context).getString(KEY_HISTORY, null) ?: return JSONArray()
        return try {
            JSONArray(raw)
        } catch (t: Throwable) {
            JSONArray()
        }
    }

    fun armRebootProbe(context: Context) {
        synchronized(lock) {
            val probe = JSONObject().put("armedAt", System.currentTimeMillis())
            prefs(context).edit().putString(KEY_REBOOT_PROBE, probe.toString()).commit()
        }
    }

    fun recordBoot(context: Context) {
        synchronized(lock) {
            val raw = prefs(context).getString(KEY_REBOOT_PROBE, null) ?: return
            val probe = try {
                JSONObject(raw)
            } catch (t: Throwable) {
                return
            }
            if (probe.has("bootReceivedAt")) return
            probe.put("bootReceivedAt", System.currentTimeMillis())
            prefs(context).edit().putString(KEY_REBOOT_PROBE, probe.toString()).commit()
        }
    }

    fun rebootProbe(context: Context): JSONObject? = synchronized(lock) {
        val raw = prefs(context).getString(KEY_REBOOT_PROBE, null) ?: return null
        return try {
            JSONObject(raw)
        } catch (t: Throwable) {
            null
        }
    }
}
