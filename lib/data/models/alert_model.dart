import 'package:equatable/equatable.dart';

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

  @override
  List<Object?> get props => [id, userId, medicineName, isActive];
}
