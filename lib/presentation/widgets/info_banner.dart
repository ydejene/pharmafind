import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

enum BannerType { info, warning, success, error }

class InfoBanner extends StatelessWidget {
  final String message;
  final BannerType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const InfoBanner({
    super.key,
    required this.message,
    this.type = BannerType.info,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: _textColor),
            ),
          ),
          if (onAction != null && actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  color: _iconColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 18, color: _iconColor),
            ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case BannerType.info:
        return AppColors.primaryGreen.withValues(alpha: 0.08);
      case BannerType.warning:
        return AppColors.accentOrange.withValues(alpha: 0.08);
      case BannerType.success:
        return AppColors.successGreen.withValues(alpha: 0.08);
      case BannerType.error:
        return AppColors.errorRed.withValues(alpha: 0.08);
    }
  }

  Color get _borderColor {
    switch (type) {
      case BannerType.info:
        return AppColors.primaryGreen.withValues(alpha: 0.2);
      case BannerType.warning:
        return AppColors.accentOrange.withValues(alpha: 0.2);
      case BannerType.success:
        return AppColors.successGreen.withValues(alpha: 0.2);
      case BannerType.error:
        return AppColors.errorRed.withValues(alpha: 0.2);
    }
  }

  Color get _iconColor {
    switch (type) {
      case BannerType.info:
        return AppColors.primaryGreen;
      case BannerType.warning:
        return AppColors.accentOrange;
      case BannerType.success:
        return AppColors.successGreen;
      case BannerType.error:
        return AppColors.errorRed;
    }
  }

  Color get _textColor {
    switch (type) {
      case BannerType.info:
      case BannerType.warning:
      case BannerType.success:
      case BannerType.error:
        return AppColors.textDark;
    }
  }

  IconData get _icon {
    switch (type) {
      case BannerType.info:
        return Icons.info_outline;
      case BannerType.warning:
        return Icons.warning_amber_outlined;
      case BannerType.success:
        return Icons.check_circle_outline;
      case BannerType.error:
        return Icons.error_outline;
    }
  }
}
