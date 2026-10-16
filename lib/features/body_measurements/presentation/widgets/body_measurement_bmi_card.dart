import 'package:flutter/material.dart';
import 'package:motion_orbit/features/profile/presentation/profile_colors.dart';
import 'package:motion_orbit/features/profile/presentation/widgets/profile_module_widgets.dart';

class ReferenceBmiCard extends StatelessWidget {
  const ReferenceBmiCard({super.key, required this.bmi});

  final double? bmi;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = switch (bmi) {
      null => 'Add height in Personal Information',
      < 18.5 => 'Below reference range',
      < 25 => 'Normal (Reference)',
      < 30 => 'Above reference range',
      _ => 'High (Reference)',
    };

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.balance, color: ProfileColors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reference BMI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (bmi != null)
                Chip(
                  label: Text(label, style: TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
            ],
          ),
          if (bmi != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  bmi!.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(width: 5),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('kg/m²'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: 25,
                    child: SizedBox.expand(
                      child: ColoredBox(color: Color(0xFFF59E0B)),
                    ),
                  ),
                  Expanded(
                    flex: 35,
                    child: SizedBox.expand(
                      child: ColoredBox(color: ProfileColors.green),
                    ),
                  ),
                  Expanded(
                    flex: 25,
                    child: SizedBox.expand(
                      child: ColoredBox(color: Color(0xFFF59E0B)),
                    ),
                  ),
                  Expanded(
                    flex: 15,
                    child: SizedBox.expand(
                      child: ColoredBox(color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '18.5',
                style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
              ),
              Text(
                '24.9',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              Text(
                '29.9',
                style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: .7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 15,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    bmi == null ? label : 'BMI is a mathematical height-to-weight reference, not a direct clinical indicator of body composition or athletic fitness.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
