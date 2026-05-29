import 'package:equatable/equatable.dart';

class PaymentCollectionEntity extends Equatable {
  final String buildingId;
  final String buildingName;
  final String apartmentNumber;
  final String? collectionIban;
  final String? collectionAccountTitle;
  final String? paymentReferenceTemplate;
  final String? paymentReference;
  final bool isCollectionConfigured;

  const PaymentCollectionEntity({
    required this.buildingId,
    required this.buildingName,
    required this.apartmentNumber,
    this.collectionIban,
    this.collectionAccountTitle,
    this.paymentReferenceTemplate,
    this.paymentReference,
    this.isCollectionConfigured = false,
  });

  @override
  List<Object?> get props => [
        buildingId,
        buildingName,
        apartmentNumber,
        collectionIban,
        collectionAccountTitle,
        paymentReferenceTemplate,
        paymentReference,
        isCollectionConfigured,
      ];
}
