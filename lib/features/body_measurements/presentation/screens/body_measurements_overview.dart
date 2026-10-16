import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motion_orbit/features/body_measurements/domain/entities/body_measurement.dart';
import 'package:motion_orbit/features/body_measurements/domain/usecases/body_measurement_use_cases.dart';
import 'package:motion_orbit/features/profile/domain/entities/user_profile.dart';
import 'package:motion_orbit/features/profile/presentation/widgets/profile_module_widgets.dart';

import '../utils/body_measurement_formatters.dart';
import 'add_body_measurement_screen.dart';
import '../widgets/body_measurement_form_widgets.dart';
import '../widgets/body_measurement_bmi_card.dart';
import '../widgets/body_measurement_history_card.dart';
import '../widgets/body_measurement_metric_cards.dart';
import '../widgets/body_measurement_trend.dart';
import '../widgets/body_measurement_weight_card.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({
    super.key,
    required this.getMeasurements,
    required this.saveMeasurement,
    required this.profile,
  });

  final GetBodyMeasurements getMeasurements;
  final SaveBodyMeasurement saveMeasurement;
  final UserProfile profile;

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  late List<BodyMeasurement> _items;
  bool _imperial = false;
  bool _advancedExpanded = false;
  bool _showHistory = true;

  @override
  void initState() {
    super.initState();
    _items = widget.getMeasurements();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(
        () => _imperial =
            preferences.getString('motion_orbit/profile_units') == 'imperial',
      );
    }
  }

  Future<void> _addMeasurement() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AddBodyMeasurementScreen(
          saveMeasurement: widget.saveMeasurement,
          previous: _items.isEmpty ? null : _items.first,
        ),
      ),
    );
    if (mounted) setState(() => _items = widget.getMeasurements());
  }

  @override
  Widget build(BuildContext context) {
    final latest = _items.isEmpty ? null : _items.first;
    final previous = _items.length > 1 ? _items[1] : null;
    final weight = latest?.weightKg;
    final previousWeight = previous?.weightKg;
    final heightCm = double.tryParse(
      widget.profile.height.trim().replaceAll(',', '.'),
    );
    final bmi = weight != null && heightCm != null && heightCm > 0
        ? weight / ((heightCm / 100) * (heightCm / 100))
        : null;
    final shownWeight = weight == null
        ? null
        : convertWeight(weight, _imperial);
    final weightChange = weight != null && previousWeight != null
        ? convertWeight(weight - previousWeight, _imperial)
        : null;

    return ProfileModuleScaffold(
      title: 'Biometric Details',
      followAppTheme: true,
      child: ProfileModuleBody(
        children: [
          if (latest == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: ProfileEmptyState(
                title: 'Start tracking your measurements',
                message: 'Add a dated measurement to see your weight, BMI, and progress here.',
                icon: Icons.monitor_weight_outlined,
              ),
            ),
          if (latest == null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _addMeasurement,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Measurement'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
          if (latest != null) ...[
            BodyMeasurementWeightHero(
              record: latest,
              value: shownWeight!,
              unit: _imperial ? 'lb' : 'kg',
              change: weightChange,
              imperial: _imperial,
              onAddMeasurement: _addMeasurement,
              onToggleHistory: () =>
                  setState(() => _showHistory = !_showHistory),
            ),
            const SizedBox(height: 14),
            ReferenceBmiCard(bmi: bmi),
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(child: ProfileSectionTitle('Core Measurements')),
                TextButton(
                  onPressed: () => setState(() => _showHistory = !_showHistory),
                  child: Text(_showHistory ? 'Latest' : 'History'),
                ),
              ],
            ),
            CoreMeasurementCard(
              label: 'Waist',
              icon: Icons.straighten,
              value: latest.waistCm,
              previous: previous?.waistCm,
              unit: _imperial ? 'in' : 'cm',
              imperial: _imperial,
            ),
            CoreMeasurementCard(
              label: 'Hip',
              icon: Icons.straighten,
              value: latest.hipsCm,
              previous: previous?.hipsCm,
              unit: _imperial ? 'in' : 'cm',
              imperial: _imperial,
            ),
            CoreMeasurementCard(
              label: 'Chest',
              icon: Icons.straighten,
              value: latest.chestCm,
              previous: previous?.chestCm,
              unit: _imperial ? 'in' : 'cm',
              imperial: _imperial,
            ),
            CoreMeasurementCard(
              label: 'Height',
              icon: Icons.height,
              value: heightCm,
              unit: _imperial ? 'in' : 'cm',
              imperial: _imperial,
            ),
            const SizedBox(height: 8),
            AdvancedMetricsCard(
              latest: latest,
              expanded: _advancedExpanded,
              imperial: _imperial,
              onToggle: () =>
                  setState(() => _advancedExpanded = !_advancedExpanded),
            ),
            const SizedBox(height: 14),
            MeasurementPrivacyNote(
              text: 'Your body measurements are stored locally on this device and are only used for your personal progress comparison.',
            ),
            const SizedBox(height: 16),
            WeightTrendCard(items: _items, imperial: _imperial),
            if (_showHistory) ...[
              const SizedBox(height: 18),
              const ProfileSectionTitle('Measurement History'),
              for (final item in _items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MeasurementHistoryCard(
                    item: item,
                    imperial: _imperial,
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
