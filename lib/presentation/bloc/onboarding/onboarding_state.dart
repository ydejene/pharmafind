part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  final bool isFirstLaunch;
  final bool isComplete;
  final int currentStep;
  final String? selectedLanguage;
  final int totalSteps;

  const OnboardingState({
    this.isFirstLaunch = true,
    this.isComplete = false,
    this.currentStep = 0,
    this.selectedLanguage,
    this.totalSteps = 3,
  });

  double get progress => (currentStep + 1) / totalSteps;

  bool get hasLanguage => selectedLanguage != null;

  OnboardingState copyWith({
    bool? isFirstLaunch,
    bool? isComplete,
    int? currentStep,
    String? selectedLanguage,
  }) {
    return OnboardingState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isComplete: isComplete ?? this.isComplete,
      currentStep: currentStep ?? this.currentStep,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      totalSteps: totalSteps,
    );
  }

  @override
  List<Object?> get props => [
        isFirstLaunch,
        isComplete,
        currentStep,
        selectedLanguage,
        totalSteps,
      ];
}
