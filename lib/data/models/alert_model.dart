import 'package:equatable/equatable.dart';

import '../../domain/entities/alert_entity.dart';

class AlertModel extends Equatable {
  final String id;
  final String userId;
  final String medicineName;
  final String searchArea;
  final bool isActive;
  final DateTime createdAt;

  const AlertModel({
    required this.id,
    required this.userId,
    required this.medicineName,
    this.searchArea = 'Kigali, Rwanda',
    this.isActive = true,
    required this.createdAt,
  });

  factory AlertModel.fromEntity(AlertEntity entity) {
    return AlertModel(
      id: entity.id,
      userId: entity.userId,
      medicineName: entity.medicineName,
      searchArea: entity.searchArea,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }

  AlertEntity toEntity() {
    return AlertEntity(
      id: id,
      userId: userId,
      medicineName: medicineName,
      searchArea: searchArea,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  factory AlertModel.fromMap(Map<String, dynamic> data, String id) {
    return AlertModel(
      id: id,
      userId: data['userId'] ?? '',
      medicineName: data['medicineName'] ?? '',
      searchArea: data['searchArea'] ?? 'Kigali, Rwanda',
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt']
          : (data['createdAt'] is String
                ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
                : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'medicineName': medicineName,
      'searchArea': searchArea,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  AlertModel copyWith({
    String? medicineName,
    String? searchArea,
    bool? isActive,
  }) {
    return AlertModel(
      id: id,
      userId: userId,
      medicineName: medicineName ?? this.medicineName,
      searchArea: searchArea ?? this.searchArea,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    medicineName,
    searchArea,
    isActive,
    createdAt,
  ];
}
