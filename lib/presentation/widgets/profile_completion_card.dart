import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/profile_completion.dart';
import '../../data/models/user_model.dart';

class ProfileCompletionCard extends StatelessWidget {
  final UserModel user;
  final String locale;
  final VoidCallback? onComplete;

  const ProfileCompletionCard({
    super.key,
    required this.user,
    required this.locale,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ProfileCompletion.percentage(user);

    if (ProfileCompletion.isComplete(user)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: AppColors.accentOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.get('complete_profile', locale),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.accentOrange,
              ),
              minHeight: 6,
            ),
          ),
          if (onComplete != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onComplete,
                child: Text(
                  AppStrings.get('complete_now', locale),
                  style: const TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
