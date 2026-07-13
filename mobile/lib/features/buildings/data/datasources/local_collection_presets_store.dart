import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/collection_preset_entity.dart';

/// Backend `GET /collection-presets` bina kayıtlarından türetir; bağımsız POST yok.
/// Kullanıcının henüz binaya bağlamadığı IBAN setleri cihazda saklanır.
class LocalCollectionPresetsStore {
  LocalCollectionPresetsStore(this._secureStorage);

  final SecureStorage _secureStorage;

  Future<List<CollectionPresetEntity>> load() async {
    final raw = await _secureStorage.readRaw(AppConstants.localCollectionPresetsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => _fromJson(e.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<CollectionPresetEntity> presets) async {
    final payload = presets.map(_toJson).toList();
    await _secureStorage.writeRaw(
      AppConstants.localCollectionPresetsKey,
      jsonEncode(payload),
    );
  }

  Future<void> upsert(CollectionPresetEntity preset) async {
    final key = preset.collectionIban;
    final list = await load();
    final next = [
      ...list.where((p) => p.collectionIban != key),
      preset,
    ];
    await saveAll(next);
  }

  Future<bool> remove(String normalizedIban) async {
    final list = await load();
    final before = list.length;
    final next =
        list.where((p) => p.collectionIban != normalizedIban).toList();
    if (next.length == before) return false;
    await saveAll(next);
    return true;
  }

  CollectionPresetEntity _fromJson(Map<String, dynamic> json) {
    DateTime? lastUsedAt;
    final raw = json['lastUsedAt'];
    if (raw is String && raw.isNotEmpty) {
      lastUsedAt = DateTime.tryParse(raw);
    }
    return CollectionPresetEntity(
      collectionIban: (json['collectionIban'] ?? '') as String,
      collectionAccountTitle: json['collectionAccountTitle'] as String?,
      collectionIbanLabel: json['collectionIbanLabel'] as String?,
      paymentReferenceTemplate: json['paymentReferenceTemplate'] as String?,
      lastUsedAt: lastUsedAt,
      buildingCount: 0,
    );
  }

  Map<String, dynamic> _toJson(CollectionPresetEntity preset) => {
        'collectionIban': preset.collectionIban,
        'collectionAccountTitle': preset.collectionAccountTitle,
        'collectionIbanLabel': preset.collectionIbanLabel,
        'paymentReferenceTemplate': preset.paymentReferenceTemplate,
        'lastUsedAt': preset.lastUsedAt?.toIso8601String(),
      };
}
