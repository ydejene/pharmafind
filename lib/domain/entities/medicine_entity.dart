import 'package:equatable/equatable.dart';

class MedicineEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final String dosageForm;

  const MedicineEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.dosageForm,
  });

  @override
  List<Object?> get props => [id, name, category, description, dosageForm];
}
