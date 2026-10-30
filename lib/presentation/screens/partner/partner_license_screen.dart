import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/settings/settings_cubit.dart';

class PartnerLicenseScreen extends StatefulWidget {
  const PartnerLicenseScreen({super.key});

  @override
  State<PartnerLicenseScreen> createState() => _PartnerLicenseScreenState();
}

class _PartnerLicenseScreenState extends State<PartnerLicenseScreen> {
  bool _licenseUploaded = false;
  bool _rmohUploaded = false;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final canSubmit = _licenseUploaded && _rmohUploaded;

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
              const SizedBox(height: 28),
              _UploadCard(
                title: AppStrings.get('pharmacy_license', locale),
                description: AppStrings.get('upload_license', locale),
                uploaded: _licenseUploaded,
                onTap: () {
                  setState(() => _licenseUploaded = true);
                },
              ),
              const SizedBox(height: 12),
              _UploadCard(
                title: AppStrings.get('rmoh_cert', locale),
                description: AppStrings.get('upload_rmoh', locale),
                uploaded: _rmohUploaded,
                onTap: () {
                  setState(() => _rmohUploaded = true);
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
  final bool uploaded;
  final VoidCallback onTap;

  const _UploadCard({
    required this.title,
    required this.description,
    required this.uploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: uploaded ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: uploaded ? AppColors.stockGreen : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: uploaded
                ? AppColors.successGreen.withValues(alpha: 0.3)
                : AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: uploaded
                    ? AppColors.successGreen
                    : AppColors.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                uploaded ? Icons.check : Icons.upload_file,
                color: uploaded ? Colors.white : AppColors.accentOrange,
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
                    uploaded ? 'Uploaded' : description,
                    style: TextStyle(
                      fontSize: 12,
                      color: uploaded
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
