import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'database_helper.dart';
import 'models.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showProfileSetup = false;

  // Profile setup controllers
  final TextEditingController _nameController = TextEditingController(
    text: 'Sanket',
  );
  final TextEditingController _ageController = TextEditingController(
    text: '28',
  );
  String _selectedGender = 'Male';
  String _selectedTimezone = 'GMT+5:30 (India Standard Time)';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() {
        _showProfileSetup = true;
      });
    }
  }

  void _skipOnboarding() {
    setState(() {
      _showProfileSetup = true;
    });
  }

  void _saveProfileAndStart() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    // Validate age is a number
    final age = _ageController.text.trim();
    if (age.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your age')));
      return;
    }
    int? parsedAge;
    try {
      parsedAge = int.parse(age);
      if (parsedAge < 0 || parsedAge > 120) {
        throw FormatException();
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a valid age (0-120)')));
      return;
    }

    final newUserSettings = UserSettings(
      name: _nameController.text.trim(),
      email:
          '${_nameController.text.trim().toLowerCase().replaceAll(' ', '')}@example.com',
      phone: '+91 98765 43210',
      profilePhoto: '',
      timezone: _selectedTimezone.split(' ')[0],
      language: 'English',
      medicineReminder: true,
      missedDose: true,
      refillReminder: true,
      dailySummary: true,
      sound: true,
      vibration: true,
    );

    await DatabaseHelper.instance.saveUserSettings(newUserSettings);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showProfileSetup) {
      return _buildProfileSetupScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildPage(
                    title: 'Your daily medication companion.',
                    description:
                        'Stay on top of your medications with timely reminders tailored to your schedule.',
                    illustration: _buildHandsPillIllustration(),
                  ),
                  _buildPage(
                    title: 'Never miss a dose.',
                    description:
                        'Get smart push alerts when it is time to take pills. Snooze if you are busy or mark as skipped.',
                    illustration: _buildAlarmPillIllustration(),
                  ),
                  _buildPage(
                    title: 'Track your medication progress.',
                    description:
                        'Check daily adherence statistics, review calendar history, and get notified before stock runs out.',
                    illustration: _buildProgressPillIllustration(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicator Dots
                  Row(
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: _currentPage == index ? 24.0 : 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF5B8DEF)
                              : const Color(0xFF7BA7F7).withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  // CTA button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B8DEF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _currentPage == 2 ? 'Get Started' : 'Next',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildPage({
    required String title,
    required String description,
    required Widget illustration,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Center(child: illustration)),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF202733),
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF718096),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Illustrations drawn using Flutter containers to represent the premium pill aesthetic
  Widget _buildHandsPillIllustration() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B8DEF).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF),
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                top: 20,
                child: _buildDecorativePill(
                  const Color(0xFF5B8DEF),
                  70,
                  30,
                  30,
                ),
              ),
              Positioned(
                bottom: 25,
                left: 15,
                child: _buildDecorativePill(
                  const Color(0xFFE85D75),
                  60,
                  26,
                  -15,
                ),
              ),
              Positioned(
                bottom: 20,
                right: 15,
                child: _buildDecorativePill(
                  const Color(0xFF20C9D8),
                  65,
                  28,
                  60,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Icon(
            Icons.favorite_rounded,
            color: Color(0xFFE85D75),
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmPillIllustration() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B8DEF).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Alarm clock background outline
          Icon(
            Icons.alarm,
            size: 140,
            color: const Color(0xFF7BA7F7).withOpacity(0.15),
          ),
          // Floating reminder pill card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B8DEF).withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Color(0xFF5B8DEF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metformin',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF202733),
                      ),
                    ),
                    Text(
                      '7:00 AM — Before Breakfast',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPillIllustration() {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B8DEF).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF20C9D8),
                    ),
                    backgroundColor: Color(0xFFF3F6FF),
                  ),
                ),
                Text(
                  '85%',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF202733),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Medication Adherence',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativePill(
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

  Widget _buildProfileSetupScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF202733)),
          onPressed: () {
            setState(() {
              _showProfileSetup = false;
            });
          },
        ),
        title: Text(
          'Profile Setup',
          style: GoogleFonts.inter(
            color: const Color(0xFF202733),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                'Let\'s get started!',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF202733),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us a little bit about yourself so we can customize your medication dashboard.',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF718096),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Form fields
              _buildLabel('Name'),
              _buildTextField(_nameController, 'Enter your name'),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Age'),
                        _buildTextField(
                          _ageController,
                          'e.g., 28',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Gender'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF718096),
                              ),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF202733),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              onChanged: (String? val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedGender = val;
                                  });
                                }
                              },
                              items: ['Male', 'Female', 'Other'].map((
                                String val,
                              ) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(val),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildLabel('Timezone'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTimezone,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF718096),
                    ),
                    style: GoogleFonts.inter(
                      color: const Color(0xFF202733),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (String? val) {
                      if (val != null) {
                        setState(() {
                          _selectedTimezone = val;
                        });
                      }
                    },
                    items:
                        [
                          'GMT+5:30 (India Standard Time)',
                          'GMT-5:00 (Eastern Standard Time)',
                          'GMT+0:00 (Greenwich Mean Time)',
                          'GMT+1:00 (Central European Time)',
                          'GMT+8:00 (China Standard Time)',
                        ].map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfileAndStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B8DEF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text(
                    'Continue as Guest',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF718096),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String placeholder, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          color: const Color(0xFF202733),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF718096).withOpacity(0.6),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
