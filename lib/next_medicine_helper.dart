import 'dart:developer' as developer;
import 'models.dart';

enum NextMedicineStatus { due, upcoming, allCompleted }

class NextMedicineInfo {
  final DoseRecord primaryRecord;
  final List<DoseRecord> sameTimeRecords;
  final NextMedicineStatus status;
  final int totalRemaining;
  final String? timeLabel;

  NextMedicineInfo({
    required this.primaryRecord,
    required this.sameTimeRecords,
    required this.status,
    required this.totalRemaining,
    this.timeLabel,
  });

  int get groupCount => sameTimeRecords.length;
  bool get isGrouped => groupCount > 1;
}

class NextMedicineHelper {
  static NextMedicineInfo? calculate({
    required List<DoseRecord> records,
    required DateTime selectedDate,
  }) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    // Filter: only scheduled records (not taken, not missed, not skipped, not snoozed)
    final candidates = records.where((r) {
      return r.status == 'scheduled';
    }).toList();

    developer.log('=== NextMedicineHelper.calculate ===', name: 'NextMedicine');
    developer.log('Current local DateTime: $now', name: 'NextMedicine');
    developer.log('Selected date: $selectedDate (isToday: $isToday)', name: 'NextMedicine');
    developer.log('Total records: ${records.length}', name: 'NextMedicine');
    developer.log('Candidates (scheduled): ${candidates.length}', name: 'NextMedicine');

    for (final r in records) {
      final diff = r.scheduledAt.difference(now);
      developer.log(
        '  ${r.medicineName} | scheduledAt: ${r.scheduledAt} | status: ${r.status} | diff: ${diff.inMinutes}min',
        name: 'NextMedicine',
      );
    }

    if (candidates.isEmpty) {
      developer.log('No candidates → returning null (allCompleted)', name: 'NextMedicine');
      return null;
    }

    // Split into due (past/now) and upcoming (future)
    final dueRecords = <DoseRecord>[];
    final upcomingRecords = <DoseRecord>[];

    for (final r in candidates) {
      if (isToday && !r.scheduledAt.isAfter(now)) {
        dueRecords.add(r);
      } else if (r.scheduledAt.isAfter(now)) {
        upcomingRecords.add(r);
      }
    }

    developer.log('Due records: ${dueRecords.length}', name: 'NextMedicine');
    for (final r in dueRecords) {
      final elapsed = now.difference(r.scheduledAt);
      developer.log('  DUE: ${r.medicineName} at ${r.scheduledAt} (${elapsed.inMinutes}min ago)', name: 'NextMedicine');
    }
    developer.log('Upcoming records: ${upcomingRecords.length}', name: 'NextMedicine');
    for (final r in upcomingRecords) {
      final diff = r.scheduledAt.difference(now);
      developer.log('  UPCOMING: ${r.medicineName} at ${r.scheduledAt} (in ${diff.inMinutes}min)', name: 'NextMedicine');
    }

    // Sort upcoming by scheduledAt
    upcomingRecords.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    // Pick the next medicine: due first, then upcoming
    final List<DoseRecord> source;
    NextMedicineStatus status;

    if (dueRecords.isNotEmpty) {
      // Group due records by scheduledAt time
      dueRecords.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      source = dueRecords;
      status = NextMedicineStatus.due;
      developer.log('→ Showing DUE: ${dueRecords.first.medicineName}', name: 'NextMedicine');
    } else if (upcomingRecords.isNotEmpty) {
      source = upcomingRecords;
      status = NextMedicineStatus.upcoming;
      developer.log('→ Showing UPCOMING: ${upcomingRecords.first.medicineName}', name: 'NextMedicine');
    } else {
      developer.log('No due or upcoming → returning null', name: 'NextMedicine');
      return null;
    }

    // Group by scheduledAt time (within 1 minute tolerance for same-time grouping)
    final primary = source.first;
    final sameTime = source.where((r) {
      return r.scheduledAt.difference(primary.scheduledAt).inMinutes.abs() < 1;
    }).toList();

    // Total remaining = all candidates (due + upcoming)
    final totalRemaining = candidates.length;

    // Time label
    String? timeLabel;
    if (status == NextMedicineStatus.upcoming) {
      final diff = primary.scheduledAt.difference(now);
      if (diff.inMinutes < 1) {
        timeLabel = 'Due now';
      } else if (diff.inMinutes < 60) {
        timeLabel = 'In ${diff.inMinutes} min';
      } else if (diff.inHours < 24) {
        final h = diff.inHours;
        final m = diff.inMinutes % 60;
        timeLabel = m > 0 ? 'In $h h $m min' : 'In $h h';
      }
    } else if (status == NextMedicineStatus.due) {
      final elapsed = now.difference(primary.scheduledAt);
      if (elapsed.inMinutes < 60) {
        timeLabel = '${elapsed.inMinutes} min overdue';
      } else {
        final h = elapsed.inHours;
        timeLabel = '$h h overdue';
      }
    }

    developer.log('Result: ${primary.medicineName} | status: $status | timeLabel: $timeLabel', name: 'NextMedicine');

    return NextMedicineInfo(
      primaryRecord: primary,
      sameTimeRecords: sameTime,
      status: status,
      totalRemaining: totalRemaining,
      timeLabel: timeLabel,
    );
  }
}
