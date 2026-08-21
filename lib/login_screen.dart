import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';
import 'onboarding_screen.dart';
import 'database_helper.dart';
import 'app_theme.dart';
import 'l10n/generated/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null && mounted) {
        await DatabaseHelper.instance.initializeDataIfNeeded();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _signInAsGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background pill decorations
          Positioned(
            top: -20,
            right: -20,
            child: _buildBackgroundPill(
              Colors.orange.withValues(alpha: 0.15),
              120,
              60,
              45,
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: _buildBackgroundPill(
              const Color(0xFFE85D75).withValues(alpha: 0.15),
              160,
              80,
              -30,
            ),
          ),
          Positioned(
            bottom: 40,
            right: -40,
            child: _buildBackgroundPill(
              const Color(0xFF20C9D8).withValues(alpha: 0.15),
              140,
              70,
              15,
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B8DEF).withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: CustomPaint(
                            size: const Size(50, 50),
                            painter: _PillLogoPainter(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App name
                  Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: GoogleFonts.inter(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.neverMissDose,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                       color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Google Sign-In button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.cardBg,
                        foregroundColor: AppTheme.textPrimary,
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF5B8DEF),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                  width: 22,
                                  height: 22,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.g_mobiledata,
                                    size: 28,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppLocalizations.of(context)!.continueGoogle,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Guest button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _signInAsGuest,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF5B8DEF),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 22,
                            color: Color(0xFF5B8DEF),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context)!.continueGuest,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF5B8DEF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms
                  Text(
                    'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

class _PillLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-45 * 3.14159 / 180);

    final capRect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.45,
      height: size.height * 0.9,
    );

    // Left half (Blue)
    paint.color = const Color(0xFF5B8DEF);
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

    // Separation band
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawLine(
      Offset(-size.width * 0.225, 0),
      Offset(size.width * 0.225, 0),
      paint,
    );

    // Highlight
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(-size.width * 0.1, -size.height * 0.2), 3, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
