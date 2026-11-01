import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class PharmaFindLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const PharmaFindLogo({super.key, this.size = 40, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.white, size: size * 0.55),
              Positioned(
                right: size * 0.12,
                top: size * 0.12,
                child: Icon(Icons.add, color: Colors.white, size: size * 0.25),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.bold,
              ),
              children: const [
                TextSpan(
                  text: 'Pharma',
                  style: TextStyle(color: AppColors.cream),
                ),
                TextSpan(
                  text: 'Find',
                  style: TextStyle(color: AppColors.accentOrange),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class PharmaFindLogoDark extends StatelessWidget {
  final double size;

  const PharmaFindLogoDark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.accentOrange,
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.white, size: size * 0.55),
              Positioned(
                right: size * 0.12,
                top: size * 0.12,
                child: Icon(Icons.add, color: Colors.white, size: size * 0.25),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.bold,
            ),
            children: const [
              TextSpan(
                text: 'Pharma',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
              TextSpan(
                text: 'Find',
                style: TextStyle(color: AppColors.accentOrange),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
