import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/auth_routes.dart';
import '../../../domain/entities/pharmacy_entity.dart';
import '../../../domain/entities/stock_item_entity.dart';
import '../../../domain/repositories/pharmacy_repository.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/search/search_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../utils/auth_navigation.dart';
import '../../widgets/pharmafind_logo.dart';

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

  StockItemEntity _toStockItem(PharmacyEntity pharmacy) {
    return StockItemEntity(
      id: pharmacy.id,
      pharmacyId: pharmacy.id,
      pharmacyName: pharmacy.name,
      pharmacyArea: pharmacy.area,
      pharmacyPhone: pharmacy.phone,
      pharmacyHours: pharmacy.hours,
      pharmacyLat: pharmacy.latitude,
      pharmacyLng: pharmacy.longitude,
      medicineName: 'Dispensary & Prescriptions',
      status: 'in_stock',
      quantity: 1,
      price: 0,
      updatedAt: DateTime.now(),
    );
  }

  void _openPharmacyDetail(PharmacyEntity pharmacy) {
    final item = _toStockItem(pharmacy);
    context.read<SearchCubit>().selectResult(item);
    Navigator.of(context).pushNamed('/pharmacy-detail');
  }

  void _openDirections(PharmacyEntity pharmacy) {
    final item = _toStockItem(pharmacy);
    context.read<SearchCubit>().selectResult(item);
    Navigator.of(context).pushNamed('/directions');
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final locale = settingsState.locale;
    final isDarkMode = settingsState.isDarkMode;
    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isPartner = isAuthenticated && authState.user.isPartner;

    return Scaffold(
      appBar: AppBar(
        title: isDarkMode
            ? const PharmaFindLogo(size: 28)
            : const PharmaFindLogoDark(size: 28),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppStrings.get('settings', locale),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AuthRoutes.profile),
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
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Text(
                        '${AppStrings.get('error', locale)}: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            final pharmacies = snapshot.data ?? [];
            if (pharmacies.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Text(
                        AppStrings.get('no_results', locale),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  AppStrings.get('find_medicine', locale),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.get('find_stock', locale),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AuthRoutes.profile),
                      icon: const Icon(Icons.person_outline, size: 18),
                      label: Text(AppStrings.get('profile', locale)),
                    ),
                    if (isPartner)
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AuthRoutes.partnerDashboard),
                        icon: const Icon(Icons.dashboard_outlined, size: 18),
                        label: Text(
                          AppStrings.get('partner_dashboard', locale),
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AuthRoutes.partnerSignup),
                        icon: const Icon(Icons.storefront_outlined, size: 18),
                        label: Text(
                          AppStrings.get('register_pharmacy', locale),
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/notify'),
                      icon: const Icon(
                        Icons.notifications_active_outlined,
                        size: 18,
                      ),
                      label: Text(AppStrings.get('notify_me', locale)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/settings'),
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: Text(AppStrings.get('settings', locale)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.get('nearby_pharmacies', locale),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${pharmacies.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...pharmacies.map(
                  (pharmacy) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.local_pharmacy_outlined,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      title: Text(
                        pharmacy.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${pharmacy.area} · ${pharmacy.hours}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pharmacy.phone.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.phone_outlined,
                                size: 20,
                                color: AppColors.primaryGreen,
                              ),
                              tooltip: AppStrings.get('call_pharmacy', locale),
                              onPressed: () {
                                final phone =
                                    pharmacy.phone.replaceAll(' ', '');
                                if (phone.isNotEmpty) {
                                  launchUrl(Uri.parse('tel:$phone'));
                                }
                              },
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.directions,
                              size: 22,
                              color: AppColors.accentOrange,
                            ),
                            tooltip: AppStrings.get('get_directions', locale),
                            onPressed: () => _openDirections(pharmacy),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textLight,
                            size: 20,
                          ),
                        ],
                      ),
                      onTap: () => _openPharmacyDetail(pharmacy),
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
