import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_models.dart';

const _assetPath = 'assets/locations/tr_provinces_districts.json';
const _neighborhoodsBaseUrl = 'https://api.turkiyeapi.dev/v2';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

/// Türkiye il/ilçe (offline asset) + mahalle (TurkiyeAPI, önbellekli).
class LocationRepository {
  LocationRepository({Dio? neighborhoodsClient})
      : _neighborhoodsClient = neighborhoodsClient ??
            Dio(
              BaseOptions(
                baseUrl: _neighborhoodsBaseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  final Dio _neighborhoodsClient;

  List<Province>? _provinces;
  List<District>? _districts;
  final Map<int, List<Neighborhood>> _neighborhoodCache = {};

  Future<void> _ensureLoaded() async {
    if (_provinces != null && _districts != null) return;
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _provinces = (json['provinces'] as List<dynamic>)
        .map((e) => Province.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => _turkishCompare(a.name, b.name));
    _districts = (json['districts'] as List<dynamic>)
        .map((e) => District.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Province>> getProvinces() async {
    await _ensureLoaded();
    return List.unmodifiable(_provinces!);
  }

  Future<List<District>> getDistrictsForProvince(int provinceId) async {
    await _ensureLoaded();
    final list = _districts!
        .where((d) => d.provinceId == provinceId)
        .toList()
      ..sort((a, b) => _turkishCompare(a.name, b.name));
    return list;
  }

  Future<List<Neighborhood>> getNeighborhoodsForDistrict(int districtId) async {
    if (_neighborhoodCache.containsKey(districtId)) {
      return List.unmodifiable(_neighborhoodCache[districtId]!);
    }

    final all = <Neighborhood>[];
    var offset = 0;
    const limit = 200;

    while (true) {
      final response = await _neighborhoodsClient.get<Map<String, dynamic>>(
        '/neighborhoods',
        queryParameters: {
          'districtId': districtId,
          'limit': limit,
          'offset': offset,
        },
      );
      final body = response.data;
      if (body == null) {
        throw Exception('neighborhoods_fetch_failed');
      }
      final data = body['data'] as List<dynamic>? ?? [];
      for (final item in data) {
        all.add(Neighborhood.fromJson(item as Map<String, dynamic>));
      }
      final meta = body['meta'] as Map<String, dynamic>? ?? {};
      final total = meta['total'] as int? ?? all.length;
      offset += data.length;
      if (offset >= total || data.isEmpty) break;
    }

    all.sort((a, b) => _turkishCompare(a.name, b.name));
    _neighborhoodCache[districtId] = all;
    return List.unmodifiable(all);
  }

  void clearNeighborhoodCache() {
    _neighborhoodCache.clear();
  }

  static int _turkishCompare(String a, String b) {
    return a.toLowerCase().compareTo(b.toLowerCase());
  }
}
