import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/auth/auth_bloc.dart';
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
          body: const SafeArea(
            child: Center(child: Text('Profile')),
          ),
        );
      },
    );
  }
}
