import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/services/onboarding_service.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingService _onboardingService;

  OnboardingCubit({required OnboardingService onboardingService})
      : _onboardingService = onboardingService,
        super(const OnboardingState());

  void initialize() {
    emit(state.copyWith(
      isFirstLaunch: _onboardingService.isFirstLaunch,
      isComplete: _onboardingService.isOnboardingComplete,
      selectedLanguage: _onboardingService.savedLanguage,
    ));
  }

  void selectLanguage(String languageCode) {
    _onboardingService.saveLanguageChoice(languageCode);
    emit(state.copyWith(
      selectedLanguage: languageCode,
      currentStep: 1,
    ));
  }

  void nextStep() {
    emit(state.copyWith(currentStep: state.currentStep + 1));
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  Future<void> completeOnboarding() async {
    await _onboardingService.completeOnboarding();
    emit(state.copyWith(isComplete: true));
  }
}
