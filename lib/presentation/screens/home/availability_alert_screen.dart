import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../utils/auth_navigation.dart';

class AvailabilityAlertScreen extends StatelessWidget {
  const AvailabilityAlertScreen({super.key, this.query});

  final String? query;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final isAuthenticated = context.watch<AuthBloc>().state is AuthAuthenticated;
    final medicine = query ?? AppStrings.get('medicine', locale);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('notify_me', locale))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.notifications_active_outlined, size: 56),
            const SizedBox(height: 20),
            Text(
              AppStrings.get('get_alert', locale),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('$medicine\n\n${AppStrings.get('alert_desc', locale)}'),
            const Spacer(),
            if (!isAuthenticated)
              FilledButton.icon(
                onPressed: () => AuthNavigation.toLogin(context),
                icon: const Icon(Icons.login),
                label: Text(AppStrings.get('sign_in', locale)),
              )
            else
              Text(
                AppStrings.get('stock_alerts_desc', locale),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
