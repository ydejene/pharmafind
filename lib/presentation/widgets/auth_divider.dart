import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }
}
