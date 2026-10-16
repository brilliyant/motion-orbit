import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motion_orbit/features/body_measurements/domain/entities/body_measurement.dart';
import 'package:motion_orbit/features/body_measurements/domain/usecases/body_measurement_use_cases.dart';
import 'package:motion_orbit/features/profile/presentation/profile_colors.dart';
import 'package:motion_orbit/features/profile/presentation/widgets/profile_module_widgets.dart';

import '../utils/body_measurement_formatters.dart';
import '../widgets/body_measurement_form_widgets.dart';

class AddBodyMeasurementScreen extends StatefulWidget {
  const AddBodyMeasurementScreen({
    super.key,
    required this.saveMeasurement,
    this.previous,
  });

  final SaveBodyMeasurement saveMeasurement;
  final BodyMeasurement? previous;

  @override
  State<AddBodyMeasurementScreen> createState() =>
      _AddBodyMeasurementScreenState();
}

class _AddBodyMeasurementScreenState extends State<AddBodyMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'weightKg': TextEditingController(),
    'waistCm': TextEditingController(),
    'hipsCm': TextEditingController(),
    'chestCm': TextEditingController(),
    'leftArmCm': TextEditingController(),
    'leftThighCm': TextEditingController(),
    'bodyFatPercent': TextEditingController(),
    'muscleMassKg': TextEditingController(),
  };
  DateTime _date = DateTime.now();
  bool _imperial = false;
  bool _optionalExpanded = true;
  String _bodyFatSource = 'Manual Entry';

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected != null) setState(() => _date = selected);
  }

  double? _value(String key) {
    final text = _controllers[key]!.text.trim();
    if (text.isEmpty) return null;
    final parsed = double.parse(text.replaceAll(',', '.'));
    if (!_imperial) return parsed;
    if (key == 'weightKg' || key == 'muscleMassKg') return parsed * 0.45359237;
    if (key == 'bodyFatPercent') return parsed;
    return parsed * 2.54;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final hasValues = _controllers.values.any(
      (controller) => controller.text.trim().isNotEmpty,
    );
    if (!hasValues) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one measurement.')),
      );
      return;
    }
    widget.saveMeasurement(
      BodyMeasurement(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: _date,
        weightKg: _value('weightKg'),
        waistCm: _value('waistCm'),
        hipsCm: _value('hipsCm'),
        chestCm: _value('chestCm'),
        leftArmCm: _value('leftArmCm'),
        leftThighCm: _value('leftThighCm'),
        bodyFatPercent: _value('bodyFatPercent'),
        muscleMassKg: _value('muscleMassKg'),
        bodyFatSource: _bodyFatSource,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final weightText = _controllers['weightKg']!.text.trim().replaceAll(
      ',',
      '.',
    );
    final enteredWeight = double.tryParse(weightText);
    final weightChange =
        enteredWeight == null || widget.previous?.weightKg == null
        ? null
        : convertWeight(
            (_imperial ? enteredWeight * 0.45359237 : enteredWeight) -
                widget.previous!.weightKg!,
            _imperial,
          );
    return ProfileModuleScaffold(
      title: 'Add Body Measurement',
      followAppTheme: true,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: colors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: Icon(Icons.check, size: 20),
                  label: const Text('Save Measurement'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          children: [
            MeasurementUnitRibbon(imperial: _imperial),
            const SizedBox(height: 12),
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Measurement Date',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              formatMeasurementDate(_date),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.calendar_today_outlined,
                            color: ProfileColors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Choose the day these measurements were taken.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ProfileCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        color: ProfileColors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Core Measurements',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      if (weightChange != null)
                        MeasurementChangePill(
                          change: weightChange,
                          unit: _imperial ? 'lb' : 'kg',
                          imperial: _imperial,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MeasurementInputField(
                    controller: _controllers['weightKg']!,
                    label: 'Current Body Weight',
                    unit: _imperial ? 'lb' : 'kg',
                    hero: true,
                    previous: widget.previous?.weightKg == null
                        ? null
                        : 'Previous: ${convertWeight(widget.previous!.weightKg!, _imperial).toStringAsFixed(1)} ${_imperial ? 'lb' : 'kg'}',
                    onChanged: (_) => setState(() {}),
                    max: 500,
                  ),
                  const SizedBox(height: 12),
                  MeasurementInputField(
                    controller: _controllers['waistCm']!,
                    label: 'Waist Circumference',
                    hint: 'Navel height',
                    unit: _imperial ? 'in' : 'cm',
                    max: 300,
                  ),
                  const SizedBox(height: 10),
                  MeasurementInputField(
                    controller: _controllers['hipsCm']!,
                    label: 'Hip Circumference',
                    hint: 'Widest gluteal point',
                    unit: _imperial ? 'in' : 'cm',
                    max: 300,
                  ),
                  const SizedBox(height: 10),
                  MeasurementInputField(
                    controller: _controllers['chestCm']!,
                    label: 'Chest Circumference',
                    hint: 'Sternum level',
                    unit: _imperial ? 'in' : 'cm',
                    max: 300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ProfileCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  InkWell(
                    onTap: () =>
                        setState(() => _optionalExpanded = !_optionalExpanded),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.straighten,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Optional Measurements',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.onSurface,
                                  ),
                                ),
                                Text(
                                  'Limbs & Body Composition Breakdown',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _optionalExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_optionalExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: MeasurementInputField(
                                  controller: _controllers['leftArmCm']!,
                                  label: 'Biceps',
                                  unit: _imperial ? 'in' : 'cm',
                                  hint: 'e.g. 32.5',
                                  max: 100,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: MeasurementInputField(
                                  controller: _controllers['leftThighCm']!,
                                  label: 'Thigh',
                                  unit: _imperial ? 'in' : 'cm',
                                  hint: 'e.g. 56.0',
                                  max: 150,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Body Fat Percentage',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      initialValue: _bodyFatSource,
                                      onSelected: (value) => setState(
                                        () => _bodyFatSource = value,
                                      ),
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'Manual Entry',
                                          child: Text('Manual Entry'),
                                        ),
                                        PopupMenuItem(
                                          value: 'Smart Scale',
                                          child: Text('Smart Scale'),
                                        ),
                                      ],
                                      child: Chip(
                                        label: Text(
                                          _bodyFatSource,
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor:
                                            colors.surfaceContainerLow,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                MeasurementInputField(
                                  controller: _controllers['bodyFatPercent']!,
                                  label: '',
                                  unit: '%',
                                  hint: 'e.g. 15.2',
                                  max: 100,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          MeasurementInputField(
                            controller: _controllers['muscleMassKg']!,
                            label: 'Estimated Muscle Mass',
                            unit: _imperial ? 'lb' : 'kg',
                            hint: 'e.g. 34.8',
                            max: 300,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            MeasurementPrivacyNote(
              text: 'Self-measured dimensions are recorded for personal progress comparison and stored locally on this device.',
            ),
          ],
        ),
      ),
    );
  }
}
