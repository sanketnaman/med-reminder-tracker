import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_helper.dart';
import 'models.dart';
import 'premium_screen.dart';

class AddDependentScreen extends StatefulWidget {
  final Dependent? dependentToEdit;
  const AddDependentScreen({super.key, this.dependentToEdit});

  @override
  State<AddDependentScreen> createState() => _AddDependentScreenState();
}

class _AddDependentScreenState extends State<AddDependentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  String _selectedRelation = 'Father';
  String _selectedGender = 'Male';
  bool _isLoading = false;

  static const List<String> _relations = [
    'Father', 'Mother', 'Spouse', 'Son', 'Daughter',
    'Brother', 'Sister', 'Grandfather', 'Grandmother', 'Other',
  ];

  static const List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final dep = widget.dependentToEdit;
    _nameController = TextEditingController(text: dep?.name ?? '');
    _ageController = TextEditingController(text: dep != null && dep.age > 0 ? dep.age.toString() : '');
    if (dep != null) {
      _selectedRelation = dep.relation;
      _selectedGender = dep.gender.isNotEmpty ? dep.gender : 'Male';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final isEdit = widget.dependentToEdit != null;
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text) ?? 0;

    if (!isEdit) {
      final canAdd = await DatabaseHelper.instance.canAddDependent();
      if (!canAdd && mounted) {
        setState(() => _isLoading = false);
        _showPremiumPrompt();
        return;
      }
    }

    final dependent = Dependent(
      id: isEdit
          ? widget.dependentToEdit!.id
          : 'dependent_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      relation: _selectedRelation,
      age: age,
      gender: _selectedGender,
      createdAt: isEdit
          ? widget.dependentToEdit!.createdAt
          : DateTime.now(),
    );

    if (isEdit) {
      await DatabaseHelper.instance.updatePatient(dependent);
    } else {
      await DatabaseHelper.instance.addPatient(dependent);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showPremiumPrompt() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.dependentToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF202733),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          isEdit ? 'Edit Dependent' : 'Add Dependent',
          style: GoogleFonts.inter(
            color: const Color(0xFF202733),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
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
                // Avatar
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B8DEF).withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.isEmpty
                            ? '?'
                            : _nameController.text[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5B8DEF),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Name
                _buildLabel('Name'),
                _buildCard(
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202733),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF718096).withValues(alpha: 0.6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Relationship
                _buildLabel('Relationship'),
                _buildCard(
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRelation,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF718096),
                    ),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF202733),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    items: _relations
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRelation = val);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Age & Gender
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Age'),
                          _buildCard(
                            TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF202733),
                              ),
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
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
                          _buildLabel('Gender'),
                          _buildCard(
                            DropdownButtonFormField<String>(
                              initialValue: _selectedGender,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF718096),
                              ),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF202733),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              items: _genders
                                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedGender = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B8DEF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Save Changes' : 'Add Dependent',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
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

  Widget _buildCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
