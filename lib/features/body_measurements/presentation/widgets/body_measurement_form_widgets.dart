import 'package:flutter/material.dart';
import 'package:motion_orbit/features/profile/presentation/profile_colors.dart';

class MeasurementInputField extends StatelessWidget {
  const MeasurementInputField({super.key, 
    required this.controller,
    required this.label,
    required this.unit,
    this.hint,
    this.previous,
    this.hero = false,
    this.max = 500,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String unit;
  final String? hint;
  final String? previous;
  final bool hero;
  final double max;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty || hint != null || previous != null)
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            if (hint != null)
              Text(
                hint!,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),
            if (previous != null)
              Text(
                previous!,
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      if (label.isNotEmpty || hint != null || previous != null)
        const SizedBox(height: 5),
      TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(
          fontSize: hero ? 26 : 16,
          fontWeight: hero ? FontWeight.w700 : FontWeight.w500,
          color: colors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          suffixText: unit,
          filled: true,
          fillColor: hero ? colors.surface : colors.surfaceContainerHighest,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: hero ? 13 : 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: ProfileColors.blue, width: 1.5),
          ),
        ),
        validator: (text) {
          if ((text ?? '').trim().isEmpty) return null;
          final number = double.tryParse(text!.trim().replaceAll(',', '.'));
          if (number == null || !number.isFinite || number <= 0 || number > max) {
            return 'Enter a valid value.';
          }
          return null;
        },
      ),
    ],
  );
  }
}

class MeasurementChangePill extends StatelessWidget {
  const MeasurementChangePill({super.key, 
    required this.change,
    required this.unit,
    required this.imperial,
  });
  final double change;
  final String unit;
  final bool imperial;
  @override
  Widget build(BuildContext context) {
    final down = change < 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            down ? Icons.trending_down : Icons.trending_up,
            size: 14,
            color: ProfileColors.green,
          ),
          const SizedBox(width: 3),
          Text(
            '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: ProfileColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class MeasurementUnitRibbon extends StatelessWidget {
  const MeasurementUnitRibbon({super.key, required this.imperial});
  final bool imperial;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    decoration: BoxDecoration(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(Icons.tune, size: 17, color: ProfileColors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Units: ${imperial ? 'Imperial (lb / in)' : 'Metric (kg / cm)'}',
            style: TextStyle(
              fontSize: 12,
            color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          'Adjust in Settings  ›',
          style: TextStyle(fontSize: 10, color: ProfileColors.blue),
        ),
      ],
    ),
  );
  }
}

class MeasurementPrivacyNote extends StatelessWidget {
  const MeasurementPrivacyNote({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 17,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
  }
}
