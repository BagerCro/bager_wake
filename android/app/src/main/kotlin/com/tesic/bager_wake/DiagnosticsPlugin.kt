package com.tesic.bager_wake

import android.Manifest
import android.app.Activity
import android.app.ActivityManager
import android.app.AlarmManager
import android.app.AppOpsManager
import android.app.NotificationManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Every reading here either comes from a platform API call that actually succeeded, or the
 * item comes back [Status.UNAVAILABLE] with a reason. Nothing is guessed.
 */
class DiagnosticsPlugin private constructor(
    private val context: Context,
    private val activity: Activity,
) : MethodChannel.MethodCallHandler {

    private val ioExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val CHANNEL_NAME = "com.tesic.bager_wake/diagnostics"
        private const val NOTIF_PERMISSION_REQUEST_CODE = 4771

        private val ALL_IDS = listOf(
            "battery_optimization",
            "notifications_enabled",
            "exact_alarm_permission",
            "background_restricted",
            "standby_bucket",
            "data_saver",
            "power_save_mode",
            "doze_state",
        )

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val plugin = DiagnosticsPlugin(activity.applicationContext, activity)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                .setMethodCallHandler(plugin)
        }
    }

    private object Status {
        const val OK = "ok"
        const val WARNING = "warning"
        const val PROBLEM = "problem"
        const val UNAVAILABLE = "unavailable"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "readAll" -> readAll(result)
            "deviceInfo" -> deviceInfo(result)
            "openSettings" -> openSettings(call, result)
            "requestNotificationPermission" -> requestNotificationPermission(result)
            else -> result.notImplemented()
        }
    }

    // getAppStandbyBucket() and friends can block on a binder call to system_server; never run
    // this on the platform thread.
    private fun readAll(result: MethodChannel.Result) {
        ioExecutor.execute {
            val items = ALL_IDS.map { id ->
                try {
                    readOne(id)
                } catch (t: Throwable) {
                    unavailable(id, "unexpected error: ${t.message ?: t.javaClass.simpleName}", true)
                }
            }
            mainHandler.post { result.success(items) }
        }
    }

    private fun readOne(id: String): Map<String, Any?> = when (id) {
        "battery_optimization" -> checkBatteryOptimization()
        "notifications_enabled" -> checkNotifications()
        "exact_alarm_permission" -> checkExactAlarms()
        "background_restricted" -> checkBackgroundRestricted()
        "standby_bucket" -> checkStandbyBucket()
        "data_saver" -> checkDataSaver()
        "power_save_mode" -> checkPowerSaveMode()
        "doze_state" -> checkDozeState()
        else -> unavailable(id, "unknown diagnostic id", false)
    }

    private fun checkBatteryOptimization(): Map<String, Any?> {
        val id = "battery_optimization"
        return try {
            val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
                ?: return unavailable(id, "PowerManager is not available on this device", true)
            // Some OEMs (notably Honor) answer this differently depending on whether the app is
            // in the foreground. We don't try to correct for that — just report what was read.
            val exempt = pm.isIgnoringBatteryOptimizations(context.packageName)
            result(
                id,
                if (exempt) Status.OK else Status.PROBLEM,
                if (exempt) "exempt from battery optimization" else "not exempt from battery optimization",
                null,
                true,
            )
        } catch (t: Throwable) {
            unavailable(id, "could not read battery optimization state: ${t.message ?: t.javaClass.simpleName}", true)
        }
    }

    private fun checkNotifications(): Map<String, Any?> {
        val id = "notifications_enabled"
        return try {
            if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) {
                return result(id, Status.PROBLEM, "notifications disabled at the app level", null, true)
            }
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
                return result(id, Status.OK, "enabled (channel importance doesn't apply before Android 8)", null, true)
            }
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                ?: return unavailable(id, "NotificationManager is not available on this device", true)
            val channels = nm.notificationChannels
            if (channels.isNullOrEmpty()) {
                // Legitimate gap, not a bug: our channel is created by the delivery-test engine,
                // which may never have run yet.
                return unavailable(id, "no notification channel exists yet - run a delivery test first", true)
            }
            val blocked = channels.any { it.importance == NotificationManager.IMPORTANCE_NONE }
            if (blocked) {
                result(id, Status.PROBLEM, "notification channel is blocked (importance: none)", null, true)
            } else {
                val worst = channels.minByOrNull { it.importance }
                result(id, Status.OK, "enabled, channel importance: ${importanceName(worst?.importance)}", null, true)
            }
        } catch (t: Throwable) {
            unavailable(id, "could not read notification state: ${t.message ?: t.javaClass.simpleName}", true)
        }
    }

    private fun checkExactAlarms(): Map<String, Any?> {
        val id = "exact_alarm_permission"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return result(id, Status.OK, "exact alarms are always allowed below Android 12 (API 31)", null, false)
        }
        return try {
            val am = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
                ?: return unavailable(id, "AlarmManager is not available on this device", true)
            val can = am.canScheduleExactAlarms()
            result(
                id,
                if (can) Status.OK else Status.PROBLEM,
                if (can) "exact alarms allowed" else "exact alarms blocked",
                null,
                true,
            )
        } catch (t: Throwable) {
            unavailable(id, "could not read exact alarm permission: ${t.message ?: t.javaClass.simpleName}", true)
        }
    }

    private fun checkBackgroundRestricted(): Map<String, Any?> {
        val id = "background_restricted"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            return unavailable(id, "needs Android 9 (API 28) or newer", false)
        }
        return try {
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as? ActivityManager
                ?: return unavailable(id, "ActivityManager is not available on this device", true)
            val restricted = am.isBackgroundRestricted
            result(
                id,
                if (restricted) Status.PROBLEM else Status.OK,
                if (restricted) "background activity is restricted" else "background activity is not restricted",
                null,
                true,
            )
        } catch (t: Throwable) {
            unavailable(id, "could not read background restriction state: ${t.message ?: t.javaClass.simpleName}", true)
        }
    }

    private fun checkStandbyBucket(): Map<String, Any?> {
        val id = "standby_bucket"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            return unavailable(id, "needs Android 9 (API 28) or newer", false)
        }
        return try {
            val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
                ?: return unavailable(id, "AppOpsManager is not available on this device", true)
            val uid = Process.myUid()
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, uid, context.packageName)
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, uid, context.packageName)
            }
            // Without this special permission, getAppStandbyBucket() either throws or hands back
            // a value that doesn't mean anything - so verify the op first rather than guess.
            if (mode != AppOpsManager.MODE_ALLOWED) {
                return unavailable(id, "grant \"Usage access\" for this app in system settings to read this", true)
            }
            val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
                ?: return unavailable(id, "UsageStatsManager is not available on this device", true)
            val bucket = usm.appStandbyBucket
            val name = standbyBucketName(bucket)
            val status = when {
                bucket >= UsageStatsManager.STANDBY_BUCKET_RARE -> Status.PROBLEM
                bucket >= UsageStatsManager.STANDBY_BUCKET_FREQUENT -> Status.WARNING
                else -> Status.OK
            }
            result(id, status, name, null, true)
        } catch (t: Throwable) {
            unavailable(id, "could not read standby bucket: ${t.message ?: t.javaClass.simpleName}", true)
        }
    }

    private fun checkDataSaver(): Map<String, Any?> {
        val id = "data_saver"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            return unavailable(id, "needs Android 7 (API 24) or newer", false)
        }
        return try {
            val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
                ?: return unavailable(id, "ConnectivityManager is not available on this device", true)
            when (cm.restrictBackgroundStatus) {
                ConnectivityManager.RESTRICT_BACKGROUND_STATUS_ENABLED ->
                    result(id, Status.WARNING, "data saver on, background data restricted", null, true)
                ConnectivityManager.RESTRICT_BACKGROUND_STATUS_WHITELISTED ->
                    result(id, Status.OK, "data saver on, this app is whitelisted", null, true)
                ConnectivityManager.RESTRICT_BACKGROUND_STATUS_DISABLED ->
                    result(id, Status.OK, "data saver off", null, true)
                else -> unavailable(id, "device returned an unrecognized data saver status", true)
            }
        } catch (t: Throwable) {
            unavailable(id, "could not read data saver state: ${t.message ?: t.javaClass.simpleName}", true)
        }
    }

    private fun checkPowerSaveMode(): Map<String, Any?> {
        val id = "power_save_mode"
        return try {
            val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
                ?: return unavailable(id, "PowerManager is not available on this device", true)
            val on = pm.isPowerSaveMode
            result(
                id,
                if (on) Status.WARNING else Status.OK,
                if (on) "battery saver is on" else "battery saver is off",
                null,
                true,
            )
        } catch (t: Throwable) {
            unavailable(id, "could not read power save mode: ${t.message ?: t.javaClass.simpleName}", true)
        }
    }

    private fun checkDozeState(): Map<String, Any?> {
        val id = "doze_state"
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return unavailable(id, "needs Android 6 (API 23) or newer", false)
        }
        return try {
            val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
                ?: return unavailable(id, "PowerManager is not available on this device", true)
            // Doze only actually engages with the screen off and the device stationary, so this
            // is almost always false while someone is looking at the app - it's a snapshot, not
            // a history of whether doze has been hitting the device.
            val idle = pm.isDeviceIdleMode
            val raw = if (idle) {
                "idle right now (snapshot)"
            } else {
                "not idle right now (snapshot - doze only engages with the screen off)"
            }
            result(id, if (idle) Status.WARNING else Status.OK, raw, null, true)
        } catch (t: Throwable) {
            unavailable(id, "could not read doze state: ${t.message ?: t.javaClass.simpleName}", true)
        }
    }

    private fun importanceName(importance: Int?): String = when (importance) {
        NotificationManager.IMPORTANCE_NONE -> "none"
        NotificationManager.IMPORTANCE_MIN -> "min"
        NotificationManager.IMPORTANCE_LOW -> "low"
        NotificationManager.IMPORTANCE_DEFAULT -> "default"
        NotificationManager.IMPORTANCE_HIGH -> "high"
        NotificationManager.IMPORTANCE_MAX -> "max"
        else -> "unspecified"
    }

    private fun standbyBucketName(bucket: Int): String = when (bucket) {
        UsageStatsManager.STANDBY_BUCKET_ACTIVE -> "ACTIVE"
        UsageStatsManager.STANDBY_BUCKET_WORKING_SET -> "WORKING_SET"
        UsageStatsManager.STANDBY_BUCKET_FREQUENT -> "FREQUENT"
        UsageStatsManager.STANDBY_BUCKET_RARE -> "RARE"
        UsageStatsManager.STANDBY_BUCKET_RESTRICTED -> "RESTRICTED"
        else -> "UNKNOWN($bucket)"
    }

    private fun result(
        id: String,
        status: String,
        rawValue: String?,
        unavailableReason: String?,
        hasSettingsShortcut: Boolean,
    ): Map<String, Any?> = mapOf(
        "id" to id,
        "status" to status,
        "rawValue" to rawValue,
        "unavailableReason" to unavailableReason,
        "hasSettingsShortcut" to hasSettingsShortcut,
    )

    private fun unavailable(id: String, reason: String, hasSettingsShortcut: Boolean): Map<String, Any?> =
        result(id, Status.UNAVAILABLE, null, reason, hasSettingsShortcut)

    private fun deviceInfo(result: MethodChannel.Result) {
        result.success(
            mapOf(
                "manufacturer" to Build.MANUFACTURER,
                "brand" to Build.BRAND,
                "model" to Build.MODEL,
                "androidRelease" to Build.VERSION.RELEASE,
                "sdkInt" to Build.VERSION.SDK_INT,
            ),
        )
    }

    private fun openSettings(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id")
        if (id == null) {
            result.success(false)
            return
        }
        val candidates = listOfNotNull(primaryIntentFor(id), appDetailsIntent(), Intent(Settings.ACTION_SETTINGS))
        result.success(tryStartAny(candidates))
    }

    private fun primaryIntentFor(id: String): Intent? = when (id) {
        "battery_optimization" ->
            // Deliberately the list screen, not ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS -
            // that one needs a Play-restricted permission we don't declare.
            Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
        "notifications_enabled" ->
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                .putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
        "exact_alarm_permission" ->
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:${context.packageName}"))
            } else {
                null
            }
        "standby_bucket" -> Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        "background_restricted" -> appDetailsIntent()
        "data_saver" ->
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                Intent(Settings.ACTION_IGNORE_BACKGROUND_DATA_RESTRICTIONS_SETTINGS)
            } else {
                null
            }
        "power_save_mode", "doze_state" -> Intent(Intent.ACTION_POWER_USAGE_SUMMARY)
        else -> null
    }

    private fun appDetailsIntent(): Intent =
        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${context.packageName}"))

    private fun tryStartAny(candidates: List<Intent>): Boolean {
        for (intent in candidates) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            try {
                if (intent.resolveActivity(context.packageManager) != null) {
                    context.startActivity(intent)
                    return true
                }
            } catch (t: Throwable) {
                // try the next fallback
            }
        }
        return false
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(NotificationManagerCompat.from(context).areNotificationsEnabled())
            return
        }
        val granted = ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        if (granted) {
            result.success(true)
            return
        }
        try {
            // This plugin is attached outside the normal ActivityAware/plugin-binding flow (see
            // MainActivity), so there's no ActivityPluginBinding to receive the async
            // onRequestPermissionsResult callback. Fire the system prompt so the user can grant
            // it, and report the pre-prompt state without blocking - the dashboard re-reads via
            // readAll() the next time it's shown and picks up whatever the user chose.
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                NOTIF_PERMISSION_REQUEST_CODE,
            )
        } catch (t: Throwable) {
            // Nothing more we can do; fall through and report the current (ungranted) state.
        }
        result.success(false)
    }
}
