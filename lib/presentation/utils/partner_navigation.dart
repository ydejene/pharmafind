import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/auth_routes.dart';
import '../../domain/entities/pharmacy_entity.dart';
import '../bloc/pharmacy/pharmacy_cubit.dart';

/// Centralized navigation helper for partner status-aware routing.
class PartnerNavigation {
  PartnerNavigation._();

  /// Determines the appropriate destination route for a partner based on their
  /// persisted pharmacy record and verification status:
  ///
  /// - Partner has no pharmacy profile -> [AuthRoutes.partnerProfile]
  /// - Profile exists but documents unsubmitted -> [AuthRoutes.partnerLicense]
  /// - Documents submitted and status is pending -> [AuthRoutes.partnerPending]
  /// - Status is rejected -> [AuthRoutes.partnerRejected]
  /// - Status is approved -> [AuthRoutes.partnerDashboard]
  static String getPartnerDestination(PharmacyEntity? pharmacy) {
    if (pharmacy == null || pharmacy.id.isEmpty) {
      return AuthRoutes.partnerProfile;
    }
    if (pharmacy.submittedAt == null ||
        pharmacy.licenseUrl == null ||
        pharmacy.licenseUrl!.isEmpty ||
        pharmacy.rmohCertUrl == null ||
        pharmacy.rmohCertUrl!.isEmpty) {
      return AuthRoutes.partnerLicense;
    }
    if (pharmacy.isApproved) {
      return AuthRoutes.partnerDashboard;
    }
    if (pharmacy.isResubmittedAwaitingReview) {
      return AuthRoutes.partnerPending;
    }
    if (pharmacy.isRejected) {
      return AuthRoutes.partnerRejected;
    }
    return AuthRoutes.partnerPending;
  }

  /// Resolves the partner destination using [PharmacyCubit], loading the pharmacy
  /// for [userId] if necessary, and navigates.
  static Future<void> routePartner(
    BuildContext context,
    String userId, {
    bool replace = true,
  }) async {
    final cubit = context.read<PharmacyCubit>();
    var state = cubit.state;

    // Check if valid data already exists for THIS user
    final hasDataForUser = state.pharmacy != null &&
        state.pharmacy!.ownerId == userId &&
        state.status == PharmacyStatus.loaded;

    final isKnownNoPharmacy = state.status == PharmacyStatus.noPharmacy &&
        state.pharmacy == null;

    if (!hasDataForUser && !isKnownNoPharmacy) {
      if (state.status == PharmacyStatus.loading) {
        // A fetch is already in progress - wait for its completion
        try {
          state = await cubit.stream
              .firstWhere((s) => s.status != PharmacyStatus.loading)
              .timeout(const Duration(seconds: 10));
        } catch (_) {
          state = cubit.state;
        }
      } else {
        // No fetch in progress or data was for another user; trigger load
        await cubit.loadPharmacy(userId);
        if (!context.mounted) return;
        state = context.read<PharmacyCubit>().state;
      }
    }

    if (!context.mounted) return;

    // Distinguish fetch failure from genuinely missing record
    if (state.status == PharmacyStatus.error) {
      final errorMsg = state.errorMessage ?? 'Failed to load pharmacy details.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.errorRed,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () {
              if (context.mounted) {
                routePartner(context, userId, replace: replace);
              }
            },
          ),
        ),
      );
      return;
    }

    // Guard against stale data from another user if cubit wasn't reset
    if (state.pharmacy != null && state.pharmacy!.ownerId != userId) {
      await cubit.loadPharmacy(userId);
      if (!context.mounted) return;
      state = context.read<PharmacyCubit>().state;
      if (state.status == PharmacyStatus.error) {
        final errorMsg = state.errorMessage ?? 'Failed to load pharmacy details.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }
    }

    final destination = getPartnerDestination(state.pharmacy);
    if (!context.mounted) return;

    if (replace) {
      Navigator.of(context).pushReplacementNamed(destination);
    } else {
      Navigator.of(context).pushNamed(destination);
    }
  }
}
