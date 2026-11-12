import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/auth_routes.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/settings/settings_cubit.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/onboarding.dart';
import 'presentation/screens/profile/edit_profile_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
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
          initialRoute: AuthRoutes.splash,
          onGenerateRoute: (routeSettings) {
            return MaterialPageRoute(
              settings: routeSettings,
              builder: (context) => switch (routeSettings.name) {
                AuthRoutes.splash => const SplashScreen(),
                AuthRoutes.language => const LanguageScreen(),
                AuthRoutes.login => const LoginScreen(),
                AuthRoutes.register => const RegisterScreen(),
                AuthRoutes.forgotPassword => const ForgotPasswordScreen(),
                AuthRoutes.home => const HomeScreen(),
                AuthRoutes.profile => const ProfileScreen(),
                '/edit-profile' => const EditProfileScreen(),
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
}
