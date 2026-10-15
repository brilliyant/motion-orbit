import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/profile_records_data_source.dart';
import '../../data/models/profile_records.dart';
import '../../data/models/profile_model.dart';
import '../profile_colors.dart';
import '../widgets/profile_module_widgets.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({super.key, required this.records, required this.profile});
  final ProfileRecordsDataSource records;
  final LocalProfile profile;

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  late List<MeasurementRecord> _items;
  bool _imperial = false;

  @override
  void initState() {
    super.initState();
    _items = widget.records.measurements();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) setState(() => _imperial = preferences.getString('motion_orbit/profile_units') == 'imperial');
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() => _items = widget.records.measurements());
  }

  @override
  Widget build(BuildContext context) {
    final latest = _items.isEmpty ? null : _items.first;
    final changes = _items.length > 1
        ? _measurementChanges(_items.first, _items[1], _imperial)
        : const <(String, String)>[];
    final height = double.tryParse(widget.profile.height.trim().replaceAll(',', '.'));
    final bmi = latest?.weightKg != null && height != null && height > 0
        ? latest!.weightKg! / ((height / 100) * (height / 100))
        : null;
    return ProfileModuleScaffold(
      title: 'Body Measurements',
      child: ProfileModuleBody(children: [
        const Text('Track your measurements', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Record dated measurements to review your own changes over time.', style: TextStyle(color: ProfileColors.textSecondary)),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: () => _open(AddBodyMeasurementScreen(records: widget.records)), icon: const Icon(Icons.add), label: const Text('Add measurement')),
        const SizedBox(height: 20),
        if (latest == null)
          const ProfileEmptyState(title: 'No measurements yet', message: 'Your saved measurements will appear here. You can record weight and any dimensions you track.', icon: Icons.straighten)
        else ...[
          ProfileSectionTitle('Latest • ${shortDate(latest.date)}'),
          ProfileCard(child: Column(children: [
            for (final entry in _measurementValues(latest, _imperial))
              _MeasurementLine(label: entry.$1, value: entry.$2),
            if (bmi != null) ...[
              const Divider(height: 22),
              _MeasurementLine(label: 'BMI', value: bmi.toStringAsFixed(1)),
              const SizedBox(height: 4),
              const Text('BMI is calculated from height and weight; it is not a body composition measurement.', style: TextStyle(fontSize: 11, color: ProfileColors.textSecondary)),
            ],
          ])),
          if (changes.isNotEmpty) ...[
            const SizedBox(height: 8),
            ProfileCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Change since ${shortDate(_items[1].date)}', style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
              const SizedBox(height: 6),
              for (final change in changes)
                _MeasurementLine(label: change.$1, value: change.$2),
            ])),
          ],
          const SizedBox(height: 18),
          const ProfileSectionTitle('History'),
          ..._items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProfileCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(shortDate(item.date), style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(_measurementValues(item, _imperial).map((entry) => '${entry.$1}: ${entry.$2}').join('  •  '), style: const TextStyle(color: ProfileColors.textSecondary)),
                ])),
              )),
        ],
      ]),
    );
  }
}

class AddBodyMeasurementScreen extends StatefulWidget {
  const AddBodyMeasurementScreen({super.key, required this.records});
  final ProfileRecordsDataSource records;

  @override
  State<AddBodyMeasurementScreen> createState() => _AddBodyMeasurementScreenState();
}

class _AddBodyMeasurementScreenState extends State<AddBodyMeasurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'weightKg': TextEditingController(),
    'waistCm': TextEditingController(),
    'chestCm': TextEditingController(),
    'hipsCm': TextEditingController(),
    'leftArmCm': TextEditingController(),
    'rightArmCm': TextEditingController(),
    'leftThighCm': TextEditingController(),
    'rightThighCm': TextEditingController(),
  };
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  bool _imperial = false;
  static const _fields = [
    ('weightKg', 'Weight', 'kg'),
    ('waistCm', 'Waist', 'cm'),
    ('chestCm', 'Chest', 'cm'),
    ('hipsCm', 'Hips', 'cm'),
    ('leftArmCm', 'Left arm', 'cm'),
    ('rightArmCm', 'Right arm', 'cm'),
    ('leftThighCm', 'Left thigh', 'cm'),
    ('rightThighCm', 'Right thigh', 'cm'),
  ];

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) setState(() => _imperial = preferences.getString('motion_orbit/profile_units') == 'imperial');
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime.now());
    if (value != null) setState(() => _date = value);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final values = <String, double?>{};
    for (final entry in _controllers.entries) {
      final input = entry.value.text.trim().isEmpty
          ? null
          : double.parse(entry.value.text.trim().replaceAll(',', '.'));
      values[entry.key] = input == null
          ? null
          : _imperial
              ? entry.key == 'weightKg' ? input * 0.45359237 : input * 2.54
              : input;
    }
    if (values.values.every((value) => value == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one measurement.')));
      return;
    }
    widget.records.saveMeasurement(MeasurementRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: _date,
      weightKg: values['weightKg'],
      waistCm: values['waistCm'],
      chestCm: values['chestCm'],
      hipsCm: values['hipsCm'],
      leftArmCm: values['leftArmCm'],
      rightArmCm: values['rightArmCm'],
      leftThighCm: values['leftThighCm'],
      rightThighCm: values['rightThighCm'],
      note: _note.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => ProfileModuleScaffold(
        title: 'Add Body Measurement',
        child: ProfileModuleBody(children: [
          ProfileCard(child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('New measurement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
            const SizedBox(height: 14),
            OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today_outlined), label: Text('Date  •  ${shortDate(_date)}')),
            const SizedBox(height: 10),
            for (final field in _fields) ...[
              TextFormField(
                controller: _controllers[field.$1],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: field.$2, suffixText: _imperial ? field.$1 == 'weightKg' ? 'lb' : 'in' : field.$3),
                validator: (text) {
                  if ((text ?? '').trim().isEmpty) return null;
                  final number = double.tryParse(text!.trim().replaceAll(',', '.'));
                  if (number == null || !number.isFinite || number <= 0 || number > 500) return 'Enter a valid ${field.$3} value.';
                  return null;
                },
              ),
              const SizedBox(height: 9),
            ],
            TextFormField(controller: _note, decoration: const InputDecoration(labelText: 'Note (optional)'), maxLines: 2),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Save measurement')),
          ]))),
        ]),
      );
}

class _MeasurementLine extends StatelessWidget {
  const _MeasurementLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(color: ProfileColors.textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
        ]),
      );
}

List<(String, String)> _measurementValues(MeasurementRecord record, bool imperial) {
  final values = <(String, double?, String)>[
    ('Weight', record.weightKg, 'kg'), ('Waist', record.waistCm, 'cm'),
    ('Chest', record.chestCm, 'cm'), ('Hips', record.hipsCm, 'cm'),
    ('Left arm', record.leftArmCm, 'cm'), ('Right arm', record.rightArmCm, 'cm'),
    ('Left thigh', record.leftThighCm, 'cm'), ('Right thigh', record.rightThighCm, 'cm'),
  ];
  return values.where((entry) => entry.$2 != null)
      .map((entry) {
        final converted = imperial
            ? entry.$1 == 'Weight' ? entry.$2! / 0.45359237 : entry.$2! / 2.54
            : entry.$2!;
        final unit = imperial ? entry.$1 == 'Weight' ? 'lb' : 'in' : entry.$3;
        return (entry.$1, '${converted.toStringAsFixed(1)} $unit');
      })
      .toList();
}

List<(String, String)> _measurementChanges(MeasurementRecord latest, MeasurementRecord previous, bool imperial) {
  final fields = <(String, double?, double?, String)>[
    ('Weight', latest.weightKg, previous.weightKg, 'kg'),
    ('Waist', latest.waistCm, previous.waistCm, 'cm'),
    ('Chest', latest.chestCm, previous.chestCm, 'cm'),
    ('Hips', latest.hipsCm, previous.hipsCm, 'cm'),
  ];
  return fields.where((item) => item.$2 != null && item.$3 != null).map((item) {
    final change = item.$2! - item.$3!;
    final converted = imperial
        ? item.$1 == 'Weight' ? change / 0.45359237 : change / 2.54
        : change;
    final unit = imperial ? item.$1 == 'Weight' ? 'lb' : 'in' : item.$4;
    return (item.$1, '${converted >= 0 ? '+' : ''}${converted.toStringAsFixed(1)} $unit');
  }).toList();
}
