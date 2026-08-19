import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'alarm_screen.dart';
import 'database_helper.dart';
import 'models.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AlarmService {
  AlarmService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const _medChannelId = 'doseza_medication_alarms';
  static const _medChannelName = 'Medication alarms';
  static const _refillChannelId = 'doseza_refill_reminders';
  static const _refillChannelName = 'Refill reminders';
  static const _appointmentChannelId = 'doseza_appointment_reminders';
  static const _appointmentChannelName = 'Appointment reminders';
  static const MethodChannel _channel = MethodChannel('com.doseza.doseza/alarm');

  static const _actionTakeNow = 'action_take_now';
  static const _actionSnooze = 'action_snooze';

  static String? _pendingAlarmPayload;

  // ==================== Initialisation ====================

  static Future<void> initialise() async {
    tz.initializeTimeZones();

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _medChannelId,
          _medChannelName,
          description: 'Time-sensitive medication reminders',
          importance: Importance.max,
          enableVibration: true,
          enableLights: true,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _refillChannelId,
          _refillChannelName,
          description: 'Low stock and refill reminders',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          playSound: true,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _appointmentChannelId,
          _appointmentChannelName,
          description: 'Upcoming doctor appointment reminders',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          playSound: true,
        ),
      );
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    final launch = await _notifications.getNotificationAppLaunchDetails();
    final payload = launch?.notificationResponse?.payload;
    if (launch != null && launch.didNotificationLaunchApp && payload != null) {
      _pendingAlarmPayload = payload;
    }

    _channel.setMethodCallHandler(_handleNativeMethod);
  }

  // ==================== Permissions ====================

  static Future<void> requestPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
    await android?.requestFullScreenIntentPermission();
  }

  // ==================== Native channel ====================

  static Future<dynamic> _handleNativeMethod(MethodCall call) async {
    switch (call.method) {
      case 'onAlarmDismissed':
        final recordId = call.arguments['recordId'] as String?;
        if (recordId != null) _handleTakeNowFromNative(recordId);
        break;
      case 'onAlarmSnoozed':
        final recordId = call.arguments['recordId'] as String?;
        if (recordId != null) _handleSnoozeFromNative(recordId);
        break;
    }
  }

  static void _handleTakeNowFromNative(String recordId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final record = await DatabaseHelper.instance.getDoseRecordById(recordId);
      if (record != null && record.status == 'scheduled') {
        record.status = 'taken';
        record.takenAt = DateTime.now();
        await DatabaseHelper.instance.updateDoseRecord(record);
        await cancel(recordId);
      }
    });
  }

  static void _handleSnoozeFromNative(String recordId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final record = await DatabaseHelper.instance.getDoseRecordById(recordId);
      if (record != null && record.status == 'scheduled') {
        record.snoozedUntil = DateTime.now().add(const Duration(minutes: 10));
        record.status = 'snoozed';
        await DatabaseHelper.instance.updateDoseRecord(record);
        await cancel(recordId);

        final snoozedDose = DoseRecord(
          id: '${record.id}_snooze_${DateTime.now().millisecondsSinceEpoch}',
          patientId: record.patientId,
          medicineId: record.medicineId,
          medicineName: record.medicineName,
          medicineType: record.medicineType,
          dosage: record.dosage,
          dosageUnit: record.dosageUnit,
          mealRelation: record.mealRelation,
          scheduledAt: record.snoozedUntil!,
          status: 'scheduled',
          notes: record.notes,
        );
        await DatabaseHelper.instance.addDoseRecord(snoozedDose);
        await schedule(snoozedDose);
      }
    });
  }

  // ==================== Notification response (actions) ====================

  static void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    if (response.notificationResponseType ==
        NotificationResponseType.selectedNotificationAction) {
      // Action button tapped (Take Now / Snooze)
      if (response.actionId == _actionTakeNow) {
        _handleTakeNowFromPayload(payload);
      } else if (response.actionId == _actionSnooze) {
        _handleSnoozeFromPayload(payload);
      }
    } else {
      // Notification body tapped — open alarm screen
      _openAlarm(payload);
    }
  }

  static void _handleTakeNowFromPayload(String payload) {
    if (!payload.startsWith('dose:')) return;
    final recordId = payload.substring('dose:'.length);
    _handleTakeNowFromNative(recordId);
  }

  static void _handleSnoozeFromPayload(String payload) {
    if (!payload.startsWith('dose:')) return;
    final recordId = payload.substring('dose:'.length);
    _handleSnoozeFromNative(recordId);
  }

  static void _openAlarm(String payload) {
    if (!payload.startsWith('dose:')) return;
    final recordId = payload.substring('dose:'.length);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final navigator = appNavigatorKey.currentState;
      final record = await DatabaseHelper.instance.getDoseRecordById(recordId);
      if (navigator != null && record != null && record.status == 'scheduled') {
        navigator.push(
          MaterialPageRoute(builder: (_) => AlarmScreen(record: record)),
        );
      }
    });
  }

  static void handlePendingAlarmIfAny() {
    if (_pendingAlarmPayload != null) {
      final payload = _pendingAlarmPayload!;
      _pendingAlarmPayload = null;
      _openAlarm(payload);
    }
  }

  // ==================== Deterministic notification ID ====================

  static int _medNotificationId(String source) =>
      source.codeUnits.fold(17, (v, u) => (v * 31 + u) & 0x3fffffff);

  static int _appointmentNotificationId(String appointmentId) =>
      2000000 + appointmentId.codeUnits.fold(17, (v, u) => (v * 31 + u) & 0x3fffffff);

  static int _refillNotificationId(String medicineId) =>
      3000000 + medicineId.codeUnits.fold(17, (v, u) => (v * 31 + u) & 0x3fffffff);

  // ==================== Medication Reminders ====================

  static Future<void> scheduleAllUpcoming() async {
    final records = await DatabaseHelper.instance.getDoseRecords();
    for (final record in records) {
      if (record.status == 'scheduled' &&
          record.scheduledAt.isAfter(DateTime.now())) {
        await schedule(record);
      }
    }
  }

  static Future<void> schedule(DoseRecord record) async {
    if (!record.scheduledAt.isAfter(DateTime.now())) return;
    // Try native AlarmManager first; fall back to flutter_local_notifications
    try {
      await _channel.invokeMethod('scheduleAlarm', {
        'recordId': record.id,
        'medicineName': record.medicineName,
        'dosage': record.dosage,
        'dosageUnit': record.dosageUnit,
        'mealRelation': record.mealRelation,
        'scheduledAt': record.scheduledAt.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to schedule native alarm: ${e.message}');
      await _scheduleLocalReminder(record);
    }
  }

  static Future<void> _scheduleLocalReminder(DoseRecord record) async {
    // Look up patient name for profile-aware notification
    String profileName = 'Your';
    try {
      final patients = await DatabaseHelper.instance.getPatients();
      final patient = patients.where((p) => p.id == record.patientId).firstOrNull;
      if (patient != null && !patient.isSelf) {
        profileName = '${patient.name}\'s';
      }
    } catch (_) {}

    final dosageStr = record.dosage.toStringAsFixed(
      record.dosage % 1 == 0 ? 0 : 1,
    );
    final body = '${record.medicineName} · $dosageStr ${record.dosageUnit} · ${record.mealRelation}';

    final androidDetails = AndroidNotificationDetails(
      _medChannelId,
      _medChannelName,
      channelDescription: 'Time-sensitive medication reminders',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      color: const Color(0xFFE85D75),
      icon: '@mipmap/ic_launcher',
      ongoing: true,
      autoCancel: false,
      actions: [
        AndroidNotificationAction(
          _actionTakeNow,
          'Take Now',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          _actionSnooze,
          'Snooze 10m',
          showsUserInterface: true,
        ),
      ],
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      _medNotificationId(record.id),
      '\ud83d\udc8a $profileName medication',
      body,
      tz.TZDateTime.from(record.scheduledAt, tz.local),
      details,
      payload: 'dose:${record.id}',
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  static Future<void> cancel(String recordId) async {
    try {
      await _channel.invokeMethod('cancelAlarm', {'recordId': recordId});
    } on PlatformException catch (e) {
      debugPrint('Failed to cancel native alarm: ${e.message}');
    }
    await _notifications.cancel(_medNotificationId(recordId));
  }

  /// Cancel all notifications for a given medicine (by cancelling each scheduled record).
  static Future<void> cancelAllForMedicine(String medicineId) async {
    final records = await DatabaseHelper.instance.getDoseRecords();
    for (final r in records) {
      if (r.medicineId == medicineId && r.status == 'scheduled') {
        await cancel(r.id);
      }
    }
  }

  /// Reschedule all future notifications for a medicine after edit.
  static Future<void> rescheduleAllForMedicine(String medicineId) async {
    await cancelAllForMedicine(medicineId);
    final records = await DatabaseHelper.instance.getDoseRecords();
    for (final r in records) {
      if (r.medicineId == medicineId &&
          r.status == 'scheduled' &&
          r.scheduledAt.isAfter(DateTime.now())) {
        await schedule(r);
      }
    }
  }

  // ==================== Refill Reminders ====================

  static Future<void> checkAndScheduleRefillReminders(String patientId) async {
    final medicines =
        await DatabaseHelper.instance.getMedicinesForPatient(patientId);
    for (final med in medicines) {
      final needsRefill =
          await DatabaseHelper.instance.checkRefillReminder(med);
      if (needsRefill != null) {
        await _showRefillNotification(needsRefill);
        await DatabaseHelper.instance.markRefillReminderSent(med.id);
      }
    }
  }

  static Future<void> _showRefillNotification(Medicine medicine) async {
    final daysLeft =
        DatabaseHelper.instance.calculateDaysRemaining(medicine);
    String body;
    if (daysLeft <= 0) {
      body = '${medicine.name} has no stock remaining! Tap to refill now.';
    } else if (daysLeft < 1) {
      final hours = (daysLeft * 24).round();
      body =
          '${medicine.name} may run out in approximately $hours hours. Tap to refill.';
    } else {
      body =
          '${medicine.name} may run out in approximately ${daysLeft.round()} days. Time to refill.';
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _refillChannelId,
        _refillChannelName,
        channelDescription: 'Low stock and refill reminders',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFFE85D75),
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      _refillNotificationId(medicine.id),
      '\ud83d\udce6 Medication running low',
      body,
      details,
    );
  }

  static Future<void> cancelRefillReminder(String medicineId) async {
    await _notifications.cancel(_refillNotificationId(medicineId));
  }

  // ==================== Appointment Reminders ====================

  static Future<void> scheduleAppointmentReminder(Appointment appt) async {
    // Look up patient name for profile-aware notification
    String profileName = 'Your';
    try {
      final patients = await DatabaseHelper.instance.getPatients();
      final patient = patients.where((p) => p.id == appt.patientId).firstOrNull;
      if (patient != null && !patient.isSelf) {
        profileName = '${patient.name}\'s';
      }
    } catch (_) {}

    final doctorInfo = appt.specialization.isNotEmpty
        ? 'Dr. ${appt.doctorName} · ${appt.specialization}'
        : 'Dr. ${appt.doctorName}';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _appointmentChannelId,
        _appointmentChannelName,
        channelDescription: 'Upcoming doctor appointment reminders',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFF5B8DEF),
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );

    // 1) 1-day-before reminder at 9:00 AM
    final dayBefore = appt.appointmentDate.subtract(const Duration(days: 1));
    final dayBeforeAt9 = tz.TZDateTime(
      tz.local,
      dayBefore.year,
      dayBefore.month,
      dayBefore.day,
      9, 0,
    );
    if (dayBeforeAt9.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        _appointmentNotificationId(appt.id) + 1,
        '\ud83d\udc68\u200d\u2695\ufe0f $profileName Appointment Tomorrow',
        '$doctorInfo — ${appt.appointmentTime}',
        dayBeforeAt9,
        details,
        payload: 'appointment:${appt.id}',
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );
    }

    // 2) At appointment time on the day
    final apptParts = appt.appointmentTime.replaceAll(RegExp(r'\s'), '').toLowerCase();
    int hour = 9;
    int minute = 0;
    final hmMatch = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(apptParts);
    if (hmMatch != null) {
      hour = int.parse(hmMatch.group(1)!);
      minute = int.parse(hmMatch.group(2)!);
    }
    if (apptParts.contains('pm') && hour < 12) hour += 12;
    if (apptParts.contains('am') && hour == 12) hour = 0;

    final atTime = tz.TZDateTime(
      tz.local,
      appt.appointmentDate.year,
      appt.appointmentDate.month,
      appt.appointmentDate.day,
      hour,
      minute,
    );
    if (atTime.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        _appointmentNotificationId(appt.id) + 2,
        '\ud83d\udc68\u200d\u2695\ufe0f $profileName Appointment Now',
        '$doctorInfo — ${appt.appointmentTime}',
        atTime,
        details,
        payload: 'appointment:${appt.id}',
        androidScheduleMode: AndroidScheduleMode.alarmClock,
      );
    }
  }

  static Future<void> cancelAppointmentReminder(String appointmentId) async {
    final baseId = _appointmentNotificationId(appointmentId);
    await _notifications.cancel(baseId + 1);
    await _notifications.cancel(baseId + 2);
  }

  static Future<void> rescheduleAppointmentReminder(Appointment appt) async {
    await cancelAppointmentReminder(appt.id);
    await scheduleAppointmentReminder(appt);
  }
}
