import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/auth_routes.dart';
import '../../../domain/entities/pharmacy_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/pharmacy/pharmacy_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../widgets/pharmafind_logo.dart';

/// Partner dashboard screen (Stage 4).
///
/// **Access Control & State Management:**
/// - Verifies that the authenticated user possesses the partner role (`user.isPartner`).
/// - Surfaces persisted pharmacy data from [PharmacyCubit].
/// - Displays actual verification status (approved, pending, or rejected).
/// - Handles loading, missing-profile (`noPharmacy`), and error states cleanly.
/// - Does not display fabricated statistics or dummy metrics.
class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-load partner pharmacy if not already loaded
    final authState = context.read<AuthBloc>().state;
    final pharmacyState = context.read<PharmacyCubit>().state;
    if (authState is AuthAuthenticated &&
        authState.user.isPartner &&
        pharmacyState.pharmacy == null &&
        pharmacyState.status != PharmacyStatus.loading) {
      context.read<PharmacyCubit>().loadPharmacy(authState.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final authState = context.watch<AuthBloc>().state;
    final pharmacyState = context.watch<PharmacyCubit>().state;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.user.isPartner) {
          final pState = context.read<PharmacyCubit>().state;
          if (pState.pharmacy == null &&
              pState.status != PharmacyStatus.loading) {
            context.read<PharmacyCubit>().loadPharmacy(state.user.uid);
          }
        }
      },
      child: _buildDashboardContent(context, authState, pharmacyState, locale),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AuthState authState,
    PharmacyState pharmacyState,
    String locale,
  ) {
    // 1. Authentication check
    if (authState is! AuthAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Authentication Required',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please log in with a partner account to access the partner portal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushReplacementNamed('/login'),
                    child: Text(AppStrings.get('login', locale)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. Role check (protect partner dashboard from student/patient accounts)
    if (!authState.user.isPartner) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block,
                      size: 56,
                      color: AppColors.errorRed,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Partner Access Required',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This dashboard is reserved for verified pharmacy partner accounts. Your account is registered as a patient/student.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/home', (route) => false),
                    child: Text(AppStrings.get('browse_app', locale)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final user = authState.user;
    final pharmacy = pharmacyState.pharmacy;
    final isLoading = pharmacyState.status == PharmacyStatus.loading;
    final hasError = pharmacyState.status == PharmacyStatus.error;
    final noPharmacy = pharmacy == null && !isLoading;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // Header section
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: AppColors.darkGreen,
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
                    const PharmaFindLogo(size: 32),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 22,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'home':
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          case 'logout':
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                            Navigator.of(context)
                                .pushReplacementNamed('/login');
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'home',
                          child: Row(
                            children: [
                              const Icon(Icons.home_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(AppStrings.get('browse_app', locale)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              const Icon(Icons.logout, size: 18),
                              const SizedBox(width: 8),
                              Text(AppStrings.get('logout', locale)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.get('partner_portal', locale),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.get('welcome', locale)}, ${user.displayName}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (pharmacy != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    pharmacy.name,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.lightOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Body content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // State 1: Loading
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),

                  // State 2: Error
                  if (hasError)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.errorRed.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.errorRed,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            pharmacyState.errorMessage ?? 'An error occurred',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => context
                                .read<PharmacyCubit>()
                                .loadPharmacy(user.uid),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),

                  // State 3: Missing Profile (noPharmacy)
                  if (noPharmacy && !hasError)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.borderLight.withValues(alpha: 0.7),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.storefront_outlined,
                              size: 44,
                              color: AppColors.accentOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Pharmacy Registered',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You have not registered your pharmacy profile yet. Complete your profile details to submit your pharmacy for verification.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMedium,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  Navigator.of(context)
                                      .pushNamed(AuthRoutes.partnerProfile),
                              icon: const Icon(Icons.add_business_outlined),
                              label: Text(
                                AppStrings.get('add_pharmacy_details', locale),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // State 4: Profile exists -> Display status & information
                  if (pharmacy != null && !isLoading) ...[
                    _buildVerificationBadge(context, pharmacy, locale),
                    const SizedBox(height: 16),
                    _buildProfileCard(pharmacy, locale),
                    const SizedBox(height: 16),
                    _buildStockSummaryCard(context, pharmacyState, locale),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.get('quick_actions', locale),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon: Icons.inventory_2_outlined,
                      title: AppStrings.get('manage_stock', locale),
                      subtitle: AppStrings.get('add_update_medicine', locale),
                      onTap: () =>
                          Navigator.of(context)
                              .pushNamed(AuthRoutes.partnerStock),
                    ),
                    _ActionTile(
                      icon: Icons.store_outlined,
                      title: AppStrings.get('pharmacy_profile', locale),
                      subtitle: AppStrings.get('edit_pharmacy_info', locale),
                      onTap: () =>
                          Navigator.of(context)
                              .pushNamed(AuthRoutes.partnerProfile),
                    ),
                    if (pharmacy.status == 'pending')
                      _ActionTile(
                        icon: Icons.hourglass_top,
                        title: 'Verification Status',
                        subtitle: 'Review document verification progress',
                        onTap: () =>
                            Navigator.of(context)
                                .pushNamed(AuthRoutes.partnerPending),
                      ),
                    if (pharmacy.status == 'rejected')
                      _ActionTile(
                        icon: Icons.warning_amber_rounded,
                        title: 'Rejection Details',
                        subtitle: 'Review reason and update profile details',
                        onTap: () =>
                            Navigator.of(context)
                                .pushNamed(AuthRoutes.partnerRejected),
                      ),
                    _ActionTile(
                      icon: Icons.home_outlined,
                      title: AppStrings.get('browse_app', locale),
                      subtitle: 'Switch to patient discovery mode',
                      onTap: () => Navigator.of(context)
                          .pushNamedAndRemoveUntil('/home', (route) => false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(
    BuildContext context,
    PharmacyEntity pharmacy,
    String locale,
  ) {
    final status = pharmacy.status.toLowerCase();
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;
    String description;

    switch (status) {
      case 'approved':
        bgColor = AppColors.stockGreen;
        textColor = AppColors.successGreen;
        icon = Icons.verified;
        label = 'VERIFIED & ACTIVE';
        description =
            'Your pharmacy is approved and visible to patients nearby.';
      case 'rejected':
        bgColor = AppColors.errorRed.withValues(alpha: 0.1);
        textColor = AppColors.errorRed;
        icon = Icons.warning_amber_rounded;
        label = 'VERIFICATION UNSUCCESSFUL';
        description =
            'Action needed: documents were not approved. Tap to review.';
      default:
        bgColor = AppColors.warningYellow.withValues(alpha: 0.15);
        textColor = AppColors.warningYellow;
        icon = Icons.hourglass_top;
        label = 'VERIFICATION IN PROGRESS';
        description =
            'Your documents are currently under review by our admin team.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(PharmacyEntity pharmacy, String locale) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                pharmacy.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (pharmacy.acceptsInsurance)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.stockGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Insurance',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            '${pharmacy.area}, ${pharmacy.district}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone_outlined, pharmacy.phone),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.email_outlined, pharmacy.email),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time_outlined, pharmacy.hours),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
        ),
      ],
    );
  }

  Widget _buildStockSummaryCard(
    BuildContext context,
    PharmacyState pharmacyState,
    String locale,
  ) {
    final isLoading = pharmacyState.status == PharmacyStatus.loading;
    final hasError = pharmacyState.status == PharmacyStatus.error;
    final items = pharmacyState.stockItems;
    final totalCount = items.length;
    final inStockCount = items.where((i) => i.isInStock).length;
    final lowOrOutCount = items
        .where((i) => i.isLowStock || i.isOutOfStock)
        .length;

    final displayTotal = isLoading
        ? '...'
        : hasError
        ? '-'
        : totalCount.toString();
    final displayInStock = isLoading
        ? '...'
        : hasError
        ? '-'
        : inStockCount.toString();
    final displayLowOrOut = isLoading
        ? '...'
        : hasError
        ? '-'
        : lowOrOutCount.toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.get('stock', locale),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              InkWell(
                key: const Key('dashboard_manage_stock_link'),
                onTap: () =>
                    Navigator.of(context).pushNamed(AuthRoutes.partnerStock),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Text(
                    AppStrings.get('manage_stock', locale),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Listed',
                  value: displayTotal,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'In Stock',
                  value: displayInStock,
                  color: AppColors.successGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Low / Out',
                  value: displayLowOrOut,
                  color: !isLoading && !hasError && lowOrOutCount > 0
                      ? AppColors.warningYellow
                      : AppColors.textLight,
                ),
              ),
            ],
          ),
          if (hasError) ...[
            const SizedBox(height: 8),
            const Text(
              'Unable to load inventory data',
              style: TextStyle(fontSize: 11, color: AppColors.errorRed),
            ),
          ] else if (totalCount == 0 && !isLoading) ...[
            const SizedBox(height: 8),
            Text(
              AppStrings.get('no_stock', locale),
              style: const TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        subtitle,
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
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
