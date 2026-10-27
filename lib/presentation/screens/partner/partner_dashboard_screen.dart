import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/pharmacy/pharmacy_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../widgets/pharma_find_logo.dart';

class PartnerDashboardScreen extends StatelessWidget {
  const PartnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final authState = context.watch<AuthBloc>().state;
    final pharmacyState = context.watch<PharmacyCubit>().state;

    final userName = authState is AuthAuthenticated
        ? authState.user.displayName
        : '';
    final pharmacy = pharmacyState.pharmacy;
    final stockCount = pharmacyState.stockItems.length;
    final inStockCount = pharmacyState.stockItems
        .where((s) => s.status == 'in_stock')
        .length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const PharmaFindLogo(size: 32),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 20,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'home':
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          case 'logout':
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'home',
                          child: Row(
                            children: [
                              const Icon(Icons.home_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(AppStrings.get('browse_app', locale)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(Icons.logout, size: 18),
                              const SizedBox(width: 8),
                              Text(AppStrings.get('logout', locale)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get('partner_portal', locale),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.get('welcome', locale)}, $userName',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (pharmacy != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    pharmacy.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
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
                    AppStrings.get('overview', locale).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.inventory_2_outlined,
                          label: AppStrings.get('total_medicines', locale),
                          value: '$stockCount',
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle_outline,
                          label: AppStrings.get('in_stock', locale),
                          value: '$inStockCount',
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.remove_red_eye_outlined,
                          label: AppStrings.get('views', locale),
                          value: '—',
                          color: AppColors.accentOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.phone_outlined,
                          label: AppStrings.get('calls', locale),
                          value: '—',
                          color: AppColors.lightOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppStrings.get('quick_actions', locale).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.inventory_2_outlined,
                    title: AppStrings.get('manage_stock', locale),
                    subtitle: AppStrings.get('add_update_medicine', locale),
                    onTap: () =>
                        Navigator.of(context).pushNamed('/partner-stock'),
                  ),
                  _ActionTile(
                    icon: Icons.store_outlined,
                    title: AppStrings.get('pharmacy_profile', locale),
                    subtitle: AppStrings.get('edit_pharmacy_info', locale),
                    onTap: () =>
                        Navigator.of(context).pushNamed('/partner-profile'),
                  ),
                  _ActionTile(
                    icon: Icons.settings_outlined,
                    title: AppStrings.get('settings', locale),
                    subtitle: AppStrings.get('app_preferences', locale),
                    onTap: () => Navigator.of(context).pushNamed('/settings'),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primaryGreen, size: 22),
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
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
