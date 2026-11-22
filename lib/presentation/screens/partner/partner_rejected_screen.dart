import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/auth_routes.dart';
import '../../bloc/pharmacy/pharmacy_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';

/// Shown when admin has rejected the partner's submitted pharmacy documents.
///
/// **Domain & Action Accuracy:**
/// - Surfaced when `PharmacyEntity.status == 'rejected'` via [PharmacyCubit].
/// - Displays the persistent pharmacy name when available.
/// - Displays the persistent pharmacy name, reviewer rejection reason, and checklist.
/// - Provides actions to resubmit verification documents ([AuthRoutes.partnerLicense]),
///   update pharmacy profile details ([AuthRoutes.partnerProfile]), or return home.
class PartnerRejectedScreen extends StatelessWidget {
  const PartnerRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final pharmacyState = context.watch<PharmacyCubit>().state;
    final pharmacy = pharmacyState.pharmacy;
    final hasPersistedRecord = pharmacy != null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.errorRed,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('action_needed', locale),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.errorRed,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('rejected_title', locale),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (hasPersistedRecord) ...[
                Text(
                  pharmacy.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.errorRed,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                AppStrings.get('rejected_desc', locale),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Rejection Reason Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 18,
                          color: AppColors.errorRed,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Reason for Rejection',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (pharmacy?.rejectionReason != null &&
                              pharmacy!.rejectionReason!.trim().isNotEmpty)
                          ? pharmacy.rejectionReason!
                          : 'No specific reason was provided. Please verify that all submitted documents are clear, valid, and unexpired before resubmitting.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Checklist of what to check
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.borderLight.withValues(alpha: 0.7),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('what_to_check', locale),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCheckItem(AppStrings.get('readable', locale)),
                    const SizedBox(height: 6),
                    _buildCheckItem(AppStrings.get('not_expired', locale)),
                    const SizedBox(height: 6),
                    _buildCheckItem(AppStrings.get('full_visible', locale)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Explanation about document resubmission
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: AppColors.accentOrange,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You can correct your documents and resubmit them for review. You may replace either your license, RMOH certificate, or both. Your existing pharmacy profile details are preserved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMedium,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Primary action: Resubmit documents
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AuthRoutes.partnerLicense);
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(AppStrings.get('resubmit', locale)),
                ),
              ),
              const SizedBox(height: 12),
              // Secondary action: Update pharmacy details
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AuthRoutes.partnerProfile);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(AppStrings.get('edit_pharmacy_info', locale)),
                ),
              ),
              const SizedBox(height: 12),
              // Tertiary action: Return to ordinary home screen (no dashboard bypass)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AuthRoutes.home,
                    (route) => false,
                  );
                },
                child: Text(
                  AppStrings.get('return_home', locale),
                  style: const TextStyle(color: AppColors.primaryGreen),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 16,
          color: AppColors.primaryGreen,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}
