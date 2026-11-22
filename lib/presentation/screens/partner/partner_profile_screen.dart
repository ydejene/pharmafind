import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/auth_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/pharmacy_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/pharmacy/pharmacy_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';

/// Screen for creating and editing a partner's pharmacy profile.
///
/// **Domain & Ownership:**
/// - Uses the authenticated partner's UID (`authState.user.uid`) as `ownerId`.
/// - Checks persistent data layer before allowing creation to prevent duplicates.
/// - New profiles are created with `status: 'pending'` via [PharmacyCubit.createPharmacy].
/// - Existing profiles are updated via [PharmacyCubit.updatePharmacy], strictly
///   preserving existing verification status, pharmacy ID, and creation timestamp.
/// - Once initial profile creation completes, navigates to [AuthRoutes.partnerLicense].
class PartnerProfileScreen extends StatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  State<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends State<PartnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _districtController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _hoursController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  bool _acceptsInsurance = true;
  bool _isEditing = false;
  bool _isSubmitting = false;
  PharmacyEntity? _existingPharmacy;
  String? _existingId;
  String _existingStatus = 'pending';
  DateTime? _existingCreatedAt;

  @override
  void initState() {
    super.initState();
    final pharmacyState = context.read<PharmacyCubit>().state;
    final authState = context.read<AuthBloc>().state;

    if (pharmacyState.pharmacy != null &&
        pharmacyState.pharmacy!.id.isNotEmpty) {
      _populateFromEntity(pharmacyState.pharmacy!);
    } else {
      // Default Kigali values for fresh creation
      _districtController.text = 'Gasabo';
      _hoursController.text = '8:00 AM - 10:00 PM';
      _latController.text = '-1.9441';
      _lngController.text = '30.0619';

      if (authState is AuthAuthenticated) {
        if (authState.user.email.isNotEmpty) {
          _emailController.text = authState.user.email;
        }
        if (authState.user.phone != null && authState.user.phone!.isNotEmpty) {
          _phoneController.text = authState.user.phone!;
        }

        // If Cubit hasn't loaded data from persistence yet, fetch it now
        if (pharmacyState.status == PharmacyStatus.initial) {
          context.read<PharmacyCubit>().loadPharmacy(authState.user.uid);
        }
      }
    }
  }

  void _populateFromEntity(PharmacyEntity pharmacy) {
    _existingPharmacy = pharmacy;
    _isEditing = true;
    _existingId = pharmacy.id;
    _existingStatus = pharmacy.status;
    _existingCreatedAt = pharmacy.createdAt;

    _nameController.text = pharmacy.name;
    _areaController.text = pharmacy.area;
    _districtController.text = pharmacy.district;
    _phoneController.text = pharmacy.phone;
    _emailController.text = pharmacy.email;
    _hoursController.text = pharmacy.hours;
    _latController.text = pharmacy.latitude.toString();
    _lngController.text = pharmacy.longitude.toString();
    _acceptsInsurance = pharmacy.acceptsInsurance;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _districtController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _hoursController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to manage your pharmacy profile.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final lat = double.tryParse(_latController.text.trim()) ?? -1.9441;
    final lng = double.tryParse(_lngController.text.trim()) ?? 30.0619;

    setState(() => _isSubmitting = true);

    if (_isEditing) {
      final existing = _existingPharmacy ?? context.read<PharmacyCubit>().state.pharmacy;
      final updated = existing != null
          ? existing.copyWith(
              name: _nameController.text.trim(),
              area: _areaController.text.trim(),
              district: _districtController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              hours: _hoursController.text.trim(),
              latitude: lat,
              longitude: lng,
              ownerId: authState.user.uid,
              status: _existingStatus,
              acceptsInsurance: _acceptsInsurance,
            )
          : PharmacyEntity(
              id: _existingId ?? '',
              name: _nameController.text.trim(),
              area: _areaController.text.trim(),
              district: _districtController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              hours: _hoursController.text.trim(),
              latitude: lat,
              longitude: lng,
              ownerId: authState.user.uid,
              status: _existingStatus,
              acceptsInsurance: _acceptsInsurance,
              createdAt: _existingCreatedAt ?? DateTime.now(),
            );
      context.read<PharmacyCubit>().updatePharmacy(updated);
    } else {
      // Final duplicate prevention check against Cubit state
      final currentPharmacy = context.read<PharmacyCubit>().state.pharmacy;
      if (currentPharmacy != null && currentPharmacy.id.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A pharmacy profile already exists for this account. Switched to edit mode.',
            ),
          ),
        );
        setState(() => _populateFromEntity(currentPharmacy));
        return;
      }

      final newPharmacy = PharmacyEntity(
        id: '',
        name: _nameController.text.trim(),
        area: _areaController.text.trim(),
        district: _districtController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        hours: _hoursController.text.trim(),
        latitude: lat,
        longitude: lng,
        ownerId: authState.user.uid,
        status: 'pending', // Initial status is always pending
        acceptsInsurance: _acceptsInsurance,
        createdAt: DateTime.now(),
      );
      context.read<PharmacyCubit>().createPharmacy(newPharmacy);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

    return BlocConsumer<PharmacyCubit, PharmacyState>(
      listener: (context, state) {
        if (state.status == PharmacyStatus.loaded) {
          if (state.pharmacy != null && state.pharmacy!.id.isNotEmpty) {
            _existingPharmacy = state.pharmacy;
          }
          if (_isSubmitting) {
            _isSubmitting = false;
            if (!_isEditing) {
              Navigator.of(context)
                  .pushReplacementNamed(AuthRoutes.partnerLicense);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.get('profile_saved', locale)),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            }
          } else if (!_isEditing && state.pharmacy != null) {
            // Background check retrieved existing persistent record
            setState(() => _populateFromEntity(state.pharmacy!));
          }
        } else if (state.status == PharmacyStatus.error) {
          _isSubmitting = false;
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        // Show loading when an initial existing-record check is in progress
        final isInitialCheck =
            state.status == PharmacyStatus.loading && !_isSubmitting;
        final isBusy = state.status == PharmacyStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.cream,
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  right: 16,
                  bottom: 20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        AppStrings.get('pharmacy_profile', locale),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: isInitialCheck
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Checking existing pharmacy profile...',
                              style: TextStyle(color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isEditing
                                    ? 'Edit pharmacy information'
                                    : AppStrings.get(
                                        'add_pharmacy_details',
                                        locale,
                                      ),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.get('details_help', locale),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMedium,
                                ),
                              ),
                              if (_isEditing) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusBgColor(_existingStatus),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getStatusIcon(_existingStatus),
                                        size: 16,
                                        color: _getStatusTextColor(
                                          _existingStatus,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Current Status: ${_existingStatus.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusTextColor(
                                            _existingStatus,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              _buildLabel(
                                AppStrings.get('pharmacy_name', locale),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                validator: (v) => Validators.validateRequired(
                                  v,
                                  'Pharmacy name',
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Kigali Health Pharmacy',
                                  prefixIcon: Icon(
                                    Icons.store_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildLabel(AppStrings.get('area', locale)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _areaController,
                                textCapitalization: TextCapitalization.words,
                                validator: (v) =>
                                    Validators.validateRequired(v, 'Area'),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Kimironko, Remera',
                                  prefixIcon: Icon(
                                    Icons.location_on_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildLabel(AppStrings.get('district', locale)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _districtController,
                                textCapitalization: TextCapitalization.words,
                                validator: (v) =>
                                    Validators.validateRequired(v, 'District'),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Gasabo, Nyarugenge',
                                  prefixIcon: Icon(
                                    Icons.map_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildLabel(AppStrings.get('phone', locale)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                validator: Validators.validatePhone,
                                decoration: const InputDecoration(
                                  hintText: '+250 7XX XXX XXX',
                                  prefixIcon: Icon(
                                    Icons.phone_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildLabel(AppStrings.get('email', locale)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.validateEmail,
                                decoration: const InputDecoration(
                                  hintText: 'pharmacy@example.rw',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildLabel(
                                AppStrings.get('operating_hours', locale),
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _hoursController,
                                validator: (v) => Validators.validateRequired(
                                  v,
                                  'Operating hours',
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 8:00 AM - 10:00 PM',
                                  prefixIcon: Icon(
                                    Icons.access_time_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('LATITUDE'),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _latController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                                signed: true,
                                              ),
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return 'Required';
                                            }
                                            if (double.tryParse(v.trim()) ==
                                                null) {
                                              return 'Invalid';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            hintText: '-1.9441',
                                            prefixIcon: Icon(
                                              Icons.pin_drop,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('LONGITUDE'),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _lngController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                                signed: true,
                                              ),
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return 'Required';
                                            }
                                            if (double.tryParse(v.trim()) ==
                                                null) {
                                              return 'Invalid';
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            hintText: '30.0619',
                                            prefixIcon: Icon(
                                              Icons.pin_drop,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.borderLight.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.shield_outlined,
                                      color: AppColors.primaryGreen,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        AppStrings.get(
                                          'accepts_insurance',
                                          locale,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      value: _acceptsInsurance,
                                      onChanged: (val) {
                                        setState(() => _acceptsInsurance = val);
                                      },
                                      activeThumbColor: AppColors.primaryGreen,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isBusy ? null : _handleSubmit,
                                  child: isBusy
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _isEditing
                                              ? AppStrings.get(
                                                  'save_changes',
                                                  locale,
                                                )
                                              : AppStrings.get(
                                                  'save_profile',
                                                  locale,
                                                ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: AppColors.textLight,
      ),
    );
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.stockGreen;
      case 'rejected':
        return AppColors.errorRed.withValues(alpha: 0.1);
      default:
        return AppColors.warningYellow.withValues(alpha: 0.15);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.successGreen;
      case 'rejected':
        return AppColors.errorRed;
      default:
        return AppColors.warningYellow;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.warning_amber;
      default:
        return Icons.hourglass_top;
    }
  }
}
