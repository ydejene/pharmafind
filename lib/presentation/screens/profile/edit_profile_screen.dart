import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/input_formatters.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../widgets/auth_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _insuranceIdController = TextEditingController();
  final _otherInsuranceController = TextEditingController();

  final List<String> _insuranceProviders = [
    'Britam',
    'Eden Care',
    'Radiant',
    'RSSB Medical Scheme',
    'MMI',
    'Old Mutual',
    'Other',
    'None',
  ];

  String _selectedInsurance = 'None';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final state = context.read<AuthBloc>().state;

    if (state is AuthAuthenticated) {
      final user = state.user;
      final provider = user.insuranceProvider?.trim() ?? '';

      _nameController.text = user.displayName;
      _phoneController.text = user.phone ?? '';
      _insuranceIdController.text = user.insuranceId ?? '';

      if (provider.isEmpty) {
        _selectedInsurance = 'None';
      } else if (_insuranceProviders.contains(provider)) {
        _selectedInsurance = provider;
      } else {
        _selectedInsurance = 'Other';
        _otherInsuranceController.text = provider;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _insuranceIdController.dispose();
    _otherInsuranceController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    String insuranceProvider = _selectedInsurance;

    if (_selectedInsurance == 'Other') {
      insuranceProvider = _otherInsuranceController.text.trim();
    } else if (_selectedInsurance == 'None') {
      insuranceProvider = '';
    }

    setState(() {
      _isSaving = true;
    });

    context.read<AuthBloc>().add(
      AuthProfileUpdateRequested(
        displayName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        insuranceProvider: insuranceProvider,
        insuranceId: _selectedInsurance == 'None'
            ? ''
            : _insuranceIdController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!_isSaving) {
          return;
        }

        if (state is AuthAuthenticated) {
          setState(() {
            _isSaving = false;
          });

          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your profile has been updated.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }

        if (state is AuthError) {
          setState(() {
            _isSaving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.textDark,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPersonalDetails(locale),
                  const SizedBox(height: 20),
                  _buildInsuranceDetails(),
                  const SizedBox(height: 28),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.manage_accounts_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your profile details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keep your personal and insurance information updated.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(String locale) {
    return _buildSection(
      title: 'Personal information',
      icon: Icons.person_outline,
      children: [
        AuthTextField(
          controller: _nameController,
          label: AppStrings.get('full_name', locale),
          hint: 'Enter your full name',
          prefixIcon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter your full name';
            }

            return null;
          },
        ),
        const SizedBox(height: 18),
        AuthTextField(
          controller: _phoneController,
          label: AppStrings.get('your_phone', locale),
          hint: '+250 7XX XXX XXX',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: RwandaPhoneValidator.validate,
        ),
      ],
    );
  }

  Widget _buildInsuranceDetails() {
    return _buildSection(
      title: 'Medical insurance',
      icon: Icons.health_and_safety_outlined,
      children: [
        const Text(
          'INSURANCE PROVIDER',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedInsurance,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.shield_outlined, size: 20),
          ),
          items: _insuranceProviders.map((provider) {
            return DropdownMenuItem<String>(
              value: provider,
              child: Text(provider),
            );
          }).toList(),
          onChanged: (provider) {
            if (provider == null) {
              return;
            }

            setState(() {
              _selectedInsurance = provider;

              if (provider == 'None') {
                _insuranceIdController.clear();
                _otherInsuranceController.clear();
              }
            });
          },
        ),
        if (_selectedInsurance == 'Other') ...[
          const SizedBox(height: 18),
          AuthTextField(
            controller: _otherInsuranceController,
            label: 'Provider name',
            hint: 'Enter your insurance provider',
            prefixIcon: Icons.business_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (_selectedInsurance == 'Other' &&
                  (value == null || value.trim().isEmpty)) {
                return 'Enter the insurance provider';
              }

              return null;
            },
          ),
        ],
        if (_selectedInsurance != 'None') ...[
          const SizedBox(height: 18),
          AuthTextField(
            controller: _insuranceIdController,
            label: 'Member or policy number',
            hint: 'Enter your insurance number',
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your insurance number';
              }

              return null;
            },
          ),
        ],
        if (_selectedInsurance == 'None') ...[
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.textLight,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You can add medical insurance later.',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.stockGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _saveProfile,
        icon: _isSaving
            ? const SizedBox(
          width: 19,
          height: 19,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.check_rounded),
        label: Text(
          _isSaving ? 'Saving...' : 'Save profile',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          backgroundColor: AppColors.primaryGreen,
          disabledBackgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}