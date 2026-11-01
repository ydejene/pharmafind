import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final String locale;
  final bool isDarkMode;
  final bool stockAlerts;
  final bool appUpdates;
  final bool hasSeenOnboarding;

  const SettingsEntity({
    required this.locale,
    required this.isDarkMode,
    required this.stockAlerts,
    required this.appUpdates,
    required this.hasSeenOnboarding,
  });

  @override
  List<Object?> get props => [
    locale,
    isDarkMode,
    stockAlerts,
    appUpdates,
    hasSeenOnboarding,
  ];
}
