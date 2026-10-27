import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/settings/settings_cubit.dart';

class NotifyConfirmationScreen extends StatelessWidget {
  const NotifyConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.stockGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.successGreen,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('alert_set', locale),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('alert_confirmed', locale),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.get('alert_desc', locale),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/home', (route) => false);
                  },
                  child: Text(AppStrings.get('back_home', locale)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/home', (route) => false);
                },
                child: Text(
                  AppStrings.get('search_again', locale),
                  style: const TextStyle(color: AppColors.primaryGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
