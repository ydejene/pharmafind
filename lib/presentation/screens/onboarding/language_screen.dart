import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/settings/settings_cubit.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _languages = [
    (code: 'rw', name: 'Kinyarwanda', greeting: 'Murakaza neza'),
    (code: 'en', name: 'English', greeting: 'Welcome'),
    (code: 'fr', name: 'Français', greeting: 'Bienvenue'),
  ];

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
              const SizedBox(height: 60),
              Text(
                AppStrings.get('choose_language', locale),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              for (final lang in _languages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(lang.name),
                    subtitle: Text(lang.greeting),
                    selected: locale == lang.code,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: locale == lang.code
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.borderLight,
                      ),
                    ),
                    onTap: () =>
                        context.read<SettingsCubit>().setLocale(lang.code),
                  ),
                ),
              const Spacer(),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<SettingsCubit>().markOnboardingSeen();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  },
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
