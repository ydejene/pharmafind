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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(title: Text(AppStrings.get('profile', locale))),
            body: Center(
              child: Text(AppStrings.get('login_required', locale)),
            ),
          );
        }

        final user = state.user;
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('profile', locale)),
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 24),
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryGreen,
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _SectionHeader(AppStrings.get('account', locale)),
                _MenuTile(
                  icon: Icons.person_outline,
                  title: AppStrings.get('edit_profile', locale),
                  onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
                ),
                _MenuTile(
                  icon: Icons.shield_outlined,
                  title: AppStrings.get('insurance_info', locale),
                  subtitle: user.insuranceProvider ?? AppStrings.get('not_set', locale),
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                _SectionHeader(AppStrings.get('preferences', locale)),
                _MenuTile(
                  icon: Icons.language,
                  title: AppStrings.get('language', locale),
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.notifications_outlined,
                  title: AppStrings.get('notifications', locale),
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                _SectionHeader(AppStrings.get('app', locale)),
                _MenuTile(
                  icon: Icons.help_outline,
                  title: AppStrings.get('help', locale),
                  onTap: () {},
                ),
                _MenuTile(
                  icon: Icons.info_outline,
                  title: AppStrings.get('about', locale),
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    icon: const Icon(Icons.logout, size: 20),
                    label: Text(AppStrings.get('logout', locale)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRed,
                      side: const BorderSide(color: AppColors.errorRed),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22, color: AppColors.textMedium),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.textLight))
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.borderLight),
      onTap: onTap,
    );
  }
}
