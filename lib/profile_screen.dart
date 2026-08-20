import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';
import 'models.dart';
import 'auth_service.dart';
import 'alarm_service.dart';
import 'login_screen.dart';
import 'add_dependent_screen.dart';
import 'premium_screen.dart';
import 'health_report_screen.dart';
import 'animation_utils.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onProfileUpdated;
  const ProfileScreen({super.key, required this.onProfileUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserSettings? _settings;
  Dependent? _selfPatient;
  bool _isLoading = true;
  bool _isPremium = false;
  int _medicineCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final s = await DatabaseHelper.instance.getUserSettings();
    final isPremium = await DatabaseHelper.instance.isPremium();
    final medicineCount = await DatabaseHelper.instance.getMedicineCount(s.name);
    final patients = await DatabaseHelper.instance.getPatients();
    final selfPatient = patients.where((p) => p.isSelf).isNotEmpty
        ? patients.firstWhere((p) => p.isSelf)
        : null;
    if (mounted) {
      setState(() {
        _settings = s;
        _selfPatient = selfPatient;
        _isPremium = isPremium;
        _medicineCount = medicineCount;
        _isLoading = false;
      });
    }
  }

  void _updateSetting(Function(UserSettings) modifier) async {
    if (_settings != null) {
      modifier(_settings!);
      await DatabaseHelper.instance.saveUserSettings(_settings!);
      _loadSettings();
      widget.onProfileUpdated();
    }
  }

  void _showEditProfileDialog() {
    if (_settings == null) return;
    final nameCtrl = TextEditingController(text: _settings!.name);
    final emailCtrl = TextEditingController(text: _settings!.email);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Photo + name header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFF5B8DEF).withOpacity(0.1),
                          backgroundImage: _settings!.profilePhoto.isNotEmpty
                              ? NetworkImage(_settings!.profilePhoto)
                              : null,
                          child: _settings!.profilePhoto.isEmpty
                              ? const Icon(Icons.person, size: 38, color: Color(0xFF5B8DEF))
                              : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF202733),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name field
                  Text(
                    'Name',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameCtrl,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202733),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFFA0AEC0)),
                      filled: true,
                      fillColor: const Color(0xFFF3F6FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF5B8DEF), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Name cannot be empty';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field (read-only if from Google)
                  Text(
                    'Email',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: emailCtrl,
                    readOnly: AuthService.currentUser != null,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202733),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFFA0AEC0)),
                      filled: true,
                      fillColor: const Color(0xFFF3F6FF),
                      prefixIcon: AuthService.currentUser != null
                          ? const Icon(Icons.lock_outline, size: 18, color: Color(0xFFA0AEC0))
                          : null,
                      suffixText: AuthService.currentUser != null ? 'Google' : null,
                      suffixStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF35B779),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF5B8DEF), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (AuthService.currentUser != null)
                    Text(
                      'Email is linked to your Google account and cannot be changed.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFFA0AEC0),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Cardiac Post-Surgery toggle
                  Text(
                    'Cardiac Post-Surgery Patient',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 20,
                          color: _selfPatient?.isCardiacPostSurgery == true
                              ? const Color(0xFFE85D75)
                              : const Color(0xFFA0AEC0),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable Spirometer & Walk Test vitals',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF202733),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'For cardiac post-surgery patients',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: const Color(0xFFA0AEC0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _selfPatient?.isCardiacPostSurgery ?? false,
                          onChanged: (val) async {
                            if (_selfPatient != null) {
                              final updated = Dependent(
                                id: _selfPatient!.id,
                                name: _selfPatient!.name,
                                relation: _selfPatient!.relation,
                                age: _selfPatient!.age,
                                gender: _selfPatient!.gender,
                                profilePhoto: _selfPatient!.profilePhoto,
                                isCardiacPostSurgery: val,
                                createdAt: _selfPatient!.createdAt,
                              );
                              await DatabaseHelper.instance.updatePatient(updated);
                              setSheetState(() {
                                _selfPatient = updated;
                              });
                            }
                          },
                          activeColor: const Color(0xFFE85D75),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        _updateSetting((s) {
                          s.name = nameCtrl.text.trim();
                          s.email = emailCtrl.text.trim();
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated!'),
                            backgroundColor: Color(0xFF35B779),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B8DEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    if (_settings == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Settings',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF202733),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildModalSwitch(
                    'Medication Reminders',
                    _settings!.medicineReminder,
                    (val) {
                      setModalState(() => _settings!.medicineReminder = val);
                      _updateSetting((s) => s.medicineReminder = val);
                    },
                  ),
                  _buildModalSwitch(
                    'Missed Dose Alerts',
                    _settings!.missedDose,
                    (val) {
                      setModalState(() => _settings!.missedDose = val);
                      _updateSetting((s) => s.missedDose = val);
                    },
                  ),
                  _buildModalSwitch(
                    'Refill Reminders',
                    _settings!.refillReminder,
                    (val) {
                      setModalState(() => _settings!.refillReminder = val);
                      _updateSetting((s) => s.refillReminder = val);
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await AlarmService.requestPermissions();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Permissions checked/updated')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B8DEF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: Text(
                      'Check/Update Permissions',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalSwitch(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: const Color(0xFF202733),
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF5B8DEF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Language',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: _settings?.language == 'English'
                  ? const Icon(Icons.check, color: Color(0xFF5B8DEF))
                  : null,
              onTap: () {
                _updateSetting((s) => s.language = 'English');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Hindi (हिन्दी)'),
              trailing: _settings?.language == 'Hindi'
                  ? const Icon(Icons.check, color: Color(0xFF5B8DEF))
                  : null,
              onTap: () {
                _updateSetting((s) => s.language = 'Hindi');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Log Out',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              Text(
                'Are you sure you want to log out? Your progress will be saved.',
                style: GoogleFonts.inter(
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final s = _settings!;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Card with User Card (incorporates soft blue color pattern)
            FadeSlideIn(delay: Duration.zero, offset: 10, child: _buildProfileHeaderCard(s)),
            const SizedBox(height: 20),

            // Settings List Groups
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 100),
                    offset: 8,
                    child: Text(
                      'General',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 140),
                    offset: 8,
                    child: _buildSettingsContainer([
                      _buildSettingsItem(
                        Icons.person_outline,
                        'Edit Profile',
                        _showEditProfileDialog,
                      ),
                      _buildSettingsItem(
                        Icons.lock_outline,
                        'Change Password',
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Change Password workflow opened.'),
                            ),
                          );
                        },
                      ),
                      _buildSettingsItem(
                        Icons.notifications_none_outlined,
                        'Notifications',
                        _showNotificationSettings,
                      ),
                      _buildSettingsItem(
                        Icons.language_outlined,
                        'Language (${s.language})',
                        _showLanguageSelector,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  FadeSlideIn(delay: const Duration(milliseconds: 200), offset: 8, child: _buildDependentsSection()),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 260),
                    offset: 8,
                    child: Text(
                      'Subscription',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 300),
                    offset: 8,
                    child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isPremium
                          ? const Color(0xFF5B8DEF).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: _isPremium
                          ? Border.all(color: const Color(0xFF5B8DEF).withOpacity(0.3))
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isPremium
                                    ? const Color(0xFF5B8DEF).withOpacity(0.15)
                                    : const Color(0xFFF3F6FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _isPremium ? Icons.workspace_premium : Icons.lock_outline,
                                color: _isPremium ? const Color(0xFF5B8DEF) : const Color(0xFF718096),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isPremium ? 'Mediaro Premium' : 'Free Plan',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF202733),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isPremium
                                        ? 'Unlimited medicines & vitals'
                                        : '$_medicineCount of ${DatabaseHelper.freeMedicineLimit} medicines used',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF718096),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isPremium,
                              activeColor: const Color(0xFF5B8DEF),
                              onChanged: (value) async {
                                if (value) {
                                  // Opening premium screen to upgrade
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                                  ).then((_) {
                                    _loadSettings();
                                    widget.onProfileUpdated();
                                  });
                                } else {
                                  // Downgrade to free
                                  await DatabaseHelper.instance.setPremium(false);
                                  _loadSettings();
                                  widget.onProfileUpdated();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Switched to Free plan'),
                                        backgroundColor: Color(0xFF35B779),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        if (!_isPremium) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Text(
                            'Upgrade to Premium:',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF718096),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildPremiumFeature('Unlimited medicines'),
                          _buildPremiumFeature('Daily vitals tracking'),
                          _buildPremiumFeature('Advanced analytics'),
                        ],
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 24),

                  // Health Reports
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 360),
                    offset: 8,
                    child: Text(
                      'Health Reports',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 400),
                    offset: 8,
                    child: _buildSettingsItem(
                      Icons.assessment_outlined,
                      'Health Reports',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HealthReportScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  FadeSlideIn(
                    delay: const Duration(milliseconds: 420),
                    offset: 8,
                    child: Text(
                      'Preferences',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 460),
                    offset: 8,
                    child: _buildSettingsContainer([
                      _buildSettingsItem(
                        Icons.description_outlined,
                        'Legal and Policies',
                        () {
                          _showPolicyDialog();
                        },
                      ),
                    ]),
                  ),
                  const SizedBox(height: 32),

                  // Log out button
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 500),
                    offset: 8,
                    child: ListTile(
                      onTap: _showLogoutConfirmation,
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFE85D75),
                      ),
                      title: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFE85D75),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(UserSettings s) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF5B8DEF), Color(0xFF7BA7F7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo_transparent.png',
                width: 28,
                height: 28,
                errorBuilder: (ctx, e, s) => const Icon(
                  Icons.medical_services_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'My Profile',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              // User Avatar
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: s.profilePhoto.isNotEmpty
                    ? NetworkImage(s.profilePhoto)
                    : null,
                child: s.profilePhoto.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.email,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.85),
                      ),
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

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: const Color(0xFF718096), size: 22),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF202733),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Color(0xFF718096),
          ),
        ),
        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
        ),
      ],
    );
  }

  Widget _buildDependentsSection() {
    return FutureBuilder<List<Dependent>>(
      future: DatabaseHelper.instance.getPatients(),
      builder: (context, snapshot) {
        final patients = snapshot.data ?? [];
        final dependents = patients.where((p) => !p.isSelf).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'My Dependents',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF718096),
                  ),
                ),
                const Spacer(),
                if (!_isPremium)
                  Text(
                    '${dependents.length}/2',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF718096),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (dependents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 40,
                              color: const Color(0xFF718096).withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No dependents added yet',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF718096),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...dependents.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dep = entry.value;
                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF5B8DEF),
                              child: Text(
                                dep.name.isEmpty ? '?' : dep.name[0].toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            title: Text(
                              dep.name,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF202733),
                              ),
                            ),
                            subtitle: Text(
                              dep.displayLabel,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF718096),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Color(0xFF718096),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddDependentScreen(
                                    dependentToEdit: dep,
                                  ),
                                ),
                              );
                              if (result == true) setState(() {});
                            },
                          ),
                          if (index < dependents.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                            ),
                        ],
                      );
                    }),
                  // Add dependent button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF5B8DEF),
                      ),
                      title: Text(
                        'Add Dependent',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5B8DEF),
                        ),
                      ),
                      onTap: () async {
                        final canAdd = await DatabaseHelper.instance.canAddDependent();
                        if (!canAdd) {
                          _showDependentLimitPrompt();
                          return;
                        }
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddDependentScreen(),
                          ),
                        );
                        if (result == true) setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDependentLimitPrompt() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    ).then((_) {
      _loadSettings();
      widget.onProfileUpdated();
    });
  }

  void _showPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Legal & Privacy Policy',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            'This application is a local medication reminder assistant. It does not provide medical diagnostics, medical advice, or therapeutic decisions. All user records are stored strictly offline on your physical device. In case of doubts, consult a certified healthcare professional before making any dosage changes.',
            style: GoogleFonts.inter(
              color: const Color(0xFF718096),
              height: 1.4,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Color(0xFF35B779),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }
}