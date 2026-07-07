import 'package:equatable/equatable.dart';

class Province extends Equatable {
  final int id;
  final String name;

  const Province({required this.id, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class District extends Equatable {
  final int id;
  final String name;
  final int provinceId;

  const District({
    required this.id,
    required this.name,
    required this.provinceId,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as int,
      name: json['name'] as String,
      provinceId: json['provinceId'] as int,
    );
  }

  @override
  List<Object?> get props => [id, name, provinceId];
}

class Neighborhood extends Equatable {
  final int id;
  final String name;
  final int districtId;

  const Neighborhood({
    required this.id,
    required this.name,
    required this.districtId,
  });

  factory Neighborhood.fromJson(Map<String, dynamic> json) {
    return Neighborhood(
      id: json['id'] as int,
      name: json['name'] as String,
      districtId: json['districtId'] as int,
    );
  }

  @override
  List<Object?> get props => [id, name, districtId];
}
