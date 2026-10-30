import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keySelectedLanguage = 'onboarding_language';
  static const _keyFirstLaunch = 'first_launch';

  final SharedPreferences _prefs;

  OnboardingService({required SharedPreferences prefs}) : _prefs = prefs;

  bool get isOnboardingComplete =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;

  bool get isFirstLaunch => _prefs.getBool(_keyFirstLaunch) ?? true;

  String? get savedLanguage => _prefs.getString(_keySelectedLanguage);

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_keyOnboardingComplete, true);
    await _prefs.setBool(_keyFirstLaunch, false);
  }

  Future<void> saveLanguageChoice(String languageCode) async {
    await _prefs.setString(_keySelectedLanguage, languageCode);
  }

  Future<void> resetOnboarding() async {
    await _prefs.remove(_keyOnboardingComplete);
    await _prefs.remove(_keySelectedLanguage);
  }
}
