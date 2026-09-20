package com.tesic.bager_wake

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Reads other apps' real battery-optimization exemption state and opens Settings for the user to
 * change it by hand - a normal app cannot grant that exemption to another app itself. Every
 * reading is either a real value from PowerManager/PackageManager or an honest null/failure, never
 * a guess.
 */
class BulkFixPlugin private constructor(
    private val context: Context,
) : MethodChannel.MethodCallHandler {

    private val ioExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    companion object {
        private const val CHANNEL_NAME = "com.tesic.bager_wake/bulk_fix"

        // Developer's own other apps - not third-party apps a user would want to bulk-fix here.
        private val EXCLUDED_PACKAGES = setOf(
            "com.tesic.bager_guard",
            "com.tesic.phone_boost",
        )

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val plugin = BulkFixPlugin(activity.applicationContext)
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
                .setMethodCallHandler(plugin)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "listInstalledApps" -> listInstalledApps(result)
            "isIgnoringBatteryOptimizations" -> isIgnoringBatteryOptimizations(call, result)
            "isIgnoringBatteryOptimizationsBatch" -> isIgnoringBatteryOptimizationsBatch(call, result)
            "openAppDetailsFor" -> openAppDetailsFor(call, result)
            else -> result.notImplemented()
        }
    }

    private fun listInstalledApps(result: MethodChannel.Result) {
        ioExecutor.execute {
            val response = try {
                val pm = context.packageManager
                val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
                val resolveInfos: List<ResolveInfo> = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0L))
                } else {
                    @Suppress("DEPRECATION")
                    pm.queryIntentActivities(intent, 0)
                }

                val seen = LinkedHashSet<String>()
                val apps = mutableListOf<Map<String, Any?>>()
                for (info in resolveInfos) {
                    val pkg = info.activityInfo?.packageName ?: continue
                    if (pkg == context.packageName) continue
                    if (pkg in EXCLUDED_PACKAGES) continue
                    if (!seen.add(pkg)) continue
                    val label = try {
                        info.loadLabel(pm).toString()
                    } catch (t: Throwable) {
                        pkg
                    }
                    apps.add(mapOf("package" to pkg, "label" to label))
                }
                val sorted = apps.sortedBy { (it["label"] as? String)?.lowercase() ?: "" }
                mapOf("apps" to sorted, "ok" to true)
            } catch (t: Throwable) {
                mapOf("apps" to emptyList<Map<String, Any?>>(), "ok" to false)
            }
            mainHandler.post { result.success(response) }
        }
    }

    private fun isIgnoringBatteryOptimizations(call: MethodCall, result: MethodChannel.Result) {
        val pkg = call.argument<String>("package")
        if (pkg == null) {
            result.error("missing_argument", "package is required", null)
            return
        }
        ioExecutor.execute {
            val value = readIgnoringBatteryOptimizations(pkg)
            mainHandler.post { result.success(value) }
        }
    }

    private fun isIgnoringBatteryOptimizationsBatch(call: MethodCall, result: MethodChannel.Result) {
        val packages = call.argument<List<String>>("packages")
        if (packages == null) {
            result.error("missing_argument", "packages is required", null)
            return
        }
        ioExecutor.execute {
            val map = LinkedHashMap<String, Boolean?>()
            for (pkg in packages) {
                map[pkg] = readIgnoringBatteryOptimizations(pkg)
            }
            mainHandler.post { result.success(map) }
        }
    }

    // Isolated per-package so one malformed/uninstalled package can't null out the whole batch.
    private fun readIgnoringBatteryOptimizations(pkg: String): Boolean? = try {
        val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        pm?.isIgnoringBatteryOptimizations(pkg)
    } catch (t: Throwable) {
        null
    }

    private fun openAppDetailsFor(call: MethodCall, result: MethodChannel.Result) {
        val pkg = call.argument<String>("package")
        if (pkg == null) {
            result.error("missing_argument", "package is required", null)
            return
        }
        ioExecutor.execute {
            val candidates = listOfNotNull(
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$pkg")),
                Intent(Settings.ACTION_SETTINGS),
            )
            val launched = tryStartAny(candidates)
            mainHandler.post { result.success(launched) }
        }
    }

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
}
