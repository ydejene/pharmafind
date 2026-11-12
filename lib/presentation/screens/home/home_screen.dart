import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/pharmacy_entity.dart';
import '../../../domain/repositories/pharmacy_repository.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../utils/auth_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PharmacyEntity>> _pharmacies;

  @override
  void initState() {
    super.initState();
    _pharmacies = context.read<IPharmacyRepository>().getApprovedPharmacies();
  }

  void _reload() {
    setState(() {
      _pharmacies = context.read<IPharmacyRepository>().getApprovedPharmacies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.read<SettingsCubit>().state.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('app_name', locale)),
        actions: [
          IconButton(
            onPressed: () => AuthNavigation.toLogin(context),
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.get('logout', locale),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<PharmacyEntity>>(
          future: _pharmacies,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Text('${AppStrings.get('error', locale)}: ${snapshot.error}'),
                    ),
                  ),
                ],
              );
            }

            final pharmacies = snapshot.data ?? [];
            if (pharmacies.isEmpty) {
              return ListView(
                children: [
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(AppStrings.get('no_results', locale)),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  AppStrings.get('find_medicine', locale),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(AppStrings.get('find_stock', locale)),
                const SizedBox(height: 24),
                Text(
                  AppStrings.get('nearby_pharmacies', locale),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ...pharmacies.map(
                  (pharmacy) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_pharmacy_outlined),
                      title: Text(pharmacy.name),
                      subtitle: Text('${pharmacy.area} · ${pharmacy.hours}'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}