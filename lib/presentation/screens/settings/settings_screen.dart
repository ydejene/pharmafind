import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/settings/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final locale = settings.locale;

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
                    AppStrings.get('settings', locale),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.get('preferences', locale).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsSection(
                    children: [
                      _SettingsTile(
                        icon: Icons.language,
                        title: AppStrings.get('language', locale),
                        trailing: DropdownButton<String>(
                          value: locale,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: 'rw',
                              child: Text('Kinyarwanda'),
                            ),
                            DropdownMenuItem(
                              value: 'fr',
                              child: Text('Français'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              context.read<SettingsCubit>().setLocale(val);
                            }
                          },
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: AppStrings.get('dark_mode', locale),
                        trailing: Switch(
                          value: settings.isDarkMode,
                          onChanged: (val) {
                            context.read<SettingsCubit>().setDarkMode(val);
                          },
                          activeThumbColor: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('notifications', locale).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsSection(
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: AppStrings.get('stock_alerts', locale),
                        subtitle: AppStrings.get('stock_alerts_desc', locale),
                        trailing: Switch(
                          value: settings.stockAlerts,
                          onChanged: (val) {
                            context.read<SettingsCubit>().setStockAlerts(val);
                          },
                          activeThumbColor: AppColors.primaryGreen,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.system_update_outlined,
                        title: AppStrings.get('app_updates', locale),
                        subtitle: AppStrings.get('app_updates_desc', locale),
                        trailing: Switch(
                          value: settings.appUpdates,
                          onChanged: (val) {
                            context.read<SettingsCubit>().setAppUpdates(val);
                          },
                          activeThumbColor: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('about', locale).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SettingsSection(
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: AppStrings.get('version', locale),
                        trailing: const Text(
                          '1.0.0',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: AppStrings.get('terms', locale),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: AppStrings.get('privacy', locale),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                      ),
                    ],
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

class _SettingsSection extends StatelessWidget {
  final List<Widget> children;

  const _SettingsSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 1,
              indent: 56,
              color: AppColors.borderLight.withValues(alpha: 0.5),
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          trailing,
        ],
      ),
    );
  }
}
