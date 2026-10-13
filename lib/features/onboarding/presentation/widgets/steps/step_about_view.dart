import 'package:flutter/material.dart';

import '../../../../../core/constants/profile_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../profile/data/models/profile_model.dart';

class StepAboutView extends StatelessWidget {
  const StepAboutView({
    super.key,
    required this.profile,
    required this.nameController,
    required this.heightController,
    required this.weightController,
    required this.heightError,
    required this.weightError,
    required this.isEditing,
    required this.onChanged,
    required this.onValidateAnthropometrics,
    required this.onContinue,
    required this.onBack,
  });

  final LocalProfile profile;
  final TextEditingController nameController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final String? heightError;
  final String? weightError;
  final bool isEditing;
  final void Function(VoidCallback change) onChanged;
  final VoidCallback onValidateAnthropometrics;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header & Friendly Framing
        Row(
          children: [
            const Text(
              'About You',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.waving_hand, size: 22, color: AppColors.primaryLight),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Customize your profile. All details are stored locally on your device.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),

        // Offline Privacy Delight Micro-Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.security, size: 16, color: AppColors.tertiary),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Zero cloud required. ',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: 'No accounts, trackers, or hidden sign-ups.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Field 1: Display Name
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.badge, size: 16, color: AppColors.textTertiary),
                SizedBox(width: 6),
                Text(
                  'Display Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'Optional',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: nameController,
            maxLength: 24,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              color: Color.fromRGBO(248, 250, 252, 1),
              fontSize: 16,
            ),
            buildCounter: (_,
                    {required currentLength,
                    required isFocused,
                    maxLength}) =>
                null,
            decoration: const InputDecoration(
              hintText: 'e.g. Alex',
              hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 15),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (v) => onChanged(() => profile.name = v),
          ),
        ),
        const SizedBox(height: 16),

        // Field 2: Age Range Selector
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month,
                    size: 16, color: AppColors.textTertiary),
                SizedBox(width: 6),
                Text(
                  'Age Range',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              'Optional',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Select an age bracket to contextualize recovery baselines',
          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 8),
        Row(
          children: ProfileConstants.ages.map((age) {
            final isSelected = profile.age == age;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onChanged(() {
                    profile.age = isSelected ? null : age;
                  }),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceContainerLow,
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
                    child: Center(
                      child: Text(
                        age,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Anthropometrics (Height & Weight Side-by-side)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Height (cm)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Height',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Opt',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: const InputDecoration(
                              hintText: '175',
                              hintStyle: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (v) {
                              onChanged(() => profile.height = v);
                              onValidateAnthropometrics();
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'CM',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (heightError != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.error,
                            size: 12, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          'Valid: 80–250 cm',
                          style: TextStyle(
                              color: AppColors.error, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Weight (kg)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Opt',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: const InputDecoration(
                              hintText: '72',
                              hintStyle: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (v) {
                              onChanged(() => profile.weight = v);
                              onValidateAnthropometrics();
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'KG',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (weightError != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.error,
                            size: 12, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          'Valid: 30–300 kg',
                          style: TextStyle(
                              color: AppColors.error, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Helper info box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, size: 16, color: AppColors.secondary),
              SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Optional ',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text:
                            '— used to calibrate workout volume and energy metrics locally. You can update or purge this anytime in Settings.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Warm Visual Affirmation Card (Offline Anchor)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF222A3D),
                      Color(0xFF0F172A),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.fitness_center,
                    size: 24,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Pace, Your Control',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Skip whatever you like. Motion Orbit never locks workouts behind missing fields.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action Buttons
        PrimaryButton(
          label: 'Continue',
          icon: Icons.arrow_forward,
          onPressed: onContinue,
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back,
              size: 16,
              color: AppColors.textSecondary,
            ),
            label: Text(
              isEditing ? 'Back to Profile' : 'Back to Welcome',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

