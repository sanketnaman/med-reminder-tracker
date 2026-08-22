import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._init();
  FirestoreService._init();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  bool get _isLoggedIn => _uid != null && _uid!.isNotEmpty;

  // ==================== User Profile & Settings ====================

  Future<void> syncUserSettings(UserSettings settings) async {
    if (!_isLoggedIn) return;
    try {
      await _db.collection('users').doc(_uid).set({
        'settings': settings.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Firestore: Failed to sync settings: $e');
    }
  }

  Future<UserSettings?> getUserSettings() async {
    if (!_isLoggedIn) return null;
    try {
      final doc = await _db.collection('users').doc(_uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['settings'] != null) {
          return UserSettings.fromMap(Map<String, dynamic>.from(data['settings']));
        }
      }
    } catch (e) {
      print('Firestore: Failed to get settings: $e');
    }
    return null;
  }

  // ==================== Medicines ====================

  Future<void> syncMedicines(List<Medicine> medicines) async {
    if (!_isLoggedIn) return;
    try {
      final batch = _db.batch();
      final col = _db.collection('users').doc(_uid).collection('medicines');

      // Get existing to delete removed ones
      final existing = await col.get();
      final existingIds = existing.docs.map((d) => d.id).toSet();
      final newIds = medicines.map((m) => m.id).toSet();

      // Delete removed
      for (final id in existingIds.difference(newIds)) {
        batch.delete(col.doc(id));
      }

      // Add/Update
      for (final med in medicines) {
        batch.set(col.doc(med.id), med.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Firestore: Failed to sync medicines: $e');
    }
  }

  Future<List<Medicine>> getMedicines() async {
    if (!_isLoggedIn) return [];
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('medicines')
          .get();
      return snapshot.docs
          .map((doc) => Medicine.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Firestore: Failed to get medicines: $e');
      return [];
    }
  }

  // ==================== Dose Records ====================

  Future<void> syncDoseRecords(List<DoseRecord> records) async {
    if (!_isLoggedIn) return;
    try {
      final batch = _db.batch();
      final col = _db.collection('users').doc(_uid).collection('doseRecords');

      // Get existing to delete removed ones
      final existing = await col.get();
      final existingIds = existing.docs.map((d) => d.id).toSet();
      final newIds = records.map((r) => r.id).toSet();

      // Delete removed
      for (final id in existingIds.difference(newIds)) {
        batch.delete(col.doc(id));
      }

      // Add/Update
      for (final record in records) {
        batch.set(col.doc(record.id), record.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Firestore: Failed to sync dose records: $e');
    }
  }

  Future<List<DoseRecord>> getDoseRecords() async {
    if (!_isLoggedIn) return [];
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('doseRecords')
          .get();
      return snapshot.docs
          .map((doc) => DoseRecord.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Firestore: Failed to get dose records: $e');
      return [];
    }
  }

  // ==================== Dependents ====================

  Future<void> syncPatients(List<Dependent> patients) async {
    if (!_isLoggedIn) return;
    try {
      final batch = _db.batch();
      final col = _db.collection('users').doc(_uid).collection('patients');

      final existing = await col.get();
      final existingIds = existing.docs.map((d) => d.id).toSet();
      final newIds = patients.map((p) => p.id).toSet();

      for (final id in existingIds.difference(newIds)) {
        batch.delete(col.doc(id));
      }

      for (final patient in patients) {
        batch.set(col.doc(patient.id), patient.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Firestore: Failed to sync patients: $e');
    }
  }

  Future<List<Dependent>> getPatients() async {
    if (!_isLoggedIn) return [];
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('patients')
          .get();
      return snapshot.docs
          .map((doc) => Dependent.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Firestore: Failed to get patients: $e');
      return [];
    }
  }

  // ==================== Vitals ====================

  Future<void> syncVitals(List<VitalReading> vitals) async {
    if (!_isLoggedIn) return;
    try {
      final batch = _db.batch();
      final col = _db.collection('users').doc(_uid).collection('vitals');

      final existing = await col.get();
      final existingIds = existing.docs.map((d) => d.id).toSet();
      final newIds = vitals.map((v) => v.id).toSet();

      for (final id in existingIds.difference(newIds)) {
        batch.delete(col.doc(id));
      }

      for (final vital in vitals) {
        batch.set(col.doc(vital.id), vital.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Firestore: Failed to sync vitals: $e');
    }
  }

  Future<List<VitalReading>> getVitals() async {
    if (!_isLoggedIn) return [];
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('vitals')
          .get();
      return snapshot.docs
          .map((doc) => VitalReading.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Firestore: Failed to get vitals: $e');
      return [];
    }
  }

  // ==================== Appointments ====================

  Future<void> syncAppointments(List<Appointment> appointments) async {
    if (!_isLoggedIn) return;
    try {
      final batch = _db.batch();
      final col = _db.collection('users').doc(_uid).collection('appointments');

      final existing = await col.get();
      final existingIds = existing.docs.map((d) => d.id).toSet();
      final newIds = appointments.map((a) => a.id).toSet();

      for (final id in existingIds.difference(newIds)) {
        batch.delete(col.doc(id));
      }

      for (final appt in appointments) {
        batch.set(col.doc(appt.id), appt.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Firestore: Failed to sync appointments: $e');
    }
  }

  Future<List<Appointment>> getAppointments() async {
    if (!_isLoggedIn) return [];
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('appointments')
          .get();
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Firestore: Failed to get appointments: $e');
      return [];
    }
  }

  // ==================== Inventory Transactions ====================

  Future<void> syncInventoryTransactions(List<InventoryTransaction> transactions) async {
    if (!_isLoggedIn) return;
    try {
      final batch = _db.batch();
      final col = _db.collection('users').doc(_uid).collection('inventory');

      final existing = await col.get();
      final existingIds = existing.docs.map((d) => d.id).toSet();
      final newIds = transactions.map((t) => t.id).toSet();

      for (final id in existingIds.difference(newIds)) {
        batch.delete(col.doc(id));
      }

      for (final txn in transactions) {
        batch.set(col.doc(txn.id), txn.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      print('Firestore: Failed to sync inventory: $e');
    }
  }

  Future<List<InventoryTransaction>> getInventoryTransactions() async {
    if (!_isLoggedIn) return [];
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_uid)
          .collection('inventory')
          .get();
      return snapshot.docs
          .map((doc) => InventoryTransaction.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Firestore: Failed to get inventory: $e');
      return [];
    }
  }

  // ==================== Full Sync (Pull from Cloud) ====================

  Future<Map<String, dynamic>> pullAllData() async {
    if (!_isLoggedIn) return {};
    try {
      final results = <String, dynamic>{};

      final settings = await getUserSettings();
      if (settings != null) results['settings'] = settings;

      final medicines = await getMedicines();
      if (medicines.isNotEmpty) results['medicines'] = medicines;

      final patients = await getPatients();
      if (patients.isNotEmpty) results['patients'] = patients;

      final vitals = await getVitals();
      if (vitals.isNotEmpty) results['vitals'] = vitals;

      final appointments = await getAppointments();
      if (appointments.isNotEmpty) results['appointments'] = appointments;

      final inventory = await getInventoryTransactions();
      if (inventory.isNotEmpty) results['inventory'] = inventory;

      final doseRecords = await getDoseRecords();
      if (doseRecords.isNotEmpty) results['doseRecords'] = doseRecords;

      return results;
    } catch (e) {
      print('Firestore: Failed to pull all data: $e');
      return {};
    }
  }

  // ==================== Full Sync (Push to Cloud) ====================

  Future<void> pushAllData({
    required UserSettings settings,
    required List<Medicine> medicines,
    required List<Dependent> patients,
    required List<VitalReading> vitals,
    required List<Appointment> appointments,
    required List<InventoryTransaction> inventory,
    required List<DoseRecord> doseRecords,
  }) async {
    if (!_isLoggedIn) return;

    await Future.wait([
      syncUserSettings(settings),
      syncMedicines(medicines),
      syncPatients(patients),
      syncVitals(vitals),
      syncAppointments(appointments),
      syncInventoryTransactions(inventory),
      syncDoseRecords(doseRecords),
    ]);
  }

  // ==================== Delete All Data ====================

  Future<void> deleteAllData() async {
    if (!_isLoggedIn) return;
    try {
      final userDoc = _db.collection('users').doc(_uid);
      final subCollections = ['medicines', 'doseRecords', 'patients', 'vitals', 'appointments', 'inventory'];

      for (final col in subCollections) {
        final snapshot = await userDoc.collection(col).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      await userDoc.delete();
    } catch (e) {
      print('Firestore: Failed to delete all data: $e');
    }
  }
}
