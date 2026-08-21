import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';
import 'animation_utils.dart';
import 'app_theme.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isYearlySelected = true;
  bool _isPremium = false;
  bool _isLoading = false;

  static const double _monthlyPrice = 199;
  static const double _yearlyPrice = 1799;
  static const double _yearlySavingPercent = 25;

  double get _monthlyEquivalent => _yearlyPrice / 12;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final isPremium = await DatabaseHelper.instance.isPremium();
    if (mounted) setState(() => _isPremium = isPremium);
  }

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);
    // Connects to existing dev toggle — replace with real IAP later
    await DatabaseHelper.instance.setPremium(true);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _isPremium = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    if (_isPremium) ...[
                      const SizedBox(height: 24),
                      _buildActiveBanner(),
                    ] else ...[
                      const SizedBox(height: 8),
                      _buildHeroSection(),
                      const SizedBox(height: 24),
                      _buildBenefitsSection(),
                      const SizedBox(height: 24),
                      _buildPlanSelector(),
                    ],
                    const SizedBox(height: 24),
                    _buildLegalSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (!_isPremium) _buildBottomCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'PREMIUM',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: const Color(0xFF5B8DEF),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A7DE8), Color(0xFF5B8DEF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B8DEF).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Abstract medication icons
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFloatingIcon('assets/icons/tablet.svg', -20, 0.9),
                const SizedBox(width: 16),
                _buildFloatingIcon('assets/icons/Capsule.svg', 10, 1.1),
                const SizedBox(width: 16),
                _buildFloatingIcon('assets/icons/Syrup.svg', -5, 1.0),
                const SizedBox(width: 16),
                _buildFloatingIcon('assets/icons/Injection.svg', 15, 0.95),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Stay on top of\nevery dose.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'More control. More confidence.\nBetter medication management.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(String asset, double offsetY, double scale) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SvgPicture.asset(
              asset,
              width: 24,
              height: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF35B779).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF35B779),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mediaro Premium',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Active — All features unlocked',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icons/Other.svg',
            width: 24,
            height: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {
        'icon': 'assets/icons/tablet.svg',
        'title': 'Unlimited medicines',
        'desc': 'Manage all your medications without the Free plan limit.',
      },
      {
        'icon': 'assets/icons/Other.svg',
        'title': 'Unlimited dependents',
        'desc': 'Manage medication schedules for your entire family.',
      },
      {
        'icon': 'assets/icons/blood_pressure.svg',
        'title': 'Daily vitals',
        'desc': 'Track BP, blood sugar, SpO2 and weight.',
      },
      {
        'icon': 'assets/icons/doctor_appointment.svg',
        'title': 'Doctor appointments',
        'desc': 'Never forget an upcoming appointment.',
      },
      {
        'icon': 'assets/icons/Other.svg',
        'title': 'Health reports',
        'desc': 'Generate doctor-ready PDF reports with vitals and adherence.',
      },
      {
        'icon': 'assets/icons/morning.svg',
        'title': 'Advanced insights',
        'desc': 'Understand your medication adherence over time.',
      },
      {
        'icon': 'assets/icons/night.svg',
        'title': 'Ad-free experience',
        'desc': 'Use Mediaro without advertisements.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why go Premium?',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...benefits.asMap().entries.map((entry) => FadeSlideIn(
            delay: Duration(milliseconds: 80 * entry.key),
            offset: 10,
            child: _buildBenefitTile(
              entry.value['icon']!,
              entry.value['title']!,
              entry.value['desc']!,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBenefitTile(String icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5B8DEF).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your plan',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _buildPlanCard(
            isYearly: true,
            label: 'YEARLY',
            price: '₹${_yearlyPrice.toInt()}',
            period: '/ year',
            subtext: '≈ ₹${_monthlyEquivalent.toInt()} / month',
            saving: '${_yearlySavingPercent.toInt()}%',
            badge: 'BEST VALUE',
          ),
          const SizedBox(height: 12),
          _buildPlanCard(
            isYearly: false,
            label: 'MONTHLY',
            price: '₹${_monthlyPrice.toInt()}',
            period: '/ month',
            subtext: null,
            saving: null,
            badge: null,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required bool isYearly,
    required String label,
    required String price,
    required String period,
    String? subtext,
    String? saving,
    String? badge,
  }) {
    final isSelected = _isYearlySelected == isYearly;

    return GestureDetector(
      onTap: () => setState(() => _isYearlySelected = isYearly),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B8DEF).withOpacity(0.04) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B8DEF) : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF5B8DEF).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            // Selection indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF5B8DEF) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF5B8DEF) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF35B779).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF35B779),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: price,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: period,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (subtext != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtext,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (saving != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE85D75).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SAVE $saving',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE85D75),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'Cancel anytime. Your subscription is managed securely through Google Play.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Terms of Service',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF5B8DEF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '  ·  ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Privacy Policy',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF5B8DEF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppTheme.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary CTA with press feedback
          AnimatedOpacityOnTap(
            onTap: _isLoading ? null : _handlePurchase,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8DEF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF5B8DEF).withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isYearlySelected
                          ? 'Continue with Yearly — ₹${_yearlyPrice.toInt()}/year'
                          : 'Continue with Monthly — ₹${_monthlyPrice.toInt()}/month',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          ),
          const SizedBox(height: 10),
          // Restore purchases
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'No previous purchases found.',
                    style: GoogleFonts.inter(),
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: Text(
              'Restore Purchases',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
