import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'models.dart';
import 'report_preview_screen.dart';
import 'app_theme.dart';

class GenerateReportScreen extends StatefulWidget {
  const GenerateReportScreen({super.key});

  @override
  State<GenerateReportScreen> createState() => _GenerateReportScreenState();
}

class _GenerateReportScreenState extends State<GenerateReportScreen> {
  List<Dependent> _patients = [];
  String? _selectedPatientId;
  int _selectedQuickRange = 7;
  DateTime? _customFrom;
  DateTime? _customTo;
  bool _useCustomRange = false;

  bool _includeMedicationSummary = true;
  bool _includeAdherence = true;
  bool _includeVitals = true;
  bool _includeAppointments = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patients = await DatabaseHelper.instance.getPatients();
    final activeId = await DatabaseHelper.instance.getActivePatientId();
    if (mounted) {
      setState(() {
        _patients = patients;
        _selectedPatientId = activeId;
      });
    }
  }

  DateTime get _fromDate {
    if (_useCustomRange && _customFrom != null) return _customFrom!;
    return DateTime.now().subtract(Duration(days: _selectedQuickRange));
  }

  DateTime get _toDate {
    if (_useCustomRange && _customTo != null) return _customTo!;
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        elevation: 0,
        leadingWidth: 16,
        leading: const SizedBox.shrink(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_transparent.png',
              width: 24,
              height: 24,
              errorBuilder: (ctx, e, s) => const Icon(
                Icons.medical_services_rounded,
                size: 24,
                color: Color(0xFF5B8DEF),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Generate Health Report',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _patients.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B8DEF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSelector(),
                  const SizedBox(height: 20),
                  _buildDateRangeSection(),
                  const SizedBox(height: 20),
                  _buildContentOptions(),
                  const SizedBox(height: 24),
                  _buildPreviewButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSelector() {
    return _buildCard(
      title: 'Profile',
      child: Column(
        children: _patients.map((p) => RadioListTile<String>(
          value: p.id,
          groupValue: _selectedPatientId,
          onChanged: (v) => setState(() => _selectedPatientId = v),
          activeColor: const Color(0xFF5B8DEF),
          contentPadding: EdgeInsets.zero,
          title: Text(p.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          subtitle: Text(p.relationLabel, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
        )).toList(),
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return _buildCard(
      title: 'Date Range',
      child: Column(
        children: [
          _buildQuickRangeOption('Last 7 Days', 7),
          _buildQuickRangeOption('Last 14 Days', 14),
          _buildQuickRangeOption('Last 30 Days', 30),
          const SizedBox(height: 8),
          _buildQuickRangeOption('Custom Range', -1, isCustom: true),
          if (_useCustomRange) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDateButton('From', _customFrom, (d) => setState(() => _customFrom = d))),
                const SizedBox(width: 12),
                Expanded(child: _buildDateButton('To', _customTo, (d) => setState(() => _customTo = d))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickRangeOption(String label, int days, {bool isCustom = false}) {
    final isSelected = isCustom ? _useCustomRange : (!_useCustomRange && _selectedQuickRange == days);
    return GestureDetector(
      onTap: () => setState(() {
        if (isCustom) {
          _useCustomRange = true;
          _customFrom ??= DateTime.now().subtract(const Duration(days: 7));
          _customTo ??= DateTime.now();
        } else {
          _useCustomRange = false;
          _selectedQuickRange = days;
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B8DEF).withOpacity(0.06) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF5B8DEF) : AppTheme.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF5B8DEF) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF5B8DEF) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, Function(DateTime) onSelect) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF5B8DEF))),
            child: child!,
          ),
        );
        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Select',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentOptions() {
    return _buildCard(
      title: 'Include in Report',
      child: Column(
        children: [
          _buildToggle('Medication Summary', _includeMedicationSummary, (v) => setState(() => _includeMedicationSummary = v)),
          _buildToggle('Medication Adherence', _includeAdherence, (v) => setState(() => _includeAdherence = v)),
          _buildToggle('Vital Signs', _includeVitals, (v) => setState(() => _includeVitals = v)),
          _buildToggle('Doctor Appointments', _includeAppointments, (v) => setState(() => _includeAppointments = v)),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF5B8DEF),
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPreviewButton() {
    final hasAny = _includeMedicationSummary || _includeAdherence || _includeVitals || _includeAppointments;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: (!hasAny || _selectedPatientId == null) ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportPreviewScreen(
                patientId: _selectedPatientId!,
                fromDate: _fromDate,
                toDate: _toDate,
                includeMedicationSummary: _includeMedicationSummary,
                includeAdherence: _includeAdherence,
                includeVitals: _includeVitals,
                includeAppointments: _includeAppointments,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B8DEF),
          disabledBackgroundColor: const Color(0xFF5B8DEF).withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          'Preview Report',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
