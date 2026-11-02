import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../utils/auth_navigation.dart';
import '../../widgets/auth_header.dart';

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
                    AuthHeader(
                      eyebrow: AppStrings.get('get_started', locale),
                      title: AppStrings.get('choose_language', locale),
                      subtitle: AppStrings.get('choose_language_sub', locale),
                    ),
                    const SizedBox(height: 32),
                    for (final language in _languages)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LanguageTile(
                          name: language.name,
                          greeting: language.greeting,
                          isSelected: locale == language.code,
                          onTap: () => context.read<SettingsCubit>().setLocale(
                            language.code,
                          ),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String name;
  final String greeting;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.name,
    required this.greeting,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(14);

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: isSelected ? colorScheme.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? colorScheme.primary
                      : AppColors.borderLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
