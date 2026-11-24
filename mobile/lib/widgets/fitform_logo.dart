import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FitformLogo extends StatelessWidget {
  final double fontSize;
  final double letterSpacing;
  final bool showIcon;

  const FitformLogo({
    super.key,
    this.fontSize = 32,
    this.letterSpacing = 2.0,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showIcon) ...[
          Icon(
            Icons.fitness_center_rounded,
            color: AppColors.spinachGreenLight,
            size: fontSize * 0.85,
          ),
          SizedBox(width: fontSize * 0.3),
        ],
        RichText(
          text: TextSpan(
            style: AppTypography.bebasNeue(
              fontSize: fontSize,
              letterSpacing: letterSpacing,
            ),
            children: const [
              TextSpan(
                text: 'FIT',
                style: TextStyle(color: AppColors.textWhite),
              ),
              TextSpan(
                text: 'FORM',
                style: TextStyle(color: AppColors.spinachGreenLight),
              ),
              TextSpan(
                text: '.',
                style: TextStyle(color: AppColors.spinachGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
