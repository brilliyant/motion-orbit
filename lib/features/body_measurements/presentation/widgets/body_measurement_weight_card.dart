import 'package:flutter/material.dart';
import 'package:motion_orbit/features/body_measurements/domain/entities/body_measurement.dart';

import 'body_measurement_form_widgets.dart';
import '../utils/body_measurement_formatters.dart';

class BodyMeasurementWeightHero extends StatelessWidget {
  const BodyMeasurementWeightHero({super.key, 
    required this.record,
    required this.value,
    required this.unit,
    required this.change,
    required this.imperial,
    required this.onAddMeasurement,
    required this.onToggleHistory,
  });

  final BodyMeasurement record;
  final double value;
  final String unit;
  final double? change;
  final bool imperial;
  final VoidCallback onAddMeasurement;
  final VoidCallback onToggleHistory;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
    elevation: 1,
    color: Theme.of(context).brightness == Brightness.dark
        ? colors.surfaceContainerLow
        : Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT WEIGHT',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 34,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(unit),
              ),
              const Spacer(),
              if (change != null)
                MeasurementChangePill(
                  change: change!,
                  unit: unit,
                  imperial: imperial,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.history,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Last recorded ${formatMeasurementDate(record.date)}',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAddMeasurement,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add Measurement'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Measurement history',
                onPressed: onToggleHistory,
                icon: const Icon(Icons.calendar_month_outlined),
                style: IconButton.styleFrom(fixedSize: const Size(48, 48)),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}
