import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/settings/settings_cubit.dart';
import 'presentation/screens/alerts/notify_confirmation_screen.dart';
import 'presentation/screens/alerts/notify_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/forgot_password_screen.dart';
import 'presentation/screens/onboarding/language_screen.dart';
import 'presentation/screens/onboarding/login_screen.dart';
import 'presentation/screens/onboarding/register_screen.dart';
import 'presentation/screens/onboarding/welcome_screen.dart';
import 'presentation/screens/partner/partner_dashboard_screen.dart';
import 'presentation/screens/partner/partner_license_screen.dart';
import 'presentation/screens/partner/partner_pending_screen.dart';
import 'presentation/screens/partner/partner_profile_screen.dart';
import 'presentation/screens/partner/partner_rejected_screen.dart';
import 'presentation/screens/partner/partner_signup_screen.dart';
import 'presentation/screens/partner/partner_stock_screen.dart';
import 'presentation/screens/pharmacy/directions_screen.dart';
import 'presentation/screens/pharmacy/pharmacy_detail_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/search/search_results_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
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
                '/welcome' => const WelcomeScreen(),
                '/language' => const LanguageScreen(),
                '/login' => const LoginScreen(),
                '/register' => const RegisterScreen(),
                '/forgot-password' => const ForgotPasswordScreen(),
                '/home' => const HomeScreen(),
                '/search-results' => const SearchResultsScreen(),
                '/pharmacy-detail' => const PharmacyDetailScreen(),
                '/directions' => const DirectionsScreen(),
                '/notify' => const NotifyScreen(),
                '/notify-confirmation' => const NotifyConfirmationScreen(),
                '/profile' => const ProfileScreen(),
                '/settings' => const SettingsScreen(),
                '/partner-signup' => const PartnerSignupScreen(),
                '/partner-license' => const PartnerLicenseScreen(),
                '/partner-pending' => const PartnerPendingScreen(),
                '/partner-rejected' => const PartnerRejectedScreen(),
                '/partner-profile' => const PartnerProfileScreen(),
                '/partner-stock' => const PartnerStockScreen(),
                '/partner-dashboard' => const PartnerDashboardScreen(),
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
