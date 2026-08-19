import 'dart:convert';
import 'package:flutter/services.dart';

class CatalogMedicine {
  final String id;
  final String genericName;
  final String strength;
  final String dosageForm;
  final String displayName;
  final String searchText;
  final bool isCombination;

  CatalogMedicine({
    required this.id,
    required this.genericName,
    required this.strength,
    required this.dosageForm,
    required this.displayName,
    required this.searchText,
    required this.isCombination,
  });

  factory CatalogMedicine.fromMap(Map<String, dynamic> map) {
    return CatalogMedicine(
      id: map['id'] ?? '',
      genericName: map['genericName'] ?? '',
      strength: map['strength'] ?? '',
      dosageForm: map['dosageForm'] ?? '',
      displayName: map['displayName'] ?? '',
      searchText: map['searchText'] ?? '',
      isCombination: map['isCombination'] ?? false,
    );
  }
}

class MedicineCatalogService {
  MedicineCatalogService._();

  static final MedicineCatalogService instance = MedicineCatalogService._();

  List<CatalogMedicine> _catalog = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final jsonStr = await rootBundle.loadString(
      'assets/data/medicine_catalog_1000.json',
    );
    final List<dynamic> decoded = json.decode(jsonStr);
    _catalog = decoded
        .map((e) => CatalogMedicine.fromMap(e as Map<String, dynamic>))
        .toList();
    _loaded = true;
  }

  List<CatalogMedicine> search(String query) {
    if (!_loaded || query.trim().isEmpty) return const [];

    final q = query.trim().toLowerCase();
    final results = <CatalogMedicine>[];

    for (final med in _catalog) {
      final genericLower = med.genericName.toLowerCase();
      final displayLower = med.displayName.toLowerCase();
      final searchLower = med.searchText.toLowerCase();

      if (genericLower.contains(q) ||
          displayLower.contains(q) ||
          searchLower.contains(q)) {
        results.add(med);
      }
    }

    // Sort: genericName starts with query first, then alphabetical
    results.sort((a, b) {
      final aStarts = a.genericName.toLowerCase().startsWith(q);
      final bStarts = b.genericName.toLowerCase().startsWith(q);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      return a.genericName.compareTo(b.genericName);
    });

    return results.take(10).toList();
  }
}
