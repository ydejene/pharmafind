part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  final String locale;
  final bool isDarkMode;
  final bool stockAlerts;
  final bool appUpdates;
  final bool hasSeenOnboarding;

  const SettingsState({
    this.locale = 'en',
    this.isDarkMode = false,
    this.stockAlerts = true,
    this.appUpdates = false,
    this.hasSeenOnboarding = false,
  });

  SettingsState copyWith({
    String? locale,
    bool? isDarkMode,
    bool? stockAlerts,
    bool? appUpdates,
    bool? hasSeenOnboarding,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      stockAlerts: stockAlerts ?? this.stockAlerts,
      appUpdates: appUpdates ?? this.appUpdates,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    isDarkMode,
    stockAlerts,
    appUpdates,
    hasSeenOnboarding,
  ];
}
