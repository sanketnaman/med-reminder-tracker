import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'database_helper.dart';
import 'models.dart';
import 'pdf_report_generator.dart';

class ReportPreviewScreen extends StatefulWidget {
  final String patientId;
  final DateTime fromDate;
  final DateTime toDate;
  final bool includeMedicationSummary;
  final bool includeAdherence;
  final bool includeVitals;
  final bool includeAppointments;

  const ReportPreviewScreen({
    super.key,
    required this.patientId,
    required this.fromDate,
    required this.toDate,
    this.includeMedicationSummary = true,
    this.includeAdherence = true,
    this.includeVitals = true,
    this.includeAppointments = false,
  });

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  bool _isLoading = true;
  bool _isGenerating = false;
  Dependent? _patient;
  int _totalMedicines = 0;
  int _totalDoses = 0;
  int _takenDoses = 0;
  String _adherencePercent = '0';
  int _bpCount = 0;
  int _sugarCount = 0;
  int _spo2Count = 0;
  int _weightCount = 0;
  int _appointmentCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPreviewData();
  }

  Future<void> _loadPreviewData() async {
    final db = DatabaseHelper.instance;
    final patients = await db.getPatients();
    _patient = patients.firstWhere((p) => p.id == widget.patientId);

    // Medicines
    final medicines = await db.getMedicinesForPatient(widget.patientId);
    _totalMedicines = medicines.length;

    // Dose records
    final allRecords = await db.getDoseRecords();
    final records = allRecords.where((r) =>
        r.patientId == widget.patientId &&
        r.scheduledAt.isAfter(widget.fromDate.subtract(const Duration(days: 1))) &&
        r.scheduledAt.isBefore(widget.toDate.add(const Duration(days: 1)))
    ).toList();

    final completed = records.where((r) => r.status != 'scheduled').toList();
    _totalDoses = completed.length;
    _takenDoses = completed.where((r) => r.status == 'taken').length;
    _adherencePercent = _totalDoses > 0
        ? ((_takenDoses / _totalDoses) * 100).toStringAsFixed(1)
        : '0.0';

    // Vitals
    final vitals = await db.getVitalReadingsForPatient(widget.patientId);
    final periodVitals = vitals.where((v) =>
        v.recordedAt.isAfter(widget.fromDate.subtract(const Duration(days: 1))) &&
        v.recordedAt.isBefore(widget.toDate.add(const Duration(days: 1)))
    ).toList();

    _bpCount = periodVitals.where((v) => v.type == 'blood_pressure').length;
    _sugarCount = periodVitals.where((v) => v.type == 'blood_sugar').length;
    _spo2Count = periodVitals.where((v) => v.type == 'spo2').length;
    _weightCount = periodVitals.where((v) => v.type == 'weight').length;

    // Appointments
    final allAppointments = await db.getAppointmentsForPatient(widget.patientId);
    _appointmentCount = allAppointments.where((a) =>
        a.appointmentDate.isAfter(widget.fromDate.subtract(const Duration(days: 1))) &&
        a.appointmentDate.isBefore(widget.toDate.add(const Duration(days: 1)))
    ).length;

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF202733)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Health Report',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF202733)),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5B8DEF)))
          : Column(
              children: [
                Expanded(child: _buildPreviewContent()),
                _buildBottomActions(),
              ],
            ),
    );
  }

  Widget _buildPreviewContent() {
    final dateRange = '${DateFormat('dd MMM').format(widget.fromDate)} – ${DateFormat('dd MMM').format(widget.toDate)}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A7DE8), Color(0xFF5B8DEF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF5B8DEF).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                Text(_patient?.name ?? 'User', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 4),
                Text(dateRange, style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.85))),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Adherence card
          if (widget.includeAdherence) ...[
            _buildStatCard(
              title: 'Medication Adherence',
              value: '$_adherencePercent%',
              subtitle: '$_takenDoses of $_totalDoses doses taken',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF35B779),
            ),
            const SizedBox(height: 12),
          ],

          // Medications card
          if (widget.includeMedicationSummary) ...[
            _buildStatCard(
              title: 'Medications',
              value: '$_totalMedicines',
              subtitle: 'Active medications in period',
              icon: Icons.medication_outlined,
              color: const Color(0xFF5B8DEF),
            ),
            const SizedBox(height: 12),
          ],

          // Vitals card
          if (widget.includeVitals) ...[
            _buildStatCard(
              title: 'Vital Readings',
              value: '${_bpCount + _sugarCount + _spo2Count + _weightCount}',
              subtitle: '$_bpCount BP · $_sugarCount Sugar · $_spo2Count SpO2 · $_weightCount Weight',
              icon: Icons.favorite_outline,
              color: const Color(0xFFE85D75),
            ),
            const SizedBox(height: 12),
          ],

          // Appointments card
          if (widget.includeAppointments) ...[
            _buildStatCard(
              title: 'Appointments',
              value: '$_appointmentCount',
              subtitle: 'Doctor visits in period',
              icon: Icons.calendar_today_outlined,
              color: const Color(0xFF20C9D8),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF718096))),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF202733))),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF718096))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generatePdf,
          icon: _isGenerating
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
          label: Text(
            _isGenerating ? 'Generating...' : 'Generate PDF',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5B8DEF),
            disabledBackgroundColor: const Color(0xFF5B8DEF).withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);

    try {
      final config = ReportConfig(
        patientId: widget.patientId,
        fromDate: widget.fromDate,
        toDate: widget.toDate,
        includeMedicationSummary: widget.includeMedicationSummary,
        includeAdherence: widget.includeAdherence,
        includeVitals: widget.includeVitals,
        includeAppointments: widget.includeAppointments,
      );

      final filePath = await PdfReportGenerator.generate(config);
      final file = File(filePath);

      if (mounted) {
        setState(() => _isGenerating = false);

        // Show success dialog with options
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Report Generated', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
            content: Text('Your health report has been generated successfully.', style: GoogleFonts.inter(fontSize: 14)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Close', style: GoogleFonts.inter(color: const Color(0xFF718096))),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Printing.layoutPdf(
                    onLayout: (format) async => file.readAsBytes(),
                    name: file.path.split(Platform.pathSeparator).last,
                  );
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18, color: Colors.white),
                label: Text('Open', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8DEF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Printing.sharePdf(bytes: await file.readAsBytes(), filename: file.path.split(Platform.pathSeparator).last);
                },
                icon: const Icon(Icons.share_rounded, size: 18, color: Colors.white),
                label: Text('Share', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF35B779),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e'), backgroundColor: const Color(0xFFE85D75)),
        );
      }
    }
  }
}
