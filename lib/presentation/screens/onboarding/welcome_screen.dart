import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/pharma_find_logo.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const PharmaFindLogoDark(size: 64),
              const SizedBox(height: 32),
              const Text(
                'PharmaFind',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.get('welcome_tagline', 'en'),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textMedium,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              _buildFeatureRow(
                Icons.search,
                AppStrings.get('feature_search', 'en'),
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(
                Icons.location_on_outlined,
                AppStrings.get('feature_locate', 'en'),
              ),
              const SizedBox(height: 16),
              _buildFeatureRow(
                Icons.notifications_outlined,
                AppStrings.get('feature_alerts', 'en'),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/language');
                  },
                  child: Text(AppStrings.get('get_started', 'en')),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text(
                  AppStrings.get('already_have_account', 'en'),
                  style: const TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
