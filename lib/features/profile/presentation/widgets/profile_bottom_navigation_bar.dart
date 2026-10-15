import 'package:flutter/material.dart';

import '../profile_colors.dart';
import 'profile_svg_icon.dart';

class ProfileBottomNavigationBar extends StatelessWidget {
  const ProfileBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _destinations = [
    _ProfileNavigationItem(label: 'Home', icon: ProfileSvgIcon.home),
    _ProfileNavigationItem(label: 'Training', icon: ProfileSvgIcon.training),
    _ProfileNavigationItem(label: 'Explore', icon: ProfileSvgIcon.explore),
    _ProfileNavigationItem(label: 'Profile', icon: ProfileSvgIcon.profile),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: ProfileColors.surface.withValues(alpha: 0.97),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var index = 0; index < _destinations.length; index++)
              _ProfileNavigationDestination(
                item: _destinations[index],
                selected: selectedIndex == index,
                onTap: () => onDestinationSelected(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileNavigationItem {
  const _ProfileNavigationItem({required this.label, required this.icon});

  final String label;
  final String icon;
}

class _ProfileNavigationDestination extends StatelessWidget {
  const _ProfileNavigationDestination({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _ProfileNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 80,
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? ProfileColors.paleBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: ProfileSvgIcon.asset(item.icon),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  color: selected
                      ? ProfileColors.blue
                      : ProfileColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
