import 'package:flutter/material.dart';

import '../../../../../core/constants/profile_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../profile/data/models/profile_model.dart';

class StepPreferencesView extends StatelessWidget {
  const StepPreferencesView({
    super.key,
    required this.profile,
    required this.isEditing,
    required this.onChanged,
    required this.onFinish,
    required this.onBack,
  });

  final LocalProfile profile;
  final bool isEditing;
  final void Function(VoidCallback change) onChanged;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    const equipmentItems = [
      (key: 'Bodyweight', icon: Icons.accessibility_new),
      (key: 'Dumbbells', icon: Icons.fitness_center),
      (key: 'Barbell', icon: Icons.sports_gymnastics),
      (key: 'Resistance Band', icon: Icons.all_inclusive),
    ];

    final daysCountText = profile.days.isEmpty
        ? 'None selected'
        : '${profile.days.length} day${profile.days.length > 1 ? 's' : ''} / week';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Your Workout Preferences',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Set your routine preferences or skip to customize later.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        // Offline & Privacy Trust Ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.cloud_off, size: 16, color: AppColors.tertiary),
              SizedBox(width: 8),
              Text(
                'Stored locally on this device • Private & offline ready',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section 1: Training Location
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Training Location',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Optional',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: ProfileConstants.locations.map((loc) {
              final isSelected = profile.location == loc;
              final IconData locIcon = switch (loc) {
                'Home' => Icons.home,
                'Gym' => Icons.fitness_center,
                _ => Icons.sync_alt,
              };
              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(() {
                    profile.location = isSelected ? null : loc;
                  }),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surfaceContainerHighest
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          locIcon,
                          size: 16,
                          color: isSelected
                              ? AppColors.outlineFocus
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          loc,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Section 2: Available Equipment
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Equipment',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Select any',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: equipmentItems.map((item) {
            final isSelected = profile.equipment.contains(item.key);
            return InkWell(
              onTap: () => onChanged(() {
                if (isSelected) {
                  profile.equipment.remove(item.key);
                } else {
                  profile.equipment.add(item.key);
                }
              }),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      size: 16,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.key,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check,
                          size: 14, color: AppColors.textPrimary),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Section 3: Preferred Workout Days
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Preferred Workout Days',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              daysCountText,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(7, (i) {
            final fullDay = ProfileConstants.dayKeys[i];
            final isSelected = profile.days.contains(fullDay);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: InkWell(
                  onTap: () => onChanged(() {
                    if (isSelected) {
                      profile.days.remove(fullDay);
                    } else {
                      profile.days.add(fullDay);
                    }
                  }),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ProfileConstants.dayInitials[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.textPrimary.withValues(alpha: 0.8)
                                : AppColors.textSecondary
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          ProfileConstants.dayLabels[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Section 4: Preferred Session Duration
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preferred Session Duration',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Estimated target',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _DurationPill(
                    duration: ProfileConstants.durations[0],
                    isSelected:
                        profile.duration == ProfileConstants.durations[0],
                    onTap: () => onChanged(() {
                      profile.duration =
                          profile.duration == ProfileConstants.durations[0]
                              ? null
                              : ProfileConstants.durations[0];
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DurationPill(
                    duration: ProfileConstants.durations[1],
                    isSelected:
                        profile.duration == ProfileConstants.durations[1],
                    onTap: () => onChanged(() {
                      profile.duration =
                          profile.duration == ProfileConstants.durations[1]
                              ? null
                              : ProfileConstants.durations[1];
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DurationPill(
                    duration: ProfileConstants.durations[2],
                    isSelected:
                        profile.duration == ProfileConstants.durations[2],
                    onTap: () => onChanged(() {
                      profile.duration =
                          profile.duration == ProfileConstants.durations[2]
                              ? null
                              : ProfileConstants.durations[2];
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DurationPill(
                    duration: ProfileConstants.durations[3],
                    isSelected:
                        profile.duration == ProfileConstants.durations[3],
                    onTap: () => onChanged(() {
                      profile.duration =
                          profile.duration == ProfileConstants.durations[3]
                              ? null
                              : ProfileConstants.durations[3];
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Clarification Notice Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info, size: 18, color: AppColors.secondary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Preferences help tailor your exercise filters and do not enforce a strict schedule. You maintain total control over your workouts.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action Buttons
        PrimaryButton(
          label: isEditing ? 'Save Profile' : 'Finish Setup',
          icon: Icons.arrow_forward,
          onPressed: onFinish,
        ),
        if (!isEditing) ...[
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: onFinish,
              child: const Text(
                'Skip for Now',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        Center(
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back,
              size: 16,
              color: AppColors.textSecondary,
            ),
            label: const Text(
              'Back',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DurationPill extends StatelessWidget {
  const _DurationPill({
    required this.duration,
    required this.isSelected,
    required this.onTap,
  });

  final String duration;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 18,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.textPrimary,
              ),
          ],
        ),
      ),
    );
  }
}

