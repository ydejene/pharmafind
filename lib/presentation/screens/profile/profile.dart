import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/settings/settings_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // getting the first letter for the profile avatar
  String _getInitial(String displayName, String email) {
    if (displayName.trim().isNotEmpty) {
      return displayName.trim()[0].toUpperCase();
    }

    if (email.trim().isNotEmpty) {
      return email.trim()[0].toUpperCase();
    }

    return 'U';
  }

  // showing the form for editing profile details
  void _showEditProfileSheet(
      BuildContext context,
      AuthAuthenticated authState,
      ) {
    final user = authState.user;

    final nameController = TextEditingController(
      text: user.displayName,
    );

    final phoneController = TextEditingController(
      text: user.phone ?? '',
    );

    final insuranceProviderController = TextEditingController(
      text: user.insuranceProvider ?? '',
    );

    final insuranceIdController = TextEditingController(
      text: user.insuranceId ?? '',
    );

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.warmWhite,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.borderLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      children: [
                        _SmallIconBox(
                          icon: Icons.edit_outlined,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Edit profile',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Update your personal and insurance details.',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _ProfileTextField(
                      controller: nameController,
                      label: 'Full name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter your full name';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _ProfileTextField(
                      controller: phoneController,
                      label: 'Phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),

                    _ProfileTextField(
                      controller: insuranceProviderController,
                      label: 'Insurance provider',
                      icon: Icons.shield_outlined,
                    ),
                    const SizedBox(height: 14),

                    _ProfileTextField(
                      controller: insuranceIdController,
                      label: 'Insurance member ID',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          // saving the updated profile information
                          context.read<AuthBloc>().add(
                            AuthProfileUpdateRequested(
                              displayName: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              insuranceProvider:
                              insuranceProviderController.text.trim(),
                              insuranceId:
                              insuranceIdController.text.trim(),
                            ),
                          );

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Your profile has been updated.',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text(
                          'Save changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      phoneController.dispose();
      insuranceProviderController.dispose();
      insuranceIdController.dispose();
    });
  }

  // showing a message for pages that are still being built
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature will be available soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // returning to login after logout
        if (state is AuthUnauthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }

        // showing authentication errors
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return const Scaffold(
              backgroundColor: AppColors.cream,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              ),
            );
          }

          if (authState is! AuthAuthenticated) {
            return Scaffold(
              backgroundColor: AppColors.cream,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 54,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.get('login_required', locale),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/login');
                        },
                        child: Text(
                          AppStrings.get('login', locale),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final user = authState.user;
          final displayName = user.displayName.trim().isNotEmpty
              ? user.displayName.trim()
              : 'PharmaFind user';

          final roleText = user.role.isEmpty
              ? 'Patient account'
              : '${user.role[0].toUpperCase()}${user.role.substring(1)} account';

          return Scaffold(
            backgroundColor: AppColors.cream,
            body: SafeArea(
              bottom: false,
              child: TweenAnimationBuilder<double>(
                // adding a small entrance animation
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (context, animationValue, child) {
                  return Opacity(
                    opacity: animationValue,
                    child: Transform.translate(
                      offset: Offset(
                        0,
                        24 * (1 - animationValue),
                      ),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    _ProfileHeader(
                      displayName: displayName,
                      email: user.email,
                      role: roleText,
                      initial: _getInitial(
                        user.displayName,
                        user.email,
                      ),
                      onBack: () => Navigator.pop(context),
                      onEdit: () {
                        _showEditProfileSheet(
                          context,
                          authState,
                        );
                      },
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          22,
                          20,
                          32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailsCard(
                              phone: user.phone,
                              insuranceProvider:
                              user.insuranceProvider,
                              insuranceId: user.insuranceId,
                              onEdit: () {
                                _showEditProfileSheet(
                                  context,
                                  authState,
                                );
                              },
                            ),
                            const SizedBox(height: 26),

                            _SectionTitle(
                              title: AppStrings.get(
                                'account',
                                locale,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _ProfileTile(
                              icon: Icons.edit_outlined,
                              title: AppStrings.get(
                                'edit_profile',
                                locale,
                              ),
                              subtitle:
                              'Update your phone and insurance details',
                              onTap: () {
                                _showEditProfileSheet(
                                  context,
                                  authState,
                                );
                              },
                            ),
                            _ProfileTile(
                              icon: Icons.shield_outlined,
                              title: AppStrings.get(
                                'insurance_info',
                                locale,
                              ),
                              subtitle:
                              user.insuranceProvider?.trim().isNotEmpty ==
                                  true
                                  ? user.insuranceProvider!
                                  : AppStrings.get(
                                'not_set',
                                locale,
                              ),
                              onTap: () {
                                _showEditProfileSheet(
                                  context,
                                  authState,
                                );
                              },
                            ),
                            _ProfileTile(
                              icon: Icons.notifications_outlined,
                              title: AppStrings.get(
                                'my_alerts',
                                locale,
                              ),
                              subtitle:
                              'View your medicine stock alerts',
                              onTap: () {
                                _showComingSoon(
                                  context,
                                  AppStrings.get(
                                    'my_alerts',
                                    locale,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 26),

                            _SectionTitle(
                              title: AppStrings.get(
                                'app',
                                locale,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _ProfileTile(
                              icon: Icons.settings_outlined,
                              title: AppStrings.get(
                                'settings',
                                locale,
                              ),
                              subtitle:
                              'Language, theme and notifications',
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).pushNamed('/settings');
                              },
                            ),
                            _ProfileTile(
                              icon: Icons.help_outline_rounded,
                              title: AppStrings.get(
                                'help',
                                locale,
                              ),
                              subtitle:
                              'Get help using PharmaFind',
                              onTap: () {
                                _showComingSoon(
                                  context,
                                  AppStrings.get(
                                    'help',
                                    locale,
                                  ),
                                );
                              },
                            ),
                            _ProfileTile(
                              icon: Icons.info_outline_rounded,
                              title: AppStrings.get(
                                'about',
                                locale,
                              ),
                              subtitle: 'Version 1.0.0',
                              onTap: () {
                                showAboutDialog(
                                  context: context,
                                  applicationName: 'PharmaFind',
                                  applicationVersion: '1.0.0',
                                  applicationLegalese:
                                  '© 2026 PharmaFind Rwanda',
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                // signing the user out
                                onPressed: () {
                                  context.read<AuthBloc>().add(
                                    AuthLogoutRequested(),
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout_rounded,
                                ),
                                label: Text(
                                  AppStrings.get(
                                    'logout',
                                    locale,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.errorRed,
                                  side: const BorderSide(
                                    color: AppColors.errorRed,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String role;
  final String initial;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.role,
    required this.initial,
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 28),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -35,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(
                  alpha: 0.16,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'My profile',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit profile',
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: AppColors.warmWhite,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -3,
                    bottom: 3,
                    child: GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        width: 29,
                        height: 29,
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Text(
                displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),

              Text(
                email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  role,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String? phone;
  final String? insuranceProvider;
  final String? insuranceId;
  final VoidCallback onEdit;

  const _DetailsCard({
    required this.phone,
    required this.insuranceProvider,
    required this.insuranceId,
    required this.onEdit,
  });

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not set';
    }

    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Profile details',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                ),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accentOrange,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 5),

          _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _displayValue(phone),
          ),
          const SizedBox(height: 14),

          _DetailRow(
            icon: Icons.shield_outlined,
            label: 'Insurance',
            value: _displayValue(insuranceProvider),
          ),
          const SizedBox(height: 14),

          _DetailRow(
            icon: Icons.badge_outlined,
            label: 'Member ID',
            value: _displayValue(insuranceId),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryGreen,
            size: 19,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textLight,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryGreen,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textLight,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryGreen,
        ),
        filled: true,
        fillColor: AppColors.cream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.errorRed,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _SmallIconBox extends StatelessWidget {
  final IconData icon;

  const _SmallIconBox({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: AppColors.primaryGreen,
        size: 22,
      ),
    );
  }
}