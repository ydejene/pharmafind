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

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppStrings.get('login_required', locale)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                child: Text(AppStrings.get('login', locale)),
              ),
            ],
          ),
        ),
      );
    }

    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 16,
              bottom: 28,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        AppStrings.get('profile', locale),
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
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  child: Text(
                    (user.displayName.isNotEmpty
                            ? user.displayName[0]
                            : user.email[0])
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName.isNotEmpty ? user.displayName : user.email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('account', locale).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileTile(
                    icon: Icons.person_outline,
                    title: AppStrings.get('edit_profile', locale),
                    onTap: () {},
                  ),
                  _ProfileTile(
                    icon: Icons.shield_outlined,
                    title: AppStrings.get('insurance_info', locale),
                    subtitle: (user.insuranceProvider?.isNotEmpty ?? false)
                        ? user.insuranceProvider!
                        : AppStrings.get('not_set', locale),
                    onTap: () {},
                  ),
                  _ProfileTile(
                    icon: Icons.notifications_outlined,
                    title: AppStrings.get('my_alerts', locale),
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('app', locale).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProfileTile(
                    icon: Icons.settings_outlined,
                    title: AppStrings.get('settings', locale),
                    onTap: () => Navigator.of(context).pushNamed('/settings'),
                  ),
                  _ProfileTile(
                    icon: Icons.help_outline,
                    title: AppStrings.get('help', locale),
                    onTap: () {},
                  ),
                  _ProfileTile(
                    icon: Icons.info_outline,
                    title: AppStrings.get('about', locale),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'PharmaFind',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '2024 PharmaFind Rwanda',
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      icon: const Icon(Icons.logout, color: AppColors.errorRed),
                      label: Text(
                        AppStrings.get('logout', locale),
                        style: const TextStyle(color: AppColors.errorRed),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.errorRed),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryGreen, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
