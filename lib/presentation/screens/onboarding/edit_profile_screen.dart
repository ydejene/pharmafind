import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/phone_formatter.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../utils/auth_snackbar.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insuranceIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _phoneController.text = state.user.phone ?? '';
      _insuranceProviderController.text = state.user.insuranceProvider ?? '';
      _insuranceIdController.text = state.user.insuranceId ?? '';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _insuranceProviderController.dispose();
    _insuranceIdController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthProfileUpdateRequested(
          phone: _phoneController.text.trim(),
          insuranceProvider: _insuranceProviderController.text.trim(),
          insuranceId: _insuranceIdController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          AuthSnackbar.showSuccess(context, 'Profile updated');
          Navigator.pop(context);
        } else if (state is AuthError) {
          AuthSnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          ),
          title: Text(
            AppStrings.get('profile', locale),
            style: const TextStyle(color: AppColors.textDark, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthAuthenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    UserAvatar(
                      displayName: state.user.displayName,
                      size: 72,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.user.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      state.user.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildLabel(AppStrings.get('your_phone', locale)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: PhoneFormatter.validate,
                      decoration: const InputDecoration(
                        hintText: '+250 7XX XXX XXX',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildLabel(AppStrings.get('insurance_provider', locale)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _insuranceProviderController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'e.g. RSSB, MMI, Radiant',
                        prefixIcon: const Icon(Icons.shield_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildLabel(AppStrings.get('member_id', locale)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _insuranceIdController,
                      decoration: const InputDecoration(
                        hintText: 'Insurance member ID',
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        child: Text(
                          AppStrings.get('save_insurance', locale),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}
