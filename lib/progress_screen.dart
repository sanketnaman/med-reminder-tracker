import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';
import 'models.dart';
import 'today_plan_screen.dart';
import 'add_edit_medicine_screen.dart';
import 'animation_utils.dart';

class ProgressScreen extends StatefulWidget {
  final String patientId;
  const ProgressScreen({super.key, this.patientId = 'default_patient'});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;
  String _timeframe = 'Weekly';

  int _totalDoses = 0;
  int _takenDoses = 0;
  int _missedDoses = 0;
  int _adherencePercent = 0;

  Map<String, List<DoseRecord>> _medRecords = {};

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    final records = (await DatabaseHelper.instance.getDoseRecords())
        .where((record) => record.patientId == widget.patientId)
        .toList();

    final now = DateTime.now();
    // Filter records based on timeframe
    final daysToLookBack = _timeframe == 'Weekly' ? 7 : 30;
    final limitDate = now.subtract(Duration(days: daysToLookBack));

    final filteredRecords = records
        .where(
          (r) => r.scheduledAt.isAfter(limitDate) && r.status != 'scheduled',
        )
        .toList();

    int total = filteredRecords.length;
    int taken = filteredRecords.where((r) => r.status == 'taken').length;
    int missed = filteredRecords
        .where((r) => r.status == 'missed' || r.status == 'skipped')
        .length;
    int percent = total > 0 ? ((taken / total) * 100).round() : 0;

    // Group by medicine
    final grouped = <String, List<DoseRecord>>{};
    for (var r in filteredRecords) {
      grouped.putIfAbsent(r.medicineName, () => []).add(r);
    }

    if (mounted) {
      setState(() {
        _totalDoses = total;
        _takenDoses = taken;
        _missedDoses = missed;
        _adherencePercent = percent;
        _medRecords = grouped;
        _isLoading = false;
      });
    }
  }

  // Alias for compatibility with TodayPlanScreen callback
  void _loadDashboardData() => _loadProgressData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 16.0,
                bottom: 8.0,
              ),
              child: Row(
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
                  const SizedBox(width: 10),
                  Text(
                    'Your Progress',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF202733),
                    ),
                  ),
                  const Spacer(),
                  // Timeframe dropdown selector
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _timeframe,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFF5B8DEF),
                        ),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF5B8DEF),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        onChanged: (String? val) {
                          if (val != null) {
                            setState(() {
                              _timeframe = val;
                              _isLoading = true;
                            });
                            _loadProgressData();
                          }
                        },
                        items: ['Weekly', 'Monthly'].map((String val) {
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

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress Card (matching top portion of provided design)
                          FadeSlideIn(delay: Duration.zero, offset: 10, child: _buildOverallProgressCard()),
                          const SizedBox(height: 24),

                          // Medication Performance List
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 120),
                            offset: 10,
                            child: Text(
                              'Medication Performance',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF202733),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          _medRecords.isEmpty
                              ? FadeSlideIn(delay: const Duration(milliseconds: 200), offset: 10, child: _buildEmptyState())
                              : Column(
                                  children: _medRecords.entries.toList().asMap().entries.map((entry) {
                                    return FadeSlideIn(
                                      delay: Duration(milliseconds: 200 + 80 * entry.key),
                                      offset: 10,
                                      child: _buildPerformanceCard(
                                        entry.value.key,
                                        entry.value.value,
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.query_stats,
              size: 50,
              color: const Color(0xFF7BA7F7).withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Your progress will appear here',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF202733),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Take your medicines regularly to start building history.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodayPlanScreen(
                      onRefreshHome: _loadDashboardData,
                      patientId: '',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Set Today\'s Medications',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
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

  Widget _buildOverallProgressCard() {
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
            color: const Color(0xFF5B8DEF).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCol('$_totalDoses', 'Total Doses'),
                    _buildStatCol('$_takenDoses', 'Taken'),
                    _buildStatCol('$_missedDoses', 'Missed'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Animated Progress bar + percentage
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AnimatedCount(
                  value: _adherencePercent,
                  suffix: '%',
                  duration: const Duration(milliseconds: 600),
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedProgressBar(
                  percent: _adherencePercent.toDouble(),
                  height: 10,
                  duration: const Duration(milliseconds: 700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(String medName, List<DoseRecord> list) {
    int total = list.length;
    int taken = list.where((r) => r.status == 'taken').length;
    double ratio = total > 0 ? (taken / total) : 0.0;
    int completion = (ratio * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                medName,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF202733),
                ),
              ),
              Text(
                '$completion% Complete',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF718096),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$taken/$total Doses',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Animated Progress bar
          AnimatedProgressBar(
            percent: completion.toDouble(),
            height: 8,
            duration: const Duration(milliseconds: 500),
          ),
        ],
      ),
    );
  }
}
