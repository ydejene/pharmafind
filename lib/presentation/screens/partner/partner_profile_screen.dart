import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/pharmacy_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/pharmacy/pharmacy_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';

class PartnerProfileScreen extends StatefulWidget {
  const PartnerProfileScreen({super.key});

  @override
  State<PartnerProfileScreen> createState() => _PartnerProfileScreenState();
}

class _PartnerProfileScreenState extends State<PartnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pharmacyNameController = TextEditingController();
  final _areaController = TextEditingController();
  final _districtController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _hoursController = TextEditingController();
  bool _acceptsInsurance = false;

  @override
  void initState() {
    super.initState();
    final pharmacyState = context.read<PharmacyCubit>().state;
    if (pharmacyState.pharmacy != null) {
      final p = pharmacyState.pharmacy!;
      _pharmacyNameController.text = p.name;
      _areaController.text = p.area;
      _districtController.text = p.district;
      _phoneController.text = p.phone;
      _emailController.text = p.email;
      _hoursController.text = p.hours;
      _acceptsInsurance = p.acceptsInsurance;
    }
  }

  @override
  void dispose() {
    _pharmacyNameController.dispose();
    _areaController.dispose();
    _districtController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final existingPharmacy = context.read<PharmacyCubit>().state.pharmacy;

    final pharmacy = PharmacyModel(
      id: existingPharmacy?.id ?? '',
      name: _pharmacyNameController.text.trim(),
      area: _areaController.text.trim(),
      district: _districtController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      hours: _hoursController.text.trim(),
      latitude: existingPharmacy?.latitude ?? -1.9441,
      longitude: existingPharmacy?.longitude ?? 29.8739,
      ownerId: authState.user.uid,
      status: 'approved',
      acceptsInsurance: _acceptsInsurance,
      createdAt: existingPharmacy?.createdAt ?? DateTime.now(),
    );

    if (existingPharmacy != null) {
      context.read<PharmacyCubit>().updatePharmacy(pharmacy);
    } else {
      context.read<PharmacyCubit>().createPharmacy(pharmacy);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.get(
            'profile_saved',
            context.read<SettingsCubit>().state.locale,
          ),
        ),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLabel(AppStrings.get('pharmacy_name', locale)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pharmacyNameController,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Pharmacy name'),
                      decoration: InputDecoration(
                        hintText: 'e.g. Green Health Pharmacy',
                        prefixIcon: const Icon(
                          Icons.local_pharmacy_outlined,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel(AppStrings.get('area', locale)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _areaController,
                      validator: (v) => Validators.validateRequired(v, 'Area'),
                      decoration: InputDecoration(
                        hintText: 'e.g. Kimironko',
                        prefixIcon: const Icon(
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
                      validator: (v) =>
                          Validators.validateRequired(v, 'District'),
                      decoration: InputDecoration(
                        hintText: 'e.g. Gasabo',
                        prefixIcon: const Icon(Icons.map_outlined, size: 20),
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
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel(AppStrings.get('email', locale)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      decoration: InputDecoration(
                        hintText: AppStrings.get('email_hint', locale),
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel(AppStrings.get('operating_hours', locale)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _hoursController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 7:00 AM - 9:00 PM',
                        prefixIcon: Icon(Icons.access_time_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.borderLight.withValues(alpha: 0.5),
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
                              AppStrings.get('accepts_insurance', locale),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
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
                        onPressed: _saveProfile,
                        child: Text(AppStrings.get('save_profile', locale)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
}
