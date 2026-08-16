import 'dart:typed_data';

import '../core/network/paginated_list_result.dart';
import '../features/dekont/domain/entities/dekont_entity.dart';
import '../features/dekont/domain/entities/dekont_upload_result.dart';
import '../features/dekont/domain/entities/dekont_status.dart';
import '../features/dekont/domain/entities/payment_collection_entity.dart';
import '../features/dekont/domain/repositories/dekont_repository.dart';
import '../features/dues/domain/entities/due_entity.dart';
import 'dev_mocks.dart' show MockAuthRepository;
import 'dev_showcase_seed.dart';

/// Dev preview — in-memory dekont (showcase bina/daire ID'leri ile uyumlu).
class MockDekontRepository implements DekontRepository {
  MockDekontRepository() {
    _seed();
  }

  final List<DekontEntity> _dekonts = [];
  int _counter = 0;

  DueEntity? _openDue(String buildingId, String aptNumber) {
    final now = DateTime.now();
    final list = buildShowcaseDues()[buildingId] ?? const <DueEntity>[];
    for (final d in list) {
      if (d.apartmentNumber == aptNumber &&
          d.month == now.month &&
          d.year == now.year &&
          d.status != DueStatus.paid) {
        return d;
      }
    }
    for (final d in list) {
      if (d.apartmentNumber == aptNumber &&
          d.month == now.month &&
          d.year == now.year) {
        return d;
      }
    }
    return null;
  }

  void _seed() {
    final now = DateTime.now();
    // Yönetici inceleme kuyruğu + sakin screenshot için tek net "onay bekliyor"
    // (oturum sakini r_lale_8 / Lale ₺1250). getMyDekonts oturuma filtreler.
    final pairs = <({
      String id,
      String buildingId,
      String buildingName,
      String aptId,
      String aptNo,
      String userId,
      String userName,
      DekontStatus status,
      Duration ago,
    })>[
      (
        id: 'dk_lale_8',
        buildingId: DevShowcaseIds.lale,
        buildingName: 'Lale Apartmanı',
        aptId: 'lale_a8',
        aptNo: '8',
        userId: 'r_lale_8',
        userName: 'Cem Aydın',
        status: DekontStatus.needsManagerReview,
        ago: const Duration(hours: 2),
      ),
      (
        id: 'dk_vefa_1',
        buildingId: DevShowcaseIds.vefa,
        buildingName: 'Vefa Apartman',
        aptId: 'vefa_a1',
        aptNo: '1',
        userId: 'r_vefa_1',
        userName: 'Ayşe Demir',
        status: DekontStatus.needsManagerReview,
        ago: const Duration(hours: 5),
      ),
      (
        id: 'dk_lale_2',
        buildingId: DevShowcaseIds.lale,
        buildingName: 'Lale Apartmanı',
        aptId: 'lale_a2',
        aptNo: '2',
        userId: 'r_lale_2',
        userName: 'Onur Akar',
        status: DekontStatus.paymentApplied,
        ago: const Duration(days: 1),
      ),
    ];

    for (final p in pairs) {
      final due = _openDue(p.buildingId, p.aptNo);
      if (due == null) continue;
      final amountStr = due.amount.toStringAsFixed(2);
      final createdAt = now.subtract(p.ago);
      final isApplied = p.status == DekontStatus.paymentApplied;
      _dekonts.add(
        DekontEntity(
          id: p.id,
          buildingId: p.buildingId,
          buildingName: p.buildingName,
          apartmentId: p.aptId,
          uploadedById: p.userId,
          dueId: due.id,
          dueIds: [due.id],
          allocations: [
            DekontDueAllocationSummary(
              dueId: due.id,
              month: due.month,
              year: due.year,
              amount: amountStr,
              remainingAmount: isApplied
                  ? '0.00'
                  : due.remainingAmount.toStringAsFixed(2),
              apartmentNumber: p.aptNo,
              status: due.status.name.toUpperCase(),
            ),
          ],
          status: p.status,
          source: 'RESIDENT_UPLOAD',
          originalFilename: 'havale-${p.aptNo}.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 110_000,
          parsedAmount: amountStr,
          recipientVerified: true,
          referenceNumber: 'AP-HV-${p.id}',
          transactionDate: createdAt,
          aiConfidence: 0.94,
          createdAt: createdAt,
          updatedAt: createdAt,
          reviewedAt: isApplied ? createdAt : null,
          apartment: DekontApartmentSummary(id: p.aptId, number: p.aptNo),
          uploadedBy: DekontUserSummary(id: p.userId, name: p.userName),
        ),
      );
    }

    _dekonts.add(
      DekontEntity(
        id: 'dk_lale_paid',
        buildingId: DevShowcaseIds.lale,
        buildingName: 'Lale Apartmanı',
        apartmentId: 'lale_a4',
        uploadedById: 'r_lale_4',
        status: DekontStatus.paymentApplied,
        source: 'RESIDENT_UPLOAD',
        originalFilename: 'havale-4.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 98_000,
        parsedAmount: '1250.00',
        recipientVerified: true,
        referenceNumber: 'AP-HV-PAID-4',
        aiConfidence: 0.95,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 3)),
        reviewedAt: now.subtract(const Duration(days: 3)),
        apartment: const DekontApartmentSummary(id: 'lale_a4', number: '4'),
        uploadedBy: const DekontUserSummary(
          id: 'r_lale_4',
          name: 'Rıza Demirtaş',
        ),
      ),
    );
  }

  @override
  Future<PaymentCollectionEntity> getPaymentCollection() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const PaymentCollectionEntity(
      buildingId: DevShowcaseIds.lale,
      buildingName: 'Lale Apartmanı',
      apartmentNumber: '8',
      collectionIban: 'TR460006400000112345678901',
      collectionAccountTitle: 'Lale Apt. Yönetimi',
      paymentReferenceTemplate: 'Daire {{number}} aidat',
      paymentReference: 'Daire 8 aidat',
      isCollectionConfigured: true,
    );
  }

  @override
  Future<DekontUploadResult> uploadDekont({
    required String fileName,
    required List<int> fileBytes,
    String? filePath,
    String? dueId,
    List<String>? dueIds,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _counter++;
    final id = 'dk-mock-new-$_counter';
    final safeName = fileName.split('/').last.split('\\').last;
    final user = MockAuthRepository.sessionUser;
    final aptId = user?.apartmentId ?? 'lale_a8';
    final aptNo =
        aptId.startsWith('lale_a') ? aptId.replaceFirst('lale_a', '') : '8';
    final entity = DekontEntity(
      id: id,
      buildingId: DevShowcaseIds.lale,
      buildingName: 'Lale Apartmanı',
      apartmentId: aptId,
      uploadedById: user?.id ?? 'r_lale_8',
      dueId: dueId,
      dueIds: dueIds ?? (dueId != null ? [dueId] : const []),
      status: DekontStatus.received,
      source: 'RESIDENT_UPLOAD',
      originalFilename: safeName,
      mimeType: safeName.toLowerCase().endsWith('.pdf')
          ? 'application/pdf'
          : 'image/jpeg',
      sizeBytes: fileBytes.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      apartment: DekontApartmentSummary(id: aptId, number: aptNo),
      uploadedBy: DekontUserSummary(
        id: user?.id ?? 'r_lale_8',
        name: user?.name ?? 'Cem Aydın',
      ),
    );
    _dekonts.insert(0, entity);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final settled = entity.copyWithStatus(DekontStatus.needsManagerReview);
    _replace(settled);
    return DekontUploadResult(dekont: settled);
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
  Future<PaginatedListResult<DekontEntity>> getMyDekonts({
    String? status,
    String? cursor,
    bool paginated = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final user = MockAuthRepository.sessionUser;
    var list = List<DekontEntity>.from(_dekonts);
    if (user != null) {
      list = list
          .where(
            (d) =>
                d.uploadedById == user.id ||
                (user.apartmentId != null && d.apartmentId == user.apartmentId),
          )
          .toList();
    }
    if (status != null) {
      list = list.where((d) => d.status.apiValue == status).toList();
    }
    return PaginatedListResult(items: list);
  }

  @override
  Future<PaginatedListResult<DekontEntity>> getBuildingDekonts(
    String buildingId, {
    String? status,
    String? apartmentId,
    String? cursor,
    bool paginated = true,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    var list = _dekonts.where((d) => d.buildingId == buildingId);
    if (status != null) {
      list = list.where((d) => d.status.apiValue == status);
    }
    if (apartmentId != null) {
      list = list.where((d) => d.apartmentId == apartmentId);
    }
    return PaginatedListResult(items: list.toList());
  }

  @override
  Future<DekontEntity> reviewDekont({
    required String id,
    required DekontReviewDecision decision,
    String? note,
    String? dueId,
    List<String>? dueIds,
    double? amount,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final current = await getDekont(id);
    final updated = current.copyWithStatus(
      decision == DekontReviewDecision.approve
          ? DekontStatus.paymentApplied
          : DekontStatus.rejected,
      reviewNote: note,
      rejectionReason: decision == DekontReviewDecision.reject ? note : null,
      dueId: dueId ?? current.dueId,
    );
    _replace(updated);
    return updated;
  }

  @override
  Future<List<int>> getDekontFileBytes(
    String id, {
    bool download = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Uint8List.fromList([
      137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1,
      0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84,
      120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69,
      78, 68, 174, 66, 96, 130,
    ]);
  }

  void _replace(DekontEntity entity) {
    final i = _dekonts.indexWhere((d) => d.id == entity.id);
    if (i >= 0) {
      _dekonts[i] = entity;
    } else {
      _dekonts.insert(0, entity);
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
      buildingName: buildingName,
      apartmentId: apartmentId,
      uploadedById: uploadedById,
      dueId: dueId ?? this.dueId,
      dueIds: dueIds,
      allocations: allocations,
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
      rejectionReason: rejectionReason,
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
