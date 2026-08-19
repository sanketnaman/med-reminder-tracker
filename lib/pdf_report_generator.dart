import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'models.dart';
import 'database_helper.dart';

class ReportConfig {
  final String patientId;
  final DateTime fromDate;
  final DateTime toDate;
  final bool includeMedicationSummary;
  final bool includeAdherence;
  final bool includeVitals;
  final bool includeAppointments;

  ReportConfig({
    required this.patientId,
    required this.fromDate,
    required this.toDate,
    this.includeMedicationSummary = true,
    this.includeAdherence = true,
    this.includeVitals = true,
    this.includeAppointments = false,
  });
}

class PdfReportGenerator {
  static const _dosezaBlue = PdfColor.fromInt(0xFF5B8DEF);
  static const _lightGray = PdfColor.fromInt(0xFFF3F6FF);
  static const _darkText = PdfColor.fromInt(0xFF202733);
  static const _grayText = PdfColor.fromInt(0xFF718096);
  static const _white = PdfColor.fromInt(0xFFFFFFFF);
  static const _green = PdfColor.fromInt(0xFF35B779);
  static const _red = PdfColor.fromInt(0xFFE85D75);

  static final _dateFmt = DateFormat('dd MMM yyyy');
  static final _dateFileFmt = DateFormat('yyyy-MM-dd');
  static final _timeFmt = DateFormat('hh:mm a');

  static Future<String> generate(ReportConfig config) async {
    final db = DatabaseHelper.instance;
    final patient = (await db.getPatients())
        .firstWhere((p) => p.id == config.patientId);

    final medicines = await db.getMedicinesForPatient(config.patientId);
    final allRecords = await db.getDoseRecords();
    final records = allRecords.where((r) =>
        r.patientId == config.patientId &&
        r.scheduledAt.isAfter(config.fromDate.subtract(const Duration(days: 1))) &&
        r.scheduledAt.isBefore(config.toDate.add(const Duration(days: 1)))
    ).toList();

    final allVitals = await db.getVitalReadingsForPatient(config.patientId);
    final vitals = allVitals.where((v) =>
        v.recordedAt.isAfter(config.fromDate.subtract(const Duration(days: 1))) &&
        v.recordedAt.isBefore(config.toDate.add(const Duration(days: 1)))
    ).toList();

    final allAppointments = await db.getAppointmentsForPatient(config.patientId);
    final appointments = allAppointments.where((a) =>
        a.appointmentDate.isAfter(config.fromDate.subtract(const Duration(days: 1))) &&
        a.appointmentDate.isBefore(config.toDate.add(const Duration(days: 1)))
    ).toList();

    final pdf = pw.Document();
    final font = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 50),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        header: (context) => _buildHeader(patient, config, font, fontBold),
        footer: (context) => _buildFooter(context, font, fontBold),
        build: (context) => [
          if (config.includeMedicationSummary)
            ..._buildMedicationSummary(medicines, font, fontBold),
          if (config.includeAdherence)
            ..._buildAdherenceSection(records, medicines, font, fontBold),
          if (config.includeVitals)
            ..._buildVitalsSection(vitals, font, fontBold),
          if (config.includeAppointments)
            ..._buildAppointmentsSection(appointments, font, fontBold),
          _buildDisclaimer(font),
        ],
      ),
    );

    final fileName = _sanitizeFileName(
      'Doseza_Health_Report_${patient.name}_${_dateFileFmt.format(config.fromDate)}_to_${_dateFileFmt.format(config.toDate)}.pdf',
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static pw.Widget _buildHeader(
    Dependent patient,
    ReportConfig config,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('DOSEZA', style: pw.TextStyle(
                    font: fontBold, fontSize: 22, color: _dosezaBlue,
                  )),
                  pw.SizedBox(height: 2),
                  pw.Text('Health & Medication Report', style: pw.TextStyle(
                    font: font, fontSize: 11, color: _grayText,
                  )),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _dosezaBlue,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text('CONFIDENTIAL', style: pw.TextStyle(
                  font: fontBold, fontSize: 8, color: _white,
                )),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(height: 1, color: _dosezaBlue),
          pw.SizedBox(height: 12),
          pw.Text('Patient Information', style: pw.TextStyle(
            font: fontBold, fontSize: 13, color: _darkText,
          )),
          pw.SizedBox(height: 6),
          _infoRow('Name', patient.name, font, fontBold),
          _infoRow('Relationship', patient.relationLabel, font, fontBold),
          if (patient.age > 0) _infoRow('Age', '${patient.age} years', font, fontBold),
          if (patient.gender.isNotEmpty) _infoRow('Gender', patient.gender, font, fontBold),
          _infoRow('Report Period', '${_dateFmt.format(config.fromDate)} – ${_dateFmt.format(config.toDate)}', font, fontBold),
          _infoRow('Generated', _dateFmt.format(DateTime.now()), font, fontBold),
          pw.SizedBox(height: 8),
          pw.Container(height: 0.5, color: _lightGray),
        ],
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label, style: pw.TextStyle(
              font: font, fontSize: 9, color: _grayText,
            )),
          ),
          pw.Text(value, style: pw.TextStyle(
            font: fontBold, fontSize: 9, color: _darkText,
          )),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildMedicationSummary(
    List<Medicine> medicines,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (medicines.isEmpty) {
      return [
        _sectionHeader('MEDICATION SUMMARY', fontBold),
        pw.Text('No medication records available for this period.',
          style: pw.TextStyle(font: font, fontSize: 9, color: _grayText)),
        pw.SizedBox(height: 16),
      ];
    }

    return [
      _sectionHeader('MEDICATION SUMMARY', fontBold),
      pw.SizedBox(height: 8),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(font: fontBold, fontSize: 8, color: _white),
        headerDecoration: const pw.BoxDecoration(color: _dosezaBlue),
        headerAlignment: pw.Alignment.centerLeft,
        cellStyle: pw.TextStyle(font: font, fontSize: 8, color: _darkText),
        cellAlignment: pw.Alignment.centerLeft,
        cellHeight: 24,
        headerHeight: 28,
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.centerLeft,
          4: pw.Alignment.centerLeft,
        },
        headerAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.centerLeft,
          4: pw.Alignment.centerLeft,
        },
        headers: ['Medicine', 'Type', 'Dose', 'Schedule', 'Meal'],
        data: medicines.map((m) => [
          m.name,
          m.type,
          '${m.dosage.toInt()} ${m.dosageUnit}',
          m.timings.join(', '),
          m.mealRelation,
        ]).toList(),
      ),
      pw.SizedBox(height: 16),
    ];
  }

  static List<pw.Widget> _buildAdherenceSection(
    List<DoseRecord> records,
    List<Medicine> medicines,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final completedRecords = records.where((r) => r.status != 'scheduled').toList();
    final totalDoses = completedRecords.length;
    final taken = completedRecords.where((r) => r.status == 'taken').length;
    final missed = completedRecords.where((r) => r.status == 'missed' || r.status == 'skipped').length;
    final adherence = totalDoses > 0 ? ((taken / totalDoses) * 100).toStringAsFixed(1) : '0.0';

    if (totalDoses == 0) {
      return [
        _sectionHeader('MEDICATION ADHERENCE', fontBold),
        pw.Text('No completed dose records available for this period.',
          style: pw.TextStyle(font: font, fontSize: 9, color: _grayText)),
        pw.SizedBox(height: 16),
      ];
    }

    // Per-medication adherence
    final medMap = <String, List<DoseRecord>>{};
    for (final r in completedRecords) {
      medMap.putIfAbsent(r.medicineName, () => []).add(r);
    }

    return [
      _sectionHeader('MEDICATION ADHERENCE', fontBold),
      pw.SizedBox(height: 8),
      pw.Row(
        children: [
          _adherenceBox('Total Doses', '$totalDoses', font, fontBold),
          pw.SizedBox(width: 10),
          _adherenceBox('Taken', '$taken', font, fontBold),
          pw.SizedBox(width: 10),
          _adherenceBox('Missed', '$missed', font, fontBold),
          pw.SizedBox(width: 10),
          _adherenceBox('Adherence', '$adherence%', font, fontBold),
        ],
      ),
      pw.SizedBox(height: 12),
      pw.Text('Medication-wise Adherence', style: pw.TextStyle(
        font: fontBold, fontSize: 10, color: _darkText,
      )),
      pw.SizedBox(height: 6),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(font: fontBold, fontSize: 8, color: _white),
        headerDecoration: const pw.BoxDecoration(color: _dosezaBlue),
        cellStyle: pw.TextStyle(font: font, fontSize: 8, color: _darkText),
        cellHeight: 22,
        headerHeight: 26,
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.center,
          4: pw.Alignment.center,
        },
        headerAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.center,
          4: pw.Alignment.center,
        },
        headers: ['Medicine', 'Scheduled', 'Taken', 'Missed', 'Adherence'],
        data: medMap.entries.map((e) {
          final medTaken = e.value.where((r) => r.status == 'taken').length;
          final medMissed = e.value.where((r) => r.status == 'missed' || r.status == 'skipped').length;
          final medTotal = e.value.length;
          final pct = medTotal > 0 ? ((medTaken / medTotal) * 100).toStringAsFixed(1) : '0.0';
          return [e.key, '$medTotal', '$medTaken', '$medMissed', '$pct%'];
        }).toList(),
      ),
      pw.SizedBox(height: 12),
      _sectionHeader('DAILY MEDICATION RECORD', fontBold),
      pw.SizedBox(height: 6),
      ..._buildDailyRecords(records, font, fontBold),
      pw.SizedBox(height: 16),
    ];
  }

  static pw.Widget _adherenceBox(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: _lightGray,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          children: [
            pw.Text(value, style: pw.TextStyle(font: fontBold, fontSize: 14, color: _dosezaBlue)),
            pw.SizedBox(height: 2),
            pw.Text(label, style: pw.TextStyle(font: font, fontSize: 7, color: _grayText)),
          ],
        ),
      ),
    );
  }

  static List<pw.Widget> _buildDailyRecords(
    List<DoseRecord> records,
    pw.Font font,
    pw.Font fontBold,
  ) {
    final dayMap = <String, List<DoseRecord>>{};
    for (final r in records) {
      final key = DateFormat('yyyy-MM-dd').format(r.scheduledAt);
      dayMap.putIfAbsent(key, () => []).add(r);
    }

    final sortedDays = dayMap.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedDays.map((day) {
      final dayRecords = dayMap[day]!;
      final completed = dayRecords.where((r) => r.status != 'scheduled').toList();
      final taken = completed.where((r) => r.status == 'taken').length;
      final missed = completed.where((r) => r.status == 'missed' || r.status == 'skipped').length;
      final total = completed.length;
      final pct = total > 0 ? ((taken / total) * 100).toStringAsFixed(0) : '0';

      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 80,
              child: pw.Text(_dateFmt.format(DateTime.parse(day)),
                style: pw.TextStyle(font: font, fontSize: 8, color: _darkText)),
            ),
            pw.SizedBox(
              width: 50,
              child: pw.Text('$total doses',
                style: pw.TextStyle(font: font, fontSize: 8, color: _grayText)),
            ),
            pw.SizedBox(
              width: 50,
              child: pw.Text('$taken taken',
                style: pw.TextStyle(font: fontBold, fontSize: 8, color: _green)),
            ),
            pw.SizedBox(
              width: 50,
              child: pw.Text('$missed missed',
                style: pw.TextStyle(font: fontBold, fontSize: 8, color: _red)),
            ),
            pw.Text('$pct%',
              style: pw.TextStyle(font: fontBold, fontSize: 8, color: _dosezaBlue)),
          ],
        ),
      );
    }).toList();
  }

  static List<pw.Widget> _buildVitalsSection(
    List<VitalReading> vitals,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (vitals.isEmpty) {
      return [
        _sectionHeader('VITAL SIGNS', fontBold),
        pw.Text('No vital readings recorded for this period.',
          style: pw.TextStyle(font: font, fontSize: 9, color: _grayText)),
        pw.SizedBox(height: 16),
      ];
    }

    final bpReadings = vitals.where((v) => v.type == 'blood_pressure').toList();
    final sugarReadings = vitals.where((v) => v.type == 'blood_sugar').toList();
    final spo2Readings = vitals.where((v) => v.type == 'spo2').toList();
    final weightReadings = vitals.where((v) => v.type == 'weight').toList();

    return [
      _sectionHeader('VITAL SIGNS', fontBold),
      pw.SizedBox(height: 8),
      if (bpReadings.isNotEmpty) ...[
        pw.Text('Blood Pressure', style: pw.TextStyle(font: fontBold, fontSize: 10, color: _darkText)),
        pw.SizedBox(height: 4),
        _vitalStats('Systolic', bpReadings.map((r) => r.systolic ?? 0).where((v) => v > 0).toList(), 'mmHg', font, fontBold),
        _vitalStats('Diastolic', bpReadings.map((r) => r.diastolic ?? 0).where((v) => v > 0).toList(), 'mmHg', font, fontBold),
        pw.SizedBox(height: 4),
        _buildVitalTable(bpReadings.map((r) => {
          'date': _dateFmt.format(r.recordedAt),
          'time': _timeFmt.format(r.recordedAt),
          'value': '${r.systolic?.toInt() ?? "—"}/${r.diastolic?.toInt() ?? "—"} mmHg',
        }).toList(), font, fontBold),
        pw.SizedBox(height: 10),
      ],
      if (sugarReadings.isNotEmpty) ...[
        pw.Text('Blood Sugar', style: pw.TextStyle(font: fontBold, fontSize: 10, color: _darkText)),
        pw.SizedBox(height: 4),
        _vitalStats('Value', sugarReadings.map((r) => r.value ?? 0).where((v) => v > 0).toList(), 'mg/dL', font, fontBold),
        pw.SizedBox(height: 4),
        _buildVitalTable(sugarReadings.map((r) => {
          'date': _dateFmt.format(r.recordedAt),
          'time': _timeFmt.format(r.recordedAt),
          'value': '${r.value?.toInt() ?? "—"} mg/dL',
        }).toList(), font, fontBold),
        pw.SizedBox(height: 10),
      ],
      if (spo2Readings.isNotEmpty) ...[
        pw.Text('SpO2', style: pw.TextStyle(font: fontBold, fontSize: 10, color: _darkText)),
        pw.SizedBox(height: 4),
        _vitalStats('Value', spo2Readings.map((r) => r.value ?? 0).where((v) => v > 0).toList(), '%', font, fontBold),
        pw.SizedBox(height: 4),
        _buildVitalTable(spo2Readings.map((r) => {
          'date': _dateFmt.format(r.recordedAt),
          'time': _timeFmt.format(r.recordedAt),
          'value': '${r.value?.toInt() ?? "—"}%',
        }).toList(), font, fontBold),
        pw.SizedBox(height: 10),
      ],
      if (weightReadings.isNotEmpty) ...[
        pw.Text('Weight', style: pw.TextStyle(font: fontBold, fontSize: 10, color: _darkText)),
        pw.SizedBox(height: 4),
        _vitalStats('Value', weightReadings.map((r) => r.value ?? 0).where((v) => v > 0).toList(), 'kg', font, fontBold),
        pw.SizedBox(height: 4),
        _buildVitalTable(weightReadings.map((r) => {
          'date': _dateFmt.format(r.recordedAt),
          'time': _timeFmt.format(r.recordedAt),
          'value': '${r.value?.toStringAsFixed(1) ?? "—"} kg',
        }).toList(), font, fontBold),
        pw.SizedBox(height: 10),
      ],
      pw.SizedBox(height: 16),
    ];
  }

  static pw.Widget _vitalStats(String label, List<double> values, String unit, pw.Font font, pw.Font fontBold) {
    if (values.isEmpty) return pw.SizedBox.shrink();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    return pw.Text(
      '$label: Avg ${avg.toStringAsFixed(0)} | Min ${min.toStringAsFixed(0)} | Max ${max.toStringAsFixed(0)} $unit',
      style: pw.TextStyle(font: font, fontSize: 8, color: _grayText),
    );
  }

  static pw.Widget _buildVitalTable(List<Map<String, String>> data, pw.Font font, pw.Font fontBold) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(font: fontBold, fontSize: 8, color: _white),
      headerDecoration: const pw.BoxDecoration(color: _dosezaBlue),
      cellStyle: pw.TextStyle(font: font, fontSize: 8, color: _darkText),
      cellHeight: 20,
      headerHeight: 24,
      headers: ['Date', 'Time', 'Reading'],
      data: data.map((r) => [r['date']!, r['time']!, r['value']!]).toList(),
    );
  }

  static List<pw.Widget> _buildAppointmentsSection(
    List<Appointment> appointments,
    pw.Font font,
    pw.Font fontBold,
  ) {
    if (appointments.isEmpty) {
      return [
        _sectionHeader('DOCTOR APPOINTMENTS', fontBold),
        pw.Text('No appointments recorded for this period.',
          style: pw.TextStyle(font: font, fontSize: 9, color: _grayText)),
        pw.SizedBox(height: 16),
      ];
    }

    return [
      _sectionHeader('DOCTOR APPOINTMENTS', fontBold),
      pw.SizedBox(height: 8),
      pw.TableHelper.fromTextArray(
        headerStyle: pw.TextStyle(font: fontBold, fontSize: 8, color: _white),
        headerDecoration: const pw.BoxDecoration(color: _dosezaBlue),
        cellStyle: pw.TextStyle(font: font, fontSize: 8, color: _darkText),
        cellHeight: 24,
        headerHeight: 26,
        headers: ['Doctor', 'Specialty', 'Date', 'Time', 'Location'],
        data: appointments.map((a) => [
          a.doctorName,
          a.specialization,
          _dateFmt.format(a.appointmentDate),
          a.appointmentTime,
          a.location,
        ]).toList(),
      ),
      pw.SizedBox(height: 16),
    ];
  }

  static pw.Widget _buildDisclaimer(pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 30),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(height: 0.5, color: _lightGray),
          pw.SizedBox(height: 8),
          pw.Text(
            'This report summarizes information recorded by the user in Doseza. It is intended to assist discussion with a healthcare professional and does not constitute a medical diagnosis or treatment recommendation.',
            style: pw.TextStyle(font: font, fontSize: 7, color: _grayText, lineSpacing: 10),
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionHeader(String title, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFEEF2FC),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(title, style: pw.TextStyle(
        font: fontBold, fontSize: 11, color: _dosezaBlue,
      )),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Doseza — Health & Medication Report',
            style: pw.TextStyle(font: font, fontSize: 7, color: _grayText)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: font, fontSize: 7, color: _grayText)),
        ],
      ),
    );
  }

  static String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}
