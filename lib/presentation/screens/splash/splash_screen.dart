import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/auth_routes.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../utils/auth_navigation.dart';
import '../../utils/partner_navigation.dart';
import '../../widgets/pharmafind_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    _startStartupFlow();
  }

  Future<void> _startStartupFlow() async {
    // Wait for the splash animation
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final settings = context.read<SettingsCubit>().state;
    if (!settings.hasSeenOnboarding) {
      Navigator.of(context).pushReplacementNamed(AuthRoutes.language);
      return;
    }

    final authBloc = context.read<AuthBloc>();
    var authState = authBloc.state;

    // Wait until authentication restoration has reached a definitive state
    if (authState is AuthInitial || authState is AuthLoading) {
      try {
        authState = await authBloc.stream
            .firstWhere((s) => s is! AuthInitial && s is! AuthLoading)
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        authState = authBloc.state;
      }
    }

    if (!mounted) return;

    if (authState is AuthAuthenticated) {
      if (authState.user.isPartner) {
        await PartnerNavigation.routePartner(
          context,
          authState.user.uid,
          replace: true,
        );
      } else {
        AuthNavigation.toHome(context);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AuthRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const PharmaFindLogo(size: 60),
                const SizedBox(height: 16),
                Text(
                  AppStrings.get('tagline', locale),
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 80),
                Text(
                  AppStrings.get('built_for', locale),
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.5),
                    fontSize: 13,
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
