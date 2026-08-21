import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'models.dart';
import 'alarm_service.dart';
import 'medicine_icon.dart';
import 'l10n/generated/app_localizations.dart';

class AlarmScreen extends StatefulWidget {
  final DoseRecord record;
  const AlarmScreen({super.key, required this.record});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;
  late AnimationController _cardController;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;
  late AnimationController _btnController;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    // Bell pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Concentric ring expand animation
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _ringAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    // Card slide-in
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardController.forward();

    // Button press scale
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _btnScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeInOut),
    );

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
    _pulseController.dispose();
    _ringController.dispose();
    _cardController.dispose();
    _btnController.dispose();
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
          AppLocalizations.of(context)!.skipDose,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to mark this dose of ${widget.record.medicineName} as skipped?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
            ),
            child: Text(AppLocalizations.of(context)!.alarmSkip, style: TextStyle(color: Colors.white)),
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
    final record = widget.record;
    final timeStr = DateFormat('hh:mm a').format(record.scheduledAt);
    final dateStr = DateFormat('dd MMMM, yyyy').format(DateTime.now());

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD92F4F),
                Color(0xFFE94B64),
                Color(0xFFF06B7D),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Subtle radial glow
              Positioned(
                top: -120,
                left: 0,
                right: 0,
                height: 400,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -80,
                right: -80,
                height: 260,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Top bar: logo + close
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/logo_transparent.png',
                                width: 32,
                                height: 32,
                                errorBuilder: (ctx, e, s) => Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.medical_services,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.appTitle,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Bell with concentric rings
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Expanding rings
                          AnimatedBuilder(
                            animation: _ringAnimation,
                            builder: (context, _) {
                              return CustomPaint(
                                size: const Size(160, 160),
                                painter: _ConcentricRingPainter(
                                  progress: _ringAnimation.value,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          // Bell icon with pulse
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                size: 52,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Headline
                    Text(
                      AppLocalizations.of(context)!.timeToTake,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.dontForget,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Medicine info card
                    SlideTransition(
                      position: _cardSlide,
                      child: FadeTransition(
                        opacity: _cardFade,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Medicine icon (large, no circle)
                              MedicineIcon(
                                medicineType: record.medicineType,
                                size: 64,
                              ),
                              const SizedBox(height: 16),

                              // Meal relation pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  record.mealRelation.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Medicine name
                              Text(
                                record.medicineName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Dosage & time
                              Text(
                                '${record.dosage.toInt()} ${record.dosageUnit}  •  $timeStr',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              // Notes
                              if (record.notes != null &&
                                  record.notes!.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: Colors.white.withOpacity(0.6),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          record.notes!,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Divider
                              Container(
                                height: 1,
                                color: Colors.white.withOpacity(0.12),
                              ),

                              const SizedBox(height: 14),

                              // Date + consistency
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    dateStr,
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppLocalizations.of(context)!.stayConsistent,
                                    style: GoogleFonts.inter(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Primary action: I Take It
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTapDown: (_) => _btnController.forward(),
                        onTapUp: (_) {
                          _btnController.reverse();
                          _onTaken();
                        },
                        onTapCancel: () => _btnController.reverse(),
                        child: AnimatedBuilder(
                          animation: _btnScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _btnScale.value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFFD92F4F),
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.iTakeIt,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFD92F4F),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Secondary actions: Skip + Snooze
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _onSkip,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.skip_next_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppLocalizations.of(context)!.alarmSkip,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: GestureDetector(
                              onTap: _onSnooze,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.snooze_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppLocalizations.of(context)!.snooze10m,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConcentricRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ConcentricRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final p = (progress + i * 0.33).clamp(0.0, 1.0);
      final radius = maxRadius * (0.5 + p * 0.5);
      final opacity = (1.0 - p) * 0.25;
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingPainter old) =>
      old.progress != progress;
}
