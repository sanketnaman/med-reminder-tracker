import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'auth_service.dart';

class DatabaseHelper {
  static const String _keyMedicines = 'doseza_medicines';
  static const String _keyRecords = 'doseza_records';
  static const String _keySettings = 'doseza_settings';
  static const String _keyPatients = 'doseza_patients';
  static const String _keyActivePatient = 'doseza_active_patient';
  static const String _keyHasInitialized = 'doseza_initialized';
  static const String _keyVitals = 'doseza_vitals';
  static const String _keyAppointments = 'doseza_appointments';
  static const String _keyInventoryTransactions = 'doseza_inventory_transactions';

  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  // ==================== User-scoped keys ====================

  String _storageKey(String base) {
    final uid = AuthService.currentUser?.uid;
    if (uid == null || uid.isEmpty) return base;
    return '${base}_$uid';
  }

  Future<void> initializeDataIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasInit = prefs.getBool(_storageKey(_keyHasInitialized)) ?? false;
    if (!hasInit) {
      await _seedInitialData(prefs);
    }
  }

  Future<void> _seedInitialData(SharedPreferences prefs) async {
    await savePatients([
      Dependent(
        id: 'default_patient',
        name: '',
        relation: 'Self',
        createdAt: DateTime.now(),
      ),
    ]);
    await setActivePatientId('default_patient');

    final defaultMedicines = [
      Medicine(
        id: 'med1',
        name: 'Metformin',
        type: 'Capsule',
        dosage: 1.0,
        dosageUnit: 'Capsule',
        totalQuantity: 30.0,
        remainingQuantity: 18.0,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        isOngoing: false,
        mealRelation: 'Before Breakfast',
        notes: 'Take with water',
        timings: ['07:00 AM'],
        frequencyType: 'Every day',
        daysOfWeek: [],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Medicine(
        id: 'med2',
        name: 'Insulin 2ml',
        type: 'Injection',
        dosage: 1.0,
        dosageUnit: 'Ampule',
        totalQuantity: 10.0,
        remainingQuantity: 1.0,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        isOngoing: true,
        mealRelation: 'No Meal Relation',
        notes: 'Keep refrigerated',
        timings: ['07:50 AM'],
        frequencyType: 'Every day',
        daysOfWeek: [],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Medicine(
        id: 'med3',
        name: 'Vitamin C',
        type: 'Tablet',
        dosage: 1.0,
        dosageUnit: 'Tablet',
        totalQuantity: 60.0,
        remainingQuantity: 44.0,
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        isOngoing: true,
        mealRelation: 'After Lunch',
        notes: 'Chewable tablet',
        timings: ['02:00 PM'],
        frequencyType: 'Every day',
        daysOfWeek: [],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Medicine(
        id: 'med4',
        name: 'Omega-3',
        type: 'Capsule',
        dosage: 1.0,
        dosageUnit: 'Capsule',
        totalQuantity: 30.0,
        remainingQuantity: 22.0,
        startDate: DateTime.now().subtract(const Duration(days: 20)),
        isOngoing: true,
        mealRelation: 'After Lunch',
        notes: 'Take with meal',
        timings: ['02:00 PM'],
        frequencyType: 'Every day',
        daysOfWeek: [],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Medicine(
        id: 'med5',
        name: 'Amoxicillin',
        type: 'Tablet',
        dosage: 1.0,
        dosageUnit: 'Tablet',
        totalQuantity: 20.0,
        remainingQuantity: 18.0,
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        isOngoing: false,
        mealRelation: 'After Meal',
        notes: 'Complete course',
        timings: ['08:00 PM'],
        frequencyType: 'Every day',
        daysOfWeek: [],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Medicine(
        id: 'med6',
        name: 'Ibuprofen',
        type: 'Tablet',
        dosage: 1.0,
        dosageUnit: 'Tablet',
        totalQuantity: 10.0,
        remainingQuantity: 0.0,
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().subtract(const Duration(days: 1)),
        isOngoing: false,
        mealRelation: 'After Meal',
        notes: 'For pain relief',
        timings: ['08:00 PM'],
        frequencyType: 'Every day',
        daysOfWeek: [],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    await saveMedicines(defaultMedicines);

    final defaultRecords = <DoseRecord>[];
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      for (var med in defaultMedicines) {
        if (date.isBefore(med.startDate)) continue;
        if (med.endDate != null && date.isAfter(med.endDate!)) continue;

        for (var timeStr in med.timings) {
          final parsedTime = _parseTimeString(timeStr);
          final scheduledAt = DateTime(
            date.year,
            date.month,
            date.day,
            parsedTime.hour,
            parsedTime.minute,
          );

          String status = 'scheduled';
          DateTime? takenAt;

          if (i > 0) {
            final isTaken =
                (med.id == 'med1' && i % 3 != 0) ||
                (med.id == 'med2' && i != 2) ||
                (med.id == 'med3' && i % 2 == 0) ||
                (med.id == 'med4' && i % 4 != 0) ||
                (med.id == 'med5');

            status = isTaken ? 'taken' : 'missed';
            if (isTaken) {
              takenAt = scheduledAt.add(const Duration(minutes: 5));
            }
          } else {
            if (scheduledAt.isBefore(now)) {
              if (med.id == 'med1') {
                status = 'taken';
                takenAt = scheduledAt.add(const Duration(minutes: 3));
              } else if (med.id == 'med2') {
                status = 'scheduled';
              } else if (med.id == 'med3') {
                status = 'scheduled';
              } else {
                status = 'scheduled';
              }
            }
          }

          defaultRecords.add(
            DoseRecord(
              id: '${med.id}_${scheduledAt.millisecondsSinceEpoch}',
              medicineId: med.id,
              medicineName: med.name,
              medicineType: med.type,
              dosage: med.dosage,
              dosageUnit: med.dosageUnit,
              mealRelation: med.mealRelation,
              scheduledAt: scheduledAt,
              status: status,
              takenAt: takenAt,
            ),
          );
        }
      }
    }

    await saveDoseRecords(defaultRecords);
    await saveUserSettings(UserSettings.defaultSettings());
    await prefs.setBool(_storageKey(_keyHasInitialized), true);
  }

  Future<List<Medicine>> getMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey(_keyMedicines));
    if (jsonStr == null) return [];
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((item) => Medicine.fromMap(item)).toList();
  }

  Future<List<Medicine>> getMedicinesForPatient(String patientId) async {
    final medicines = await getMedicines();
    return medicines
        .where((medicine) => medicine.patientId == patientId)
        .toList();
  }

  Future<List<Dependent>> getPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(_keyPatients));
    if (raw == null) {
      final fallback = Dependent(
        id: 'default_patient',
        name: '',
        relation: 'Self',
        createdAt: DateTime.now(),
      );
      await savePatients([fallback]);
      return [fallback];
    }
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((item) => Dependent.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePatients(List<Dependent> patients) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey(_keyPatients),
      json.encode(patients.map((patient) => patient.toMap()).toList()),
    );
  }

  Future<void> addPatient(Dependent patient) async {
    final patients = await getPatients();
    patients.add(patient);
    await savePatients(patients);
  }

  Future<void> updatePatient(Dependent patient) async {
    final patients = await getPatients();
    final index = patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      patients[index] = patient;
      await savePatients(patients);
    }
  }

  Future<void> deletePatient(String patientId) async {
    if (patientId == 'default_patient') return;

    // Delete all medicines for this patient
    final medicines = await getMedicines();
    final patientMedIds = medicines
        .where((m) => m.patientId == patientId)
        .map((m) => m.id)
        .toList();
    medicines.removeWhere((m) => m.patientId == patientId);
    await saveMedicines(medicines);

    // Delete all dose records for this patient
    final records = await getDoseRecords();
    records.removeWhere((r) =>
        r.patientId == patientId || patientMedIds.contains(r.medicineId));
    await saveDoseRecords(records);

    // Delete all vitals for this patient
    final vitals = await getVitalReadings();
    vitals.removeWhere((v) => v.patientId == patientId);
    await saveVitalReadings(vitals);

    // Delete all appointments for this patient
    final appointments = await getAppointments();
    appointments.removeWhere((a) => a.patientId == patientId);
    await saveAppointments(appointments);

    // Delete inventory transactions for this patient's medicines
    final transactions = await getInventoryTransactions();
    transactions.removeWhere((t) => patientMedIds.contains(t.medicineId));
    await saveInventoryTransactions(transactions);

    // Remove patient from list
    final patients = await getPatients();
    patients.removeWhere((p) => p.id == patientId);
    await savePatients(patients);

    // Reset active patient to self if needed
    final activeId = await getActivePatientId();
    if (activeId == patientId) {
      await setActivePatientId('default_patient');
    }
  }

  Future<int> getDependentCount() async {
    final patients = await getPatients();
    return patients.where((p) => !p.isSelf).length;
  }

  Future<bool> canAddDependent() async {
    if (await isPremium()) return true;
    final count = await getDependentCount();
    return count < 2;
  }

  Future<String> getActivePatientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKey(_keyActivePatient)) ?? 'default_patient';
  }

  Future<void> setActivePatientId(String patientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(_keyActivePatient), patientId);
  }

  Future<void> saveMedicines(List<Medicine> medicines) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(medicines.map((m) => m.toMap()).toList());
    await prefs.setString(_storageKey(_keyMedicines), jsonStr);
  }

  Future<void> addMedicine(Medicine medicine) async {
    final medicines = await getMedicines();
    medicines.add(medicine);
    await saveMedicines(medicines);
    await generateRecordsForNewMedicine(medicine);

    // Log initial stock transaction
    await addInventoryTransaction(InventoryTransaction(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      medicineId: medicine.id,
      medicineName: medicine.name,
      type: 'initial',
      quantityChange: medicine.totalQuantity,
      stockAfter: medicine.remainingQuantity,
      createdAt: DateTime.now(),
      notes: 'Initial stock: ${medicine.totalQuantity.toInt()} ${medicine.dosageUnit}',
    ));
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final medicines = await getMedicines();
    final index = medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      medicines[index] = medicine;
      await saveMedicines(medicines);
      // Clean upcoming scheduled records and regenerate
      await regenerateRecordsForMedicine(medicine);
    }
  }

  Future<void> deleteMedicine(String medicineId) async {
    final medicines = await getMedicines();
    medicines.removeWhere((m) => m.id == medicineId);
    await saveMedicines(medicines);

    final records = await getDoseRecords();
    records.removeWhere(
      (r) => r.medicineId == medicineId && r.status == 'scheduled',
    );
    await saveDoseRecords(records);
  }

  Future<List<DoseRecord>> getDoseRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey(_keyRecords));
    if (jsonStr == null) return [];
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((item) => DoseRecord.fromMap(item)).toList();
  }

  Future<DoseRecord?> getDoseRecordById(String recordId) async {
    final records = await getDoseRecords();
    for (final record in records) {
      if (record.id == recordId) return record;
    }
    return null;
  }

  Future<void> saveDoseRecords(List<DoseRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(records.map((r) => r.toMap()).toList());
    await prefs.setString(_storageKey(_keyRecords), jsonStr);
  }

  Future<void> addDoseRecord(DoseRecord record) async {
    final records = await getDoseRecords();
    records.add(record);
    await saveDoseRecords(records);
  }

  Future<void> updateDoseRecord(DoseRecord record) async {
    final records = await getDoseRecords();
    final index = records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      final oldRecord = records[index];
      records[index] = record;
      await saveDoseRecords(records);

      // Decrement inventory ONLY when transitioning TO 'taken' (prevents duplicate deduction)
      if (record.status == 'taken' && oldRecord.status != 'taken') {
        final medicines = await getMedicines();
        final medIndex = medicines.indexWhere((m) => m.id == record.medicineId);
        if (medIndex != -1) {
          final med = medicines[medIndex];
          if (med.remainingQuantity >= record.dosage) {
            med.remainingQuantity -= record.dosage;
            await saveMedicines(medicines);
            await addInventoryTransaction(InventoryTransaction(
              id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
              medicineId: med.id,
              medicineName: med.name,
              type: 'dose_consumed',
              quantityChange: -record.dosage,
              stockAfter: med.remainingQuantity,
              createdAt: DateTime.now(),
              notes: '${record.dosage} ${record.dosageUnit} dose taken',
            ));
          }
        }
      }
    }
  }

  Future<UserSettings> getUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey(_keySettings));
    if (jsonStr == null) return UserSettings.defaultSettings();
    return UserSettings.fromJson(jsonStr);
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(_keySettings), settings.toJson());
  }

  // Generates dose records for the given date if they do not exist
  Future<List<DoseRecord>> getDoseRecordsForDate(
    DateTime date, {
    String? patientId,
  }) async {
    await initializeDataIfNeeded();
    final records = await getDoseRecords();
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    final activePatientId = patientId ?? await getActivePatientId();
    final filtered = records
        .where(
          (r) =>
              r.patientId == activePatientId &&
              r.scheduledAt.isAfter(
                dayStart.subtract(const Duration(microseconds: 1)),
              ) &&
              r.scheduledAt.isBefore(
                dayEnd.add(const Duration(microseconds: 1)),
              ),
        )
        .toList();

    // Dynamically generate records if none exist yet for this date
    if (filtered.isEmpty &&
        date.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
      final medicines = await getMedicinesForPatient(activePatientId);

      for (var med in medicines) {
        if (dayStart.isBefore(
          DateTime(med.startDate.year, med.startDate.month, med.startDate.day),
        ))
          continue;
        if (med.endDate != null &&
            dayStart.isAfter(
              DateTime(med.endDate!.year, med.endDate!.month, med.endDate!.day),
            ))
          continue;

        // Frequency checks
        if (med.frequencyType == 'Specific days') {
          final weekday = dayStart.weekday;
          if (!med.daysOfWeek.contains(weekday)) continue;
        }

        for (var timeStr in med.timings) {
          final time = _parseTimeString(timeStr);
          final scheduledTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          final newRecord = DoseRecord(
            id: '${med.id}_${scheduledTime.millisecondsSinceEpoch}',
            patientId: med.patientId,
            medicineId: med.id,
            medicineName: med.name,
            medicineType: med.type,
            dosage: med.dosage,
            dosageUnit: med.dosageUnit,
            mealRelation: med.mealRelation,
            scheduledAt: scheduledTime,
            status: 'scheduled',
          );
          records.add(newRecord);
          filtered.add(newRecord);
        }
      }
      if (filtered.isNotEmpty) {
        await saveDoseRecords(records);
      }
    }

    // Auto mark past scheduled doses as missed
    bool updated = false;
    final now = DateTime.now();
    for (var r in filtered) {
      if (r.status == 'scheduled' &&
          r.scheduledAt.isBefore(now.subtract(const Duration(hours: 2)))) {
        r.status = 'missed';
        updated = true;
      }
    }
    if (updated) {
      await saveDoseRecords(records);
    }

    filtered.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return filtered;
  }

  Future<void> generateRecordsForNewMedicine(Medicine medicine) async {
    final records = await getDoseRecords();
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);

    // Generate upcoming times for today and next 7 days
    for (int i = 0; i < 7; i++) {
      final date = dayStart.add(Duration(days: i));
      if (medicine.endDate != null && date.isAfter(medicine.endDate!)) break;

      if (medicine.frequencyType == 'Specific days') {
        if (!medicine.daysOfWeek.contains(date.weekday)) continue;
      }

      for (var timeStr in medicine.timings) {
        final time = _parseTimeString(timeStr);
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Skip if already in the past
        if (scheduledTime.isBefore(DateTime.now())) continue;

        records.add(
          DoseRecord(
            id: '${medicine.id}_${scheduledTime.millisecondsSinceEpoch}',
            patientId: medicine.patientId,
            medicineId: medicine.id,
            medicineName: medicine.name,
            medicineType: medicine.type,
            dosage: medicine.dosage,
            dosageUnit: medicine.dosageUnit,
            mealRelation: medicine.mealRelation,
            scheduledAt: scheduledTime,
            status: 'scheduled',
          ),
        );
      }
    }
    await saveDoseRecords(records);
  }

  Future<void> regenerateRecordsForMedicine(Medicine medicine) async {
    final records = await getDoseRecords();
    // Remove future scheduled records for this medicine
    records.removeWhere(
      (r) =>
          r.medicineId == medicine.id &&
          r.status == 'scheduled' &&
          r.scheduledAt.isAfter(DateTime.now()),
    );
    await saveDoseRecords(records);
    await generateRecordsForNewMedicine(medicine);
  }

  Future<void> fixExistingRecordsMedicineType() async {
    final records = await getDoseRecords();
    final medicines = await getMedicines();
    final medicineMap = <String, Medicine>{};
    for (final med in medicines) {
      medicineMap[med.id] = med;
    }
    bool changed = false;
    for (int i = 0; i < records.length; i++) {
      final record = records[i];
      final med = medicineMap[record.medicineId];
      if (med != null && record.medicineType != med.type) {
        records[i] = DoseRecord(
          id: record.id,
          patientId: record.patientId,
          medicineId: record.medicineId,
          medicineName: record.medicineName,
          medicineType: med.type,
          dosage: record.dosage,
          dosageUnit: record.dosageUnit,
          mealRelation: record.mealRelation,
          scheduledAt: record.scheduledAt,
          status: record.status,
          takenAt: record.takenAt,
          snoozedUntil: record.snoozedUntil,
          notes: record.notes,
        );
        changed = true;
      }
    }
    if (changed) {
      await saveDoseRecords(records);
    }
  }

  static DoseTimeOfDay _parseTimeString(String timeStr) {
    // E.g., "07:00 AM" or "2:00 PM"
    final clean = timeStr.trim();
    final parts = clean.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    if (parts.length > 1) {
      final ampm = parts[1].toUpperCase();
      if (ampm == 'PM' && hour < 12) {
        hour += 12;
      } else if (ampm == 'AM' && hour == 12) {
        hour = 0;
      }
    }
    return DoseTimeOfDay(hour: hour, minute: minute);
  }

  // ==================== Inventory Transactions ====================

  Future<List<InventoryTransaction>> getInventoryTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey(_keyInventoryTransactions));
    if (jsonStr == null) return [];
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((item) => InventoryTransaction.fromMap(item)).toList();
  }

  Future<void> saveInventoryTransactions(List<InventoryTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(transactions.map((t) => t.toMap()).toList());
    await prefs.setString(_storageKey(_keyInventoryTransactions), jsonStr);
  }

  Future<void> addInventoryTransaction(InventoryTransaction transaction) async {
    final transactions = await getInventoryTransactions();
    transactions.add(transaction);
    await saveInventoryTransactions(transactions);
  }

  Future<List<InventoryTransaction>> getTransactionsForMedicine(String medicineId) async {
    final transactions = await getInventoryTransactions();
    return transactions.where((t) => t.medicineId == medicineId).toList();
  }

  Future<List<InventoryTransaction>> getTransactionsForPatient(String patientId) async {
    final medicines = await getMedicinesForPatient(patientId);
    final medIds = medicines.map((m) => m.id).toSet();
    final transactions = await getInventoryTransactions();
    return transactions.where((t) => medIds.contains(t.medicineId)).toList();
  }

  // Calculate days remaining based on actual schedule
  double calculateDaysRemaining(Medicine med) {
    if (med.remainingQuantity <= 0) return 0;
    if (med.dosage <= 0) return med.remainingQuantity;

    // Calculate daily consumption based on schedule
    final dosesPerDay = _calculateDosesPerDay(med);
    if (dosesPerDay <= 0) return med.remainingQuantity;

    final dailyConsumption = med.dosage * dosesPerDay;
    return med.remainingQuantity / dailyConsumption;
  }

  double _calculateDosesPerDay(Medicine med) {
    final timingsCount = med.timings.length;
    if (med.frequencyType == 'Every day') {
      return timingsCount.toDouble();
    } else if (med.frequencyType == 'Specific days') {
      // Average doses per day based on days of week
      return timingsCount * (med.daysOfWeek.length / 7.0);
    }
    return timingsCount.toDouble();
  }

  // Get stock status for a medicine
  String getStockStatus(Medicine med) {
    final daysLeft = calculateDaysRemaining(med);
    if (med.remainingQuantity <= 0) return 'out_of_stock';
    if (daysLeft <= 3) return 'critical';
    if (daysLeft <= 7) return 'low';
    return 'normal';
  }

  // Add stock (refill)
  Future<void> addStock(String medicineId, double quantity, {String? notes}) async {
    final medicines = await getMedicines();
    final medIndex = medicines.indexWhere((m) => m.id == medicineId);
    if (medIndex == -1) return;

    final med = medicines[medIndex];
    med.remainingQuantity += quantity;
    await saveMedicines(medicines);

    await addInventoryTransaction(InventoryTransaction(
      id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
      medicineId: med.id,
      medicineName: med.name,
      type: 'refill',
      quantityChange: quantity,
      stockAfter: med.remainingQuantity,
      createdAt: DateTime.now(),
      notes: notes ?? 'Refill: +${quantity.toInt()} ${med.dosageUnit}',
    ));

    // Reset refill reminder sent date since stock was replenished
    med.refillReminderSentAt = null;
    await saveMedicines(medicines);
  }

  // Check and update refill reminder status
  Future<Medicine?> checkRefillReminder(Medicine med) async {
    final daysLeft = calculateDaysRemaining(med);
    if (daysLeft <= med.refillThresholdDays && med.refillReminderSentAt == null) {
      // Refill reminder should be sent
      return med;
    }
    return null;
  }

  // Mark refill reminder as sent
  Future<void> markRefillReminderSent(String medicineId) async {
    final medicines = await getMedicines();
    final medIndex = medicines.indexWhere((m) => m.id == medicineId);
    if (medIndex != -1) {
      medicines[medIndex].refillReminderSentAt = DateTime.now();
      await saveMedicines(medicines);
    }
  }

  // ==================== Vitals ====================

  Future<List<VitalReading>> getVitalReadings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey(_keyVitals));
    if (jsonStr == null) return [];
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((item) => VitalReading.fromMap(item)).toList();
  }

  Future<void> saveVitalReadings(List<VitalReading> readings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(readings.map((r) => r.toMap()).toList());
    await prefs.setString(_storageKey(_keyVitals), jsonStr);
  }

  Future<void> addVitalReading(VitalReading reading) async {
    final readings = await getVitalReadings();
    readings.add(reading);
    await saveVitalReadings(readings);
  }

  Future<void> deleteVitalReading(String id) async {
    final readings = await getVitalReadings();
    readings.removeWhere((r) => r.id == id);
    await saveVitalReadings(readings);
  }

  Future<List<VitalReading>> getVitalReadingsForPatient(String patientId) async {
    final readings = await getVitalReadings();
    return readings.where((r) => r.patientId == patientId).toList();
  }

  Future<List<VitalReading>> getVitalReadingsForDate(DateTime date, {String? patientId}) async {
    final activePatientId = patientId ?? await getActivePatientId();
    final readings = await getVitalReadings();
    return readings.where((r) =>
      r.patientId == activePatientId &&
      r.recordedAt.year == date.year &&
      r.recordedAt.month == date.month &&
      r.recordedAt.day == date.day
    ).toList();
  }

  Future<Map<String, VitalReading>> getLatestVitals({String? patientId}) async {
    final activePatientId = patientId ?? await getActivePatientId();
    final readings = await getVitalReadings();
    final filtered = readings.where((r) => r.patientId == activePatientId);
    final map = <String, VitalReading>{};
    for (final r in filtered) {
      final existing = map[r.type];
      if (existing == null || r.recordedAt.isAfter(existing.recordedAt)) {
        map[r.type] = r;
      }
    }
    return map;
  }

  // ==================== Premium ====================

  static const int freeMedicineLimit = 5;

  Future<bool> isPremium() async {
    final settings = await getUserSettings();
    return settings.isPremium;
  }

  Future<void> setPremium(bool value) async {
    final settings = await getUserSettings();
    settings.isPremium = value;
    await saveUserSettings(settings);
  }

  Future<bool> canAddMedicine(String patientId) async {
    if (await isPremium()) return true;
    final medicines = await getMedicinesForPatient(patientId);
    return medicines.length < freeMedicineLimit;
  }

  Future<int> getMedicineCount(String patientId) async {
    final medicines = await getMedicinesForPatient(patientId);
    return medicines.length;
  }

  // ==================== Appointments ====================

  Future<List<Appointment>> getAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey(_keyAppointments));
    if (jsonStr == null) return [];
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((item) => Appointment.fromMap(item)).toList();
  }

  Future<void> saveAppointments(List<Appointment> appointments) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = json.encode(appointments.map((a) => a.toMap()).toList());
    await prefs.setString(_storageKey(_keyAppointments), jsonStr);
  }

  Future<void> addAppointment(Appointment appointment) async {
    final appointments = await getAppointments();
    appointments.add(appointment);
    await saveAppointments(appointments);
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final appointments = await getAppointments();
    final index = appointments.indexWhere((a) => a.id == appointment.id);
    if (index != -1) {
      appointments[index] = appointment;
      await saveAppointments(appointments);
    }
  }

  Future<void> deleteAppointment(String id) async {
    final appointments = await getAppointments();
    appointments.removeWhere((a) => a.id == id);
    await saveAppointments(appointments);
  }

  Future<List<Appointment>> getAppointmentsForPatient(String patientId) async {
    final appointments = await getAppointments();
    return appointments.where((a) => a.patientId == patientId).toList();
  }

  Future<List<Appointment>> getUpcomingAppointments({String? patientId}) async {
    final activePatientId = patientId ?? await getActivePatientId();
    final appointments = await getAppointments();
    appointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    return appointments.where((a) =>
      a.patientId == activePatientId &&
      a.appointmentDate.isAfter(DateTime.now())
    ).toList();
  }

  Future<Appointment?> getNextAppointment({String? patientId}) async {
    final upcoming = await getUpcomingAppointments(patientId: patientId);
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  // ==================== Migration ====================

  Future<void> migrateExistingData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasMigrated = prefs.getBool(_storageKey('doseza_profile_migrated')) ?? false;
    if (hasMigrated) return;

    // Ensure self profile exists
    final patients = await getPatients();
    final hasSelf = patients.any((p) => p.relation == 'Self');
    if (!hasSelf) {
      patients.insert(0, Dependent(
        id: 'default_patient',
        name: '',
        relation: 'Self',
        createdAt: DateTime.now(),
      ));
      await savePatients(patients);
    }

    // Tag all existing records with default_patient if missing
    final medicines = await getMedicines();
    bool changed = false;
    for (int i = 0; i < medicines.length; i++) {
      if (medicines[i].patientId.isEmpty || medicines[i].patientId == 'default_patient') {
        continue; // Already correct
      }
    }

    final records = await getDoseRecords();
    for (int i = 0; i < records.length; i++) {
      if (records[i].patientId.isEmpty) {
        records[i] = DoseRecord(
          id: records[i].id,
          patientId: 'default_patient',
          medicineId: records[i].medicineId,
          medicineName: records[i].medicineName,
          medicineType: records[i].medicineType,
          dosage: records[i].dosage,
          dosageUnit: records[i].dosageUnit,
          mealRelation: records[i].mealRelation,
          scheduledAt: records[i].scheduledAt,
          status: records[i].status,
          takenAt: records[i].takenAt,
          snoozedUntil: records[i].snoozedUntil,
          notes: records[i].notes,
        );
        changed = true;
      }
    }
    if (changed) await saveDoseRecords(records);

    final vitals = await getVitalReadings();
    for (int i = 0; i < vitals.length; i++) {
      if (vitals[i].patientId.isEmpty) {
        vitals[i] = VitalReading(
          id: vitals[i].id,
          patientId: 'default_patient',
          type: vitals[i].type,
          systolic: vitals[i].systolic,
          diastolic: vitals[i].diastolic,
          value: vitals[i].value,
          unit: vitals[i].unit,
          recordedAt: vitals[i].recordedAt,
          notes: vitals[i].notes,
        );
        changed = true;
      }
    }
    if (changed) await saveVitalReadings(vitals);

    final appointments = await getAppointments();
    for (int i = 0; i < appointments.length; i++) {
      if (appointments[i].patientId.isEmpty) {
        appointments[i] = Appointment(
          id: appointments[i].id,
          patientId: 'default_patient',
          doctorName: appointments[i].doctorName,
          specialization: appointments[i].specialization,
          appointmentDate: appointments[i].appointmentDate,
          appointmentTime: appointments[i].appointmentTime,
          location: appointments[i].location,
          notes: appointments[i].notes,
          reminderEnabled: appointments[i].reminderEnabled,
          reminderMinutesBefore: appointments[i].reminderMinutesBefore,
          createdAt: appointments[i].createdAt,
        );
        changed = true;
      }
    }
    if (changed) await saveAppointments(appointments);

    await prefs.setBool(_storageKey('doseza_profile_migrated'), true);
  }
}

class DoseTimeOfDay {
  final int hour;
  final int minute;
  DoseTimeOfDay({required this.hour, required this.minute});
}