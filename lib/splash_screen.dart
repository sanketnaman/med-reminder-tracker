import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'database_helper.dart';
import 'alarm_service.dart';
import 'auth_service.dart';
import 'animation_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    try {
      await DatabaseHelper.instance.initializeDataIfNeeded();
      await DatabaseHelper.instance.migrateExistingData();
      await DatabaseHelper.instance.fixExistingRecordsMedicineType();
      await AlarmService.requestPermissions();
      await AlarmService.scheduleAllUpcoming();
      await _rescheduleAppointmentReminders();
    } catch (e) {
      debugPrint('Splash initialization error: $e');
    }

    Timer(const Duration(milliseconds: 1800), () async {
      if (mounted) {
        final isLoggedIn = AuthService.isLoggedIn;
        Widget destination;

        if (!isLoggedIn) {
          destination = const LoginScreen();
        } else {
          final settings = await DatabaseHelper.instance.getUserSettings();
          final hasCompleteProfile = settings.name.isNotEmpty && settings.age > 0 && settings.gender.isNotEmpty;
          destination = hasCompleteProfile ? const HomeScreen() : const OnboardingScreen();
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => destination,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        ).then((_) {
          AlarmService.handlePendingAlarmIfAny();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: Stack(
        children: [
          // Graphic Pill Shapes in Background
          Positioned(
            top: -20,
            right: -20,
            child: _buildBackgroundPill(
              Colors.orange.withOpacity(0.15),
              120,
              60,
              45,
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: _buildBackgroundPill(
              const Color(0xFFE85D75).withOpacity(0.15),
              160,
              80,
              -30,
            ),
          ),
          Positioned(
            bottom: 40,
            right: -40,
            child: _buildBackgroundPill(
              const Color(0xFF20C9D8).withOpacity(0.15),
              140,
              70,
              15,
            ),
          ),
          // Centered Brand Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom Pill Logo — fade + scale in
                FadeScaleIn(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B8DEF).withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(50, 50),
                        painter: PillLogoPainter(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App Name — staggered fade in
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  offset: 8,
                  child: const Text(
                    'Doseza',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF202733),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline — staggered fade in
                FadeSlideIn(
                  delay: const Duration(milliseconds: 350),
                  offset: 8,
                  child: const Text(
                    'Never miss a dose.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF718096),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Loading indicator at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFF5B8DEF).withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rescheduleAppointmentReminders() async {
    final appointments = await DatabaseHelper.instance.getAppointments();
    final now = DateTime.now();
    for (final appt in appointments) {
      if (appt.appointmentDate.isAfter(now)) {
        await AlarmService.scheduleAppointmentReminder(appt);
      }
    }
  }

  Widget _buildBackgroundPill(
    Color color,
    double width,
    double height,
    double angle,
  ) {
    return Transform.rotate(
      angle: angle * 3.14159 / 180,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class PillLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw blue half of pill
    paint.color = const Color(0xFF5B8DEF);

    // Draw rotated capsule
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-45 * 3.14159 / 180);

    final capRect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.45,
      height: size.height * 0.9,
    );

    // Left half (Blue)
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(-size.width, -size.height, size.width, size.height * 2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, Radius.circular(size.width * 0.225)),
      paint,
    );
    canvas.restore();

    // Right half (Red/Coral)
    paint.color = const Color(0xFFE85D75);
    canvas.save();
    canvas.clipRect(
      Rect.fromLTWH(0, -size.height, size.width, size.height * 2),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, Radius.circular(size.width * 0.225)),
      paint,
    );
    canvas.restore();

    // Draw separation band
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawLine(
      Offset(-size.width * 0.225, 0),
      Offset(size.width * 0.225, 0),
      paint,
    );

    // Draw highlights
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(Offset(-size.width * 0.1, -size.height * 0.2), 3, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
