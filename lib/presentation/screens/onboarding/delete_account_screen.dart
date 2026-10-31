import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../utils/auth_snackbar.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _emailController = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
        ),
        title: Text(
          AppStrings.get('delete_account', locale),
          style: const TextStyle(color: AppColors.textDark, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final userEmail =
              state is AuthAuthenticated ? state.user.email : '';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.errorRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.errorRed,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.get('delete_account_confirm', locale),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textDark,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'TYPE YOUR EMAIL TO CONFIRM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      _confirmed =
                          value.trim().toLowerCase() == userEmail;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: userEmail,
                    prefixIcon:
                        const Icon(Icons.email_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter "$userEmail" to proceed',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _confirmed
                        ? () {
                            AuthSnackbar.showSuccess(
                              context,
                              AppStrings.get('account_deleted', locale),
                            );
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      disabledBackgroundColor:
                          AppColors.errorRed.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      AppStrings.get('delete_account', locale),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppStrings.get('not_now', locale),
                      style: const TextStyle(color: AppColors.textMedium),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
