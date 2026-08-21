import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'models.dart';
import 'animation_utils.dart';

class VitalsScreen extends StatefulWidget {
  final String patientId;
  const VitalsScreen({super.key, required this.patientId});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  Map<String, VitalReading> _latestVitals = {};
  Map<String, List<VitalReading>> _groupedReadings = {};
  bool _isLoading = true;
  bool _isCardiacPostSurgery = false;

  @override
  void initState() {
    super.initState();
    _loadVitals();
  }

  Future<void> _loadVitals() async {
    setState(() => _isLoading = true);
    final latest = await DatabaseHelper.instance.getLatestVitals(patientId: widget.patientId);
    final all = await DatabaseHelper.instance.getVitalReadingsForPatient(widget.patientId);
    all.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    final grouped = <String, List<VitalReading>>{};
    for (final r in all) {
      final dateKey = DateFormat('yyyy-MM-dd').format(r.recordedAt);
      grouped.putIfAbsent(dateKey, () => []).add(r);
    }

    final patients = await DatabaseHelper.instance.getPatients();
    final patient = patients.where((p) => p.id == widget.patientId).isNotEmpty
        ? patients.firstWhere((p) => p.id == widget.patientId)
        : null;

    setState(() {
      _latestVitals = latest;
      _groupedReadings = grouped;
      _isCardiacPostSurgery = patient?.isCardiacPostSurgery ?? false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
              onRefresh: _loadVitals,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: FadeSlideIn(delay: Duration.zero, offset: 10, child: _buildSummarySection())),
                  SliverToBoxAdapter(child: FadeSlideIn(delay: const Duration(milliseconds: 120), offset: 10, child: _buildHistoryHeader())),
                  _groupedReadings.isEmpty
                      ? SliverToBoxAdapter(child: FadeSlideIn(delay: const Duration(milliseconds: 200), offset: 10, child: _buildEmptyState()))
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final dateKey = _groupedReadings.keys.elementAt(index);
                              final readings = _groupedReadings[dateKey]!;
                              return FadeSlideIn(
                                delay: Duration(milliseconds: 200 + 80 * index),
                                offset: 10,
                                child: _buildDateGroup(dateKey, readings),
                              );
                            },
                            childCount: _groupedReadings.length,
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReadingSheet,
        backgroundColor: const Color(0xFF5B8DEF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Log Reading',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: Color(0xFF5B8DEF),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Today's Vitals",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, MMMM d').format(DateTime.now()),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildVitalCard(
                  'Blood Pressure',
                  _latestVitals['blood_pressure']?.displayValue ?? '--',
                  'mmHg',
                  const Color(0xFFE85D75),
                  'assets/icons/blood_pressure.svg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  'Blood Sugar',
                  _latestVitals['blood_sugar']?.displayValue ?? '--',
                  'mg/dL',
                  const Color(0xFFF5A623),
                  'assets/icons/blood_sugar.svg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVitalCard(
                  'Weight',
                  _latestVitals['weight']?.displayValue ?? '--',
                  'kg',
                  const Color(0xFF5B8DEF),
                  'assets/icons/weight.svg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalCard(
                  'SPO2',
                  _latestVitals['spo2']?.displayValue ?? '--',
                  '%',
                  const Color(0xFF20C9D8),
                  'assets/icons/spo2.svg',
                ),
              ),
            ],
          ),
          if (_isCardiacPostSurgery) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVitalCard(
                    'Spirometer',
                    _latestVitals['spirometer']?.displayValue ?? '--',
                    'L',
                    const Color(0xFF35B779),
                    null,
                    fallbackIcon: Icons.air,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalCard(
                    'Walk Test',
                    _latestVitals['walk']?.displayValue ?? '--',
                    'steps',
                    const Color(0xFF9B59B6),
                    null,
                    fallbackIcon: Icons.directions_walk,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalCard(
    String title,
    String value,
    String unit,
    Color color,
    String? svgAssetPath, {
    bool fullWidth = false,
    IconData? fallbackIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: fullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: fullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              if (svgAssetPath != null)
                SvgPicture.asset(
                  svgAssetPath,
                  width: 44,
                  height: 44,
                )
              else
                Icon(
                  fallbackIcon ?? Icons.medical_information,
                  size: 44,
                  color: color,
                ),
              if (fullWidth) ...[
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (!fullWidth) ...[
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: fullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: fullWidth ? 28 : 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (_latestVitals.containsKey(title.toLowerCase().replaceAll(' ', '_'))) ...[
            const SizedBox(height: 4),
            Text(
              'Last: ${DateFormat('hh:mm a').format(_latestVitals[title.toLowerCase().replaceAll(' ', '_')]!.recordedAt)}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        'History',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.favorite_outline,
              size: 60,
              color: const Color(0xFF7BA7F7).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No vitals recorded yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Log Reading" to record your first vital.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateGroup(String dateKey, List<VitalReading> readings) {
    final date = DateTime.parse(dateKey);
    final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;
    final dateLabel = isToday
        ? 'Today'
        : DateFormat('EEEE, MMMM d').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              dateLabel,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ...readings.map((r) => _buildReadingTile(r)),
        ],
      ),
    );
  }

  Widget _buildReadingTile(VitalReading reading) {
    Color color;
    String? svgAssetPath;
    IconData? fallbackIcon;
    switch (reading.type) {
      case 'blood_pressure':
        color = const Color(0xFFE85D75);
        svgAssetPath = 'assets/icons/blood_pressure.svg';
        break;
      case 'blood_sugar':
        color = const Color(0xFFF5A623);
        svgAssetPath = 'assets/icons/blood_sugar.svg';
        break;
      case 'weight':
        color = const Color(0xFF5B8DEF);
        svgAssetPath = 'assets/icons/weight.svg';
        break;
      case 'spo2':
        color = const Color(0xFF20C9D8);
        svgAssetPath = 'assets/icons/spo2.svg';
        break;
      case 'spirometer':
        color = const Color(0xFF35B779);
        fallbackIcon = Icons.air;
        break;
      case 'walk':
        color = const Color(0xFF9B59B6);
        fallbackIcon = Icons.directions_walk;
        break;
      default:
        color = const Color(0xFF718096);
        svgAssetPath = 'assets/icons/Other.svg';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (svgAssetPath != null)
            SvgPicture.asset(
              svgAssetPath,
              width: 32,
              height: 32,
            )
          else
            Icon(
              fallbackIcon ?? Icons.medical_information,
              size: 32,
              color: color,
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reading.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('hh:mm a').format(reading.recordedAt),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${reading.displayValue} ${reading.unit}',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteReading(reading),
            child: Icon(
              Icons.delete_outline,
              size: 18,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteReading(VitalReading reading) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reading', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Delete this ${reading.displayName} reading?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE85D75)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteVitalReading(reading.id);
      _loadVitals();
    }
  }

  void _showAddReadingSheet() {
    String selectedType = 'blood_pressure';
    String? selectedSugarSubType;
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final sugarController = TextEditingController();
    final weightController = TextEditingController();
    final spo2Controller = TextEditingController();
    final spirometerController = TextEditingController();
    final walkController = TextEditingController();
    final now = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Log Vital Reading',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vital Type',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTypeChip('BP', 'blood_pressure', selectedType, (val) {
                            setSheetState(() => selectedType = val);
                          }),
                          const SizedBox(width: 8),
                          _buildTypeChip('Sugar', 'blood_sugar', selectedType, (val) {
                            setSheetState(() {
                              selectedType = val;
                              selectedSugarSubType = null;
                            });
                          }),
                          const SizedBox(width: 8),
                          _buildTypeChip('Weight', 'weight', selectedType, (val) {
                            setSheetState(() => selectedType = val);
                          }),
                          const SizedBox(width: 8),
                          _buildTypeChip('SPO2', 'spo2', selectedType, (val) {
                            setSheetState(() => selectedType = val);
                          }),
                        ],
                      ),
                      if (_isCardiacPostSurgery) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTypeChip('Spirometer', 'spirometer', selectedType, (val) {
                              setSheetState(() => selectedType = val);
                            }),
                            const SizedBox(width: 8),
                            _buildTypeChip('Walk Test', 'walk', selectedType, (val) {
                              setSheetState(() => selectedType = val);
                            }),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Date & Time (auto-filled)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.chipBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF5B8DEF)),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(now),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.access_time, size: 18, color: Color(0xFF5B8DEF)),
                            const SizedBox(width: 10),
                            Text(
                              DateFormat('hh:mm a').format(now),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Input fields based on type
                      if (selectedType == 'blood_pressure') ...[
                        Text(
                          'Systolic (mmHg)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(systolicController, 'e.g. 120', TextInputType.number),
                        const SizedBox(height: 16),
                        Text(
                          'Diastolic (mmHg)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(diastolicController, 'e.g. 80', TextInputType.number),
                      ],
                      if (selectedType == 'blood_sugar') ...[
                        Text(
                          'When?',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTypeChip('Before Meal', 'before_meal', selectedSugarSubType ?? '', (val) {
                              setSheetState(() => selectedSugarSubType = val);
                            }),
                            const SizedBox(width: 8),
                            _buildTypeChip('After Meal', 'after_meal', selectedSugarSubType ?? '', (val) {
                              setSheetState(() => selectedSugarSubType = val);
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Blood Sugar (mg/dL)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(sugarController, 'e.g. 100', TextInputType.number),
                      ],
                      if (selectedType == 'weight') ...[
                        Text(
                          'Weight (kg)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(weightController, 'e.g. 70.5', TextInputType.number),
                      ],
                      if (selectedType == 'spo2') ...[
                        Text(
                          'SPO2 (%)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(spo2Controller, 'e.g. 98', TextInputType.number),
                      ],
                      if (selectedType == 'spirometer') ...[
                        Text(
                          'Spirometer Reading (L)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(spirometerController, 'e.g. 2.5', TextInputType.number),
                      ],
                      if (selectedType == 'walk') ...[
                        Text(
                          'Walk Test (steps)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(walkController, 'e.g. 500', TextInputType.number),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _saveReading(
                            selectedType,
                            selectedSugarSubType,
                            systolicController,
                            diastolicController,
                            sugarController,
                            weightController,
                            spo2Controller,
                            spirometerController,
                            walkController,
                            now,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B8DEF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Save Reading',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildTypeChip(String label, String value, String selected, Function(String) onTap) {
    final isSelected = selected == value;
    final Color chipColor;
    switch (value) {
      case 'blood_pressure':
        chipColor = const Color(0xFFE85D75);
        break;
      case 'blood_sugar':
        chipColor = const Color(0xFFF5A623);
        break;
      case 'weight':
        chipColor = const Color(0xFF5B8DEF);
        break;
      case 'spo2':
        chipColor = const Color(0xFF20C9D8);
        break;
      default:
        chipColor = const Color(0xFF5B8DEF);
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? chipColor.withOpacity(0.1) : AppTheme.chipBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? chipColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? chipColor : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, TextInputType type) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  void _saveReading(
    String type,
    String? sugarSubType,
    TextEditingController systolicCtrl,
    TextEditingController diastolicCtrl,
    TextEditingController sugarCtrl,
    TextEditingController weightCtrl,
    TextEditingController spo2Ctrl,
    TextEditingController spirometerCtrl,
    TextEditingController walkCtrl,
    DateTime now,
  ) {
    double? systolic, diastolic, value;
    String unit;
    String? subType;

    switch (type) {
      case 'blood_pressure':
        systolic = double.tryParse(systolicCtrl.text);
        diastolic = double.tryParse(diastolicCtrl.text);
        if (systolic == null || diastolic == null) {
          _showError('Please enter both Systolic and Diastolic values');
          return;
        }
        unit = 'mmHg';
        break;
      case 'blood_sugar':
        value = double.tryParse(sugarCtrl.text);
        if (value == null) {
          _showError('Please enter a Blood Sugar value');
          return;
        }
        unit = 'mg/dL';
        subType = sugarSubType;
        break;
      case 'weight':
        value = double.tryParse(weightCtrl.text);
        if (value == null) {
          _showError('Please enter a Weight value');
          return;
        }
        unit = 'kg';
        break;
      case 'spo2':
        value = double.tryParse(spo2Ctrl.text);
        if (value == null) {
          _showError('Please enter an SPO2 value');
          return;
        }
        unit = '%';
        break;
      case 'spirometer':
        value = double.tryParse(spirometerCtrl.text);
        if (value == null) {
          _showError('Please enter a Spirometer value');
          return;
        }
        unit = 'L';
        break;
      case 'walk':
        value = double.tryParse(walkCtrl.text);
        if (value == null) {
          _showError('Please enter a Walk Test value');
          return;
        }
        unit = 'steps';
        break;
      default:
        return;
    }

    final reading = VitalReading(
      id: '${type}_${now.millisecondsSinceEpoch}',
      patientId: widget.patientId,
      type: type,
      subType: subType,
      systolic: systolic,
      diastolic: diastolic,
      value: value,
      unit: unit,
      recordedAt: now,
    );

    DatabaseHelper.instance.addVitalReading(reading).then((_) {
      Navigator.pop(context);
      _loadVitals();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reading.displayName} reading saved!'),
          backgroundColor: const Color(0xFF35B779),
        ),
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFE85D75)),
    );
  }
}
