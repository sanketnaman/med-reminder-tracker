import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'models.dart';
import 'add_edit_medicine_screen.dart';
import 'today_plan_screen.dart';
import 'inventory_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'premium_screen.dart';
import 'medicine_icon.dart';
import 'vitals_screen.dart';
import 'alarm_service.dart';
import 'appointments_screen.dart';
import 'next_medicine_helper.dart';
import 'add_dependent_screen.dart';
import 'animation_utils.dart';
import 'app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentTab = 0;
  Timer? _nextMedicineTimer;

  // State values for Dashboard
  UserSettings? _settings;
  List<Patient> _patients = [];
  String _activePatientId = 'default_patient';
  List<DoseRecord> _todayRecords = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  bool _isPremium = false;
  NextMedicineInfo? _nextMedicine;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDashboardData();
    _nextMedicineTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _currentTab == 0) {
        _recalculateNextMedicine();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nextMedicineTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadDashboardData();
    }
  }

  void _recalculateNextMedicine() {
    final nextMedicine = NextMedicineHelper.calculate(
      records: _todayRecords,
      selectedDate: _selectedDate,
    );
    if (mounted) {
      setState(() {
        _nextMedicine = nextMedicine;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    final settings = await DatabaseHelper.instance.getUserSettings();
    final patients = await DatabaseHelper.instance.getPatients();
    final activePatientId = await DatabaseHelper.instance.getActivePatientId();
    final records = await DatabaseHelper.instance.getDoseRecordsForDate(
      _selectedDate,
      patientId: activePatientId,
    );
    final isPremium = await DatabaseHelper.instance.isPremium();
    final nextMedicine = NextMedicineHelper.calculate(
      records: records,
      selectedDate: _selectedDate,
    );
    // Check for refill reminders in background
    AlarmService.checkAndScheduleRefillReminders(activePatientId);
    if (mounted) {
      setState(() {
        _settings = settings;
        _patients = patients;
        _activePatientId = activePatientId;
        _todayRecords = records;
        _isPremium = isPremium;
        _nextMedicine = nextMedicine;
        _isLoading = false;
      });
    }
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    if (hour < 21) return 'Evening';
    return 'Night';
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _isLoading = true;
    });
    _loadDashboardData();
  }

  void _markAsTaken(DoseRecord record) async {
    record.status = 'taken';
    record.takenAt = DateTime.now();
    await DatabaseHelper.instance.updateDoseRecord(record);
    await AlarmService.cancel(record.id);
    _loadDashboardData();
  }

  Patient? get _activePatient {
    for (final patient in _patients) {
      if (patient.id == _activePatientId) return patient;
    }
    return null;
  }

  Future<void> _selectPatient(Patient patient) async {
    await DatabaseHelper.instance.setActivePatientId(patient.id);
    await _loadDashboardData();
  }

  void _showPatientSwitcher() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Switch Profile',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ..._patients.map(
                (patient) => _buildProfileOption(
                  patient,
                  isActive: patient.id == _activePatientId,
                  onTap: () async {
                    await _selectPatient(patient);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddDependentScreen(),
                    ),
                  ).then((_) => _loadDashboardData());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B8DEF).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF5B8DEF),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Add Dependent',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF5B8DEF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(Dependent patient, {required bool isActive, required VoidCallback onTap}) {
    final initial = patient.name.isEmpty ? '?' : patient.name[0].toUpperCase();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5B8DEF).withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF5B8DEF) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: isActive
                  ? const Color(0xFF5B8DEF)
                  : AppTheme.textSecondary,
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (patient.relation != 'Self')
                    Text(
                      patient.relationLabel,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF5B8DEF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showNotificationPanel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF5B8DEF)),
            const SizedBox(width: 8),
            Text(
              'Notifications',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem('Metformin reminder sent (7:00 AM)'),
            _buildNotificationItem('Insulin 2ml reminder sent (7:50 AM)'),
            _buildNotificationItem(
              'Low stock alert: Insulin 1 Ampule remaining!',
            ),
          ],
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

  Widget _buildNotificationItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFF5B8DEF)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold matching current active tab
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: _buildCurrentTabBody(),
      bottomNavigationBar: _buildBottomTabBar(),
      floatingActionButton: _currentTab == 0 ? _buildFloatingAddButton() : null,
    );
  }

  Widget _buildCurrentTabBody() {
    switch (_currentTab) {
      case 0:
        return _buildDashboardView();
      case 1:
        return InventoryScreen(
          onRefreshHome: _loadDashboardData,
          patientId: _activePatientId,
        );
      case 2:
        return ProgressScreen(patientId: _activePatientId);
      case 3:
        return VitalsScreen(patientId: _activePatientId);
      case 4:
        return ProfileScreen(onProfileUpdated: _loadDashboardData);
      default:
        return _buildDashboardView();
    }
  }

  Widget _buildDashboardView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final name = _activePatient?.name ?? _settings?.name ?? '';
    final formattedDate = DateFormat('EEEE, MMMM dd').format(_selectedDate);

    // Doses calculation
    final totalDose = _todayRecords.length;
    final takenDose = _todayRecords.where((r) => r.status == 'taken').length;
    final progressPercent = totalDose > 0
        ? ((takenDose / totalDose) * 100).round()
        : 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Morning Greeting Header
            FadeSlideIn(
              delay: Duration.zero,
              offset: 10,
              child: Row(
              children: [
                Image.asset(
                  'assets/images/logo_transparent.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (ctx, e, s) => const Icon(
                    Icons.medical_services_rounded,
                    size: 40,
                    color: Color(0xFF5B8DEF),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: GestureDetector(
                    onTap: _showPatientSwitcher,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: SmoothSwitch(
                                key: ValueKey(_activePatientId),
                                child: Text(
                                  'Good ${_getTimeGreeting()}, $name',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_activePatient?.isSelf == true ? "Self" : _activePatient?.relation ?? "Self"} • $formattedDate',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showNotificationPanel,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.notifications_none_outlined,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
            const SizedBox(height: 20),

            // Today's Medication Progress Card
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              offset: 10,
              child: _buildProgressCard(totalDose, takenDose, progressPercent),
            ),
            const SizedBox(height: 24),

            // Horizontal Date picker
            FadeSlideIn(
              delay: const Duration(milliseconds: 180),
              offset: 10,
              child: _buildHorizontalCalendar(),
            ),
            const SizedBox(height: 24),

            // Doctor Appointment Card (Premium Feature)
            FadeSlideIn(
              delay: const Duration(milliseconds: 260),
              offset: 10,
              child: _buildDoctorAppointmentCard(),
            ),
            const SizedBox(height: 24),

            // Next Medicine Card
            if (_nextMedicine != null) ...[
              FadeSlideIn(
                delay: const Duration(milliseconds: 340),
                offset: 10,
                child: _buildNextMedicineCard(),
              ),
              const SizedBox(height: 24),
            ],

            // Timeline Items - Grouped by time of day
            if (_todayRecords.isEmpty)
              _buildEmptyState()
            else
              ..._timeGroups.expand((group) {
                final records = _recordsForGroup(group['start'] as int, group['end'] as int);
                if (records.isEmpty) return <Widget>[];
                return [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              group['asset'] as String,
                              width: 28,
                              height: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              group['label'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${records.length} Medicine${records.length > 1 ? 's' : ''}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...records.map((record) => FadeSlideIn(
                    delay: const Duration(milliseconds: 420),
                    offset: 8,
                    child: _buildTimelineCard(record),
                  )),
                  const SizedBox(height: 8),
                ];
              }),
            const SizedBox(height: 60), // Space for floating button
          ],
        ),
      ),
    );
  }

  static const List<Map<String, dynamic>> _timeGroups = [
    {'label': 'Morning', 'asset': 'assets/icons/morning.svg', 'start': 5, 'end': 12},
    {'label': 'Afternoon', 'asset': 'assets/icons/afternoon.svg', 'start': 12, 'end': 17},
    {'label': 'Evening', 'asset': 'assets/icons/evening.svg', 'start': 17, 'end': 21},
    {'label': 'Night', 'asset': 'assets/icons/night.svg', 'start': 21, 'end': 29},
  ];

  List<DoseRecord> _recordsForGroup(int startHour, int endHour) {
    return _todayRecords.where((r) {
      final hour = r.scheduledAt.hour;
      if (endHour > 24) {
        return hour >= startHour || hour < (endHour - 24);
      }
      return hour >= startHour && hour < endHour;
    }).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 60,
              color: const Color(0xFF7BA7F7).withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No medicines added yet',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add your first medicine and we\'ll remind you.',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final canAdd = await DatabaseHelper.instance.canAddMedicine(_activePatientId);
                if (!canAdd && mounted) {
                  _showUpgradeDialog();
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditMedicineScreen(patientId: _activePatientId),
                  ),
                ).then((value) {
                  if (value == true) _loadDashboardData();
                });
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Add First Medicine',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
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

  Widget _buildProgressCard(int total, int taken, int percent) {
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
            color: const Color(0xFF5B8DEF).withOpacity(0.35),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF5B8DEF).withOpacity(0.12),
            blurRadius: 48,
            spreadRadius: -8,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
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
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProgressStat('Total Dose', '$total'),
              const SizedBox(width: 32),
              _buildProgressStat('Taken', '$taken'),
              const Spacer(),
              AnimatedCount(
                value: percent,
                suffix: '%',
                duration: const Duration(milliseconds: 500),
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Animated Progress bar
          AnimatedProgressBar(
            percent: percent.toDouble(),
            height: 18,
            duration: const Duration(milliseconds: 600),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TodayPlanScreen(
                    onRefreshHome: _loadDashboardData,
                    patientId: _activePatientId,
                  ),
                ),
              ).then((value) => _loadDashboardData());
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Text(
                'View Today\'s Plan',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCalendar() {
    final today = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        // Generate week around selected day
        final day = today
            .subtract(Duration(days: today.weekday - 1))
            .add(Duration(days: index));
        final isSelected =
            _selectedDate.day == day.day && _selectedDate.month == day.month;

        final dayLetter = DateFormat('E').format(day).substring(0, 1);
        final dateNum = DateFormat('d').format(day);

        return GestureDetector(
          onTap: () => _onDateSelected(day),
          child: Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF5B8DEF) : AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  dayLetter,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateNum,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimelineCard(DoseRecord record) {
    final isTaken = record.status == 'taken';
    final isUpcoming = record.status == 'scheduled' && record.scheduledAt.isAfter(DateTime.now());
    final timeStr = DateFormat('hh:mm a').format(record.scheduledAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Medicine Type Icon
          MedicineIcon(
            medicineType: record.medicineType,
            size: 52,
          ),
          const SizedBox(width: 14),

          // Detail list
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (record.mealRelation.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D75).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      record.mealRelation,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFE85D75),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                Text(
                  record.medicineName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${record.dosage.toInt()} ${record.dosageUnit}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action tag - clearly distinct based on status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isTaken
                  ? const Color(0xFF35B779).withOpacity(0.12)
                  : isUpcoming
                      ? const Color(0xFF5B8DEF).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isTaken ? 'Taken ✓' : isUpcoming ? 'Upcoming' : 'Missed',
              style: GoogleFonts.inter(
                color: isTaken
                    ? const Color(0xFF35B779)
                    : isUpcoming
                        ? const Color(0xFF5B8DEF)
                        : AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabItem(0, Icons.home_filled, 'Home'),
              _buildTabItem(1, Icons.inventory_2_outlined, 'Inventory'),
              _buildTabItem(2, Icons.bar_chart_outlined, 'Progress'),
              _buildTabItem(3, Icons.favorite_outline, 'Vitals'),
              _buildTabItem(4, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () {
        if (index == 3 && !_isPremium) {
          _showUpgradeDialog();
          return;
        }
        setState(() {
          _currentTab = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color:                   isSelected
                      ? const Color(0xFF5B8DEF)
                      : AppTheme.textSecondary,
                  size: 24,
                ),
                if (index == 3 && !_isPremium)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5A623),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        size: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? const Color(0xFF5B8DEF)
                    : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingAddButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final canAdd = await DatabaseHelper.instance.canAddMedicine(_activePatientId);
          if (!canAdd && mounted) {
            _showUpgradeDialog();
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddEditMedicineScreen(patientId: _activePatientId),
            ),
          ).then((value) {
            if (value == true) {
              _loadDashboardData();
            }
          });
        },
        backgroundColor: const Color(0xFF5B8DEF),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          'Add Medicine',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  void _showUpgradeDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    ).then((_) => _loadDashboardData());
  }

  void _snoozeNextMedicine() async {
    final record = _nextMedicine?.primaryRecord;
    if (record == null) return;
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Snooze Dose',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: const Text('How long would you like to snooze this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 10),
            child: const Text('10 Min'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 30),
            child: const Text('30 Min'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 60),
            child: const Text('1 Hour'),
          ),
        ],
      ),
    );
    if (minutes != null && mounted) {
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
      _loadDashboardData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Snoozed for $minutes minutes.')),
        );
      }
    }
  }

  Widget _buildNextMedicineCard() {
    final info = _nextMedicine!;
    final record = info.primaryRecord;
    final timeStr = DateFormat('hh:mm a').format(record.scheduledAt);
    final isDue = info.status == NextMedicineStatus.due;
    final isAllCompleted = info.status == NextMedicineStatus.allCompleted;

    if (isAllCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎉',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            'All medicines completed!',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'ve completed all your scheduled medicines for today.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDue
                      ? const Color(0xFFF5A623).withOpacity(0.1)
                      : const Color(0xFF5B8DEF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'NEXT MEDICINE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDue ? const Color(0xFFF5A623) : const Color(0xFF5B8DEF),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                timeStr,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDue ? const Color(0xFFF5A623) : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Medicine info
          Row(
            children: [
              // Medicine icon
              MedicineIcon(
                medicineType: record.medicineType,
                size: 52,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.medicineName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${record.dosage.toInt()} ${record.dosageUnit}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Meal relation + time label
          const SizedBox(height: 10),
          Row(
            children: [
              if (record.mealRelation.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE85D75).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    record.mealRelation,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFE85D75),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (info.timeLabel != null)
                Text(
                  info.timeLabel!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDue ? const Color(0xFFF5A623) : AppTheme.textSecondary,
                  ),
                ),
            ],
          ),

          // Action buttons
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _markAsTaken(record);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF35B779),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          isDue ? 'Take Now' : 'Mark as Taken',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _snoozeNextMedicine,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.snooze, color: AppTheme.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Snooze',
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Grouped extra medicine mini-cards
          if (info.isGrouped) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isDue ? const Color(0xFFF5A623) : const Color(0xFF5B8DEF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isDue ? 'OVERDUE' : 'ALSO SCHEDULED',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDue ? const Color(0xFFF5A623) : const Color(0xFF5B8DEF),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isDue
                        ? const Color(0xFFF5A623).withOpacity(0.1)
                        : const Color(0xFF5B8DEF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${info.groupCount - 1} more',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isDue ? const Color(0xFFF5A623) : const Color(0xFF5B8DEF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...info.sameTimeRecords.where((r) => r.id != record.id).map((r) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDue
                      ? const Color(0xFFF5A623).withOpacity(0.04)
                      : const Color(0xFF5B8DEF).withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDue
                        ? const Color(0xFFF5A623).withOpacity(0.12)
                        : const Color(0xFF5B8DEF).withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    MedicineIcon(medicineType: r.medicineType, size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.medicineName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${r.dosage.toInt()} ${r.dosageUnit}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _markAsTaken(r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF35B779),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Take',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDoctorAppointmentCard() {
    return GestureDetector(
      onTap: () {
        if (!_isPremium) {
          _showUpgradeDialog();
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentsScreen(patientId: _activePatientId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/doctor_appointment.svg',
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Doctor Appointments',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (!_isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5A623).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PRO',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF5A623),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isPremium
                        ? 'Schedule and manage visits'
                        : 'Upgrade to Premium to access',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _isPremium ? Icons.arrow_forward_ios : Icons.lock_outline,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
