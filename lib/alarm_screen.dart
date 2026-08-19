import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'database_helper.dart';
import 'models.dart';
import 'alarm_service.dart';

class AlarmScreen extends StatefulWidget {
  final DoseRecord record;
  const AlarmScreen({super.key, required this.record});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Keep screen on and show over lock screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    // Setup flashing red animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Play native alarm ringtone loop
    _playAlarmSound();
  }

  void _playAlarmSound() {
    FlutterRingtonePlayer().playAlarm(
      looping: true,
      asAlarm: true,
      volume: 1.0,
    );
  }

  void _stopAlarmSound() {
    FlutterRingtonePlayer().stop();
  }

  @override
  void dispose() {
    _stopAlarmSound();
    _animationController.dispose();
    super.dispose();
  }

  void _onTaken() async {
    _stopAlarmSound();
    widget.record.status = 'taken';
    widget.record.takenAt = DateTime.now();
    await DatabaseHelper.instance.updateDoseRecord(widget.record);
    await AlarmService.cancel(widget.record.id);
    if (mounted) {
      Navigator.pop(context, 'taken');
    }
  }

  void _onSkip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Skip Dose',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to mark this dose of ${widget.record.medicineName} as skipped?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
            ),
            child: const Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _stopAlarmSound();
      widget.record.status = 'skipped';
      await DatabaseHelper.instance.updateDoseRecord(widget.record);
      await AlarmService.cancel(widget.record.id);
      if (mounted) {
        Navigator.pop(context, 'skipped');
      }
    }
  }

  void _onSnooze() async {
    _stopAlarmSound();
    widget.record.status = 'snoozed';
    widget.record.snoozedUntil = DateTime.now().add(
      const Duration(minutes: 10),
    );
    await DatabaseHelper.instance.updateDoseRecord(widget.record);
    await AlarmService.cancel(widget.record.id);
    final snoozedDose = DoseRecord(
      id: '${widget.record.id}_snooze_${DateTime.now().millisecondsSinceEpoch}',
      patientId: widget.record.patientId,
      medicineId: widget.record.medicineId,
      medicineName: widget.record.medicineName,
      medicineType: widget.record.medicineType,
      dosage: widget.record.dosage,
      dosageUnit: widget.record.dosageUnit,
      mealRelation: widget.record.mealRelation,
      scheduledAt: widget.record.snoozedUntil!,
      status: 'scheduled',
      notes: widget.record.notes,
    );
    await DatabaseHelper.instance.addDoseRecord(snoozedDose);
    await AlarmService.schedule(snoozedDose);
    if (mounted) {
      Navigator.pop(context, 'snoozed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      body: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE85D75).withOpacity(_opacityAnimation.value),
                  const Color(0xFFB3263E).withOpacity(_opacityAnimation.value),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flashing Bell Icon
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Alarm text
                Text(
                  'MEDICINE REMINDER',
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                // Medicine Name
                Text(
                  widget.record.medicineName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Dosage & Instructions card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${widget.record.dosage.toInt()} ${widget.record.dosageUnit}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.record.mealRelation,
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.record.notes != null &&
                          widget.record.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Note: ${widget.record.notes}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),

                // Action Buttons: Taken / Skip / Snooze
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onTaken,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB3263E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                    ),
                    child: Text(
                      'I Take It',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onSkip,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onSnooze,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.25),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Snooze (10m)',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
