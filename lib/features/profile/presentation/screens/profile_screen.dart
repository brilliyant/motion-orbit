import 'package:flutter/material.dart';

import '../../domain/entities/user_profile.dart';
import '../profile_colors.dart';
import '../widgets/profile_account_hub.dart';
import '../widgets/profile_bottom_navigation_bar.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_metric_card.dart';
import '../widgets/profile_svg_icon.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.profile,
    required this.selectedTab,
    required this.onEditProfile,
    required this.onTabSelected,
    required this.onOpenDestination,
    this.latestMeasurement,
  });

  final UserProfile profile;
  final int selectedTab;
  final VoidCallback onEditProfile;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<String> onOpenDestination;
  final double? latestMeasurement;

  @override
  Widget build(BuildContext context) {
    final name = profile.name.trim();
    final weight = _weightValue(latestMeasurement?.toString() ?? profile.weight);
    final height = _heightValue(profile.height);

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: ProfileColors.background,
      ),
      child: Scaffold(
        backgroundColor: ProfileColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _ProfileTopBar(name: name),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      children: [
                        ProfileHeaderCard(
                          name: name,
                          level: profile.level ?? 'Level not set',
                          goal: profile.goal ?? 'Goal not set',
                          onEdit: onEditProfile,
                        ),
                        const SizedBox(height: 24),
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
                            const Expanded(
                              child: ProfileMetricCard(
                                label: 'WORKOUTS',
                                icon: ProfileSvgIcon.workout,
                                value: '—',
                                unit: '',
                                caption: 'No session data yet',
                                valueColor: ProfileColors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const _ConsistencyCard(),
                        const SizedBox(height: 24),
                        ProfileAccountHub(
                          onDestinationSelected: (destination) =>
                              onOpenDestination(destination),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ProfileBottomNavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: onTabSelected,
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

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ProfileColors.surface.withValues(alpha: 0.96),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/profile/motion_orbit_logo.png',
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            semanticLabel: 'Motion Orbit',
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Motion Orbit',
              style: TextStyle(
                color: ProfileColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Semantics(
            label: name.isEmpty ? 'Profile' : '$name profile',
            image: true,
            child: ClipOval(
              child: Image.asset(
                'assets/profile/profile_portrait.jpeg',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsistencyCard extends StatelessWidget {
  const _ConsistencyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              SizedBox(
                width: 14,
                height: 16,
                child: ProfileSvgIcon.asset(ProfileSvgIcon.flame),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Consistency Orbit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ProfileColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'No sessions yet',
                style: TextStyle(
                  color: ProfileColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0,
              minHeight: 8,
              backgroundColor: ProfileColors.divider,
              valueColor: AlwaysStoppedAnimation(ProfileColors.blue),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Log workouts to build your streak',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ProfileColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                'Not tracked yet',
                style: TextStyle(color: ProfileColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
