import 'package:equatable/equatable.dart';

class AlertEntity extends Equatable {
  final String id;
  final String userId;
  final String medicineName;
  final String searchArea;
  final bool isActive;
  final DateTime createdAt;

  const AlertEntity({
    required this.id,
    required this.userId,
    required this.medicineName,
    required this.searchArea,
    this.isActive = true,
    required this.createdAt,
  });

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
