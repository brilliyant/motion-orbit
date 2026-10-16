import 'package:flutter/material.dart';
import 'package:motion_orbit/features/body_measurements/domain/entities/body_measurement.dart';
import 'package:motion_orbit/features/profile/presentation/widgets/profile_module_widgets.dart';

import '../utils/body_measurement_formatters.dart';

class MeasurementHistoryCard extends StatelessWidget {
  const MeasurementHistoryCard({super.key, required this.item, required this.imperial});

  final BodyMeasurement item;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final measurements = <String>[];
    _addValue(
      measurements,
      'Weight',
      item.weightKg,
      'kg',
      imperial,
      weight: true,
    );
    _addValue(measurements, 'Waist', item.waistCm, 'cm', imperial);
    _addValue(measurements, 'Hip', item.hipsCm, 'cm', imperial);
    _addValue(measurements, 'Chest', item.chestCm, 'cm', imperial);
    _addValue(measurements, 'Body fat', item.bodyFatPercent, '%', false);

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatMeasurementDate(item.date),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            measurements.isEmpty
                ? 'No measurements recorded'
                : measurements.join('  •  '),
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
          if (item.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                item.note,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static void _addValue(
    List<String> values,
    String label,
    double? value,
    String unit,
    bool imperial, {
    bool weight = false,
  }) {
    if (value == null) return;
    final shown = imperial ? value / (weight ? 0.45359237 : 2.54) : value;
    final shownUnit = imperial ? (weight ? 'lb' : 'in') : unit;
    values.add('$label ${shown.toStringAsFixed(1)} $shownUnit');
  }
}
