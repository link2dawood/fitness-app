package com.example.fitness_pro

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class MainActivity : FlutterActivity() {
    private var deviceTts: DeviceTts? = null
    private var permissionResult: MethodChannel.Result? = null
    private var pendingReminders: JSONArray? = null

    private fun saveReminders(entries: JSONArray, result: MethodChannel.Result) {
        try {
            WorkoutReminders.sync(this, entries)
            result.success(null)
        } catch (error: Exception) {
            result.error("schedule_failed", error.message, null)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        deviceTts?.close()
        deviceTts = DeviceTts(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fitness_pro/tts")
            .setMethodCallHandler(deviceTts)
        val restored = WorkoutReminders.entries(this)
        for (i in 0 until restored.length()) WorkoutReminders.schedule(this, restored.getJSONObject(i))
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fitness_pro/general_settings")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "keepScreenOn" -> {
                        if (call.arguments == true) window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        else window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        result.success(null)
                    }
                    "syncReminders" -> {
                        val input = call.arguments as? List<*>
                        if (input == null) {
                            result.error("invalid_reminders", "Invalid reminder list", null)
                        } else {
                            try {
                                val entries = JSONArray(input)
                                var requiresPermission = false
                                val previous = WorkoutReminders.entries(this)
                                for (i in 0 until entries.length()) {
                                    val item = entries.getJSONObject(i)
                                    require(item.getInt("id") > 0 && item.getInt("hour") in 0..23 && item.getInt("minute") in 0..59)
                                    val days = item.getJSONArray("days")
                                    require(days.length() in 1..7)
                                    for (day in 0 until days.length()) require(days.getInt(day) in 1..7)
                                    val sameEnabledReminder = (0 until previous.length()).any { index ->
                                        val old = previous.getJSONObject(index)
                                        old.getInt("id") == item.getInt("id") && old.getBoolean("enabled") &&
                                            old.getInt("hour") == item.getInt("hour") && old.getInt("minute") == item.getInt("minute") &&
                                            old.getJSONArray("days").toString() == days.toString()
                                    }
                                    requiresPermission = requiresPermission || (item.getBoolean("enabled") && !sameEnabledReminder)
                                }
                                if (requiresPermission && Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                                    if (permissionResult != null) {
                                        result.error("busy", "Notification permission is already being requested", null)
                                    } else {
                                        permissionResult = result
                                        pendingReminders = entries
                                        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 8124)
                                    }
                                } else if (requiresPermission && !WorkoutReminders.notificationsAllowed(this)) {
                                    result.error("notifications_denied", "Allow workout notifications in Android settings", null)
                                } else {
                                    saveReminders(entries, result)
                                }
                            } catch (error: Exception) {
                                result.error("invalid_reminders", error.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != 8124) return
        val result = permissionResult ?: return
        val entries = pendingReminders
        permissionResult = null
        pendingReminders = null
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED && entries != null && WorkoutReminders.notificationsAllowed(this)) {
            saveReminders(entries, result)
        } else {
            result.error("notifications_denied", "Notification permission was denied", null)
        }
    }

    override fun onDestroy() {
        deviceTts?.close()
        deviceTts = null
        super.onDestroy()
    }
}
