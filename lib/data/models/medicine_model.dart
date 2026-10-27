import 'package:equatable/equatable.dart';

class MedicineModel extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final String dosageForm;

  const MedicineModel({
    required this.id,
    required this.name,
    this.category = 'General',
    this.description = '',
    this.dosageForm = 'Capsules',
  });

  factory MedicineModel.fromMap(Map<String, dynamic> data, String id) {
    return MedicineModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'General',
      description: data['description'] ?? '',
      dosageForm: data['dosageForm'] ?? 'Capsules',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'dosageForm': dosageForm,
    };
  }

  @override
  List<Object?> get props => [id, name, category];
}
