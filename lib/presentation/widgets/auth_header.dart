import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'pharmafind_logo.dart';

class AuthHeader extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? subtitle;

  const AuthHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        theme.brightness == Brightness.dark
            ? const PharmaFindLogo(size: 44)
            : const PharmaFindLogoDark(size: 44),
        const SizedBox(height: 32),
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
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textLight,
            ),
          ),
        ],
      ],
    );
  }
}
