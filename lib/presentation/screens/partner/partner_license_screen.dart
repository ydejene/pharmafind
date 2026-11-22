import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/auth_routes.dart';
import '../../bloc/pharmacy/pharmacy_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';

/// Pharmacy license / document submission screen (Stage 6-B).
///
/// **Verification & Privacy:**
/// - Real file selection using [FilePicker] supporting PDF, PNG, JPG/JPEG documents.
/// - Document metadata is uploaded and persisted via [PharmacyCubit.submitDocuments].
/// - Displays a prominent prototype privacy notice regarding unsigned Cloudinary uploads.
class PartnerLicenseScreen extends StatefulWidget {
  const PartnerLicenseScreen({super.key});

  @override
  State<PartnerLicenseScreen> createState() => _PartnerLicenseScreenState();
}

class _PartnerLicenseScreenState extends State<PartnerLicenseScreen> {
  Uint8List? _licenseBytes;
  String? _licenseFilename;

  Uint8List? _rmohBytes;
  String? _rmohFilename;

  bool _isSubmitting = false;

  Future<void> _pickLicense() async {
    if (_isSubmitting) return;
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          setState(() {
            _licenseBytes = bytes;
            _licenseFilename = file.name;
          });
        } else {
          _showError('Unable to read selected file bytes.');
        }
      }
    } catch (e) {
      _showError('Failed to select pharmacy license: $e');
    }
  }

  Future<void> _pickRmoh() async {
    if (_isSubmitting) return;
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          setState(() {
            _rmohBytes = bytes;
            _rmohFilename = file.name;
          });
        } else {
          _showError('Unable to read selected file bytes.');
        }
      }
    } catch (e) {
      _showError('Failed to select RMOH certificate: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  void _handleSubmit() {
    final pharmacy = context.read<PharmacyCubit>().state.pharmacy;
    if (pharmacy == null || pharmacy.id.isEmpty) {
      _showError(
        'No pharmacy profile found. Please register your pharmacy profile first.',
      );
      return;
    }

    final hasExistingLicense =
        pharmacy.licenseUrl != null && pharmacy.licenseUrl!.isNotEmpty;
    final hasExistingRmoh =
        pharmacy.rmohCertUrl != null && pharmacy.rmohCertUrl!.isNotEmpty;

    final hasNewLicense = _licenseBytes != null;
    final hasNewRmoh = _rmohBytes != null;

    final hasAnyNewSelection = hasNewLicense || hasNewRmoh;
    final hasLicenseSatisfied = hasNewLicense || hasExistingLicense;
    final hasRmohSatisfied = hasNewRmoh || hasExistingRmoh;

    if (!hasAnyNewSelection ||
        !hasLicenseSatisfied ||
        !hasRmohSatisfied ||
        _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<PharmacyCubit>().submitDocuments(
      pharmacyId: pharmacy.id,
      licenseBytes: _licenseBytes,
      licenseFilename: _licenseFilename,
      rmohBytes: _rmohBytes,
      rmohFilename: _rmohFilename,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final pharmacyState = context.watch<PharmacyCubit>().state;
    final pharmacy = pharmacyState.pharmacy;

    final hasExistingLicense =
        pharmacy?.licenseUrl != null && pharmacy!.licenseUrl!.isNotEmpty;
    final hasExistingRmoh =
        pharmacy?.rmohCertUrl != null && pharmacy!.rmohCertUrl!.isNotEmpty;

    final hasNewLicense = _licenseBytes != null;
    final hasNewRmoh = _rmohBytes != null;
    final hasAnyNewSelection = hasNewLicense || hasNewRmoh;
    final hasLicenseSatisfied = hasNewLicense || hasExistingLicense;
    final hasRmohSatisfied = hasNewRmoh || hasExistingRmoh;

    final canSubmit = hasAnyNewSelection &&
        hasLicenseSatisfied &&
        hasRmohSatisfied &&
        !_isSubmitting;

    final existingLicenseName = pharmacy?.licensePublicId != null
        ? pharmacy!.licensePublicId!.split('/').last
        : (hasExistingLicense ? 'License document on file' : null);
    final existingRmohName = pharmacy?.rmohCertPublicId != null
        ? pharmacy!.rmohCertPublicId!.split('/').last
        : (hasExistingRmoh ? 'RMOH certificate on file' : null);

    return BlocConsumer<PharmacyCubit, PharmacyState>(
      listener: (context, state) {
        if (state.status == PharmacyStatus.loaded) {
          if (_isSubmitting) {
            _isSubmitting = false;
            Navigator.of(context).pushReplacementNamed(AuthRoutes.partnerPending);
          }
        } else if (state.status == PharmacyStatus.error) {
          if (_isSubmitting) {
            setState(() => _isSubmitting = false);
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              _showError(state.errorMessage!);
            }
          }
        }
      },
      builder: (context, state) {
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
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
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
                      const _StepDot(active: true, completed: true),
                      Container(
                        width: 40,
                        height: 2,
                        color: AppColors.primaryGreen,
                      ),
                      const _StepDot(active: true, completed: false),
                      Container(
                        width: 40,
                        height: 2,
                        color: AppColors.borderLight,
                      ),
                      const _StepDot(active: false, completed: false),
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
                  // Prototype Privacy Notice
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
                          Icons.security_outlined,
                          size: 20,
                          color: AppColors.warningYellow,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Prototype Privacy Notice: Uploaded verification documents use an unsigned preset and are publicly accessible via their URL under current project settings. Do not upload actual sensitive personal or business licences; please use sample/test documents only.',
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
                    selectedFilename: _licenseFilename,
                    hasExistingDocument: hasExistingLicense,
                    existingDocumentName: existingLicenseName,
                    isUploading: _isSubmitting,
                    onTap: _pickLicense,
                  ),
                  const SizedBox(height: 12),
                  _UploadCard(
                    title: AppStrings.get('rmoh_cert', locale),
                    description: AppStrings.get('upload_rmoh', locale),
                    selectedFilename: _rmohFilename,
                    hasExistingDocument: hasExistingRmoh,
                    existingDocumentName: existingRmohName,
                    isUploading: _isSubmitting,
                    onTap: _pickRmoh,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: canSubmit ? _handleSubmit : null,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(AppStrings.get('submit_review', locale)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
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
  final String? selectedFilename;
  final bool hasExistingDocument;
  final String? existingDocumentName;
  final bool isUploading;
  final VoidCallback onTap;

  const _UploadCard({
    required this.title,
    required this.description,
    this.selectedFilename,
    this.hasExistingDocument = false,
    this.existingDocumentName,
    required this.isUploading,
    required this.onTap,
  });

  bool get selected => selectedFilename != null && selectedFilename!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final subtitle = selected
        ? '$selectedFilename (Tap to replace)'
        : hasExistingDocument
            ? (existingDocumentName != null && existingDocumentName!.isNotEmpty
                ? '$existingDocumentName (Tap to replace)'
                : 'Current document on file (Tap to replace)')
            : description;

    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.stockGreen
              : (hasExistingDocument ? Colors.white : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.successGreen.withValues(alpha: 0.3)
                : (hasExistingDocument
                    ? AppColors.primaryGreen.withValues(alpha: 0.3)
                    : AppColors.borderLight.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.successGreen
                    : (hasExistingDocument
                        ? AppColors.primaryGreen.withValues(alpha: 0.12)
                        : AppColors.accentOrange.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected
                    ? Icons.check
                    : (hasExistingDocument
                        ? Icons.description_outlined
                        : Icons.upload_file),
                color: selected
                    ? Colors.white
                    : (hasExistingDocument
                        ? AppColors.primaryGreen
                        : AppColors.accentOrange),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (hasExistingDocument && !selected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ON FILE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? AppColors.successGreen
                          : (hasExistingDocument
                              ? AppColors.textMedium
                              : AppColors.textLight),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
