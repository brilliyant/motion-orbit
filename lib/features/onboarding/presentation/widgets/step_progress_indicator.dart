import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (step == 1) ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STEP 1 OF 3',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  '33% Completed',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ] else if (step == 2) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'STEP 2 OF 3',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.offline_pin,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'On-device',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SETUP PROGRESS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Step 3 of 3',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),

          // 3-Segmented Progress Track
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: step >= 2
                        ? AppColors.primary
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: step >= 2
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: step >= 3
                        ? AppColors.primary
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: step >= 3
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

