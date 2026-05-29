import 'dart:typed_data';

import '../features/dekont/domain/entities/dekont_entity.dart';
import '../features/dekont/domain/entities/dekont_status.dart';
import '../features/dekont/domain/entities/payment_collection_entity.dart';
import '../features/dekont/domain/repositories/dekont_repository.dart';

/// Dev preview — in-memory dekont + ödeme bilgisi.
class MockDekontRepository implements DekontRepository {
  MockDekontRepository() {
    _seed();
  }

  final List<DekontEntity> _dekonts = [];
  int _counter = 0;

  void _seed() {
    _dekonts.addAll([
      DekontEntity(
        id: 'dk-mock-1',
        buildingId: 'b1',
        apartmentId: 'apt-1',
        uploadedById: 'resident-1',
        dueId: 'due-1',
        status: DekontStatus.needsManagerReview,
        source: 'RESIDENT_UPLOAD',
        originalFilename: 'havale-dekont.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 120_000,
        parsedAmount: '500.00',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        apartment: const DekontApartmentSummary(id: 'apt-1', number: '5'),
        uploadedBy: const DekontUserSummary(
          id: 'resident-1',
          name: 'Ayşe Yılmaz',
          email: 'ayse@example.com',
        ),
      ),
      DekontEntity(
        id: 'dk-mock-2',
        buildingId: 'b1',
        apartmentId: 'apt-2',
        uploadedById: 'resident-2',
        status: DekontStatus.paymentApplied,
        source: 'RESIDENT_UPLOAD',
        originalFilename: 'odeme.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 85_000,
        parsedAmount: '500.00',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        apartment: const DekontApartmentSummary(id: 'apt-2', number: '12'),
        uploadedBy: const DekontUserSummary(
          id: 'resident-2',
          name: 'Mehmet Demir',
        ),
      ),
    ]);
  }

  @override
  Future<PaymentCollectionEntity> getPaymentCollection() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const PaymentCollectionEntity(
      buildingId: 'b1',
      buildingName: 'Gül Sitesi',
      apartmentNumber: '5',
      collectionIban: 'TR330006100519786457841326',
      collectionAccountTitle: 'Gül Sitesi Yönetimi',
      paymentReferenceTemplate: 'Daire {{number}}',
      paymentReference: 'Daire 5',
      isCollectionConfigured: true,
    );
  }

  @override
  Future<DekontEntity> uploadDekont({
    required String filePath,
    String? dueId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _counter++;
    final id = 'dk-mock-new-$_counter';
    final entity = DekontEntity(
      id: id,
      buildingId: 'b1',
      apartmentId: 'apt-1',
      uploadedById: 'resident-1',
      dueId: dueId,
      status: DekontStatus.received,
      source: 'RESIDENT_UPLOAD',
      originalFilename: filePath.split('/').last.split('\\').last,
      mimeType: filePath.toLowerCase().endsWith('.pdf')
          ? 'application/pdf'
          : 'image/jpeg',
      sizeBytes: 50_000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _dekonts.insert(0, entity);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final settled = entity.copyWithStatus(DekontStatus.needsManagerReview);
    _replace(settled);
    return settled;
  }

  @override
  Future<DekontEntity> getDekont(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _dekonts.firstWhere(
      (d) => d.id == id,
      orElse: () => throw Exception('Dekont bulunamadı'),
    );
  }

  @override
  Future<List<DekontEntity>> getMyDekonts({String? status}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (status == null) return List.from(_dekonts);
    return _dekonts.where((d) => d.status.apiValue == status).toList();
  }

  @override
  Future<List<DekontEntity>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    var list = _dekonts.where((d) => d.buildingId == buildingId);
    if (status != null) {
      list = list.where((d) => d.status.apiValue == status);
    }
    if (apartmentId != null) {
      list = list.where((d) => d.apartmentId == apartmentId);
    }
    return list.toList();
  }

  @override
  Future<DekontEntity> reviewDekont({
    required String id,
    required DekontReviewDecision decision,
    String? note,
    String? dueId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final current = await getDekont(id);
    final updated = current.copyWithStatus(
      decision == DekontReviewDecision.approve
          ? DekontStatus.paymentApplied
          : DekontStatus.rejected,
      reviewNote: note,
      rejectionReason:
          decision == DekontReviewDecision.reject ? note : null,
      dueId: dueId ?? current.dueId,
    );
    _replace(updated);
    return updated;
  }

  @override
  Future<List<int>> getDekontFileBytes(String id, {bool download = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // 1x1 PNG
    return Uint8List.fromList([
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0,
      0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73,
      68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0,
      0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
    ]);
  }

  void _replace(DekontEntity entity) {
    final i = _dekonts.indexWhere((d) => d.id == entity.id);
    if (i >= 0) {
      _dekonts[i] = entity;
    }
  }
}

extension on DekontEntity {
  DekontEntity copyWithStatus(
    DekontStatus status, {
    String? reviewNote,
    String? rejectionReason,
    String? dueId,
  }) {
    return DekontEntity(
      id: id,
      buildingId: buildingId,
      apartmentId: apartmentId,
      uploadedById: uploadedById,
      dueId: dueId ?? this.dueId,
      status: status,
      source: source,
      originalFilename: originalFilename,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
      recipientVerified: recipientVerified,
      referenceNumber: referenceNumber,
      parsedAmount: parsedAmount,
      transactionDate: transactionDate,
      aiConfidence: aiConfidence,
      reviewedAt: DateTime.now(),
      reviewNote: reviewNote ?? this.reviewNote,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      parseError: parseError,
      parserProfile: parserProfile,
      parsedJson: parsedJson,
      apartment: apartment,
      uploadedBy: uploadedBy,
    );
  }
}
