import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/alert_entity.dart';
import '../../../domain/repositories/alert_repository.dart';

part 'alert_state.dart';

class AlertCubit extends Cubit<AlertState> {
  final IAlertRepository alertRepository;

  AlertCubit({
    required this.alertRepository,
  }) : super(const AlertState());

  // saving a new medicine availability alert
  Future<void> createAlert({
    required String userId,
    required String medicineName,
    required String searchArea,
  }) async {
    if (medicineName.trim().isEmpty ||
        searchArea.trim().isEmpty) {
      emit(
        state.copyWith(
          status: AlertStatus.error,
          errorMessage: 'Enter the medicine and search area.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: AlertStatus.loading,
        clearError: true,
      ),
    );

    try {
      final alert = AlertEntity(
        id: '',
        userId: userId,
        medicineName: medicineName.trim(),
        searchArea: searchArea.trim(),
        createdAt: DateTime.now(),
      );

      await alertRepository.createAlert(alert);

      emit(
        state.copyWith(
          status: AlertStatus.saved,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AlertStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // getting all the alerts saved by one user
  Future<void> loadUserAlerts(String userId) async {
    emit(
      state.copyWith(
        status: AlertStatus.loading,
        clearError: true,
      ),
    );

    try {
      final alerts = await alertRepository.getUserAlerts(userId);

      emit(
        state.copyWith(
          status: AlertStatus.loaded,
          alerts: alerts,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AlertStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // removing one saved alert
  Future<void> deleteAlert({
    required String alertId,
    required String userId,
  }) async {
    try {
      await alertRepository.deleteAlert(alertId);
      await loadUserAlerts(userId);
    } catch (error) {
      emit(
        state.copyWith(
          status: AlertStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  // clearing the previous screen status
  void reset() {
    emit(const AlertState());
  }
}