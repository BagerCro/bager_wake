package com.tesic.bager_wake

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Launches OEM settings screens (autostart managers, per-app battery whitelists, ...) for
 * `assets/oem_profiles.json`.
 *
 * There is no public API to ask "is autostart enabled for this app" on MIUI, One UI, etc.,
 * so this plugin only ever gets the user to the right screen — it never reports the result
 * of what happens there. Each `FixStep` carries an ordered chain of [IntentCandidate]s;
 * [launchIntent] tries one at a time and returns false when a candidate can't be launched,
 * which is the signal the Dart side (`OemProfileService.launchStep`) uses to move on to the
 * next one in the chain.
 */
object IntentLauncherPlugin {
    private const val CHANNEL = "com.tesic.bager_wake/intents"

    fun register(flutterEngine: FlutterEngine, activity: Activity) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(Handler(activity))
    }

    private class Handler(private val activity: Activity) : MethodChannel.MethodCallHandler {
        override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
            if (call.method != "launchIntent") {
                result.notImplemented()
                return
            }
            val action = call.argument<String>("action")
            val pkg = call.argument<String>("package")
            val component = call.argument<String>("component")
            val usesPackageData = call.argument<Boolean>("usesPackageData") ?: false

            result.success(launch(action, pkg, component, usesPackageData))
        }

        private fun launch(
            action: String?,
            pkg: String?,
            component: String?,
            usesPackageData: Boolean,
        ): Boolean {
            val intent = buildIntent(action, pkg, component, usesPackageData) ?: return false
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

            // On API 30+ (package visibility) resolveActivity silently returns null for any
            // package not declared in the manifest's <queries> block, same as if it weren't
            // installed. Checking here — not just catching failures below — is what lets a
            // dead candidate fall through to the next one in the chain instead of us finding
            // out only when startActivity throws.
            if (!resolves(intent)) return false

            return try {
                activity.startActivity(intent)
                true
            } catch (e: ActivityNotFoundException) {
                false
            } catch (e: SecurityException) {
                // A number of OEM settings activities (MIUI, ColorOS, ...) resolve fine but are
                // declared android:exported="false", so they only fail once we try to start
                // them. Treating that the same as "not found" is the whole point of the chain.
                false
            }
        }

        private fun buildIntent(
            action: String?,
            pkg: String?,
            component: String?,
            usesPackageData: Boolean,
        ): Intent? {
            val intent = when {
                pkg != null && component != null ->
                    Intent().apply { setComponent(ComponentName(pkg, component)) }
                action != null ->
                    Intent(action).apply { if (pkg != null) setPackage(pkg) }
                // No action or component name we trust for this brand: fall back to opening
                // the OEM's own app (e.g. Transsion's Phone Manager) so the user can hunt for
                // the right toggle by hand instead of getting a dead button.
                pkg != null -> activity.packageManager.getLaunchIntentForPackage(pkg)
                else -> null
            } ?: return null

            if (usesPackageData) {
                intent.data = Uri.parse("package:${activity.packageName}")
            }
            return intent
        }

        private fun resolves(intent: Intent): Boolean {
            val pm = activity.packageManager
            val resolveInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.resolveActivity(intent, PackageManager.ResolveInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.resolveActivity(intent, 0)
            }
            return resolveInfo != null
        }
    }
}
