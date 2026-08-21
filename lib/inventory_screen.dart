import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'database_helper.dart';
import 'models.dart';
import 'add_edit_medicine_screen.dart';
import 'medicine_icon.dart';
import 'premium_screen.dart';
import 'animation_utils.dart';
import 'l10n/generated/app_localizations.dart';

class InventoryScreen extends StatefulWidget {
  final VoidCallback onRefreshHome;
  final String patientId;
  const InventoryScreen({
    super.key,
    required this.onRefreshHome,
    this.patientId = 'default_patient',
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Medicine> _medicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    final list = await DatabaseHelper.instance.getMedicinesForPatient(
      widget.patientId,
    );
    if (mounted) {
      setState(() {
        _medicines = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _editMedicine(Medicine medicine) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditMedicineScreen(
          medicineToEdit: medicine,
          patientId: widget.patientId,
        ),
      ),
    );
    if (saved == true) {
      await _loadMedicines();
      widget.onRefreshHome();
    }
  }

  void _showRefillDialog(Medicine medicine) {
    final quantityController = TextEditingController(
      text: medicine.totalQuantity.toInt().toString(),
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Refill ${medicine.name}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Current stock info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.chipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current stock: ${medicine.remainingQuantity.toInt()} ${medicine.dosageUnit}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.addQuantity,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterQuantity,
                    hintStyle: GoogleFonts.inter(
                      color: AppTheme.textSecondary.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixText: medicine.dosageUnit,
                    suffixStyle: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterQuantity;
                    }
                    final qty = double.tryParse(val);
                    if (qty == null || qty <= 0) {
                      return AppLocalizations.of(context)!.pleaseEnterValidQuantity;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Quick add buttons
              Row(
                children: [10, 20, 30, 60].map((qty) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        onPressed: () {
                          quantityController.text = qty.toString();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          '+$qty',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5B8DEF),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final qty = double.parse(quantityController.text);
                        await DatabaseHelper.instance.addStock(
                          medicine.id,
                          qty,
                        );
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                        await _loadMedicines();
                        widget.onRefreshHome();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added $qty ${medicine.dosageUnit} to ${medicine.name}',
                              ),
                              backgroundColor: const Color(0xFF35B779),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B8DEF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.addStock,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            FadeSlideIn(
              delay: Duration.zero,
              offset: 10,
              child: Padding(
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
                    AppLocalizations.of(context)!.inventoryDetails,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ),

            // Banner
            FadeSlideIn(
              delay: const Duration(milliseconds: 80),
              offset: 10,
              child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B8DEF), Color(0xFF7BA7F7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.refillReminderBanner,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),

            // List of medicines in stock
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _medicines.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8.0,
                      ),
                      itemCount: _medicines.length,
                      itemBuilder: (context, index) {
                        final med = _medicines[index];
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 160 + 80 * index),
                          offset: 10,
                          child: _buildInventoryCard(med),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: const Color(0xFF7BA7F7).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.emptyCabinet,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.emptyCabinetSub,
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final canAdd = await DatabaseHelper.instance.canAddMedicine(widget.patientId);
              if (!canAdd && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Free plan limited to ${DatabaseHelper.freeMedicineLimit} medicines. Upgrade to Premium.'),
                    backgroundColor: const Color(0xFFE85D75),
                    action: SnackBarAction(
                      label: AppLocalizations.of(context)!.upgrade,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PremiumScreen()),
                        ).then((_) {
                          _loadMedicines();
                          widget.onRefreshHome();
                        });
                      },
                    ),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditMedicineScreen(patientId: widget.patientId),
                ),
              ).then((value) {
                if (value == true) {
                  _loadMedicines();
                  widget.onRefreshHome();
                }
              });
            },
            icon: const Icon(Icons.add),
              label: Text(
              AppLocalizations.of(context)!.addFirstMedicine,
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
    );
  }

  Widget _buildInventoryCard(Medicine med) {
    // Calculate days remaining
    final daysRemaining = DatabaseHelper.instance.calculateDaysRemaining(med);
    final stockStatus = DatabaseHelper.instance.getStockStatus(med);

    // Determine status label and color based on days remaining
    String statusLabel;
    Color statusColor;
    Color statusBgColor;

    switch (stockStatus) {
      case 'out_of_stock':
        statusLabel = AppLocalizations.of(context)!.outOfStock;
        statusColor = const Color(0xFFE85D75);
        statusBgColor = const Color(0xFFE85D75).withOpacity(0.1);
        break;
      case 'critical':
        statusLabel = AppLocalizations.of(context)!.critical;
        statusColor = const Color(0xFFE85D75);
        statusBgColor = const Color(0xFFE85D75).withOpacity(0.1);
        break;
      case 'low':
        statusLabel = AppLocalizations.of(context)!.lowStock;
        statusColor = const Color(0xFFF5A623);
        statusBgColor = const Color(0xFFF5A623).withOpacity(0.1);
        break;
      default:
        statusLabel = AppLocalizations.of(context)!.inStock;
        statusColor = const Color(0xFF35B779);
        statusBgColor = const Color(0xFF35B779).withOpacity(0.1);
    }

    // Format days remaining text
    String daysText;
    if (daysRemaining <= 0) {
      daysText = AppLocalizations.of(context)!.noStockRemaining;
    } else if (daysRemaining < 1) {
      final hours = (daysRemaining * 24).round();
      daysText = '~$hours hours left';
    } else if (daysRemaining == 1) {
      daysText = '~1 day left';
    } else {
      daysText = '~${daysRemaining.round()} days left';
    }

    return InkWell(
      onTap: () => _editMedicine(med),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Medicine Icon
            MedicineIcon(
              medicineType: med.type,
              size: 52,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine Name
                  Text(
                    med.name,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Medicine Type
                  Text(
                    med.type,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: MedicineIcon.getColorForType(med.type),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Status Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Remaining quantity and days
                  Row(
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 14,
                        color: AppTheme.textSecondary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${med.remainingQuantity.toInt()} ${med.dosageUnit} ${AppLocalizations.of(context)!.remaining}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppTheme.textSecondary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        daysText,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editMedicine(med),
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.edit,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showRefillDialog(med),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B8DEF).withOpacity(0.12),
                    foregroundColor: const Color(0xFF5B8DEF),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.refillNow,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
