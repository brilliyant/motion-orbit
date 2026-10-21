import 'package:flutter/material.dart';

import 'package:motion_orbit/features/profile/data/datasources/profile_records_data_source.dart';
import 'package:motion_orbit/features/profile/data/models/profile_records.dart';
import 'package:motion_orbit/features/profile/presentation/profile_colors.dart';
import 'package:motion_orbit/features/profile/presentation/widgets/profile_module_widgets.dart';

class GoalsOverviewScreen extends StatefulWidget {
  const GoalsOverviewScreen({super.key, required this.records});
  final ProfileRecordsDataSource records;

  @override
  State<GoalsOverviewScreen> createState() => _GoalsOverviewScreenState();
}

class _GoalsOverviewScreenState extends State<GoalsOverviewScreen> {
  late List<FitnessGoal> _goals;

  @override
  void initState() { super.initState(); _reload(); }
  void _reload() => _goals = widget.records.goals();

  Future<void> _edit([FitnessGoal? goal]) async {
    await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => CreateEditGoalScreen(records: widget.records, goal: goal)));
    if (mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) => ProfileModuleScaffold(
        title: 'Goals',
        actions: [IconButton(tooltip: 'Create goal', onPressed: () => _edit(), icon: const Icon(Icons.add))],
        child: ProfileModuleBody(children: [
          const Text('Your goals', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Completion is calculated from matching records when a baseline is available.', style: TextStyle(color: ProfileColors.textSecondary)),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Create goal')),
          const SizedBox(height: 18),
          if (_goals.isEmpty)
            const ProfileEmptyState(title: 'No goals yet', message: 'Create a measurable target to track it against your own records.', icon: Icons.flag_outlined)
          else ..._goals.map((goal) {
            final progress = _goalProgress(goal, widget.records);
            return Padding(padding: const EdgeInsets.only(bottom: 10), child: ProfileCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary))),
                Chip(label: Text(goal.isPrimary ? 'Primary' : 'Secondary'), visualDensity: VisualDensity.compact),
                IconButton(tooltip: 'Edit goal', onPressed: () => _edit(goal), icon: const Icon(Icons.edit_outlined, size: 20)),
              ]),
              Text('${goal.metric == GoalMetric.assessment ? goal.assessmentTest : goal.metric == GoalMetric.weight ? 'Weight' : 'Waist'} target: ${goal.target.toStringAsFixed(1)} ${_goalUnit(goal)}', style: const TextStyle(color: ProfileColors.textSecondary)),
              const SizedBox(height: 10),
              if (progress.$1 == null)
                const Text('Log a baseline and new result to calculate progress.', style: TextStyle(fontSize: 12, color: ProfileColors.textSecondary))
              else ...[
                LinearProgressIndicator(value: progress.$1, minHeight: 7, borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 6),
                Text('${progress.$1! >= 1 ? 'Target reached' : 'In progress'}  â€¢  ${(progress.$1! * 100).round()}%  â€¢  Due ${shortDate(goal.targetDate)}', style: const TextStyle(fontSize: 12, color: ProfileColors.textSecondary)),
              ],
            ])));
          }),
        ]),
      );
}

class CreateEditGoalScreen extends StatefulWidget {
  const CreateEditGoalScreen({super.key, required this.records, this.goal});
  final ProfileRecordsDataSource records;
  final FitnessGoal? goal;

  @override
  State<CreateEditGoalScreen> createState() => _CreateEditGoalScreenState();
}

class _CreateEditGoalScreenState extends State<CreateEditGoalScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _target;
  late GoalMetric _metric;
  late DateTime _date;
  String _test = 'Push-up';
  bool _primary = false;
  static const _tests = ['Push-up', 'Sit-up', 'Plank', 'Pull-up', '12-minute run'];

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    _title = TextEditingController(text: goal?.title ?? '');
    _target = TextEditingController(text: goal?.target.toString() ?? '');
    _metric = goal?.metric ?? GoalMetric.assessment;
    _date = goal?.targetDate ?? DateTime.now().add(const Duration(days: 30));
    _test = goal?.assessmentTest ?? _test;
    _primary = goal?.isPrimary ?? false;
  }

  @override
  void dispose() { _title.dispose(); _target.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.goal == null ? DateTime.now() : DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  double? _currentValue() {
    if (_metric == GoalMetric.assessment) {
      for (final record in widget.records.assessments()) { if (record.test == _test) return record.value; }
      return null;
    }
    final measurements = widget.records.measurements();
    for (final record in measurements) {
      final value = _metric == GoalMetric.weight ? record.weightKg : record.waistCm;
      if (value != null) return value;
    }
    return null;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    final goal = FitnessGoal(
      id: widget.goal?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      metric: _metric,
      target: double.parse(_target.text.trim().replaceAll(',', '.')),
      startingValue: widget.goal?.startingValue ?? _currentValue(),
      targetDate: _date,
      assessmentTest: _metric == GoalMetric.assessment ? _test : null,
      isPrimary: _primary,
      isComplete: widget.goal?.isComplete ?? false,
    );
    if (goal.isPrimary) {
      final oldPrimary = widget.records.goals().where((item) => item.id != goal.id && item.isPrimary);
      for (final old in oldPrimary) {
        widget.records.saveGoal(FitnessGoal(
          id: old.id,
          title: old.title,
          metric: old.metric,
          target: old.target,
          startingValue: old.startingValue,
          targetDate: old.targetDate,
          assessmentTest: old.assessmentTest,
          isPrimary: false,
          isComplete: old.isComplete,
        ));
      }
    }
    widget.records.saveGoal(goal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => ProfileModuleScaffold(
        title: widget.goal == null ? 'Create Goal' : 'Edit Goal',
        child: ProfileModuleBody(children: [
          ProfileCard(child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Goal name'), validator: (value) => (value ?? '').trim().isEmpty ? 'Enter a goal name.' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<GoalMetric>(
              initialValue: _metric,
              decoration: const InputDecoration(labelText: 'Measure progress with'),
              items: const [
                DropdownMenuItem(value: GoalMetric.assessment, child: Text('Fitness assessment')),
                DropdownMenuItem(value: GoalMetric.weight, child: Text('Weight')),
                DropdownMenuItem(value: GoalMetric.waist, child: Text('Waist measurement')),
              ],
              onChanged: (value) => setState(() => _metric = value ?? _metric),
            ),
            if (_metric == GoalMetric.assessment) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(initialValue: _test, decoration: const InputDecoration(labelText: 'Assessment test'), items: _tests.map((test) => DropdownMenuItem(value: test, child: Text(test))).toList(), onChanged: (value) => setState(() => _test = value ?? _test)),
            ],
            const SizedBox(height: 12),
            TextFormField(controller: _target, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Target', suffixText: _goalUnit(FitnessGoal(id: '', title: '', metric: _metric, target: 0, startingValue: null, targetDate: _date, assessmentTest: _test))), validator: (value) { final number = double.tryParse((value ?? '').trim().replaceAll(',', '.')); return number == null || !number.isFinite || number <= 0 ? 'Enter a target greater than zero.' : null; }),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.event_outlined), label: Text('Target date  â€¢  ${shortDate(_date)}')),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Set as primary goal'), value: _primary, onChanged: (value) => setState(() => _primary = value)),
            const SizedBox(height: 12),
            const Text('Your goal only changes this target. It does not modify your training schedule.', style: TextStyle(fontSize: 12, color: ProfileColors.textSecondary)),
            const SizedBox(height: 14),
            FilledButton(onPressed: _save, child: const Text('Save goal')),
          ]))),
        ]),
      );
}

(double?, double?) _goalProgress(FitnessGoal goal, ProfileRecordsDataSource records) {
  final values = goal.metric == GoalMetric.assessment
      ? records.assessments().where((item) => item.test == goal.assessmentTest).map((item) => item.value).toList()
      : records.measurements().map((item) => goal.metric == GoalMetric.weight ? item.weightKg : item.waistCm).whereType<double>().toList();
  if (values.isEmpty || goal.startingValue == null || goal.target == goal.startingValue) return (null, null);
  final progress = ((values.first - goal.startingValue!) / (goal.target - goal.startingValue!)).clamp(0.0, 1.0);
  return (progress, values.first);
}

String _goalUnit(FitnessGoal goal) => switch (goal.metric) {
      GoalMetric.assessment => switch (goal.assessmentTest) { 'Plank' => 'sec', '12-minute run' => 'm', _ => 'reps' },
      GoalMetric.weight => 'kg',
      GoalMetric.waist => 'cm',
    };

