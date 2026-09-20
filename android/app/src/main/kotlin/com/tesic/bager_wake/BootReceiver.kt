package com.tesic.bager_wake

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * The reboot probe. No public API exposes whether an OEM's autostart permission is on, so this
 * infers it: if the user reboots while the probe is armed and this receiver never runs, the
 * system never let the app start at boot.
 *
 * It deliberately does NOT reschedule a test that was in flight. Android clears alarms across a
 * reboot, so silently re-arming them would hide the fact that the run was interrupted and make
 * a broken reading look like a clean one.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != Intent.ACTION_LOCKED_BOOT_COMPLETED
        ) {
            return
        }
        val app = context.applicationContext
        TestStore.recordBoot(app)
        TestStore.flagRebootDuringRun(app)
    }
}
