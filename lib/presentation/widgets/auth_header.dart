import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String? eyebrow;
  final String title;

  const AuthHeader({super.key, this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: AppColors.accentOrange,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
