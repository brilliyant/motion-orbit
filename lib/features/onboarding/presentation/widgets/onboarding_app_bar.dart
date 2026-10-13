import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/motion_orbit_logo.dart';

class OnboardingAppBar extends StatelessWidget {
  const OnboardingAppBar({
    super.key,
    required this.step,
    required this.onBack,
  });

  final int step;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final title = switch (step) {
      1 => 'Body Profile',
      2 => 'Goal Selection',
      _ => 'Equipment Calibration',
    };

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          bottom: BorderSide(
            color: Color(0x1AFFFFFF),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: 'Back',
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
          const MotionOrbitLogoMark(size: 26),
          const SizedBox(width: 8),
          const Text(
            'MOTION ORBIT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 18,
                color: Color(0xFF002A78),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

