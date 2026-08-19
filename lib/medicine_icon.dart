import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MedicineIcon extends StatelessWidget {
  final String medicineType;
  final double size;
  final Color? color;

  const MedicineIcon({
    super.key,
    required this.medicineType,
    this.size = 40,
    this.color,
  });

  String get _assetPath {
    switch (medicineType.toLowerCase()) {
      case 'tablet':
        return 'assets/icons/tablet.svg';
      case 'capsule':
        return 'assets/icons/Capsule.svg';
      case 'syrup':
        return 'assets/icons/Syrup.svg';
      case 'injection':
        return 'assets/icons/Injection.svg';
      case 'drops':
        return 'assets/icons/Drops.svg';
      case 'cream':
        return 'assets/icons/Cream.svg';
      case 'powder':
        return 'assets/icons/Powder.svg';
      default:
        return 'assets/icons/Other.svg';
    }
  }

  Color get _fallbackColor {
    switch (medicineType.toLowerCase()) {
      case 'tablet':
        return const Color(0xFF5B8DEF);
      case 'capsule':
        return const Color(0xFF20C9D8);
      case 'syrup':
        return const Color(0xFFF5A623);
      case 'injection':
        return const Color(0xFFE85D75);
      case 'drops':
        return const Color(0xFF7BA7F7);
      case 'cream':
        return const Color(0xFF35B779);
      case 'powder':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF718096);
    }
  }

  IconData get _fallbackIcon {
    switch (medicineType.toLowerCase()) {
      case 'tablet':
        return Icons.medication;
      case 'capsule':
        return Icons.circle;
      case 'syrup':
        return Icons.local_drink;
      case 'injection':
        return Icons.vaccines;
      case 'drops':
        return Icons.water_drop;
      case 'cream':
        return Icons.science;
      case 'powder':
        return Icons.grain;
      default:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      placeholderBuilder: (context) => Icon(
        _fallbackIcon,
        size: size,
        color: color ?? _fallbackColor,
      ),
      errorBuilder: (context, error, stackTrace) => Icon(
        _fallbackIcon,
        size: size,
        color: color ?? _fallbackColor,
      ),
    );
  }

  static Color getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return const Color(0xFF5B8DEF);
      case 'capsule':
        return const Color(0xFF20C9D8);
      case 'syrup':
        return const Color(0xFFF5A623);
      case 'injection':
        return const Color(0xFFE85D75);
      case 'drops':
        return const Color(0xFF7BA7F7);
      case 'cream':
        return const Color(0xFF35B779);
      case 'powder':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF718096);
    }
  }

  static String getAssetPath(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return 'assets/icons/tablet.svg';
      case 'capsule':
        return 'assets/icons/Capsule.svg';
      case 'syrup':
        return 'assets/icons/Syrup.svg';
      case 'injection':
        return 'assets/icons/Injection.svg';
      case 'drops':
        return 'assets/icons/Drops.svg';
      case 'cream':
        return 'assets/icons/Cream.svg';
      case 'powder':
        return 'assets/icons/Powder.svg';
      default:
        return 'assets/icons/Other.svg';
    }
  }
}
