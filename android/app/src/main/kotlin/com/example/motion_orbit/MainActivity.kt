package com.example.motion_orbit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val storageExecutor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "motion_orbit/local_profile")
            .setMethodCallHandler { call, result ->
                if (call.method !in listOf("read", "write", "recover")) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                storageExecutor.execute {
                    try {
                        val preferences = getSharedPreferences("motion_orbit_profile", MODE_PRIVATE)
                        val response: String? = when (call.method) {
                            "read" -> preferences.getString("state", null)
                            "write" -> {
                                val state = call.arguments as? String
                                    ?: throw IllegalArgumentException("Missing profile state")
                                val previous = preferences.getString("state", null)
                                if (!preferences.edit().putString("state", state).commit()) {
                                    // commit updates the in-memory map even when disk writing fails.
                                    // Restore it so a retry cannot read an unsaved completion flag.
                                    preferences.edit().putString("state", previous).commit()
                                    throw IllegalStateException("Profile could not be saved")
                                }
                                null
                            }
                            else -> {
                                val previous = preferences.getString("state", null)
                                val editor = preferences.edit()
                                if (previous != null) {
                                    editor.putString("unreadable_${System.currentTimeMillis()}", previous)
                                }
                                if (!editor.remove("state").commit()) {
                                    preferences.edit().putString("state", previous).commit()
                                    throw IllegalStateException("Setup could not be restarted")
                                }
                                null
                            }
                        }
                        runOnUiThread { result.success(response) }
                    } catch (error: Exception) {
                        runOnUiThread { result.error("LOCAL_STORAGE", "Local profile storage failed", null) }
                    }
                }
            }
    }

    override fun onDestroy() {
        storageExecutor.shutdown()
        super.onDestroy()
    }
}
