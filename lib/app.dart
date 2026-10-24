import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/settings/settings_cubit.dart';
import 'presentation/screens/onboarding/login_screen.dart';
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
                '/login' => const LoginScreen(),
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
