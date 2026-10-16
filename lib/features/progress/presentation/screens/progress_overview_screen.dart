import 'package:flutter/material.dart';

import 'package:motion_orbit/features/profile/data/datasources/profile_records_data_source.dart';
import 'package:motion_orbit/features/profile/data/models/profile_records.dart';
import 'package:motion_orbit/features/profile/presentation/profile_colors.dart';
import 'package:motion_orbit/features/profile/presentation/widgets/profile_module_widgets.dart';

class ProgressOverviewScreen extends StatefulWidget {
  const ProgressOverviewScreen({super.key, required this.records});
  final ProfileRecordsDataSource records;

  @override
  State<ProgressOverviewScreen> createState() => _ProgressOverviewScreenState();
}

class _ProgressOverviewScreenState extends State<ProgressOverviewScreen> {
  String _range = 'All time';

  @override
  Widget build(BuildContext context) {
    final cutoff = switch (_range) {
      '30 days' => DateTime.now().subtract(const Duration(days: 30)),
      '90 days' => DateTime.now().subtract(const Duration(days: 90)),
      _ => DateTime(2000),
    };
    final assessments = widget.records.assessments().where((item) => !item.date.isBefore(cutoff)).toList();
    final measurements = widget.records.measurements().where((item) => !item.date.isBefore(cutoff)).toList();
    final loggedItems = assessments.length + measurements.length;
    return ProfileModuleScaffold(
      title: 'Progress Overview',
      child: ProfileModuleBody(children: [
        const Text('Your progress', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Trends are based on records saved on this device.', style: TextStyle(color: ProfileColors.textSecondary)),
        const SizedBox(height: 14),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '30 days', label: Text('30 days')),
            ButtonSegment(value: '90 days', label: Text('90 days')),
            ButtonSegment(value: 'All time', label: Text('All time')),
          ],
          selected: {_range},
          onSelectionChanged: (value) => setState(() => _range = value.first),
        ),
        const SizedBox(height: 16),
        ProfileCard(child: Row(children: [
          const Icon(Icons.bookmarks_outlined, color: ProfileColors.blue, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text('$loggedItems saved ${loggedItems == 1 ? 'entry' : 'entries'} in $_range', style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary))),
        ])),
        const SizedBox(height: 18),
        const ProfileSectionTitle('Performance'),
        if (assessments.isEmpty)
          const ProfileEmptyState(title: 'No performance data in this range', message: 'Save assessments to see comparisons here.', icon: Icons.show_chart)
        else ..._assessmentTrends(assessments),
        const SizedBox(height: 16),
        const ProfileSectionTitle('Body measurements'),
        if (measurements.isEmpty)
          const ProfileEmptyState(title: 'No measurement data in this range', message: 'Log measurements to see changes over time.', icon: Icons.straighten)
        else ..._measurementTrends(measurements),
        const SizedBox(height: 12),
        const Text('Training session data is not available in this build. Workout logs alone do not establish changes in muscle mass.', style: TextStyle(fontSize: 12, color: ProfileColors.textSecondary)),
      ]),
    );
  }

  List<Widget> _assessmentTrends(List<AssessmentRecord> items) {
    final groups = <String, List<AssessmentRecord>>{};
    for (final item in items) { groups.putIfAbsent(item.test, () => []).add(item); }
    return groups.entries.map((entry) {
      final latest = entry.value.first;
      final earliest = entry.value.last;
      final delta = latest.value - earliest.value;
      final unit = switch (latest.metric) { AssessmentMetric.repetitions => 'reps', AssessmentMetric.seconds => 'sec', AssessmentMetric.meters => 'm' };
      return Padding(padding: const EdgeInsets.only(bottom: 8), child: ProfileCard(child: Row(children: [
        Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary))),
        Text('${latest.value.toStringAsFixed(1)} $unit', style: const TextStyle(color: ProfileColors.textPrimary)),
        if (entry.value.length > 1) ...[
          const SizedBox(width: 10),
          Text('${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} $unit', style: const TextStyle(color: ProfileColors.blue, fontWeight: FontWeight.w700)),
        ],
      ])));
    }).toList();
  }

  List<Widget> _measurementTrends(List<MeasurementRecord> items) {
    final fields = <String, double? Function(MeasurementRecord)>{
      'Weight': (item) => item.weightKg,
      'Waist': (item) => item.waistCm,
      'Chest': (item) => item.chestCm,
      'Hips': (item) => item.hipsCm,
    };
    return fields.entries.map((field) {
      final values = items.where((item) => field.value(item) != null).toList();
      if (values.isEmpty) return const SizedBox.shrink();
      final latest = field.value(values.first)!;
      final delta = values.length > 1 ? latest - field.value(values.last)! : null;
      return Padding(padding: const EdgeInsets.only(bottom: 8), child: ProfileCard(child: Row(children: [
        Expanded(child: Text(field.key, style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary))),
        Text('${latest.toStringAsFixed(1)} ${field.key == 'Weight' ? 'kg' : 'cm'}', style: const TextStyle(color: ProfileColors.textPrimary)),
        if (delta != null) ...[
          const SizedBox(width: 10),
          Text('${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} ${field.key == 'Weight' ? 'kg' : 'cm'}', style: const TextStyle(color: ProfileColors.blue, fontWeight: FontWeight.w700)),
        ],
      ])));
    }).toList();
  }
}

