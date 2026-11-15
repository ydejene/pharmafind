import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/settings/settings_cubit.dart';

/// Pharmacy license / document submission screen (Stage 3).
///
/// **Infrastructure note:** No Firebase Storage or file-picker package is
/// present in `pubspec.yaml`. Document upload is therefore *simulated*: tapping
/// an upload card marks it as selected locally. No remote file upload occurs.
/// A production implementation requires team agreement on Firebase Storage,
/// storage security rules, and the addition of `file_picker` and `firebase_storage`
/// packages.
class PartnerLicenseScreen extends StatefulWidget {
  const PartnerLicenseScreen({super.key});

  @override
  State<PartnerLicenseScreen> createState() => _PartnerLicenseScreenState();
}

class _PartnerLicenseScreenState extends State<PartnerLicenseScreen> {
  bool _licenseSelected = false;
  bool _rmohSelected = false;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final canSubmit = _licenseSelected && _rmohSelected;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.get('verification', locale),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              // 3-step progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StepDot(active: true, completed: true),
                  Container(
                    width: 40,
                    height: 2,
                    color: AppColors.primaryGreen,
                  ),
                  _StepDot(active: true, completed: false),
                  Container(width: 40, height: 2, color: AppColors.borderLight),
                  _StepDot(active: false, completed: false),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                AppStrings.get('upload_docs', locale),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.accentOrange,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('pharmacy_license', locale),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.get('license_desc', locale),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Explicit infrastructure limitation notice
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
                        'Document upload simulation: Remote file storage (Firebase Storage / file picker) is not configured in this environment. Document selection is simulated locally.',
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
              const SizedBox(height: 20),
              _UploadCard(
                title: AppStrings.get('pharmacy_license', locale),
                description: AppStrings.get('upload_license', locale),
                selected: _licenseSelected,
                onTap: () {
                  setState(() => _licenseSelected = true);
                },
              ),
              const SizedBox(height: 12),
              _UploadCard(
                title: AppStrings.get('rmoh_cert', locale),
                description: AppStrings.get('upload_rmoh', locale),
                selected: _rmohSelected,
                onTap: () {
                  setState(() => _rmohSelected = true);
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: canSubmit
                      ? () {
                          Navigator.of(context)
                              .pushReplacementNamed('/partner-pending');
                        }
                      : null,
                  child: Text(AppStrings.get('submit_review', locale)),
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

class _StepDot extends StatelessWidget {
  final bool active;
  final bool completed;

  const _StepDot({required this.active, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? AppColors.primaryGreen : AppColors.borderLight,
        shape: BoxShape.circle,
      ),
      child: completed
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : active
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _UploadCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: selected ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.stockGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.successGreen.withValues(alpha: 0.3)
                : AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.successGreen
                    : AppColors.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected ? Icons.check : Icons.upload_file,
                color: selected ? Colors.white : AppColors.accentOrange,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    selected ? 'Selected (Simulation)' : description,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? AppColors.successGreen
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
