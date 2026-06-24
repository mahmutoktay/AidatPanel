import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/utils/turkish_string_utils.dart';

/// Türkiye 81 il + 973 ilçe (TurkiyeAPI veri seti).
class TurkishLocations {
  TurkishLocations._();

  static const _assetPath = 'assets/data/tr_locations.json';

  static List<_Province>? _provinces;
  static Map<String, List<String>>? _districtMap;
  static Map<String, int>? _populationMap;
  static List<String>? _sortedCities;
  static Future<void>? _loadFuture;

  static Future<void> ensureLoaded() {
    return _loadFuture ??= _load();
  }

  static Future<void> _load() async {
    if (_provinces != null) return;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(raw) as List<dynamic>;
    final provinces = <_Province>[];
    final districts = <String, List<String>>{};
    final populations = <String, int>{};

    for (final row in decoded) {
      final map = row as Map<String, dynamic>;
      final name = map['name'] as String;
      final population = (map['population'] as num?)?.toInt() ?? 0;
      final districtList = (map['districts'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
      provinces.add(
        _Province(name: name, population: population, districts: districtList),
      );
      districts[name] = sortTurkishList(districtList);
      populations[name] = population;
    }

    provinces.sort((a, b) => compareTurkish(a.name, b.name));

    _provinces = provinces;
    _districtMap = districts;
    _populationMap = populations;
    _sortedCities = provinces.map((p) => p.name).toList();
  }

  static bool get isLoaded => _provinces != null;

  static Map<String, List<String>> get data {
    final d = _districtMap;
    if (d == null) {
      throw StateError(
        'TurkishLocations henüz yüklenmedi. ensureLoaded() çağırın.',
      );
    }
    return d;
  }

  static List<String> get sortedCityNames {
    final list = _sortedCities;
    if (list != null) return list;
    return sortTurkishList(data.keys);
  }

  static int populationOf(String city) => _populationMap?[city] ?? 0;

  static List<String> districtsOf(String city) {
    return List<String>.from(data[city] ?? const []);
  }

  static List<String> filterCities(String query) {
    return filterTurkishSearch(
      sortedCityNames,
      query,
      weight: populationOf,
    );
  }

  static List<String> filterDistricts(String city, String query) {
    return filterTurkishSearch(districtsOf(city), query);
  }
}

class _Province {
  const _Province({
    required this.name,
    required this.population,
    required this.districts,
  });

  final String name;
  final int population;
  final List<String> districts;
}

/// Geriye dönük uyumluluk.
Map<String, List<String>> get turkishCities => TurkishLocations.data;

List<String> get sortedCityNames => TurkishLocations.sortedCityNames;
