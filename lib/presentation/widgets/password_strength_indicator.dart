import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  int get _strength {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*]').hasMatch(password)) score++;
    return score.clamp(0, 4);
  }

  Color get _color => switch (_strength) {
    0 => AppColors.borderLight,
    1 => AppColors.errorRed,
    2 => Colors.orange,
    3 => AppColors.accentOrange,
    _ => AppColors.primaryGreen,
  };

  String get _label => switch (_strength) {
    0 => '',
    1 => 'Weak',
    2 => 'Fair',
    3 => 'Good',
    _ => 'Strong',
  };

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: _strength / 4,
                backgroundColor: AppColors.borderLight,
                color: _color,
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _label,
            style: TextStyle(fontSize: 12, color: _color),
          ),
        ],
      ),
    );
  }
}
