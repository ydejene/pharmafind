import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/auth_routes.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/settings/settings_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _avatarAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // setting up the simple page entrance animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // making the profile avatar appear with a small scale animation
    _avatarAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0,
        0.7,
        curve: Curves.easeOutBack,
      ),
    );

    // moving the page content slightly upward when it opens
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // getting the first letter for the profile avatar
  String _getInitial(String name, String email) {
    if (name.trim().isNotEmpty) {
      return name.trim()[0].toUpperCase();
    }

    if (email.trim().isNotEmpty) {
      return email.trim()[0].toUpperCase();
    }

    return 'U';
  }

  // returning not set when the user has no insurance provider
  String _insuranceName(String? provider, String notSet) {
    if (provider == null || provider.trim().isEmpty) {
      return notSet;
    }

    return provider;
  }

  // showing the saved insurance information
  void _showInsuranceDetails({
    required BuildContext context,
    required String locale,
    required String provider,
    required String insuranceId,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.health_and_safety_outlined,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        AppStrings.get(
                          'medical_insurance',
                          locale,
                        ),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _InsuranceDetail(
                  icon: Icons.apartment_rounded,
                  label: AppStrings.get(
                    'provider',
                    locale,
                  ),
                  value: provider,
                ),
                const SizedBox(height: 20),
                _InsuranceDetail(
                  icon: Icons.badge_outlined,
                  label: AppStrings.get(
                    'member_policy_number',
                    locale,
                  ),
                  value: insuranceId.isEmpty
                      ? AppStrings.get(
                    'not_provided',
                    locale,
                  )
                      : insuranceId,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // closing the sheet before opening edit profile
                      Navigator.pop(sheetContext);
                      Navigator.of(context).pushNamed('/edit-profile');
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 19,
                    ),
                    label: Text(
                      AppStrings.get(
                        'edit_details',
                        locale,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // asking the user before logging out
  void _confirmLogout(
      BuildContext context,
      String locale,
      ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            AppStrings.get(
              'logout_title',
              locale,
            ),
          ),
          content: Text(
            AppStrings.get(
              'logout_message',
              locale,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppStrings.get(
                  'cancel',
                  locale,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // sending the logout request to the authentication bloc
                context.read<AuthBloc>().add(
                  AuthLogoutRequested(),
                );
              },
              child: Text(
                AppStrings.get(
                  'logout',
                  locale,
                ),
                style: const TextStyle(
                  color: AppColors.errorRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // showing a message when the user is not logged in
        if (state is! AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                AppStrings.get('profile', locale),
              ),
            ),
            body: Center(
              child: Text(
                AppStrings.get(
                  'login_required',
                  locale,
                ),
              ),
            ),
          );
        }

        final user = state.user;
        final notSet = AppStrings.get('not_set', locale);

        final insurance = _insuranceName(
          user.insuranceProvider,
          notSet,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppStrings.get('profile', locale),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: colorScheme.onSurface,
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
                  children: [
                    // showing the user details at the top of the page
                    ScaleTransition(
                      scale: _avatarAnimation,
                      child: _ProfileHeader(
                        initial: _getInitial(
                          user.displayName,
                          user.email,
                        ),
                        name: user.displayName,
                        email: user.email,
                        defaultName: AppStrings.get(
                          'default_user',
                          locale,
                        ),
                        editLabel: AppStrings.get(
                          'edit_profile',
                          locale,
                        ),
                        onEdit: () {
                          Navigator.of(context).pushNamed('/edit-profile');
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // showing the account options
                    _ProfileSection(
                      title: AppStrings.get(
                        'account',
                        locale,
                      ),
                      children: [
                        _MenuTile(
                          icon: Icons.person_outline_rounded,
                          title: AppStrings.get(
                            'edit_profile',
                            locale,
                          ),
                          subtitle: AppStrings.get(
                            'update_personal_info',
                            locale,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed('/edit-profile');
                          },
                        ),
                        _MenuTile(
                          icon: Icons.health_and_safety_outlined,
                          title: AppStrings.get(
                            'insurance_info',
                            locale,
                          ),
                          subtitle: insurance,
                          onTap: () {
                            _showInsuranceDetails(
                              context: context,
                              locale: locale,
                              provider: insurance,
                              insuranceId: user.insuranceId ?? '',
                            );
                          },
                        ),
                        if (user.isPartner)
                          _MenuTile(
                            icon: Icons.dashboard_outlined,
                            title: AppStrings.get(
                              'partner_dashboard',
                              locale,
                            ),
                            subtitle: AppStrings.get(
                              'partner_portal',
                              locale,
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AuthRoutes.partnerDashboard);
                            },
                          )
                        else
                          _MenuTile(
                            icon: Icons.storefront_outlined,
                            title: AppStrings.get(
                              'register_pharmacy',
                              locale,
                            ),
                            subtitle: 'Register your pharmacy profile',
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AuthRoutes.partnerSignup);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // showing language and notification preferences
                    _ProfileSection(
                      title: AppStrings.get(
                        'preferences',
                        locale,
                      ),
                      children: [
                        _MenuTile(
                          icon: Icons.language_rounded,
                          title: AppStrings.get(
                            'language',
                            locale,
                          ),
                          subtitle: AppStrings.get(
                            'choose_language_preference',
                            locale,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed('/language');
                          },
                        ),
                        _MenuTile(
                          icon: Icons.notifications_none_rounded,
                          title: AppStrings.get(
                            'notifications',
                            locale,
                          ),
                          subtitle: AppStrings.get(
                            'manage_alerts',
                            locale,
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                        ),
                        _MenuTile(
                          icon: Icons.notifications_active_outlined,
                          title: AppStrings.get(
                            'notify_me',
                            locale,
                          ),
                          subtitle: 'Create medicine availability alerts',
                          onTap: () {
                            Navigator.of(context).pushNamed('/notify');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // showing help and information about the app
                    _ProfileSection(
                      title: AppStrings.get(
                        'app',
                        locale,
                      ),
                      children: [
                        _MenuTile(
                          icon: Icons.help_outline_rounded,
                          title: AppStrings.get(
                            'help',
                            locale,
                          ),
                          subtitle: AppStrings.get(
                            'help_desc',
                            locale,
                          ),
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: Text(
                                    AppStrings.get(
                                      'help',
                                      locale,
                                    ),
                                  ),
                                  content: Text(
                                    AppStrings.get(
                                      'details_help',
                                      locale,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                      },
                                      child: Text(
                                        AppStrings.get(
                                          'ok',
                                          locale,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        _MenuTile(
                          icon: Icons.info_outline_rounded,
                          title: AppStrings.get(
                            'about',
                            locale,
                          ),
                          subtitle: AppStrings.get(
                            'about_desc',
                            locale,
                          ),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: AppStrings.get(
                                'app_name',
                                locale,
                              ),
                              applicationLegalese: AppStrings.get(
                                'tagline',
                                locale,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // logging the user out of the application
                    TextButton.icon(
                      onPressed: () {
                        _confirmLogout(
                          context,
                          locale,
                        );
                      },
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 20,
                      ),
                      label: Text(
                        AppStrings.get(
                          'logout',
                          locale,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// showing the main user information inside the profile header
class _ProfileHeader extends StatelessWidget {
  final String initial;
  final String name;
  final String email;
  final String defaultName;
  final String editLabel;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.initial,
    required this.name,
    required this.email,
    required this.defaultName,
    required this.editLabel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          name.trim().isEmpty ? defaultName : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 17),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(
            Icons.edit_outlined,
            size: 17,
          ),
          label: Text(
            editLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryGreen,
            side: BorderSide(
              color: AppColors.primaryGreen.withValues(alpha: 0.28),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 11,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }
}

// grouping related profile options without adding visible lines
class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            bottom: 10,
          ),
          child: Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

// creating one clean option inside a profile section
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.09),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: AppColors.primaryGreen,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// showing one saved insurance value
class _InsuranceDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InsuranceDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: colorScheme.onSurfaceVariant,
          size: 21,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
