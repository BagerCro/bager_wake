package com.tesic.bager_wake

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        DiagnosticsPlugin.register(flutterEngine, this)
        IntentLauncherPlugin.register(flutterEngine, this)
        TestEnginePlugin.register(flutterEngine, this)
        BulkFixPlugin.register(flutterEngine, this)
    }
}
