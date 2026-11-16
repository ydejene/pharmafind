import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/pharmacy_entity.dart';
import '../../../domain/repositories/pharmacy_repository.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../bloc/search/search_cubit.dart';
import '../../utils/auth_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PharmacyEntity>> _pharmacies;
  final _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    await context.read<SearchCubit>().searchMedicine(query);
    if (mounted) Navigator.of(context).pushNamed('/search-results');
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.read<SettingsCubit>().state.locale;
    final isAuthenticated = context.watch<AuthBloc>().state is AuthAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('app_name', locale)),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
            icon: const Icon(Icons.person_outline),
            tooltip: AppStrings.get('profile', locale),
          ),
          IconButton(
            onPressed: () => AuthNavigation.toLogin(context),
            icon: Icon(isAuthenticated ? Icons.logout : Icons.login),
            tooltip: AppStrings.get(
              isAuthenticated ? 'logout' : 'sign_in',
              locale,
            ),
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
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/profile'),
                      icon: const Icon(Icons.person_outline),
                      label: Text(AppStrings.get('profile', locale)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/partner-signup'),
                      icon: const Icon(Icons.storefront_outlined),
                      label: Text(AppStrings.get('register_pharmacy', locale)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: AppStrings.get('search_medicine', locale),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: _search,
                      icon: const Icon(Icons.arrow_forward),
                      tooltip: AppStrings.get('search_medicine', locale),
                    ),
                  ),
                ),
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
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(pharmacy.name),
                          content: Text(
                            '${pharmacy.area}\n${pharmacy.hours}\n${pharmacy.phone}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(AppStrings.get('ok', locale)),
                            ),
                          ],
                        ),
                      ),
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