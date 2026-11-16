import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../bloc/settings/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final locale = settings.locale;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('settings', locale))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(AppStrings.get('dark_mode', locale)),
            subtitle: Text(AppStrings.get('dark_mode_desc', locale)),
            value: settings.isDarkMode,
            onChanged: (value) => context.read<SettingsCubit>().setDarkMode(value),
          ),
          SwitchListTile(
            title: Text(AppStrings.get('stock_alerts', locale)),
            subtitle: Text(AppStrings.get('stock_alerts_desc', locale)),
            value: settings.stockAlerts,
            onChanged: (value) => context.read<SettingsCubit>().setStockAlerts(value),
          ),
          SwitchListTile(
            title: Text(AppStrings.get('app_updates', locale)),
            subtitle: Text(AppStrings.get('app_updates_desc', locale)),
            value: settings.appUpdates,
            onChanged: (value) => context.read<SettingsCubit>().setAppUpdates(value),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppStrings.get('language', locale)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/language'),
          ),
        ],
      ),
    );
  }
}
