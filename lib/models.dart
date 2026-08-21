import 'dart:convert';

class Medicine {
  final String id;
  final String patientId;
  final String name;
  final String type; // Tablet, Capsule, Syrup, Injection, etc.
  final double dosage;
  final String dosageUnit; // Tablet, Capsule, ml, etc.
  final double totalQuantity;
  double remainingQuantity;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isOngoing;
  final String
  mealRelation; // Before Meal, During Meal, After Meal, No Meal Relation
  final String notes;
  final String? image;
  final List<String> timings; // ["07:00 AM", "02:00 PM"]
  final String frequencyType; // Every day, Specific days
  final List<int> daysOfWeek; // [1, 3, 5] (1=Mon, 7=Sun)
  final DateTime createdAt;
  final DateTime updatedAt;
  int refillThresholdDays; // Days remaining to trigger refill reminder
  DateTime? refillReminderSentAt; // When last refill reminder was sent

  Medicine({
    required this.id,
    this.patientId = 'default_patient',
    required this.name,
    required this.type,
    required this.dosage,
    required this.dosageUnit,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.startDate,
    this.endDate,
    required this.isOngoing,
    required this.mealRelation,
    required this.notes,
    this.image,
    required this.timings,
    required this.frequencyType,
    required this.daysOfWeek,
    required this.createdAt,
    required this.updatedAt,
    this.refillThresholdDays = 7,
    this.refillReminderSentAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'name': name,
      'type': type,
      'dosage': dosage,
      'dosageUnit': dosageUnit,
      'totalQuantity': totalQuantity,
      'remainingQuantity': remainingQuantity,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isOngoing': isOngoing,
      'mealRelation': mealRelation,
      'notes': notes,
      'image': image,
      'timings': timings,
      'frequencyType': frequencyType,
      'daysOfWeek': daysOfWeek,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'refillThresholdDays': refillThresholdDays,
      'refillReminderSentAt': refillReminderSentAt?.toIso8601String(),
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? 'default_patient',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      dosage: (map['dosage'] as num?)?.toDouble() ?? 1.0,
      dosageUnit: map['dosageUnit'] ?? '',
      totalQuantity: (map['totalQuantity'] as num?)?.toDouble() ?? 30.0,
      remainingQuantity: (map['remainingQuantity'] as num?)?.toDouble() ?? 30.0,
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      isOngoing: map['isOngoing'] ?? true,
      mealRelation: map['mealRelation'] ?? 'No Meal Relation',
      notes: map['notes'] ?? '',
      image: map['image'],
      timings: List<String>.from(map['timings'] ?? []),
      frequencyType: map['frequencyType'] ?? 'Every day',
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      refillThresholdDays: (map['refillThresholdDays'] as num?)?.toInt() ?? 7,
      refillReminderSentAt: map['refillReminderSentAt'] != null
          ? DateTime.parse(map['refillReminderSentAt'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Medicine.fromJson(String source) =>
      Medicine.fromMap(json.decode(source));
}

class DoseRecord {
  final String id;
  final String patientId;
  final String medicineId;
  final String medicineName;
  final String medicineType;
  final double dosage;
  final String dosageUnit;
  final String mealRelation;
  final DateTime scheduledAt;
  String status; // scheduled, taken, missed, skipped, snoozed
  DateTime? takenAt;
  DateTime? snoozedUntil;
  String? notes;

  DoseRecord({
    required this.id,
    this.patientId = 'default_patient',
    required this.medicineId,
    required this.medicineName,
    this.medicineType = 'Tablet',
    required this.dosage,
    required this.dosageUnit,
    required this.mealRelation,
    required this.scheduledAt,
    required this.status,
    this.takenAt,
    this.snoozedUntil,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'medicineType': medicineType,
      'dosage': dosage,
      'dosageUnit': dosageUnit,
      'mealRelation': mealRelation,
      'scheduledAt': scheduledAt.toIso8601String(),
      'status': status,
      'takenAt': takenAt?.toIso8601String(),
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'notes': notes,
    };
  }

  factory DoseRecord.fromMap(Map<String, dynamic> map) {
    return DoseRecord(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? 'default_patient',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      medicineType: map['medicineType'] ?? 'Tablet',
      dosage: (map['dosage'] as num?)?.toDouble() ?? 1.0,
      dosageUnit: map['dosageUnit'] ?? '',
      mealRelation: map['mealRelation'] ?? '',
      scheduledAt: DateTime.parse(map['scheduledAt']),
      status: map['status'] ?? 'scheduled',
      takenAt: map['takenAt'] != null ? DateTime.parse(map['takenAt']) : null,
      snoozedUntil: map['snoozedUntil'] != null
          ? DateTime.parse(map['snoozedUntil'])
          : null,
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DoseRecord.fromJson(String source) =>
      DoseRecord.fromMap(json.decode(source));
}

class Dependent {
  final String id;
  final String name;
  final String relation;
  final int age;
  final String gender;
  final String profilePhoto;
  final bool isCardiacPostSurgery;
  final DateTime createdAt;

  const Dependent({
    required this.id,
    required this.name,
    this.relation = 'Other',
    this.age = 0,
    this.gender = '',
    this.profilePhoto = '',
    this.isCardiacPostSurgery = false,
    required this.createdAt,
  });

  bool get isSelf => relation == 'Self';

  String get relationLabel {
    switch (relation) {
      case 'Self': return 'Self';
      case 'Father': return 'Father';
      case 'Mother': return 'Mother';
      case 'Spouse': return 'Spouse';
      case 'Son': return 'Son';
      case 'Daughter': return 'Daughter';
      case 'Brother': return 'Brother';
      case 'Sister': return 'Sister';
      case 'Grandfather': return 'Grandfather';
      case 'Grandmother': return 'Grandmother';
      default: return relation;
    }
  }

  String get ageLabel {
    if (age <= 0) return '';
    return '$age years';
  }

  String get displayLabel {
    final parts = <String>[];
    if (relation != 'Self') parts.add(relationLabel);
    if (age > 0) parts.add(ageLabel);
    return parts.join(' · ');
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'relation': relation,
    'age': age,
    'gender': gender,
    'profilePhoto': profilePhoto,
    'isCardiacPostSurgery': isCardiacPostSurgery,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Dependent.fromMap(Map<String, dynamic> map) => Dependent(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    relation: map['relation'] ?? 'Other',
    age: map['age'] ?? 0,
    gender: map['gender'] ?? '',
    profilePhoto: map['profilePhoto'] ?? '',
    isCardiacPostSurgery: map['isCardiacPostSurgery'] ?? false,
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
  );
}

typedef Patient = Dependent;

class UserSettings {
  String name;
  String email;
  String phone;
  String profilePhoto;
  String timezone;
  String language;
  bool medicineReminder;
  bool missedDose;
  bool refillReminder;
  bool dailySummary;
  bool sound;
  bool vibration;
  bool isPremium;
  bool isDarkMode;
  int reminderAdvanceMinutes; // 0, 5, or 10
  int snoozeDurationMinutes; // 5, 10, or 15
  String profileFor; // Myself, My Parent, My Spouse, My Child, Someone else
  int age;
  String gender;

  UserSettings({
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePhoto,
    required this.timezone,
    required this.language,
    required this.medicineReminder,
    required this.missedDose,
    required this.refillReminder,
    required this.dailySummary,
    required this.sound,
    required this.vibration,
    this.isPremium = false,
    this.isDarkMode = false,
    this.reminderAdvanceMinutes = 0,
    this.snoozeDurationMinutes = 10,
    this.profileFor = 'Myself',
    this.age = 0,
    this.gender = '',
  });

  bool get isProfileComplete => name.isNotEmpty && age > 0 && gender.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profilePhoto': profilePhoto,
      'timezone': timezone,
      'language': language,
      'medicineReminder': medicineReminder,
      'missedDose': missedDose,
      'refillReminder': refillReminder,
      'dailySummary': dailySummary,
      'sound': sound,
      'vibration': vibration,
      'isPremium': isPremium,
      'isDarkMode': isDarkMode,
      'reminderAdvanceMinutes': reminderAdvanceMinutes,
      'snoozeDurationMinutes': snoozeDurationMinutes,
      'profileFor': profileFor,
      'age': age,
      'gender': gender,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      timezone: map['timezone'] ?? '',
      language: map['language'] ?? 'English',
      medicineReminder: map['medicineReminder'] ?? true,
      missedDose: map['missedDose'] ?? true,
      refillReminder: map['refillReminder'] ?? true,
      dailySummary: map['dailySummary'] ?? true,
      sound: map['sound'] ?? true,
      vibration: map['vibration'] ?? true,
      isPremium: map['isPremium'] ?? false,
      isDarkMode: map['isDarkMode'] ?? false,
      reminderAdvanceMinutes: map['reminderAdvanceMinutes'] ?? 0,
      snoozeDurationMinutes: map['snoozeDurationMinutes'] ?? 10,
      profileFor: map['profileFor'] ?? 'Myself',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
    );
  }

  factory UserSettings.defaultSettings() {
    return UserSettings(
      name: '',
      email: '',
      phone: '',
      profilePhoto: '',
      timezone: '',
      language: 'English',
      medicineReminder: true,
      missedDose: true,
      refillReminder: true,
      dailySummary: true,
      sound: true,
      vibration: true,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSettings.fromJson(String source) =>
      UserSettings.fromMap(json.decode(source));
}

class VitalReading {
  final String id;
  final String patientId;
  final String type;
  final String? subType; // 'before_meal' or 'after_meal' for blood_sugar
  final double? systolic;
  final double? diastolic;
  final double? value;
  final String unit;
  final DateTime recordedAt;
  final String? notes;

  VitalReading({
    required this.id,
    this.patientId = 'default_patient',
    required this.type,
    this.subType,
    this.systolic,
    this.diastolic,
    this.value,
    required this.unit,
    required this.recordedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'type': type,
      'subType': subType,
      'systolic': systolic,
      'diastolic': diastolic,
      'value': value,
      'unit': unit,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory VitalReading.fromMap(Map<String, dynamic> map) {
    return VitalReading(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? 'default_patient',
      type: map['type'] ?? '',
      subType: map['subType'],
      systolic: (map['systolic'] as num?)?.toDouble(),
      diastolic: (map['diastolic'] as num?)?.toDouble(),
      value: (map['value'] as num?)?.toDouble(),
      unit: map['unit'] ?? '',
      recordedAt: DateTime.parse(map['recordedAt']),
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());

  factory VitalReading.fromJson(String source) =>
      VitalReading.fromMap(json.decode(source));

  String get displayValue {
    switch (type) {
      case 'blood_pressure':
        return '${systolic?.toInt() ?? 0}/${diastolic?.toInt() ?? 0}';
      case 'blood_sugar':
        return '${value?.toInt() ?? 0}';
      case 'weight':
        return '${value?.toStringAsFixed(1) ?? '0'}';
      case 'spo2':
        return '${value?.toInt() ?? 0}';
      case 'spirometer':
        return '${value?.toStringAsFixed(1) ?? '0'}';
      case 'walk':
        return '${value?.toInt() ?? 0}';
      default:
        return '';
    }
  }

  String get displayName {
    switch (type) {
      case 'blood_pressure':
        return 'Blood Pressure';
      case 'blood_sugar':
        final label = subType == 'after_meal' ? ' (After Meal)' : subType == 'before_meal' ? ' (Before Meal)' : '';
        return 'Blood Sugar$label';
      case 'weight':
        return 'Weight';
      case 'spo2':
        return 'SPO2';
      case 'spirometer':
        return 'Spirometer';
      case 'walk':
        return 'Walk Test';
      default:
        return '';
    }
  }
}

class Appointment {
  final String id;
  final String patientId;
  final String doctorName;
  final String specialization;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String location;
  final String? notes;
  final bool reminderEnabled;
  final int reminderMinutesBefore;
  final DateTime createdAt;

  Appointment({
    required this.id,
    this.patientId = 'default_patient',
    required this.doctorName,
    this.specialization = '',
    required this.appointmentDate,
    required this.appointmentTime,
    required this.location,
    this.notes,
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 30,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorName': doctorName,
      'specialization': specialization,
      'appointmentDate': appointmentDate.toIso8601String(),
      'appointmentTime': appointmentTime,
      'location': location,
      'notes': notes,
      'reminderEnabled': reminderEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? 'default_patient',
      doctorName: map['doctorName'] ?? '',
      specialization: map['specialization'] ?? '',
      appointmentDate: DateTime.parse(map['appointmentDate']),
      appointmentTime: map['appointmentTime'] ?? '',
      location: map['location'] ?? '',
      notes: map['notes'],
      reminderEnabled: map['reminderEnabled'] ?? true,
      reminderMinutesBefore: map['reminderMinutesBefore'] ?? 30,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Appointment.fromJson(String source) =>
      Appointment.fromMap(json.decode(source));

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
    
    if (appointmentDay == today) return 'Today';
    if (appointmentDay == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (appointmentDay == today.subtract(const Duration(days: 1))) return 'Yesterday';
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[appointmentDate.month - 1]} ${appointmentDate.day}, ${appointmentDate.year}';
  }

  bool get isUpcoming => appointmentDate.isAfter(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year && 
           appointmentDate.month == now.month && 
           appointmentDate.day == now.day;
  }
}

class InventoryTransaction {
  final String id;
  final String medicineId;
  final String medicineName;
  final String type; // 'initial', 'dose_consumed', 'refill', 'adjustment'
  final double quantityChange; // positive for add, negative for consume
  final double stockAfter;
  final DateTime createdAt;
  final String? notes;
  final String patientId;

  InventoryTransaction({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.type,
    required this.quantityChange,
    required this.stockAfter,
    required this.createdAt,
    this.notes,
    this.patientId = 'default_patient',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'type': type,
      'quantityChange': quantityChange,
      'stockAfter': stockAfter,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'patientId': patientId,
    };
  }

  factory InventoryTransaction.fromMap(Map<String, dynamic> map) {
    return InventoryTransaction(
      id: map['id'] ?? '',
      medicineId: map['medicineId'] ?? '',
      medicineName: map['medicineName'] ?? '',
      type: map['type'] ?? '',
      quantityChange: (map['quantityChange'] as num?)?.toDouble() ?? 0.0,
      stockAfter: (map['stockAfter'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['createdAt']),
      notes: map['notes'],
      patientId: map['patientId'] ?? 'default_patient',
    );
  }

  String toJson() => json.encode(toMap());

  factory InventoryTransaction.fromJson(String source) =>
      InventoryTransaction.fromMap(json.decode(source));

  String get typeDisplayName {
    switch (type) {
      case 'initial':
        return 'Initial stock';
      case 'dose_consumed':
        return 'Dose taken';
      case 'refill':
        return 'Refill';
      case 'adjustment':
        return 'Manual adjustment';
      default:
        return type;
    }
  }
}
