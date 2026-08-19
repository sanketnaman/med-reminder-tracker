import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'models.dart';
import 'alarm_service.dart';
import 'add_edit_medicine_screen.dart';

class TodayPlanScreen extends StatefulWidget {
  final VoidCallback onRefreshHome;
  final String patientId;
  const TodayPlanScreen({
    super.key,
    required this.onRefreshHome,
    this.patientId = 'default_patient',
  });

  @override
  State<TodayPlanScreen> createState() => _TodayPlanScreenState();
}

class _TodayPlanScreenState extends State<TodayPlanScreen> {
  List<DoseRecord> _records = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadTodayPlan();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {}); // Refresh countdowns
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadTodayPlan() async {
    final list = await DatabaseHelper.instance.getDoseRecordsForDate(
      DateTime.now(),
      patientId: widget.patientId,
    );
    if (mounted) {
      setState(() {
        _records = list;
        _isLoading = false;
      });
    }
  }

  void _markAsTaken(DoseRecord record) async {
    record.status = 'taken';
    record.takenAt = DateTime.now();
    await DatabaseHelper.instance.updateDoseRecord(record);
    await AlarmService.cancel(record.id);
    _loadTodayPlan();
    widget.onRefreshHome();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${record.medicineName} marked as Taken!')),
      );
    }
  }

  void _snoozeReminder(DoseRecord record) async {
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Snooze Dose',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: const Text('How long would you like to snooze this reminder?'),
        actions: [
          _snoozeAction(context, '10 Min', 10),
          _snoozeAction(context, '30 Min', 30),
          _snoozeAction(context, '1 Hour', 60),
        ],
      ),
    );

    if (minutes != null) {
      record.status = 'snoozed';
      record.snoozedUntil = DateTime.now().add(Duration(minutes: minutes));
      await DatabaseHelper.instance.updateDoseRecord(record);
      await AlarmService.cancel(record.id);
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
      await AlarmService.schedule(snoozedDose);
      _loadTodayPlan();
      widget.onRefreshHome();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Snoozed for $minutes minutes.')),
        );
      }
    }
  }

  Widget _snoozeAction(BuildContext context, String text, int value) {
    return TextButton(
      onPressed: () => Navigator.pop(context, value),
      child: Text(text, style: const TextStyle(color: Color(0xFF5B8DEF))),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Math stats
    final total = _records.length;
    final taken = _records.where((r) => r.status == 'taken').length;
    final completionPercent = total > 0 ? ((taken / total) * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 16.0,
                bottom: 8.0,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Color(0xFF202733),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Plan',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF202733),
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM dd').format(DateTime.now()),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF718096),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Matching progress card
                          _buildPlanProgressCard(
                            total,
                            taken,
                            completionPercent,
                          ),
                          const SizedBox(height: 24),

                          // Medication Schedule timeline
                          _records.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _records.length,
                                  itemBuilder: (context, index) {
                                    final rec = _records[index];
                                    return _buildPlanItem(rec);
                                  },
                                ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 50,
              color: const Color(0xFF7BA7F7).withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No medication scheduled for today.',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF202733),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add medicines with scheduled times to see them here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF718096),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final canAdd = await DatabaseHelper.instance.canAddMedicine('');
                if (!canAdd && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Free plan limited to ${DatabaseHelper.freeMedicineLimit} medicines. Upgrade to Premium.'),
                      backgroundColor: const Color(0xFFE85D75),
                      action: SnackBarAction(
                        label: 'Upgrade',
                        textColor: Colors.white,
                        onPressed: () async {
                          await DatabaseHelper.instance.setPremium(true);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Premium activated!'),
                                backgroundColor: Color(0xFF35B779),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditMedicineScreen(
                      patientId: '',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Add Medicine',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8DEF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanProgressCard(int total, int taken, int percent) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B8DEF), Color(0xFF7BA7F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B8DEF).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Medication Progress',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$total',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Total Dose',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 48),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$taken',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Taken',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Circular Progress
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 8,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF20C9D8),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
                Text(
                  '$percent%',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem(DoseRecord record) {
    final now = DateTime.now();
    final isUpcoming =
        record.scheduledAt.isAfter(now) && record.status == 'scheduled';

    // Calculate time left helper
    String timeLeftLabel = '';
    if (isUpcoming) {
      final diff = record.scheduledAt.difference(now);
      if (diff.inMinutes < 60) {
        timeLeftLabel = '${diff.inMinutes}m Left';
      } else {
        timeLeftLabel = '${diff.inHours}h Left';
      }
    }

    final isTaken = record.status == 'taken';
    final timeStr = DateFormat('hh:mm a').format(record.scheduledAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Pill Icon outline
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isTaken
                  ? const Color(0xFF35B779).withOpacity(0.1)
                  : const Color(0xFF5B8DEF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTaken ? Icons.check_circle_outline : Icons.vaccines_outlined,
              color: isTaken
                  ? const Color(0xFF35B779)
                  : const Color(0xFF5B8DEF),
            ),
          ),
          const SizedBox(width: 14),

          // Medicine Name & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (timeLeftLabel.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D75).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      timeLeftLabel,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFE85D75),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                Text(
                  record.medicineName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF202733),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${record.dosage.toInt()} ${record.dosageUnit}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF718096),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isTaken)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF35B779).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Taken',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF35B779),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                )
              else ...[
                ElevatedButton(
                  onPressed: () => _markAsTaken(record),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B8DEF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Taken',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                OutlinedButton(
                  onPressed: () => _snoozeReminder(record),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.snooze,
                        size: 12,
                        color: Color(0xFF718096),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Snooze',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF718096),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
