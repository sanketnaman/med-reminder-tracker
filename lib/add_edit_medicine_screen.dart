import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'models.dart';
import 'alarm_service.dart';
import 'medicine_icon.dart';
import 'medicine_catalog_service.dart';
import 'premium_screen.dart';
import 'l10n/generated/app_localizations.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicineToEdit;
  final String patientId;
  const AddEditMedicineScreen({
    super.key,
    this.medicineToEdit,
    this.patientId = 'default_patient',
  });

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _totalQuantityController;
  late TextEditingController _notesController;

  // Selected values
  String _selectedType = 'Tablet';
  String _selectedDosageUnit = 'Tablet';
  String _mealRelation = 'Before Meal';
  String _frequencyType = 'Every day';

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isOngoing = true;

  List<String> _timings = ['07:00 AM'];
  List<int> _daysOfWeek = [1, 2, 3, 4, 5, 6, 7]; // 1=Mon, 7=Sun

  // Catalog autocomplete
  List<CatalogMedicine> _catalogResults = [];
  Timer? _searchDebounce;

  // Dropdown lists
  final List<String> _medicineTypes = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Drops',
    'Cream',
    'Powder',
    'Other',
  ];
  final List<String> _dosageUnits = [
    'Tablet',
    'Capsule',
    'ml',
    'Drop',
    'Spoon',
    'Other',
  ];
  final List<String> _frequencies = ['Every day', 'Specific days'];

  @override
  void initState() {
    super.initState();
    final med = widget.medicineToEdit;

    _nameController = TextEditingController(text: med?.name ?? '');
    _loadCatalog();
    _dosageController = TextEditingController(
      text: med?.dosage.toString() ?? '1',
    );
    _totalQuantityController = TextEditingController(
      text: med?.totalQuantity.toString() ?? '30',
    );
    _notesController = TextEditingController(text: med?.notes ?? '');

    if (med != null) {
      _selectedType = med.type;
      _selectedDosageUnit = med.dosageUnit;
      _mealRelation = med.mealRelation;
      _frequencyType = med.frequencyType;
      _startDate = med.startDate;
      _endDate = med.endDate;
      _isOngoing = med.isOngoing;
      _timings = List.from(med.timings);
      _daysOfWeek = List.from(med.daysOfWeek);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _totalQuantityController.dispose();
    _notesController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    await MedicineCatalogService.instance.load();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      final results = MedicineCatalogService.instance.search(query);
      if (mounted) {
        setState(() {
          _catalogResults = results;
        });
      }
    });
  }

  void _selectCatalogMedicine(CatalogMedicine catalog) {
    final strength = catalog.strength.trim();
    _nameController.text = strength.isEmpty
        ? catalog.genericName
        : '${catalog.genericName} $strength';

    // Map dosageForm to existing type list
    final formLower = catalog.dosageForm.toLowerCase();
    String matchedType = 'Other';
    for (final t in _medicineTypes) {
      if (t.toLowerCase() == formLower) {
        matchedType = t;
        break;
      }
    }
    // Handle common variations
    if (formLower.contains('tablet')) {
      matchedType = 'Tablet';
    } else if (formLower.contains('capsule')) {
      matchedType = 'Capsule';
    } else if (formLower.contains('syrup') || formLower.contains('suspension') || formLower.contains('solution')) {
      matchedType = 'Syrup';
    } else if (formLower.contains('injection') || formLower.contains('injectable')) {
      matchedType = 'Injection';
    } else if (formLower.contains('drop')) {
      matchedType = 'Drops';
    } else if (formLower.contains('cream') || formLower.contains('ointment') || formLower.contains('gel')) {
      matchedType = 'Cream';
    } else if (formLower.contains('powder')) {
      matchedType = 'Powder';
    }

    // Parse strength: "500 mg", "120 mg/5 mL", "5 mg", "10 mg + 75 mg"
    String dosageAmount = '1';
    String matchedUnit = 'Other';

    final strengthClean = strength.replaceAll(RegExp(r'\s*[\+/]\s*.*'), '').trim();
    final numMatch = RegExp(r'([\d.]+)').firstMatch(strengthClean);
    if (numMatch != null) {
      dosageAmount = numMatch.group(1)!;
    }

    if (formLower.contains('tablet')) {
      matchedUnit = 'Tablet';
    } else if (formLower.contains('capsule')) {
      matchedUnit = 'Capsule';
    } else if (formLower.contains('ml') || formLower.contains('syrup') || formLower.contains('suspension') || formLower.contains('solution')) {
      matchedUnit = 'ml';
    } else if (formLower.contains('drop')) {
      matchedUnit = 'Drop';
    } else if (formLower.contains('spoon') || formLower.contains('teaspoon')) {
      matchedUnit = 'Spoon';
    } else {
      // Try to parse unit from strength string (e.g., "500 mg" → "mg")
      final unitMatch = RegExp(r'[\d.]+\s*(mg|mcg|g|ml|mL|iu|units?)').firstMatch(strength);
      if (unitMatch != null) {
        matchedUnit = unitMatch.group(1)!.toLowerCase();
        if (matchedUnit == 'mcg') matchedUnit = 'mcg';
      }
    }

    setState(() {
      _selectedType = matchedType;
      _selectedDosageUnit = matchedUnit;
      _dosageController.text = dosageAmount;
      _catalogResults = [];
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? _startDate
          : (_endDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B8DEF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF202733),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
          _isOngoing = false;
        }
      });
    }
  }

  Future<void> _addTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );

    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      final formatted = DateFormat('hh:mm a').format(dt);
      setState(() {
        if (!_timings.contains(formatted)) {
          _timings.add(formatted);
          _timings.sort((a, b) => a.compareTo(b));
        }
      });
    }
  }

  void _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    final isEdit = widget.medicineToEdit != null;

    // Check medicine limit for new medicines (free tier)
    if (!isEdit) {
      final canAdd = await DatabaseHelper.instance.canAddMedicine(widget.patientId);
      if (!canAdd && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Free plan limited to ${DatabaseHelper.freeMedicineLimit} medicines. Upgrade to Premium.'),
            backgroundColor: const Color(0xFFE85D75),
            action: SnackBarAction(
              label: 'Upgrade',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                );
              },
            ),
          ),
        );
        return;
      }
    }

    final medName = _nameController.text.trim();
    final dosage = double.tryParse(_dosageController.text) ?? 1.0;
    final totalQty = double.tryParse(_totalQuantityController.text) ?? 30.0;
    final notes = _notesController.text.trim();

    if (_timings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorAlertTime)),
      );
      return;
    }

    final id = isEdit
        ? widget.medicineToEdit!.id
        : DateTime.now().millisecondsSinceEpoch.toString();

    final medicine = Medicine(
      id: id,
      patientId: isEdit ? widget.medicineToEdit!.patientId : widget.patientId,
      name: medName,
      type: _selectedType,
      dosage: dosage,
      dosageUnit: _selectedDosageUnit,
      totalQuantity: totalQty,
      remainingQuantity: isEdit
          ? widget.medicineToEdit!.remainingQuantity
          : totalQty,
      startDate: _startDate,
      endDate: _isOngoing ? null : _endDate,
      isOngoing: _isOngoing,
      mealRelation: _mealRelation,
      notes: notes,
      timings: _timings,
      frequencyType: _frequencyType,
      daysOfWeek: _daysOfWeek,
      createdAt: isEdit ? widget.medicineToEdit!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (isEdit) {
      final existingRecords = await DatabaseHelper.instance.getDoseRecords();
      for (final record in existingRecords.where(
        (record) =>
            record.medicineId == widget.medicineToEdit!.id &&
            record.status == 'scheduled',
      )) {
        await AlarmService.cancel(record.id);
      }
      await DatabaseHelper.instance.updateMedicine(medicine);
    } else {
      await DatabaseHelper.instance.addMedicine(medicine);
    }
    await AlarmService.scheduleAllUpcoming();

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _deleteMedicine() async {
    if (widget.medicineToEdit == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.deleteMedicineLabel,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${widget.medicineToEdit!.name}? All scheduled reminders will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE85D75),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final records = await DatabaseHelper.instance.getDoseRecords();
      for (final record in records.where(
        (record) => record.medicineId == widget.medicineToEdit!.id,
      )) {
        await AlarmService.cancel(record.id);
      }
      await DatabaseHelper.instance.deleteMedicine(widget.medicineToEdit!.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.medicineToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
              isEdit ? AppLocalizations.of(context)!.editMedicineTitle : AppLocalizations.of(context)!.addMedicineTitle,
              style: GoogleFonts.inter(
                color: const Color(0xFF202733),
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Custom Pill Graphic illustration (matching Mediaro's style)
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B8DEF).withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD56B), // yellow ball
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                            top: 20,
                            child: Transform.rotate(
                              angle: 0.5,
                              child: Container(
                                width: 50,
                                height: 26,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE85D75),
                                      Color(0xFF5B8DEF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel(AppLocalizations.of(context)!.medicineName),
                _buildCardContainer(
                  Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF202733),
                        ),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.searchMedicine,
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF718096).withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: _nameController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _nameController.clear();
                                    setState(() {
                                      _catalogResults = [];
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: _onSearchChanged,
                        validator: (val) => val == null || val.trim().isEmpty
                            ? AppLocalizations.of(context)!.pleaseEnterName
                            : null,
                      ),
                      if (_catalogResults.isNotEmpty) ...[
                        const Divider(height: 1, thickness: 1),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 240),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _catalogResults.length,
                            itemBuilder: (context, index) {
                              final med = _catalogResults[index];
                              return InkWell(
                                onTap: () => _selectCatalogMedicine(med),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF5B8DEF).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.medication_outlined,
                                          size: 18,
                                          color: Color(0xFF5B8DEF),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              med.genericName,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF202733),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${med.strength} • ${med.dosageForm}',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: const Color(0xFF718096),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (med.isCombination)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF20C9D8).withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Combo',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF20C9D8),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Type & Dosage & Total Quantity row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(AppLocalizations.of(context)!.typeOfMedicine),
                          _buildMedicineTypeDropdown(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(AppLocalizations.of(context)!.doseDaily),
                          _buildCardContainer(
                            TextFormField(
                              controller: _dosageController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF202733),
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Total Dose'),
                          _buildCardContainer(
                            TextFormField(
                              controller: _totalQuantityController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF202733),
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Start Date & End Date Pickers
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(AppLocalizations.of(context)!.startDate),
                          GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: _buildCardContainer(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yy').format(_startDate),
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF202733),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_month,
                                      color: Color(0xFF718096),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(AppLocalizations.of(context)!.endDate),
                          GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: _buildCardContainer(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _isOngoing
                                          ? AppLocalizations.of(context)!.ongoing
                                          : (_endDate != null
                                                ? DateFormat(
                                                    'dd/MM/yy',
                                                  ).format(_endDate!)
                                                : AppLocalizations.of(context)!.select),
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF202733),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_month,
                                      color: Color(0xFF718096),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildLabel(AppLocalizations.of(context)!.setReminder),
                _buildDropdownCard(_frequencyType, _frequencies, (val) {
                  setState(() {
                    _frequencyType = val!;
                  });
                }, labelMapper: (val) {
                  switch (val) {
                    case 'Every day': return AppLocalizations.of(context)!.everyDay;
                    case 'Specific days': return AppLocalizations.of(context)!.specificDays;
                    default: return val;
                  }
                }),
                const SizedBox(height: 20),

                // Specific Days Selection (If "Specific days" is selected)
                if (_frequencyType == 'Specific days') ...[
                  _buildLabel(AppLocalizations.of(context)!.selectDays),
                  _buildDaysSelector(),
                  const SizedBox(height: 20),
                ],

                // Time Timings List
                _buildLabel(AppLocalizations.of(context)!.time),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._timings.map(
                      (time) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B8DEF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF5B8DEF),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _timings.remove(time);
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFF5B8DEF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _addTime(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Color(0xFF5B8DEF)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Meal relation segmented tabs
                _buildLabel(AppLocalizations.of(context)!.mealRelation),
                Row(
                  children: [AppLocalizations.of(context)!.beforeMeal, AppLocalizations.of(context)!.duringMeal, AppLocalizations.of(context)!.afterMeal].map((
                    relation,
                  ) {
                    final isSel = _mealRelation == relation;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _mealRelation = relation;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFF5B8DEF)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              relation,
                              style: GoogleFonts.inter(
                                color: isSel
                                    ? Colors.white
                                    : const Color(0xFF718096),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                _buildLabel(AppLocalizations.of(context)!.instructionsNotes),
                _buildCardContainer(
                  TextFormField(
                    controller: _notesController,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202733),
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g., Take with warm water',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF718096).withOpacity(0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Save or Save & Delete buttons
                Row(
                  children: [
                    if (isEdit) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _deleteMedicine,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE85D75)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.deleteMedicineLabel,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFE85D75),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveMedicine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B8DEF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isEdit ? AppLocalizations.of(context)!.saveChanges : AppLocalizations.of(context)!.saveMedicine,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF718096),
        ),
      ),
    );
  }

  Widget _buildCardContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDropdownCard(
    String value,
    List<String> list,
    Function(String?) onChanged, {
    String Function(String)? labelMapper,
  }) {
    return _buildCardContainer(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF718096),
            ),
            style: GoogleFonts.inter(
              color: const Color(0xFF202733),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            onChanged: onChanged,
            items: list.map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(labelMapper != null ? labelMapper(val) : val),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineTypeDropdown() {
    String localizeType(String type) {
      switch (type) {
        case 'Tablet': return AppLocalizations.of(context)!.tablet;
        case 'Capsule': return AppLocalizations.of(context)!.capsule;
        case 'Syrup': return AppLocalizations.of(context)!.syrup;
        case 'Injection': return AppLocalizations.of(context)!.injection;
        case 'Drops': return AppLocalizations.of(context)!.drops;
        case 'Cream': return AppLocalizations.of(context)!.cream;
        case 'Powder': return AppLocalizations.of(context)!.powder;
        case 'Other': return AppLocalizations.of(context)!.otherType;
        default: return type;
      }
    }
    return _buildCardContainer(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedType,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF718096),
              size: 20,
            ),
            style: GoogleFonts.inter(
              color: const Color(0xFF202733),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            onChanged: (val) {
              setState(() {
                _selectedType = val!;
              });
            },
            selectedItemBuilder: (BuildContext context) {
              return _medicineTypes.map((String type) {
                return Row(
                  children: [
                    MedicineIcon(
                      medicineType: type,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        localizeType(type),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
            items: _medicineTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Row(
                  children: [
                    MedicineIcon(
                      medicineType: type,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        localizeType(type),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysSelector() {
    final List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final dayNum = index + 1;
        final isSel = _daysOfWeek.contains(dayNum);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSel) {
                if (_daysOfWeek.length > 1) {
                  _daysOfWeek.remove(dayNum);
                }
              } else {
                _daysOfWeek.add(dayNum);
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSel ? const Color(0xFF5B8DEF) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                weekdays[index],
                style: GoogleFonts.inter(
                  color: isSel ? Colors.white : const Color(0xFF718096),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
