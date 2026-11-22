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
import '../../widgets/notification_bell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PharmacyEntity>> _pharmacies;
  final _searchController = TextEditingController();

  static const int _pharmaciesPerPage = 5;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pharmacies =
        context.read<IPharmacyRepository>().getApprovedPharmacies();
  }

  // loading the pharmacies again
  void _reload() {
    setState(() {
      _currentPage = 0;
      _pharmacies =
          context.read<IPharmacyRepository>().getApprovedPharmacies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // searching for a medicine
  Future<void> _search() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) return;

    await context.read<SearchCubit>().searchMedicine(query);

    if (mounted) {
      Navigator.of(context).pushNamed('/search-results');
    }
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

  // opening the pharmacy details
  void _openPharmacyDetail(PharmacyEntity pharmacy) {
    final item = _toStockItem(pharmacy);

    context.read<SearchCubit>().selectResult(item);
    Navigator.of(context).pushNamed('/pharmacy-detail');
  }

  // opening the pharmacy directions
  void _openDirections(PharmacyEntity pharmacy) {
    final item = _toStockItem(pharmacy);

    context.read<SearchCubit>().selectResult(item);
    Navigator.of(context).pushNamed('/directions');
  }

  // changing the pharmacy page
  void _changePage(int page, int totalPages) {
    if (page < 0 || page >= totalPages) return;

    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsCubit>().state;
    final locale = settingsState.locale;
    final isDarkMode = settingsState.isDarkMode;

    final authState = context.watch<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isPartner = isAuthenticated && authState.user.isPartner;

    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      appBar: AppBar(
        title: isDarkMode
            ? const PharmaFindLogo(size: 28)
            : const PharmaFindLogoDark(size: 28),
        actions: [
          // opening the notifications page
          const NotificationBell(),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppStrings.get('settings', locale),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AuthRoutes.profile);
            },
            icon: const Icon(Icons.person_outline),
            tooltip: AppStrings.get('profile', locale),
          ),
          IconButton(
            onPressed: () => AuthNavigation.toLogin(context),
            icon: Icon(
              isAuthenticated ? Icons.logout : Icons.login,
            ),
            tooltip: AppStrings.get(
              isAuthenticated ? 'logout' : 'sign_in',
              locale,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<PharmacyEntity>>(
          future: _pharmacies,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  _MessageCard(
                    icon: Icons.error_outline,
                    iconColor: Colors.red,
                    message:
                    '${AppStrings.get('error', locale)}: ${snapshot.error}',
                    buttonText: 'Try again',
                    onPressed: _reload,
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
                  _MessageCard(
                    icon: Icons.local_pharmacy_outlined,
                    iconColor: AppColors.primaryGreen,
                    message: AppStrings.get('no_results', locale),
                    buttonText: 'Refresh',
                    onPressed: _reload,
                  ),
                ],
              );
            }

            final totalPages =
            (pharmacies.length / _pharmaciesPerPage).ceil();

            final safeCurrentPage = _currentPage < totalPages
                ? _currentPage
                : totalPages - 1;

            final startIndex =
                safeCurrentPage * _pharmaciesPerPage;

            final endIndex =
            (startIndex + _pharmaciesPerPage) >
                pharmacies.length
                ? pharmacies.length
                : startIndex + _pharmaciesPerPage;

            final visiblePharmacies =
            pharmacies.sublist(startIndex, endIndex);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              children: [
                // showing the welcome section
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryGreen,
                        Color(0xFF117A65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(
                          alpha: 0.22,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -18,
                        top: -30,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 35,
                        bottom: -45,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: 0.07,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.16,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.medication_outlined,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            AppStrings.get(
                              'find_medicine',
                              locale,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            AppStrings.get('find_stock', locale),
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.85,
                              ),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // showing the search box
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorScheme.outline.withValues(
                        alpha: 0.13,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: AppStrings.get(
                        'search_medicine',
                        locale,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primaryGreen,
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(5),
                        child: IconButton.filled(
                          onPressed: _search,
                          style: IconButton.styleFrom(
                            backgroundColor:
                            AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 20,
                          ),
                          tooltip: AppStrings.get(
                            'search_medicine',
                            locale,
                          ),
                        ),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Quick actions',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // showing the quick actions
                SizedBox(
                  height: 114,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _QuickAction(
                        width: 112,
                        icon: Icons.person_outline,
                        label: AppStrings.get('profile', locale),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            AuthRoutes.profile,
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      if (isPartner)
                        _QuickAction(
                          width: 155,
                          icon: Icons.dashboard_outlined,
                          label: AppStrings.get(
                            'partner_dashboard',
                            locale,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AuthRoutes.partnerDashboard,
                            );
                          },
                        )
                      else
                        _QuickAction(
                          width: 175,
                          icon: Icons.storefront_outlined,
                          label: AppStrings.get(
                            'register_pharmacy',
                            locale,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AuthRoutes.partnerSignup,
                            );
                          },
                        ),
                      const SizedBox(width: 10),
                      _QuickAction(
                        width: 112,
                        icon: Icons.settings_outlined,
                        label: AppStrings.get('settings', locale),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/settings',
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // showing the pharmacy heading
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.get(
                          'nearby_pharmacies',
                          locale,
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pharmacies.length}',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  'Showing ${startIndex + 1}–$endIndex of ${pharmacies.length}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 14),

                // showing five pharmacies on each page
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey<int>(safeCurrentPage),
                    children: visiblePharmacies.map((pharmacy) {
                      return _PharmacyCard(
                        pharmacy: pharmacy,
                        locale: locale,
                        onTap: () {
                          _openPharmacyDetail(pharmacy);
                        },
                        onDirections: () {
                          _openDirections(pharmacy);
                        },
                      );
                    }).toList(),
                  ),
                ),

                if (totalPages > 1) ...[
                  const SizedBox(height: 12),

                  // changing between the pharmacy pages
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.outline.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: safeCurrentPage > 0
                              ? () {
                            _changePage(
                              safeCurrentPage - 1,
                              totalPages,
                            );
                          }
                              : null,
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: List.generate(
                              totalPages,
                                  (index) {
                                final selected =
                                    index == safeCurrentPage;

                                return GestureDetector(
                                  onTap: () {
                                    _changePage(
                                      index,
                                      totalPages,
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 220,
                                    ),
                                    width: selected ? 28 : 9,
                                    height: 9,
                                    margin:
                                    const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.primaryGreen
                                          : AppColors.textLight
                                          .withValues(
                                        alpha: 0.25,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                          safeCurrentPage < totalPages - 1
                              ? () {
                            _changePage(
                              safeCurrentPage + 1,
                              totalPages,
                            );
                          }
                              : null,
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 7),

                  Center(
                    child: Text(
                      'Page ${safeCurrentPage + 1} of $totalPages',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.width,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: width,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(
                alpha: 0.13,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryGreen,
                  size: 21,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PharmacyCard extends StatelessWidget {
  const _PharmacyCard({
    required this.pharmacy,
    required this.locale,
    required this.onTap,
    required this.onDirections,
  });

  final PharmacyEntity pharmacy;
  final String locale;
  final VoidCallback onTap;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_pharmacy_outlined,
                  color: AppColors.primaryGreen,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pharmacy.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pharmacy.area,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 15,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pharmacy.hours,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Column(
                children: [
                  if (pharmacy.phone.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        final phone =
                        pharmacy.phone.replaceAll(' ', '');

                        if (phone.isNotEmpty) {
                          launchUrl(Uri.parse('tel:$phone'));
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor:
                        AppColors.primaryGreen.withValues(
                          alpha: 0.1,
                        ),
                      ),
                      icon: const Icon(
                        Icons.phone_outlined,
                        size: 19,
                        color: AppColors.primaryGreen,
                      ),
                      tooltip: AppStrings.get(
                        'call_pharmacy',
                        locale,
                      ),
                    ),
                  IconButton(
                    onPressed: onDirections,
                    style: IconButton.styleFrom(
                      backgroundColor:
                      AppColors.accentOrange.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    icon: const Icon(
                      Icons.directions_outlined,
                      size: 19,
                      color: AppColors.accentOrange,
                    ),
                    tooltip: AppStrings.get(
                      'get_directions',
                      locale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 45),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.refresh),
            label: Text(buttonText),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}