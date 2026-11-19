part of 'alert_cubit.dart';

enum AlertStatus {
  initial,
  loading,
  saved,
  loaded,
  error,
}

class AlertState extends Equatable {
  final AlertStatus status;
  final List<AlertEntity> alerts;
  final String? errorMessage;

  const AlertState({
    this.status = AlertStatus.initial,
    this.alerts = const [],
    this.errorMessage,
  });

  AlertState copyWith({
    AlertStatus? status,
    List<AlertEntity>? alerts,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AlertState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    alerts,
    errorMessage,
  ];
}