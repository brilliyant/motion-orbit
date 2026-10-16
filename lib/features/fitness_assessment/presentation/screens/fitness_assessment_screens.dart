import 'package:flutter/material.dart';

import 'package:motion_orbit/features/profile/data/datasources/profile_records_data_source.dart';
import 'package:motion_orbit/features/profile/data/models/profile_records.dart';
import 'package:motion_orbit/features/profile/presentation/profile_colors.dart';
import 'package:motion_orbit/features/profile/presentation/widgets/profile_module_widgets.dart';

class FitnessAssessmentScreen extends StatefulWidget {
  const FitnessAssessmentScreen({super.key, required this.records});
  final ProfileRecordsDataSource records;

  @override
  State<FitnessAssessmentScreen> createState() => _FitnessAssessmentScreenState();
}

class _FitnessAssessmentScreenState extends State<FitnessAssessmentScreen> {
  late List<AssessmentRecord> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.records.assessments();
  }

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() => _items = widget.records.assessments());
  }

  @override
  Widget build(BuildContext context) => ProfileModuleScaffold(
        title: 'Fitness Assessment',
        child: ProfileModuleBody(children: [
          const Text('Your performance baseline', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Log manual assessments and compare your own results over time.', style: TextStyle(color: ProfileColors.textSecondary)),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _open(RecordAssessmentScreen(records: widget.records)),
            icon: const Icon(Icons.add),
            label: const Text('Record assessment'),
          ),
          const SizedBox(height: 20),
          ProfileSectionTitle('Recent assessments', trailing: TextButton(
            onPressed: () => _open(AssessmentHistoryScreen(records: widget.records)),
            child: const Text('View history'),
          )),
          if (_items.isEmpty)
            const ProfileEmptyState(
              title: 'No assessments yet',
              message: 'Add a manual result to establish your personal baseline.',
              icon: Icons.fitness_center,
            )
          else
            ..._items.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AssessmentRecordTile(record: item),
                )),
        ]),
      );
}

class RecordAssessmentScreen extends StatefulWidget {
  const RecordAssessmentScreen({super.key, required this.records});
  final ProfileRecordsDataSource records;

  @override
  State<RecordAssessmentScreen> createState() => _RecordAssessmentScreenState();
}

class _RecordAssessmentScreenState extends State<RecordAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _value = TextEditingController();
  final _note = TextEditingController();
  String _test = 'Push-up';
  DateTime _date = DateTime.now();
  static const _tests = ['Push-up', 'Sit-up', 'Plank', 'Pull-up', '12-minute run'];

  AssessmentMetric get _metric => switch (_test) {
        'Plank' => AssessmentMetric.seconds,
        '12-minute run' => AssessmentMetric.meters,
        _ => AssessmentMetric.repetitions,
      };
  String get _unit => switch (_metric) {
        AssessmentMetric.repetitions => 'reps',
        AssessmentMetric.seconds => 'seconds',
        AssessmentMetric.meters => 'meters',
      };

  @override
  void dispose() {
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (value != null) setState(() => _date = value);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.records.saveAssessment(AssessmentRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      test: _test,
      metric: _metric,
      value: double.parse(_value.text.trim().replaceAll(',', '.')),
      date: _date,
      note: _note.text.trim(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => ProfileModuleScaffold(
        title: 'Record Assessment',
        child: ProfileModuleBody(children: [
          ProfileCard(child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Assessment details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _test,
                decoration: const InputDecoration(labelText: 'Test type'),
                items: _tests.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) => setState(() => _test = value ?? _test),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _value,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Result', suffixText: _unit),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
                  if (parsed == null || !parsed.isFinite || parsed <= 0) return 'Enter a value greater than zero.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today_outlined), label: Text('Date  •  ${shortDate(_date)}')),
              const SizedBox(height: 12),
              TextFormField(controller: _note, maxLines: 2, decoration: const InputDecoration(labelText: 'Note (optional)')),
              const SizedBox(height: 18),
              FilledButton(onPressed: _save, child: const Text('Save assessment')),
            ]),
          )),
        ]),
      );
}

class AssessmentHistoryScreen extends StatelessWidget {
  const AssessmentHistoryScreen({super.key, required this.records});
  final ProfileRecordsDataSource records;

  @override
  Widget build(BuildContext context) {
    final items = records.assessments();
    final byTest = <String, List<AssessmentRecord>>{};
    for (final item in items) {
      byTest.putIfAbsent(item.test, () => []).add(item);
    }
    return ProfileModuleScaffold(
      title: 'Assessment History',
      child: ProfileModuleBody(children: [
        if (items.isEmpty)
          const ProfileEmptyState(title: 'No history to show', message: 'Saved assessment results will appear here in date order.', icon: Icons.history)
        else ...[
          for (final entry in byTest.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ProfileSectionTitle(entry.key),
                if (entry.value.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ProfileCard(child: _Comparison(current: entry.value[0], prior: entry.value[1])),
                  ),
                ...entry.value.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AssessmentRecordTile(record: item),
                    )),
              ]),
            ),
        ],
      ]),
    );
  }
}

class AssessmentRecordTile extends StatelessWidget {
  const AssessmentRecordTile({super.key, required this.record});
  final AssessmentRecord record;

  @override
  Widget build(BuildContext context) => ProfileCard(
        child: Row(children: [
          const Icon(Icons.fitness_center, color: ProfileColors.blue),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(record.test, style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
            Text(shortDate(record.date), style: const TextStyle(fontSize: 12, color: ProfileColors.textSecondary)),
          ])),
          Text('${record.value.toStringAsFixed(record.metric == AssessmentMetric.repetitions ? 0 : 1)} ${switch (record.metric) { AssessmentMetric.repetitions => 'reps', AssessmentMetric.seconds => 'sec', AssessmentMetric.meters => 'm' }}', style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.blue)),
        ]),
      );
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.current, required this.prior});
  final AssessmentRecord current;
  final AssessmentRecord prior;

  @override
  Widget build(BuildContext context) {
    final change = current.value - prior.value;
    final percent = prior.value == 0 ? null : change / prior.value * 100;
    return Row(children: [
      const Icon(Icons.compare_arrows, color: ProfileColors.blue),
      const SizedBox(width: 10),
      Expanded(child: Text('Since ${shortDate(prior.date)}', style: const TextStyle(color: ProfileColors.textSecondary))),
      Text('${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} ${switch (current.metric) { AssessmentMetric.repetitions => 'reps', AssessmentMetric.seconds => 'sec', AssessmentMetric.meters => 'm' }}${percent == null ? '' : ' (${percent.toStringAsFixed(0)}%)'}', style: const TextStyle(color: ProfileColors.textPrimary, fontWeight: FontWeight.w700)),
    ]);
  }
}
