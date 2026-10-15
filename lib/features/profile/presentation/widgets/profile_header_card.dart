import 'package:flutter/material.dart';

import '../profile_colors.dart';
import 'profile_svg_icon.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.level,
    required this.goal,
    required this.onEdit,
  });

  final String name;
  final String level;
  final String goal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: ProfileColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -54,
            right: -55,
            child: Container(
              width: 144,
              height: 144,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1FDAE2FD),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/profile/profile_portrait.jpeg',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          semanticLabel: 'Profile portrait',
                        ),
                      ),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: ProfileColors.green,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 9,
                            height: 11,
                            child: ProfileSvgIcon.asset(ProfileSvgIcon.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name.isEmpty ? 'Your Profile' : name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: ProfileColors.textPrimary,
                                  fontSize: 20,
                                  height: 28 / 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: onEdit,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 11,
                                      height: 11,
                                      child: ProfileSvgIcon.asset(
                                        ProfileSvgIcon.edit,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: ProfileColors.blue,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _ProfileBadge(
                              icon: ProfileSvgIcon.beginner,
                              label: level,
                              color: ProfileColors.beginner,
                            ),
                            _ProfileBadge(
                              icon: ProfileSvgIcon.goal,
                              label: goal,
                              color: const Color(0xFFDBE1FF),
                              textColor: const Color(0xFF003EA8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 16,
                      child: ProfileSvgIcon.asset(ProfileSvgIcon.offline),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Offline profile • Stored on this device',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ProfileColors.textSecondary,
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Saved',
                      style: TextStyle(
                        color: ProfileColors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.icon,
    required this.label,
    required this.color,
    this.textColor = const Color(0xFF3F465C),
  });

  final String icon;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 11, height: 11, child: ProfileSvgIcon.asset(icon)),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              height: 14 / 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
