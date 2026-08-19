package com.doseza.doseza

import android.app.NotificationManager
import android.app.NotificationChannel
import android.app.PendingIntent
import android.app.AlarmManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.PowerManager
import androidx.core.app.NotificationCompat

class AlarmReceiver : BroadcastReceiver() {

    companion object {
        const val CHANNEL_ID = "doseza_medication_alarms"
        const val ACTION_ALARM_FIRE = "com.doseza.doseza.ALARM_FIRE"
        const val ACTION_SNOOZE = "com.doseza.doseza.SNOOZE"
        const val ACTION_DISMISS = "com.doseza.doseza.DISMISS"
        const val EXTRA_RECORD_ID = "record_id"
        const val EXTRA_MEDICINE_NAME = "medicine_name"
        const val EXTRA_DOSAGE = "dosage"
        const val EXTRA_DOSAGE_UNIT = "dosage_unit"
        const val EXTRA_MEAL_RELATION = "meal_relation"

        fun notificationIdFor(recordId: String): Int {
            return recordId.hashCode() and 0x7fffffff
        }
    }

    private var wakeLock: PowerManager.WakeLock? = null

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_ALARM_FIRE -> {
                val recordId = intent.getStringExtra(EXTRA_RECORD_ID) ?: return
                val medicineName = intent.getStringExtra(EXTRA_MEDICINE_NAME) ?: "Medicine"
                val dosage = intent.getDoubleExtra(EXTRA_DOSAGE, 0.0)
                val dosageUnit = intent.getStringExtra(EXTRA_DOSAGE_UNIT) ?: "mg"
                val mealRelation = intent.getStringExtra(EXTRA_MEAL_RELATION) ?: "Before meal"

                acquireWakeLock(context)
                createNotificationChannel(context)

                // Build the full-screen intent for AlarmActivity
                val fullScreenIntent = Intent(context, AlarmActivity::class.java).apply {
                    putExtra(EXTRA_RECORD_ID, recordId)
                    putExtra(EXTRA_MEDICINE_NAME, medicineName)
                    putExtra(EXTRA_DOSAGE, dosage)
                    putExtra(EXTRA_DOSAGE_UNIT, dosageUnit)
                    putExtra(EXTRA_MEAL_RELATION, mealRelation)
                    addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_NO_USER_ACTION
                    )
                }
                val fullScreenPendingIntent = PendingIntent.getActivity(
                    context,
                    recordId.hashCode(),
                    fullScreenIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                // Build a high-importance notification with fullScreenIntent
                val alarmSound = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                    .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                    .setContentTitle("Time to take $medicineName")
                    .setContentText("${dosage.toInt()} $dosageUnit • $mealRelation")
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .setCategory(NotificationCompat.CATEGORY_ALARM)
                    .setFullScreenIntent(fullScreenPendingIntent, true)
                    .setAutoCancel(false)
                    .setOngoing(true)
                    .setSound(alarmSound)
                    .setVibrate(longArrayOf(0, 500, 200, 500, 200, 500))
                    .setColor(Color.parseColor("#E85D75"))
                    .build()

                val notifId = notificationIdFor(recordId)
                val notificationManager =
                    context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.notify(notifId, notification)

                // Also try to start the activity directly as a fallback
                try {
                    context.startActivity(fullScreenIntent)
                } catch (_: Exception) {
                    // The notification fullScreenIntent will handle it
                }
            }

            ACTION_SNOOZE -> {
                val recordId = intent.getStringExtra(EXTRA_RECORD_ID) ?: return
                snoozeAlarm(context, recordId)
            }

            ACTION_DISMISS -> {
                val recordId = intent.getStringExtra(EXTRA_RECORD_ID) ?: return
                dismissAlarm(context, recordId)
            }
        }
    }

    private fun acquireWakeLock(context: Context) {
        val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or
            PowerManager.ACQUIRE_CAUSES_WAKEUP or
            PowerManager.ON_AFTER_RELEASE,
            "Doseza:AlarmWakeLock"
        )
        wakeLock?.acquire(10 * 60 * 1000L)
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Medication Alarms"
            val descriptionText = "Time-sensitive medication reminders"
            val channel = NotificationChannel(
                CHANNEL_ID, name, NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = descriptionText
                enableVibration(true)
                enableLights(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
                setSound(
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM),
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
            }
            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun snoozeAlarm(context: Context, recordId: String) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = ACTION_ALARM_FIRE
            putExtra(EXTRA_RECORD_ID, recordId)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, recordId.hashCode(), intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            System.currentTimeMillis() + 10 * 60 * 1000L,
            pendingIntent
        )

        val notifId = notificationIdFor(recordId)
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(notifId)
        releaseWakeLock()
    }

    private fun dismissAlarm(context: Context, recordId: String) {
        val notifId = notificationIdFor(recordId)
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(notifId)
        releaseWakeLock()
    }

    private fun releaseWakeLock() {
        wakeLock?.let { if (it.isHeld) it.release() }
    }
}
