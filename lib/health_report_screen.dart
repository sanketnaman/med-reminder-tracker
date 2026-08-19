import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'database_helper.dart';
import 'premium_screen.dart';
import 'generate_report_screen.dart';

class HealthReportScreen extends StatefulWidget {
  const HealthReportScreen({super.key});

  @override
  State<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen> {
  bool _isPremium = false;
  List<ReportHistoryItem> _recentReports = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final isPremium = await DatabaseHelper.instance.isPremium();
    final reports = await _loadReportHistory();
    if (mounted) {
      setState(() {
        _isPremium = isPremium;
        _recentReports = reports;
      });
    }
  }

  Future<List<ReportHistoryItem>> _loadReportHistory() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().whereType<File>().where((f) =>
        f.path.contains('Doseza_Health_Report') && f.path.endsWith('.pdf')
    ).toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files.take(10).map((f) {
      final name = f.path.split(Platform.pathSeparator).last;
      return ReportHistoryItem(file: f, fileName: name);
    }).toList();
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
          'Health Reports',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF202733)),
        ),
        centerTitle: true,
      ),
      body: _isPremium ? _buildPremiumBody() : _buildFreeBody(),
    );
  }

  Widget _buildFreeBody() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF5B8DEF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assessment_outlined, size: 40, color: Color(0xFF5B8DEF)),
          ),
          const SizedBox(height: 20),
          Text(
            'Health Reports',
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF202733)),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5A623).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'PRO',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFF5A623)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Generate doctor-ready reports from your medication and vitals history.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF718096), height: 1.5),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()))
                    .then((_) => _loadData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8DEF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Upgrade to Premium',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPremiumBody() {
    return Column(
      children: [
        Expanded(
          child: _recentReports.isEmpty ? _buildEmptyState() : _buildReportList(),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GenerateReportScreen()))
                    .then((_) => _loadData());
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Generate Report',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B8DEF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined, size: 60, color: const Color(0xFF5B8DEF).withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No reports yet',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF202733)),
            ),
            const SizedBox(height: 6),
            Text(
              'Generate your first health report to share with your doctor.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF718096)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _recentReports.length,
      itemBuilder: (context, index) {
        final report = _recentReports[index];
        return _buildReportTile(report);
      },
    );
  }

  Widget _buildReportTile(ReportHistoryItem report) {
    // Parse filename: Doseza_Health_Report_<Name>_<Start>_to_<End>.pdf
    final parts = report.fileName.replaceAll('.pdf', '').split('_');
    String profileName = 'Unknown';
    String dateRange = '';
    if (parts.length >= 6) {
      profileName = parts[4];
      final startRaw = parts[5];
      final endRaw = parts.length > 6 ? parts.sublist(6).join('_') : '';
      try {
        final start = DateFormat('yyyy-MM-dd').parse(startRaw);
        final end = endRaw.isNotEmpty ? DateFormat('yyyy-MM-dd').parse(endRaw) : start;
        dateRange = '${DateFormat('dd MMM').format(start)} – ${DateFormat('dd MMM').format(end)}';
      } catch (_) {
        dateRange = '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF5B8DEF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, size: 22, color: Color(0xFF5B8DEF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profileName, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF202733))),
                if (dateRange.isNotEmpty)
                  Text(dateRange, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF718096))),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, size: 20, color: Color(0xFF5B8DEF)),
            onPressed: () => _openReport(report.file),
          ),
        ],
      ),
    );
  }

  Future<void> _openReport(File file) async {
    try {
      await Printing.layoutPdf(
        onLayout: (format) async => file.readAsBytes(),
        name: file.path.split(Platform.pathSeparator).last,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open report: $e'), backgroundColor: const Color(0xFFE85D75)),
        );
      }
    }
  }
}

class ReportHistoryItem {
  final File file;
  final String fileName;
  ReportHistoryItem({required this.file, required this.fileName});
}
