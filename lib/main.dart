import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/pharmacy_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/pharmacy/pharmacy_cubit.dart';
import 'presentation/bloc/search/search_cubit.dart';
import 'presentation/bloc/settings/settings_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final authRepository = AuthRepository();
  final pharmacyRepository = PharmacyRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(prefs: prefs)),
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(authRepository: authRepository)
                ..add(AuthCheckRequested()),
        ),
        BlocProvider<SearchCubit>(
          create: (_) => SearchCubit(pharmacyRepository: pharmacyRepository),
        ),
        BlocProvider<PharmacyCubit>(
          create: (_) => PharmacyCubit(pharmacyRepository: pharmacyRepository),
        ),
      ],
      child: const PharmaFindApp(),
    ),
  );
}
