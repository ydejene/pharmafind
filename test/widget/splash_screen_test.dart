import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_find/presentation/screens/splash/splash_screen.dart';
import 'package:pharma_find/presentation/bloc/settings/settings_cubit.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('renders logo and tagline', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        BlocProvider<SettingsCubit>(
          create: (_) => SettingsCubit(prefs: prefs),
          child: const MaterialApp(home: SplashScreen()),
        ),
      );

      expect(find.text('PharmaFind'), findsWidgets);
    });
  });
}
