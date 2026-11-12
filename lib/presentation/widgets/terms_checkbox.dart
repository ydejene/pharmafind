import 'package:flutter/gestures.dart';
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
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 13, color: AppColors.textLight),
              children: [
                TextSpan(text: AppStrings.get('accept_terms', locale).split(AppStrings.get('terms_link', locale)).first),
                TextSpan(
                  text: AppStrings.get('terms_link', locale),
                  style: const TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                TextSpan(text: ' ${AppStrings.get('and', locale)} '),
                TextSpan(
                  text: AppStrings.get('privacy_link', locale),
                  style: const TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
