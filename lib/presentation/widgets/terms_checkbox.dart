import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String locale;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text.rich(
              TextSpan(
                text: AppStrings.get('i_agree_to', locale),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                ),
                children: [
                  TextSpan(
                    text: AppStrings.get('terms_of_service', locale),
                    style: const TextStyle(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' ${AppStrings.get('and', locale)} ',
                  ),
                  TextSpan(
                    text: AppStrings.get('privacy_policy', locale),
                    style: const TextStyle(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
