import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/settings/settings_cubit.dart';
import 'presentation/screens/onboarding/forgot_password_screen.dart';
import 'presentation/screens/onboarding/language_screen.dart';
import 'presentation/screens/onboarding/login_screen.dart';
import 'presentation/screens/onboarding/register_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

class PharmaFindApp extends StatelessWidget {
  const PharmaFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          title: 'PharmaFind',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          onGenerateRoute: (routeSettings) {
            return MaterialPageRoute(
              settings: routeSettings,
              builder: (context) => switch (routeSettings.name) {
                '/' => const SplashScreen(),
                '/language' => const LanguageScreen(),
                '/login' => const LoginScreen(),
                '/register' => const RegisterScreen(),
                '/forgot-password' => const ForgotPasswordScreen(),
                _ => Scaffold(
                  body: Center(
                    child: Text(AppStrings.get('error', settings.locale)),
                  ),
                ),
              },
            );
          },
        );
      },
    );
  }

  static Widget _buildPlaceholderScreen(
    BuildContext context, {
    required String title,
    required String routeName,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$title ($routeName)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Foundation placeholder — Pending feature implementation.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
