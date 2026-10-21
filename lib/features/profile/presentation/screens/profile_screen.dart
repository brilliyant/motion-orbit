import 'package:flutter/material.dart';

import '../../domain/entities/user_profile.dart';
import '../widgets/profile_account_hub.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_metric_card.dart';
import '../widgets/profile_svg_icon.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onEditProfile,
    required this.onOpenDestination,
    this.latestMeasurement,
  });

  final UserProfile profile;
  final VoidCallback onEditProfile;
  final ValueChanged<String> onOpenDestination;
  final double? latestMeasurement;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = profile.name.trim();
    final weight = _weightValue(
      latestMeasurement?.toString() ?? profile.weight,
    );
    final height = _heightValue(profile.height);

    return SafeArea(
      bottom: false,
      child: Center(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const SizedBox(height: 12),
            ProfileHeaderCard(
              name: name,
              level: profile.level ?? 'Level not set',
              goal: profile.goal ?? 'Goal not set',
              onEdit: onEditProfile,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ProfileMetricCard(
                    label: 'WEIGHT',
                    icon: ProfileSvgIcon.weight,
                    value: weight,
                    unit: weight == '—' ? '' : 'kg',
                    caption: weight == '—'
                        ? 'Add in profile'
                        : latestMeasurement == null
                        ? 'Profile value'
                        : 'Latest measurement',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ProfileMetricCard(
                    label: 'HEIGHT',
                    icon: ProfileSvgIcon.height,
                    value: height,
                    unit: height == '—' ? '' : 'cm',
                    caption: height == '—'
                        ? 'Add in profile'
                        : 'Profile standard',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ProfileMetricCard(
                    label: 'WORKOUTS',
                    icon: ProfileSvgIcon.workout,
                    value: '—',
                    unit: '',
                    caption: 'No session data yet',
                    valueColor: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _ConsistencyCard(),
            const SizedBox(height: 12),
            ProfileAccountHub(
              onDestinationSelected: (destination) =>
                  onOpenDestination(destination),
            ),
          ],
        ),
      ),
    );
  }

  static String _weightValue(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return '—';
    final parsed = double.tryParse(normalized);
    return parsed == null ? normalized : parsed.toStringAsFixed(1);
  }

  static String _heightValue(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return '—';
    final parsed = double.tryParse(normalized);
    if (parsed == null) return normalized;
    return parsed == parsed.roundToDouble()
        ? parsed.toInt().toString()
        : parsed.toString();
  }
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
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
          Row(
            children: [
              SizedBox(
                width: 14,
                height: 16,
                child: ProfileSvgIcon.asset(ProfileSvgIcon.flame),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Consistency Orbit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'No sessions yet',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 8,
              backgroundColor: colors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Log workouts to build your streak',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Not tracked yet',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
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
