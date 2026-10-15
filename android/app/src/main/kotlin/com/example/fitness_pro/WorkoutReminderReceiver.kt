package com.example.fitness_pro

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

object WorkoutReminders {
    private const val CHANNEL = "workout_reminders"
    private fun prefs(context: Context) = context.getSharedPreferences("workout_reminders", Context.MODE_PRIVATE)
    fun entries(context: Context) = JSONArray(prefs(context).getString("entries", "[]"))

    fun notificationsAllowed(context: Context): Boolean {
        val manager = context.getSystemService(NotificationManager::class.java)
        if (!manager.areNotificationsEnabled()) return false
        return Build.VERSION.SDK_INT < 26 || manager.getNotificationChannel(CHANNEL)?.importance != NotificationManager.IMPORTANCE_NONE
    }

    private fun alarmIntent(context: Context, id: Int): PendingIntent = PendingIntent.getBroadcast(
        context, id, Intent(context, WorkoutReminderReceiver::class.java).putExtra("reminder_id", id),
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

    fun sync(context: Context, updated: JSONArray) {
        val alarms = context.getSystemService(AlarmManager::class.java)
        val notifications = context.getSystemService(NotificationManager::class.java)
        val old = entries(context)
        if (!prefs(context).edit().putString("entries", updated.toString()).commit()) error("Could not store reminders")
        for (i in 0 until old.length()) {
            val id = old.getJSONObject(i).getInt("id")
            alarms.cancel(alarmIntent(context, id))
            notifications.cancel(id)
        }
        for (i in 0 until updated.length()) schedule(context, updated.getJSONObject(i))
    }

    fun schedule(context: Context, reminder: JSONObject) {
        if (!reminder.getBoolean("enabled")) return
        val now = System.currentTimeMillis()
        val days = reminder.getJSONArray("days")
        for (offset in 0..7) {
            val next = Calendar.getInstance().apply {
                add(Calendar.DATE, offset)
                set(Calendar.HOUR_OF_DAY, reminder.getInt("hour"))
                set(Calendar.MINUTE, reminder.getInt("minute"))
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            val allowed = (0 until days.length()).any { days.getInt(it) == next.get(Calendar.DAY_OF_WEEK) }
            if (allowed && next.timeInMillis > now) {
                context.getSystemService(AlarmManager::class.java).setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, next.timeInMillis, alarmIntent(context, reminder.getInt("id")))
                return
            }
        }
    }

    fun notify(context: Context, reminder: JSONObject) {
        if (!notificationsAllowed(context)) return
        val manager = context.getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26) {
            manager.createNotificationChannel(NotificationChannel(CHANNEL, "Workout reminders", NotificationManager.IMPORTANCE_DEFAULT))
        }
        val openApp = PendingIntent.getActivity(context, reminder.getInt("id"),
            Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(context, CHANNEL) else Notification.Builder(context)
        val notification = builder.setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("Time for your workout")
            .setContentText("Keep your routine going. Your next workout is ready.")
            .setContentIntent(openApp).setAutoCancel(true).build()
        try { manager.notify(reminder.getInt("id"), notification) } catch (_: SecurityException) { }
    }
}

class WorkoutReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val entries = WorkoutReminders.entries(context)
        if (intent.action != null) {
            for (i in 0 until entries.length()) WorkoutReminders.schedule(context, entries.getJSONObject(i))
            return
        }
        val id = intent.getIntExtra("reminder_id", -1)
        for (i in 0 until entries.length()) {
            val reminder = entries.getJSONObject(i)
            if (reminder.getInt("id") == id && reminder.getBoolean("enabled")) {
                WorkoutReminders.notify(context, reminder)
                WorkoutReminders.schedule(context, reminder)
                return
            }
        }
    }
}
