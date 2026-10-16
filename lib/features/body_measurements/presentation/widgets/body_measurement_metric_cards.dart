import 'package:flutter/material.dart';
import 'package:motion_orbit/features/body_measurements/domain/entities/body_measurement.dart';
import 'package:motion_orbit/features/profile/presentation/widgets/profile_module_widgets.dart';

import 'body_measurement_form_widgets.dart';
import '../utils/body_measurement_formatters.dart';

class CoreMeasurementCard extends StatelessWidget {
  const CoreMeasurementCard({super.key, 
    required this.label,
    required this.icon,
    required this.value,
    required this.unit,
    required this.imperial,
    this.previous,
  });

  final String label;
  final IconData icon;
  final double? value;
  final double? previous;
  final String unit;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shown = value == null ? null : convertLength(value!, imperial);
    final delta = value != null && previous != null
        ? convertLength(value! - previous!, imperial)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ProfileCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            Text(
              shown?.toStringAsFixed(1) ?? '—',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(width: 5),
            Text(unit, style: TextStyle(fontSize: 11)),
            if (delta != null) ...[
              const SizedBox(width: 8),
              MeasurementChangePill(
                change: delta,
                unit: unit,
                imperial: imperial,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdvancedMetricsCard extends StatelessWidget {
  const AdvancedMetricsCard({super.key, 
    required this.latest,
    required this.expanded,
    required this.imperial,
    required this.onToggle,
  });

  final BodyMeasurement latest;
  final bool expanded;
  final bool imperial;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ProfileCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.accessibility_new,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Advanced Metrics',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        'Circumferences & Composition',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                AdvancedMetricTile(
                  label: 'Biceps',
                  value: latest.leftArmCm,
                  unit: imperial ? 'in' : 'cm',
                  imperial: imperial,
                  icon: Icons.fitness_center,
                ),
                AdvancedMetricTile(
                  label: 'Thigh',
                  value: latest.leftThighCm,
                  unit: imperial ? 'in' : 'cm',
                  imperial: imperial,
                  icon: Icons.directions_run,
                ),
                AdvancedMetricTile(
                  label: 'Body Fat',
                  value: latest.bodyFatPercent,
                  unit: '%',
                  source: latest.bodyFatSource,
                  icon: Icons.sync,
                ),
                AdvancedMetricTile(
                  label: 'Muscle Mass',
                  value: latest.muscleMassKg,
                  unit: imperial ? 'lb' : 'kg',
                  imperial: imperial,
                  weight: true,
                  icon: Icons.edit_note,
                ),
              ],
            ),
          ),
      ],
    ),
  );
  }
}

class AdvancedMetricTile extends StatelessWidget {
  const AdvancedMetricTile({super.key, 
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.imperial = false,
    this.weight = false,
    this.source,
  });

  final String label;
  final double? value;
  final String unit;
  final IconData icon;
  final bool imperial;
  final bool weight;
  final String? source;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final converted = value == null
        ? null
        : imperial
        ? value! / (weight ? 0.45359237 : 2.54)
        : value!;

    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 78) / 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(icon, size: 15, color: colors.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(
                  converted == null
                      ? '—'
                      : '${converted.toStringAsFixed(1)} $unit',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            if (source != null)
              Text(
                source!,
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
