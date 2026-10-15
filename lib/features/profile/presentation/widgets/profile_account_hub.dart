import 'package:flutter/material.dart';

import '../profile_colors.dart';
import 'profile_svg_icon.dart';

class ProfileAccountHub extends StatelessWidget {
  const ProfileAccountHub({super.key, required this.onDestinationSelected});

  final ValueChanged<String> onDestinationSelected;

  static const _items = [
    _ProfileHubItem(
      title: 'Personal Information',
      subtitle: 'Personal details & training preferences',
      icon: ProfileSvgIcon.personalInformation,
      destination: 'Personal Information',
    ),
    _ProfileHubItem(
      title: 'Fitness Assessment',
      subtitle: 'Strength, endurance & mobility',
      icon: ProfileSvgIcon.fitnessAssessment,
      destination: 'Fitness Assessment',
    ),
    _ProfileHubItem(
      title: 'Body Measurements',
      subtitle: 'Weight & body dimensions',
      icon: ProfileSvgIcon.bodyMeasurements,
      destination: 'Body Measurements',
    ),
    _ProfileHubItem(
      title: 'Progress',
      subtitle: 'Body & performance trends',
      icon: ProfileSvgIcon.progress,
      destination: 'Progress',
    ),
    _ProfileHubItem(
      title: 'Goals',
      subtitle: 'Targets & milestones',
      icon: ProfileSvgIcon.goals,
      destination: 'Goals',
    ),
    _ProfileHubItem(
      title: 'Settings',
      subtitle: 'Preferences & data management',
      icon: ProfileSvgIcon.settings,
      destination: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'ACCOUNT HUB',
                  style: TextStyle(
                    color: ProfileColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              Text(
                'Offline-first',
                style: TextStyle(
                  color: ProfileColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
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
          child: Column(
            children: [
              for (var index = 0; index < _items.length; index++) ...[
                _ProfileHubRow(
                  item: _items[index],
                  onTap: () => onDestinationSelected(_items[index].destination),
                ),
                if (index != _items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1, color: ProfileColors.divider),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHubItem {
  const _ProfileHubItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.destination,
  });

  final String title;
  final String subtitle;
  final String icon;
  final String destination;
}

class _ProfileHubRow extends StatelessWidget {
  const _ProfileHubRow({required this.item, required this.onTap});

  final _ProfileHubItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ProfileColors.divider,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: ProfileSvgIcon.asset(item.icon),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProfileColors.textPrimary,
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ProfileColors.textSecondary,
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 7,
                  height: 11,
                  child: ProfileSvgIcon.asset(ProfileSvgIcon.chevronRight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
