import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/auth_routes.dart';
import '../../../domain/entities/pharmacy_entity.dart';
import '../../../domain/entities/stock_item_entity.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/pharmacy/pharmacy_cubit.dart';
import '../../bloc/settings/settings_cubit.dart';

/// Screen for managing pharmacy partner medicine stock.
///
/// **Architecture & Access Control:**
/// - Uses pure domain entities ([StockItemEntity], [PharmacyEntity]).
/// - Interacts strictly with [PharmacyCubit] use-case methods:
///   [PharmacyCubit.addStockItem], [PharmacyCubit.updateStockItem],
///   [PharmacyCubit.deleteStockItem], and [PharmacyCubit.refreshStock].
/// - Enforces role-based access: requires authenticated partner account.
/// - Requires an approved pharmacy record associated with the authenticated partner.
/// - Synchronizes with real-time stock stream and supports pull-to-refresh.
/// - Validates required fields, price (> 0), and quantity (>= 0).
/// - Enforces explicit deletion confirmation.
class PartnerStockScreen extends StatefulWidget {
  const PartnerStockScreen({super.key});

  @override
  State<PartnerStockScreen> createState() => _PartnerStockScreenState();
}

class _PartnerStockScreenState extends State<PartnerStockScreen> {
  bool _isRedirecting = false;

  void _checkAndRedirect(PharmacyEntity? pharmacy) {
    if (_isRedirecting || !mounted || pharmacy == null) return;
    if (pharmacy.isApproved) return;

    // Incomplete documents check: do not redirect to pending
    final hasUnsubmittedDocs = pharmacy.submittedAt == null ||
        pharmacy.licenseUrl == null ||
        pharmacy.licenseUrl!.isEmpty ||
        pharmacy.rmohCertUrl == null ||
        pharmacy.rmohCertUrl!.isEmpty;
    if (hasUnsubmittedDocs) return;

    if (pharmacy.status == 'pending' || pharmacy.isResubmittedAwaitingReview) {
      _isRedirecting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AuthRoutes.partnerPending);
        }
      });
    } else if (pharmacy.isRejected) {
      _isRedirecting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AuthRoutes.partnerRejected);
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final pharmacyState = context.read<PharmacyCubit>().state;

    if (authState is AuthAuthenticated && authState.user.isPartner) {
      final pharmacy = pharmacyState.pharmacy;
      final isStale = pharmacy != null && pharmacy.ownerId != authState.user.uid;
      if ((isStale || pharmacy == null) &&
          pharmacyState.status != PharmacyStatus.loading) {
        context.read<PharmacyCubit>().loadPharmacy(authState.user.uid);
      } else if (pharmacy != null && pharmacy.ownerId == authState.user.uid) {
        if (pharmacy.isApproved) {
          context.read<PharmacyCubit>().subscribeToStock(
            pharmacy.id,
          );
        } else {
          _checkAndRedirect(pharmacy);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final authState = context.watch<AuthBloc>().state;
    final pharmacyState = context.watch<PharmacyCubit>().state;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated && state.user.isPartner) {
              final pState = context.read<PharmacyCubit>().state;
              final isStale = pState.pharmacy != null &&
                  pState.pharmacy!.ownerId != state.user.uid;
              if ((isStale || pState.pharmacy == null) &&
                  pState.status != PharmacyStatus.loading) {
                context.read<PharmacyCubit>().loadPharmacy(state.user.uid);
              } else if (pState.pharmacy != null &&
                  pState.pharmacy!.ownerId == state.user.uid) {
                if (pState.pharmacy!.isApproved) {
                  context.read<PharmacyCubit>().subscribeToStock(
                    pState.pharmacy!.id,
                  );
                } else {
                  _checkAndRedirect(pState.pharmacy);
                }
              }
            }
          },
        ),
        BlocListener<PharmacyCubit, PharmacyState>(
          listener: (context, state) {
            if (state.status == PharmacyStatus.error &&
                state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.errorRed,
                ),
              );
            } else if (state.status == PharmacyStatus.loaded &&
                state.pharmacy != null) {
              final auth = context.read<AuthBloc>().state;
              if (auth is AuthAuthenticated && auth.user.isPartner) {
                if (state.pharmacy!.ownerId == auth.user.uid) {
                  if (state.pharmacy!.isApproved) {
                    context.read<PharmacyCubit>().subscribeToStock(
                      state.pharmacy!.id,
                    );
                  } else {
                    _checkAndRedirect(state.pharmacy);
                  }
                }
              }
            }
          },
        ),
      ],
      child: _buildContent(context, authState, pharmacyState, locale),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AuthState authState,
    PharmacyState pharmacyState,
    String locale,
  ) {
    // 1. Authentication Check
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
                    'Please log in with a partner account to manage medicine stock.',
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

    // 2. Role Check
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
                    'Stock management is reserved for verified pharmacy partner accounts.',
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

    final pharmacy = pharmacyState.pharmacy;
    final isLoading = pharmacyState.status == PharmacyStatus.loading;
    final hasError = pharmacyState.status == PharmacyStatus.error;

    return _buildStockScaffold(
      context,
      authState,
      pharmacyState,
      pharmacy,
      isLoading,
      hasError,
      locale,
    );
  }

  Widget _buildStockScaffold(
    BuildContext context,
    AuthAuthenticated authState,
    PharmacyState pharmacyState,
    PharmacyEntity? pharmacy,
    bool isLoading,
    bool hasError,
    String locale,
  ) {
    // 3. Stale owner check: loaded pharmacy belongs to a different user
    final isStaleOwner =
        pharmacy != null && pharmacy.ownerId != authState.user.uid;
    if (isStaleOwner) {
      if (pharmacyState.status != PharmacyStatus.loading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<PharmacyCubit>().loadPharmacy(authState.user.uid);
          }
        });
      }
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          title: Text(AppStrings.get('manage_stock', locale)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    // 4. Loading state while pharmacy is unresolved
    if ((pharmacyState.status == PharmacyStatus.initial || isLoading) &&
        pharmacy == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          title: Text(AppStrings.get('manage_stock', locale)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    // 5. Pharmacy load error
    if (hasError) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          title: Text(AppStrings.get('manage_stock', locale)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.errorRed,
                ),
                const SizedBox(height: 12),
                Text(
                  pharmacyState.errorMessage ??
                      'Failed to load pharmacy profile',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.errorRed),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<PharmacyCubit>().loadPharmacy(
                    authState.user.uid,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 6. No Pharmacy Registered Check
    if (pharmacy == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          title: Text(AppStrings.get('manage_stock', locale)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    size: 48,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Pharmacy Registered',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You must create your pharmacy profile before managing medicine stock.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMedium),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.of(context)
                          .pushNamed(AuthRoutes.partnerProfile),
                  icon: const Icon(Icons.add_business_outlined),
                  label: Text(AppStrings.get('add_pharmacy_details', locale)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 7. Require strictly approved status to access stock management
    if (!pharmacy.isApproved) {
      // 7a. Incomplete verification documents check (takes precedence over default pending status)
      if (pharmacy.submittedAt == null ||
          pharmacy.licenseUrl == null ||
          pharmacy.licenseUrl!.isEmpty ||
          pharmacy.rmohCertUrl == null ||
          pharmacy.rmohCertUrl!.isEmpty) {
        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            title: Text(AppStrings.get('manage_stock', locale)),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.upload_file_outlined,
                      size: 48,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verification Documents Required',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You must upload your pharmacy license and RMOH certificate before managing medicine stock.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.of(context)
                            .pushNamed(AuthRoutes.partnerLicense),
                    icon: const Icon(Icons.file_upload_outlined),
                    label: const Text('Upload Documents'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // 7b. Pending verification status guard & redirect (only when documents are submitted)
      if (pharmacy.status == 'pending' || pharmacy.isResubmittedAwaitingReview) {
        _checkAndRedirect(pharmacy);
        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            title: Text(AppStrings.get('manage_stock', locale)),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warningYellow.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top,
                      size: 48,
                      color: AppColors.warningYellow,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verification Under Review',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stock management is locked while your pharmacy documents are pending review.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AuthRoutes.partnerPending),
                    child: const Text('View Verification Status'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // 7c. Rejected verification status guard & redirect
      if (pharmacy.isRejected) {
        _checkAndRedirect(pharmacy);
        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            title: Text(AppStrings.get('manage_stock', locale)),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: AppColors.errorRed,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Verification Unsuccessful',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stock management is disabled. Please review the rejection reason and update your documents.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMedium),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AuthRoutes.partnerRejected),
                    child: const Text('Review Rejection Details'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // 7d. Fallback for any other unapproved status
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          title: Text(AppStrings.get('manage_stock', locale)),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Stock management requires an approved pharmacy account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMedium),
            ),
          ),
        ),
      );
    }

    // 8. Approved Pharmacy: Full stock management scaffold

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 16,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  key: const Key('stock_back_button'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('manage_stock', locale),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pharmacy.name,
                        style: const TextStyle(
                          color: AppColors.lightOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('add_stock_header_button'),
                  onPressed: () =>
                      _showAddStockDialog(context, locale, pharmacy),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 26,
                  ),
                  tooltip: AppStrings.get('add_medicine', locale),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: _buildStockContent(
              context,
              pharmacyState,
              pharmacy,
              locale,
              authState.user.uid,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockContent(
    BuildContext context,
    PharmacyState state,
    PharmacyEntity pharmacy,
    String locale,
    String ownerId,
  ) {
    if (state.status == PharmacyStatus.loading && state.stockItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (state.status == PharmacyStatus.error && state.stockItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.errorRed,
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'Failed to load stock items',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorRed),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<PharmacyCubit>().loadStock(pharmacy.id),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.stockItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.textLight.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('no_stock', locale),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add medicine inventory to help nearby patients discover stock availability.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                key: const Key('add_stock_empty_button'),
                onPressed: () => _showAddStockDialog(context, locale, pharmacy),
                icon: const Icon(Icons.add),
                label: Text(AppStrings.get('add_medicine', locale)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () => context.read<PharmacyCubit>().refreshStock(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.stockItems.length,
        itemBuilder: (context, index) {
          final item = state.stockItems[index];
          return _StockItemCard(
            key: Key('stock_item_${item.id}'),
            item: item,
            locale: locale,
            onEdit: () => _showEditStockDialog(context, locale, item),
            onDelete: () => _showDeleteConfirmation(context, item),
          );
        },
      ),
    );
  }

  void _showAddStockDialog(
    BuildContext context,
    String locale,
    PharmacyEntity pharmacy,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    String status = 'in_stock';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get('add_medicine', locale),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('stock_medicine_name_input'),
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('medicine_name', locale),
                      prefixIcon: const Icon(
                        Icons.medication_outlined,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a medicine name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('stock_price_input'),
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${AppStrings.get('price', locale)} (RWF)',
                      prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter price in RWF';
                      }
                      final price = int.tryParse(val.trim());
                      if (price == null || price <= 0) {
                        return 'Price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('stock_quantity_input'),
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('quantity', locale),
                      prefixIcon: const Icon(
                        Icons.inventory_outlined,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter quantity';
                      }
                      final qty = int.tryParse(val.trim());
                      if (qty == null || qty < 0) {
                        return 'Quantity cannot be negative';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('stock_status_dropdown'),
                    initialValue: status,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('status', locale),
                      prefixIcon: const Icon(Icons.info_outline, size: 20),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'in_stock',
                        child: Text('In Stock'),
                      ),
                      DropdownMenuItem(
                        value: 'low_stock',
                        child: Text('Low Stock'),
                      ),
                      DropdownMenuItem(
                        value: 'out_of_stock',
                        child: Text('Out of Stock'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setSheetState(() => status = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      key: const Key('submit_stock_button'),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        final price = int.parse(priceController.text.trim());
                        final qty = int.parse(quantityController.text.trim());
                        final medicineName = nameController.text.trim();

                        final item = StockItemEntity(
                          id: '',
                          pharmacyId: pharmacy.id,
                          pharmacyName: pharmacy.name,
                          pharmacyArea: pharmacy.area,
                          pharmacyPhone: pharmacy.phone,
                          pharmacyHours: pharmacy.hours,
                          pharmacyLat: pharmacy.latitude,
                          pharmacyLng: pharmacy.longitude,
                          medicineName: medicineName,
                          status: status,
                          quantity: qty,
                          price: price,
                          updatedAt: DateTime.now(),
                        );

                        context.read<PharmacyCubit>().addStockItem(item);
                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$medicineName added to stock'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                      child: Text(AppStrings.get('add_medicine', locale)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditStockDialog(
    BuildContext context,
    String locale,
    StockItemEntity item,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: item.medicineName);
    final priceController = TextEditingController(text: item.price.toString());
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    String status = item.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppStrings.get('edit', locale)} ${item.medicineName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('edit_stock_name_input'),
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('medicine_name', locale),
                      prefixIcon: const Icon(
                        Icons.medication_outlined,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a medicine name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('edit_stock_price_input'),
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '${AppStrings.get('price', locale)} (RWF)',
                      prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter price in RWF';
                      }
                      final price = int.tryParse(val.trim());
                      if (price == null || price <= 0) {
                        return 'Price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('edit_stock_quantity_input'),
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('quantity', locale),
                      prefixIcon: const Icon(
                        Icons.inventory_outlined,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter quantity';
                      }
                      final qty = int.tryParse(val.trim());
                      if (qty == null || qty < 0) {
                        return 'Quantity cannot be negative';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: const Key('edit_stock_status_dropdown'),
                    initialValue: status,
                    decoration: InputDecoration(
                      labelText: AppStrings.get('status', locale),
                      prefixIcon: const Icon(Icons.info_outline, size: 20),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'in_stock',
                        child: Text('In Stock'),
                      ),
                      DropdownMenuItem(
                        value: 'low_stock',
                        child: Text('Low Stock'),
                      ),
                      DropdownMenuItem(
                        value: 'out_of_stock',
                        child: Text('Out of Stock'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setSheetState(() => status = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      key: const Key('save_stock_changes_button'),
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        final price = int.parse(priceController.text.trim());
                        final qty = int.parse(quantityController.text.trim());
                        final updatedName = nameController.text.trim();

                        final updated = StockItemEntity(
                          id: item.id,
                          pharmacyId: item.pharmacyId,
                          pharmacyName: item.pharmacyName,
                          pharmacyArea: item.pharmacyArea,
                          pharmacyPhone: item.pharmacyPhone,
                          pharmacyHours: item.pharmacyHours,
                          pharmacyLat: item.pharmacyLat,
                          pharmacyLng: item.pharmacyLng,
                          medicineName: updatedName,
                          status: status,
                          quantity: qty,
                          price: price,
                          updatedAt: DateTime.now(),
                        );

                        context.read<PharmacyCubit>().updateStockItem(updated);
                        Navigator.pop(sheetContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$updatedName updated'),
                            backgroundColor: AppColors.successGreen,
                          ),
                        );
                      },
                      child: Text(AppStrings.get('save_changes', locale)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, StockItemEntity item) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Stock Item'),
        content: Text(
          'Are you sure you want to remove "${item.medicineName}" from your inventory?',
        ),
        actions: [
          TextButton(
            key: const Key('cancel_delete_button'),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm_delete_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<PharmacyCubit>().deleteStockItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item.medicineName}" removed from stock'),
            backgroundColor: AppColors.darkGreen,
          ),
        );
      }
    });
  }
}

class _StockItemCard extends StatelessWidget {
  final StockItemEntity item;
  final String locale;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StockItemCard({
    super.key,
    required this.item,
    required this.locale,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      'in_stock' => AppColors.successGreen,
      'low_stock' => AppColors.warningYellow,
      _ => AppColors.errorRed,
    };

    final statusLabel = switch (item.status) {
      'in_stock' => 'In Stock',
      'low_stock' => 'Low Stock',
      _ => 'Out of Stock',
    };

    final formattedPrice =
        'RWF ${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.medicineName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} ${AppStrings.get('packs', locale)} · $formattedPrice',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            key: Key('edit_item_${item.id}'),
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primaryGreen,
            tooltip: AppStrings.get('edit', locale),
          ),
          IconButton(
            key: Key('delete_item_${item.id}'),
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.errorRed,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
