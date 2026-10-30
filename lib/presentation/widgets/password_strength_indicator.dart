import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/password_strength.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = PasswordStrengthChecker.check(password);
    final label = PasswordStrengthChecker.label(strength);
    final color = _colorForStrength(strength);
    final filled = _filledBars(strength);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: index < filled ? color : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForStrength(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.errorRed;
      case PasswordStrength.fair:
        return AppColors.accentOrange;
      case PasswordStrength.strong:
        return AppColors.successGreen;
    }
  }

  int _filledBars(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 1;
      case PasswordStrength.fair:
        return 2;
      case PasswordStrength.strong:
        return 3;
    }
  }
}
