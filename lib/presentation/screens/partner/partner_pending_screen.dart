import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/pharmacy/pharmacy_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';

/// Shown while the partner's pharmacy documents are under review.
///
/// **Persistence & Domain Integration:**
/// Verification status (`'pending'` | `'approved'` | `'rejected'`) is held in
/// [PharmacyEntity.status] and surfaced by [PharmacyCubit].
/// - If a persisted pharmacy record exists for the owner, this screen displays
///   its name and persisted status.
/// - If no pharmacy record exists yet (e.g. because full pharmacy profile creation
///   is completed in Stage 4), a clear status-preview notice is shown.
/// - Tapping "Check Status" actively re-queries the pharmacy repository via
///   [PharmacyCubit.loadPharmacy].
class PartnerPendingScreen extends StatelessWidget {
  const PartnerPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final authState = context.watch<AuthBloc>().state;
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
                  color: AppColors.warningYellow.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top,
                  color: AppColors.warningYellow,
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.get('under_review', locale),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.accentOrange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('pending_title', locale),
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
                    color: AppColors.primaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],
              Text(
                AppStrings.get('pending_desc', locale),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.get('review_time', locale),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.warningYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Honest notice if no persisted pharmacy document exists yet
              if (!hasPersistedRecord)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningYellow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warningYellow.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: AppColors.warningYellow,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Status Notice: No persisted pharmacy record exists yet for this account. Pharmacy profile registration is completed in Stage 4.',
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      await context.read<PharmacyCubit>().loadPharmacy(
                        authState.user.uid,
                      );
                      if (!context.mounted) return;
                      final updated = context
                          .read<PharmacyCubit>()
                          .state
                          .pharmacy;
                      if (updated?.status == 'approved') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pharmacy approved! Dashboard available in Stage 4.',
                            ),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      } else if (updated?.status == 'rejected') {
                        Navigator.of(context)
                            .pushReplacementNamed('/partner-rejected');
                      } else if (updated?.status == 'pending') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Verification is still under review.',
                            ),
                            backgroundColor: AppColors.warningYellow,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No persisted pharmacy found. Complete profile in Stage 4.',
                            ),
                          ),
                        );
                      }
                    } else {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/home', (route) => false);
                    }
                  },
                  child: Text(AppStrings.get('check_status', locale)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/home', (route) => false);
                },
                child: Text(
                  AppStrings.get('browse_app', locale),
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
}
