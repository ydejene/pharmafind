import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/search/search_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../widgets/pharma_find_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _insuranceOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    context.read<SearchCubit>().searchMedicine(query);
    Navigator.of(context).pushNamed('/search-results');
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final authState = context.watch<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 28,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const PharmaFindLogo(size: 36),
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Kigali, Rwanda',
                          style: TextStyle(
                            color: AppColors.cream.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.menu,
                            color: AppColors.cream,
                            size: 20,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'profile':
                                if (isLoggedIn) {
                                  Navigator.of(context).pushNamed('/profile');
                                } else {
                                  Navigator.of(context).pushNamed('/login');
                                }
                              case 'settings':
                                Navigator.of(context).pushNamed('/settings');
                              case 'logout':
                                context.read<AuthBloc>().add(
                                  AuthLogoutRequested(),
                                );
                                Navigator.of(context)
                                    .pushReplacementNamed('/login');
                              case 'login':
                                Navigator.of(context).pushNamed('/login');
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 18),
                                  const SizedBox(width: 8),
                                  Text(AppStrings.get('profile', locale)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'settings',
                              child: Row(
                                children: [
                                  const Icon(Icons.settings_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Text(AppStrings.get('settings', locale)),
                                ],
                              ),
                            ),
                            if (isLoggedIn)
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    const Icon(Icons.logout, size: 18),
                                    const SizedBox(width: 8),
                                    Text(AppStrings.get('logout', locale)),
                                  ],
                                ),
                              )
                            else
                              PopupMenuItem(
                                value: 'login',
                                child: Row(
                                  children: [
                                    const Icon(Icons.login, size: 18),
                                    const SizedBox(width: 8),
                                    Text(AppStrings.get('login', locale)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  AppStrings.get('find_medicine', locale),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.get('what_medicine', locale),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _performSearch(),
                    decoration: InputDecoration(
                      hintText: AppStrings.get('search_medicine', locale),
                      hintStyle: const TextStyle(color: AppColors.textLight),
                      prefixIcon: IconButton(
                        onPressed: _performSearch,
                        icon: const Icon(
                          Icons.search,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _insuranceOnly = !_insuranceOnly);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.borderLight.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: AppColors.primaryGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.get('show_insurance', locale),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  AppStrings.get('filter_insurance', locale),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _insuranceOnly,
                            onChanged: (val) {
                              setState(() => _insuranceOnly = val);
                            },
                            activeThumbColor: AppColors.primaryGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.get('quick_access', locale),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderLight.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 40,
                                top: 30,
                                right: 40,
                                child: Container(
                                  height: 2,
                                  color: AppColors.borderLight.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 20,
                                left: 80,
                                bottom: 20,
                                child: Container(
                                  width: 2,
                                  color: AppColors.borderLight.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              Center(
                                child: Icon(
                                  Icons.location_on,
                                  color: AppColors.accentOrange,
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.get(
                                        'nearby_pharmacies',
                                        locale,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      AppStrings.get('find_stock', locale),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentOrange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.get('stock_verified', locale),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
