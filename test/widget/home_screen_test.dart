import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pharma_find/presentation/screens/home/home_screen.dart';
import 'package:pharma_find/presentation/bloc/auth/auth_bloc.dart';
import 'package:pharma_find/presentation/bloc/search/search_cubit.dart';
import 'package:pharma_find/presentation/bloc/settings/settings_cubit.dart';
import 'package:pharma_find/data/repositories/auth_repository.dart';
import 'package:pharma_find/data/repositories/pharmacy_repository.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders search field and insurance toggle', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>(
              create: (_) => SettingsCubit(prefs: prefs),
            ),
            BlocProvider<AuthBloc>(
              create: (_) => AuthBloc(authRepository: AuthRepository()),
            ),
            BlocProvider<SearchCubit>(
              create: (_) =>
                  SearchCubit(pharmacyRepository: PharmacyRepository()),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
