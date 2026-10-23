import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../utils/auth_navigation.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _languages = [
    (code: 'rw', name: 'Kinyarwanda', greeting: 'Murakaza neza'),
    (code: 'en', name: 'English', greeting: 'Welcome'),
    (code: 'fr', name: 'Français', greeting: 'Bienvenue'),
  ];

  Future<void> _handleContinue(BuildContext context) async {
    await context.read<SettingsCubit>().markOnboardingSeen();
    if (context.mounted) AuthNavigation.toLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      AppStrings.get('choose_language', locale),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    for (final language in _languages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(language.name),
                          subtitle: Text(language.greeting),
                          selected: locale == language.code,
                          onTap: () => context.read<SettingsCubit>().setLocale(language.code),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _handleContinue(context),
                  child: Text(AppStrings.get('continue_btn', locale)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
