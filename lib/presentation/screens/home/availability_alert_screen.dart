import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/auth_routes.dart';
import '../../bloc/alert/alert_cubit.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../utils/auth_navigation.dart';

class AvailabilityAlertScreen extends StatefulWidget {
  const AvailabilityAlertScreen({
    super.key,
    this.query,
  });

  final String? query;

  @override
  State<AvailabilityAlertScreen> createState() {
    return _AvailabilityAlertScreenState();
  }
}

class _AvailabilityAlertScreenState
    extends State<AvailabilityAlertScreen> {
  final _formKey = GlobalKey<FormState>();

  final _areaController = TextEditingController(
    text: 'Kigali, Rwanda',
  );

  @override
  void initState() {
    super.initState();

    // clearing the result from the previously created alert
    context.read<AlertCubit>().reset();
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  // saving the alert for the current user
  void _saveAlert(
      BuildContext context,
      String medicine,
      ) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      AuthNavigation.toLogin(context);
      return;
    }

    context.read<AlertCubit>().createAlert(
      userId: authState.user.uid,
      medicineName: medicine,
      searchArea: _areaController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<SettingsCubit>().state.locale;
    final authState = context.watch<AuthBloc>().state;

    final medicine = widget.query?.trim().isNotEmpty == true
        ? widget.query!.trim()
        : AppStrings.get('medicine', locale);

    return BlocConsumer<AlertCubit, AlertState>(
      listener: (context, state) {
        // showing an error when the alert cannot be saved
        if (state.status == AlertStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    AppStrings.get('error', locale),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      builder: (context, alertState) {
        if (alertState.status == AlertStatus.saved) {
          return _AlertSavedView(
            medicine: medicine,
            locale: locale,
          );
        }

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            title: Text(
              AppStrings.get('notify_me', locale),
            ),
            centerTitle: true,
            backgroundColor: AppColors.cream,
            foregroundColor: AppColors.textDark,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                30,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // showing the selected medicine
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.darkGreen,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2414291F),
                            blurRadius: 20,
                            offset: Offset(0, 9),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active_outlined,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            AppStrings.get(
                              'get_alert',
                              locale,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            medicine,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.lightOrange,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.get(
                              'alert_desc',
                              locale,
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // selecting the area where the medicine should be found
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get(
                              'search_area',
                              locale,
                            ),
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _areaController,
                            textCapitalization:
                            TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: AppStrings.get(
                                'area_hint',
                                locale,
                              ),
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return 'Enter your search area';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: AppColors.textLight,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppStrings.get(
                                    'alert_note',
                                    locale,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    if (authState is! AuthAuthenticated)
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            AuthNavigation.toLogin(context);
                          },
                          icon: const Icon(Icons.login),
                          label: Text(
                            AppStrings.get(
                              'sign_in',
                              locale,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                          alertState.status ==
                              AlertStatus.loading
                              ? null
                              : () {
                            _saveAlert(
                              context,
                              medicine,
                            );
                          },
                          icon:
                          alertState.status ==
                              AlertStatus.loading
                              ? const SizedBox(
                            width: 19,
                            height: 19,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons.notifications_active_outlined,
                          ),
                          label: Text(
                            alertState.status ==
                                AlertStatus.loading
                                ? 'Saving...'
                                : AppStrings.get(
                              'save_notify',
                              locale,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
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

// showing confirmation after the alert has been saved
class _AlertSavedView extends StatelessWidget {
  final String medicine;
  final String locale;

  const _AlertSavedView({
    required this.medicine,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: AppColors.stockGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.successGreen,
                  size: 46,
                ),
              ),
              const SizedBox(height: 26),
              Text(
                AppStrings.get(
                  'search_saved',
                  locale,
                ),
                style: const TextStyle(
                  color: AppColors.accentOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppStrings.get(
                  'notify_confirmed',
                  locale,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${AppStrings.get('watching_desc', locale)} '
                    '$medicine'
                    '${AppStrings.get('hear_from_us', locale)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AuthRoutes.home,
                          (route) => false,
                    );
                  },
                  child: Text(
                    AppStrings.get(
                      'return_home',
                      locale,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}