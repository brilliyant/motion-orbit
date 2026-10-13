import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/motion_orbit_logo.dart';
import '../../../../../core/widgets/primary_button.dart';

class StepWelcomeView extends StatelessWidget {
  const StepWelcomeView({
    super.key,
    required this.onGetStarted,
  });

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Offline Trust Badge & Status Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 14, color: AppColors.outlineFocus),
                  SizedBox(width: 6),
                  Text(
                    'Offline Native • Private',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.successBase,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'v1.0 Ready',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hero & Orbital Core Section
        Center(
          child: SizedBox(
            width: 280,
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Orbital background rings & glowing halo
                const Positioned.fill(
                  child: CustomPaint(
                    painter: HeroOrbitBackgroundPainter(isWelcome: true),
                  ),
                ),
                // Motion Orbit Logo with Elevation Frame
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x332563EB),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceBase,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: MotionOrbitLogoMark(size: 60),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Wordmark & Tagline
        const Text(
          'Motion Orbit',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Train Smart. Move Better.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(height: 20),

        // Core Mission Statement Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Text(
            'Plan workouts, track your sets, and optionally check your exercise form with on-device AI.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 3 Micro-Pillars Grid
        const Row(
          children: [
            Expanded(
              child: _WelcomePillar(
                icon: Icons.fitness_center,
                iconColor: AppColors.outlineFocus,
                title: 'Plan Sets',
                subtitle: 'Log weights',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _WelcomePillar(
                icon: Icons.phonelink_lock,
                iconColor: AppColors.tertiary,
                title: 'Local Data',
                subtitle: 'No accounts',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _WelcomePillar(
                icon: Icons.view_in_ar,
                iconColor: AppColors.secondary,
                title: 'Form Vision',
                subtitle: 'On-device',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Primary CTA Button
        PrimaryButton(
          label: 'Get Started',
          icon: Icons.arrow_forward,
          onPressed: onGetStarted,
        ),
        const SizedBox(height: 12),

        // Secondary Hint Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, size: 14, color: AppColors.tertiary),
                SizedBox(width: 6),
                Text(
                  'Works offline. No account required.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomePillar extends StatelessWidget {
  const _WelcomePillar({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

