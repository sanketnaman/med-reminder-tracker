import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'models.dart';
import 'alarm_service.dart';
import 'animation_utils.dart';

class AppointmentsScreen extends StatefulWidget {
  final String patientId;
  const AppointmentsScreen({super.key, required this.patientId});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    final appointments = await DatabaseHelper.instance.getAppointmentsForPatient(widget.patientId);
    appointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    setState(() {
      _appointments = appointments;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: FadeSlideIn(delay: Duration.zero, offset: 10, child: _buildHeader())),
                  _appointments.isEmpty
                      ? SliverToBoxAdapter(child: FadeSlideIn(delay: const Duration(milliseconds: 100), offset: 10, child: _buildEmptyState()))
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => FadeSlideIn(
                              delay: Duration(milliseconds: 80 * index),
                              offset: 10,
                              child: _buildAppointmentCard(_appointments[index]),
                            ),
                            childCount: _appointments.length,
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddAppointmentSheet,
        backgroundColor: const Color(0xFF5B8DEF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Appointment',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final upcoming = _appointments.where((a) => a.isUpcoming).length;
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
              const SizedBox(width: 10),
              Text(
                'Doctor Appointments',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF202733),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (upcoming > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5B8DEF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$upcoming upcoming appointment${upcoming > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5B8DEF),
                ),
              ),
            ),
        ],
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
              Icons.calendar_today_outlined,
              size: 60,
              color: const Color(0xFF5B8DEF).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF202733),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "New Appointment" to schedule your first doctor visit.',
              style: GoogleFonts.inter(color: const Color(0xFF718096)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final isPast = !appointment.isUpcoming;
    final isToday = appointment.isToday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isToday
              ? Border.all(color: const Color(0xFF5B8DEF), width: 2)
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
                SvgPicture.asset(
                  'assets/icons/doctor_appointment.svg',
                  width: 36,
                  height: 36,
                  colorFilter: ColorFilter.mode(
                    isPast ? const Color(0xFF718096) : const Color(0xFF5B8DEF),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isPast
                              ? const Color(0xFF718096)
                              : const Color(0xFF202733),
                        ),
                      ),
                      if (appointment.specialization.isNotEmpty)
                        Text(
                          appointment.specialization,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF718096),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF35B779),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'TODAY',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _deleteAppointment(appointment),
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: const Color(0xFF718096).withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.calendar_today, appointment.formattedDate),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.access_time, appointment.appointmentTime),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on_outlined, appointment.location),
                ],
              ),
            ),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                appointment.notes!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF718096),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF5B8DEF)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF202733),
            ),
          ),
        ),
      ],
    );
  }

  void _deleteAppointment(Appointment appointment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Appointment', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Delete appointment with ${appointment.doctorName}?'),
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
      await AlarmService.cancelAppointmentReminder(appointment.id);
      await DatabaseHelper.instance.deleteAppointment(appointment.id);
      _loadAppointments();
    }
  }

  void _showAddAppointmentSheet() {
    final doctorController = TextEditingController();
    final specializationController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'New Appointment',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF202733),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Doctor Name'),
                      const SizedBox(height: 8),
                      _buildTextField(doctorController, 'e.g. Dr. Smith'),
                      const SizedBox(height: 16),
                      _buildLabel('Specialization'),
                      const SizedBox(height: 8),
                      _buildTextField(specializationController, 'e.g. Cardiologist'),
                      const SizedBox(height: 16),
                      _buildLabel('Appointment Date'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Color(0xFF5B8DEF)),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF202733),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Appointment Time'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setSheetState(() => selectedTime = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 18, color: Color(0xFF5B8DEF)),
                              const SizedBox(width: 10),
                              Text(
                                selectedTime.format(context),
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF202733),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Location'),
                      const SizedBox(height: 8),
                      _buildTextField(locationController, 'e.g. City Hospital, Room 302'),
                      const SizedBox(height: 16),
                      _buildLabel('Notes (Optional)'),
                      const SizedBox(height: 8),
                      _buildTextField(notesController, 'Any additional notes...', maxLines: 3),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _saveAppointment(
                            doctorController,
                            specializationController,
                            locationController,
                            notesController,
                            selectedDate,
                            selectedTime,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B8DEF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Save Appointment',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF202733),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF202733),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFFA0AEC0),
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  void _saveAppointment(
    TextEditingController doctorCtrl,
    TextEditingController specCtrl,
    TextEditingController locationCtrl,
    TextEditingController notesCtrl,
    DateTime date,
    TimeOfDay time,
  ) {
    if (doctorCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter doctor name'),
          backgroundColor: Color(0xFFE85D75),
        ),
      );
      return;
    }

    if (locationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter location'),
          backgroundColor: Color(0xFFE85D75),
        ),
      );
      return;
    }

    final appointment = Appointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      patientId: widget.patientId,
      doctorName: doctorCtrl.text.trim(),
      specialization: specCtrl.text.trim(),
      appointmentDate: date,
      appointmentTime: time.format(context),
      location: locationCtrl.text.trim(),
      notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
      createdAt: DateTime.now(),
    );

    DatabaseHelper.instance.addAppointment(appointment).then((_) {
      AlarmService.scheduleAppointmentReminder(appointment);
      Navigator.pop(context);
      _loadAppointments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment saved!'),
          backgroundColor: Color(0xFF35B779),
        ),
      );
    });
  }
}
