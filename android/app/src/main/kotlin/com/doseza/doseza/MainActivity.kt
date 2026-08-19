package com.doseza.doseza

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.doseza.doseza/alarm"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val recordId = call.argument<String>("recordId") ?: return@setMethodCallHandler
                    val medicineName = call.argument<String>("medicineName") ?: "Medicine"
                    val dosage = call.argument<Double>("dosage") ?: 0.0
                    val dosageUnit = call.argument<String>("dosageUnit") ?: "mg"
                    val mealRelation = call.argument<String>("mealRelation") ?: "Before meal"
                    val scheduledAt = call.argument<Long>("scheduledAt") ?: 0L

                    scheduleNativeAlarm(
                        recordId, medicineName, dosage, dosageUnit, mealRelation, scheduledAt
                    )
                    result.success(true)
                }
                "cancelAlarm" -> {
                    val recordId = call.argument<String>("recordId") ?: return@setMethodCallHandler
                    cancelNativeAlarm(recordId)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleNativeAlarm(
        recordId: String,
        medicineName: String,
        dosage: Double,
        dosageUnit: String,
        mealRelation: String,
        scheduledAt: Long
    ) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(this, AlarmReceiver::class.java).apply {
            action = AlarmReceiver.ACTION_ALARM_FIRE
            putExtra(AlarmReceiver.EXTRA_RECORD_ID, recordId)
            putExtra(AlarmReceiver.EXTRA_MEDICINE_NAME, medicineName)
            putExtra(AlarmReceiver.EXTRA_DOSAGE, dosage)
            putExtra(AlarmReceiver.EXTRA_DOSAGE_UNIT, dosageUnit)
            putExtra(AlarmReceiver.EXTRA_MEAL_RELATION, mealRelation)
        }

        val requestCode = recordId.hashCode()
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Use exact alarms for medication reminders
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                scheduledAt,
                pendingIntent
            )
        } else {
            alarmManager.setExact(
                AlarmManager.RTC_WAKEUP,
                scheduledAt,
                pendingIntent
            )
        }
    }

    private fun cancelNativeAlarm(recordId: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val intent = Intent(this, AlarmReceiver::class.java).apply {
            action = AlarmReceiver.ACTION_ALARM_FIRE
            putExtra(AlarmReceiver.EXTRA_RECORD_ID, recordId)
        }

        val requestCode = recordId.hashCode()
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
    }

    override fun onDestroy() {
        methodChannel?.setMethodCallHandler(null)
        super.onDestroy()
    }
}
