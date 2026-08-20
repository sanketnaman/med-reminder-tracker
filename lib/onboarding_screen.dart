import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'database_helper.dart';
import 'models.dart';
import 'auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedGender = '';
  String _profileFor = 'Myself';
  String _selectedLanguage = 'English';
  String _selectedTimezone = '';
  bool _reminderSound = true;
  int _reminderAdvanceMinutes = 0;
  int _snoozeDurationMinutes = 10;
  String? _profilePhotoPath;
  String? _googlePhotoUrl;
  bool _isGoogleUser = false;
  bool _emailVerified = false;
  bool _isLoading = false;

  static const _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const _profileForOptions = ['Myself', 'My Parent', 'My Spouse', 'My Child', 'Someone else'];
  static const _languageOptions = ['English', 'Hindi', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Arabic', 'Portuguese', 'Russian'];
  static const _advanceOptions = [0, 5, 10];
  static const _snoozeOptions = [5, 10, 15];

  @override
  void initState() {
    super.initState();
    _prefillFromGoogle();
    _detectTimezone();
  }

  void _prefillFromGoogle() {
    final user = AuthService.currentUser;
    if (user != null) {
      _isGoogleUser = true;
      _nameController.text = user.displayName ?? '';
      _googlePhotoUrl = user.photoURL;
      _emailVerified = user.emailVerified;
    }
  }

  void _detectTimezone() {
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60);
    final sign = hours >= 0 ? '+' : '-';
    final h = hours.abs().toString().padLeft(2, '0');
    final m = minutes.abs().toString().padLeft(2, '0');
    _selectedTimezone = 'GMT$sign$h:$m';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  int _calculateCompletionPercent() {
    int filled = 0;
    const total = 5;
    if (_nameController.text.trim().isNotEmpty) filled++;
    if (_ageController.text.trim().isNotEmpty) {
      final age = int.tryParse(_ageController.text.trim());
      if (age != null && age > 0 && age <= 120) filled++;
    }
    if (_selectedGender.isNotEmpty) filled++;
    if (_profileFor.isNotEmpty) filled++;
    if (_selectedTimezone.isNotEmpty) filled++;
    return ((filled / total) * 100).round();
  }

  String _mapProfileForToRelation(String profileFor) {
    switch (profileFor) {
      case 'Myself':
        return 'Self';
      case 'My Parent':
        return 'Father';
      case 'My Spouse':
        return 'Spouse';
      case 'My Child':
        return 'Son';
      default:
        return 'Other';
    }
  }

  Future<void> _saveProfileAndContinue() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your age')),
      );
      return;
    }
    int? parsedAge;
    try {
      parsedAge = int.parse(ageText);
      if (parsedAge < 0 || parsedAge > 120) throw FormatException();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age (0-120)')),
      );
      return;
    }

    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String photoUrl = _googlePhotoUrl ?? '';
      if (_profilePhotoPath != null) {
        photoUrl = _profilePhotoPath!;
      }

      final settings = UserSettings(
        name: _nameController.text.trim(),
        email: AuthService.currentUser?.email ?? '',
        phone: AuthService.currentUser?.phoneNumber ?? '',
        profilePhoto: photoUrl,
        timezone: _selectedTimezone,
        language: _selectedLanguage,
        medicineReminder: true,
        missedDose: true,
        refillReminder: true,
        dailySummary: true,
        sound: _reminderSound,
        vibration: true,
        reminderAdvanceMinutes: _reminderAdvanceMinutes,
        snoozeDurationMinutes: _snoozeDurationMinutes,
        profileFor: _profileFor,
        age: parsedAge,
        gender: _selectedGender,
      );

      await DatabaseHelper.instance.saveUserSettings(settings);

      final relation = _mapProfileForToRelation(_profileFor);
      final existingPatients = await DatabaseHelper.instance.getPatients();
      final selfIndex = existingPatients.indexWhere((p) => p.isSelf);

      final selfPatient = Dependent(
        id: 'default_patient',
        name: _nameController.text.trim(),
        relation: relation,
        age: parsedAge,
        gender: _selectedGender,
        profilePhoto: photoUrl,
        createdAt: DateTime.now(),
      );

      if (selfIndex != -1) {
        existingPatients[selfIndex] = selfPatient;
        await DatabaseHelper.instance.savePatients(existingPatients);
      } else {
        await DatabaseHelper.instance.addPatient(selfPatient);
      }

      await DatabaseHelper.instance.setActivePatientId('default_patient');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = _calculateCompletionPercent();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildProfilePhoto(),
                    const SizedBox(height: 32),
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 24),
                    _buildProfileForSection(),
                    const SizedBox(height: 24),
                    _buildPreferencesSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomBar(percent),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userName = _nameController.text.isNotEmpty
        ? _nameController.text.split(' ').first
        : '';
    final greeting = userName.isNotEmpty ? ', $userName' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome$greeting \u{1F44B}',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF202733),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Let's personalize your Doseza experience.",
          style: GoogleFonts.inter(
            fontSize: 15,
            color: const Color(0xFF718096),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5B8DEF).withOpacity(0.08),
              border: Border.all(
                color: const Color(0xFF5B8DEF).withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _buildPhotoContent(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showPhotoSourceDialog,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B8DEF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoContent() {
    if (_profilePhotoPath != null) {
      return Image.file(
        File(_profilePhotoPath!),
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      );
    }
    if (_googlePhotoUrl != null && _googlePhotoUrl!.isNotEmpty) {
      return Image.network(
        _googlePhotoUrl!,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 110,
      height: 110,
      color: const Color(0xFF5B8DEF).withOpacity(0.08),
      child: Icon(
        Icons.person_rounded,
        size: 50,
        color: const Color(0xFF5B8DEF).withOpacity(0.5),
      ),
    );
  }

  void _showPhotoSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Profile Photo',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF202733),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: Color(0xFF5B8DEF)),
              title: Text('Take photo', style: GoogleFonts.inter()),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF5B8DEF)),
              title: Text('Choose from gallery', style: GoogleFonts.inter()),
              onTap: () => Navigator.pop(ctx),
            ),
            if (_googlePhotoUrl != null)
              ListTile(
                leading: const Icon(Icons.account_circle_rounded, color: Color(0xFF5B8DEF)),
                title: Text('Use Google photo', style: GoogleFonts.inter()),
                onTap: () {
                  setState(() {
                    _profilePhotoPath = null;
                  });
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      child: Column(
        children: [
          _buildFieldLabel('Full Name'),
          _buildTextField(
            controller: _nameController,
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Email'),
          _buildEmailField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Age'),
                    _buildTextField(
                      controller: _ageController,
                      hint: 'e.g., 28',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Gender'),
                    _buildDropdown<String>(
                      value: _selectedGender.isEmpty ? null : _selectedGender,
                      hint: 'Select',
                      items: _genderOptions,
                      onChanged: (val) {
                        setState(() => _selectedGender = val ?? '');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    final email = AuthService.currentUser?.email ?? '';
    final isReadonly = _isGoogleUser && email.isNotEmpty;

    return Container(
      decoration: _cardDecoration(),
      child: TextField(
        readOnly: isReadonly,
        controller: TextEditingController(text: email),
        style: GoogleFonts.inter(
          color: const Color(0xFF202733),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Email address',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF718096).withOpacity(0.6),
            fontSize: 15,
          ),
          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF718096), size: 20),
          suffixIcon: isReadonly
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_emailVerified)
                      const Icon(Icons.verified_rounded, color: Color(0xFF35B779), size: 18),
                    if (_emailVerified) const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B8DEF).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Google',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5B8DEF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildProfileForSection() {
    return _buildSection(
      title: 'Who is this profile for?',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _profileForOptions.map((option) {
          final isSelected = _profileFor == option;
          return GestureDetector(
            onTap: () => setState(() => _profileFor = option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5B8DEF).withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5B8DEF)
                      : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                option,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF5B8DEF)
                      : const Color(0xFF718096),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'Preferences',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('Language'),
          _buildDropdown<String>(
            value: _selectedLanguage,
            hint: 'Select language',
            items: _languageOptions,
            onChanged: (val) {
              setState(() => _selectedLanguage = val ?? 'English');
            },
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Timezone'),
          Container(
            decoration: _cardDecoration(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, color: Color(0xFF718096), size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedTimezone.isNotEmpty ? _selectedTimezone : 'Detecting...',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF202733),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF35B779).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Auto-detected',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF35B779),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFieldLabel('Reminders'),
          _buildToggleRow(
            icon: Icons.notifications_active_outlined,
            title: 'Reminder sound',
            value: _reminderSound,
            onChanged: (val) => setState(() => _reminderSound = val),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Advance notification'),
          Row(
            children: _advanceOptions.map((minutes) {
              final label = minutes == 0 ? 'At time' : '${minutes}min before';
              final isSelected = _reminderAdvanceMinutes == minutes;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _reminderAdvanceMinutes = minutes),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: minutes != _advanceOptions.last ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5B8DEF).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5B8DEF)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF5B8DEF)
                            : const Color(0xFF718096),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel('Snooze duration'),
          Row(
            children: _snoozeOptions.map((minutes) {
              final label = '${minutes}min';
              final isSelected = _snoozeDurationMinutes == minutes;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _snoozeDurationMinutes = minutes),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: minutes != _snoozeOptions.last ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5B8DEF).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5B8DEF)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF5B8DEF)
                            : const Color(0xFF718096),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF202733),
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF718096),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: _cardDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          color: const Color(0xFF202733),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF718096).withOpacity(0.6),
            fontSize: 15,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF718096), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: GoogleFonts.inter(
              color: const Color(0xFF718096).withOpacity(0.6),
              fontSize: 15,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096)),
          style: GoogleFonts.inter(
            color: const Color(0xFF202733),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text('$item'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF718096), size: 20),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF202733),
            ),
          ),
          const Spacer(),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF5B8DEF),
              activeTrackColor: const Color(0xFF5B8DEF).withOpacity(0.3),
              inactiveThumbColor: const Color(0xFFE2E8F0),
              inactiveTrackColor: const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(int percent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B8DEF)),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Profile $percent% complete',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProfileAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8DEF),
                foregroundColor: Colors.white,
                elevation: 0,
                disabledBackgroundColor: const Color(0xFF5B8DEF).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 18),
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
                      'Continue to Doseza',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
