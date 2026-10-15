import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/profile_records_data_source.dart';
import '../../data/models/profile_records.dart';
import '../profile_colors.dart';
import '../widgets/profile_module_widgets.dart';

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
                Text('${progress.$1! >= 1 ? 'Target reached' : 'In progress'}  •  ${(progress.$1! * 100).round()}%  •  Due ${shortDate(goal.targetDate)}', style: const TextStyle(fontSize: 12, color: ProfileColors.textSecondary)),
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
              value: _metric,
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
              DropdownButtonFormField<String>(value: _test, decoration: const InputDecoration(labelText: 'Assessment test'), items: _tests.map((test) => DropdownMenuItem(value: test, child: Text(test))).toList(), onChanged: (value) => setState(() => _test = value ?? _test)),
            ],
            const SizedBox(height: 12),
            TextFormField(controller: _target, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Target', suffixText: _goalUnit(FitnessGoal(id: '', title: '', metric: _metric, target: 0, startingValue: null, targetDate: _date, assessmentTest: _test))), validator: (value) { final number = double.tryParse((value ?? '').trim().replaceAll(',', '.')); return number == null || !number.isFinite || number <= 0 ? 'Enter a target greater than zero.' : null; }),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.event_outlined), label: Text('Target date  •  ${shortDate(_date)}')),
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

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  String _units = 'metric';
  bool _loaded = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _units = preferences.getString('motion_orbit/profile_units') ?? 'metric'; _loaded = true; });
  }

  Future<void> _setUnits(String value) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString('motion_orbit/profile_units', value);
    if (!saved || !mounted) return;
    setState(() => _units = value);
  }

  @override
  Widget build(BuildContext context) => ProfileModuleScaffold(
        title: 'Settings',
        child: ProfileModuleBody(children: [
          const ProfileSectionTitle('Measurement units'),
          ProfileCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Preferred units', style: TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('Choose the units used when entering and reviewing body measurements.', style: TextStyle(color: ProfileColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
            if (!_loaded) const LinearProgressIndicator(minHeight: 2) else SegmentedButton<String>(
              segments: const [ButtonSegment(value: 'metric', label: Text('Metric')), ButtonSegment(value: 'imperial', label: Text('Imperial'))],
              selected: {_units},
              onSelectionChanged: (values) => _setUnits(values.first),
            ),
          ])),
          const SizedBox(height: 16),
          const ProfileSectionTitle('Local data'),
          const ProfileCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.offline_pin_outlined, color: ProfileColors.green),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Stored on this device', style: TextStyle(fontWeight: FontWeight.w700, color: ProfileColors.textPrimary)),
              SizedBox(height: 4),
              Text('Profile details use local preferences. Assessments, measurements, and goals use the app’s ObjectBox database. No account or cloud sync is required.', style: TextStyle(fontSize: 12, color: ProfileColors.textSecondary)),
            ])),
          ])),
          const SizedBox(height: 16),
          const ProfileSectionTitle('Unavailable in this build'),
          const ProfileCard(child: Column(children: [
            _UnavailableSetting(title: 'Appearance', subtitle: 'Theme selection is not connected yet.'),
            Divider(height: 20),
            _UnavailableSetting(title: 'Language', subtitle: 'Only the current app language is available.'),
            Divider(height: 20),
            _UnavailableSetting(title: 'Reminders & notifications', subtitle: 'No notification service is configured.'),
            Divider(height: 20),
            _UnavailableSetting(title: 'Export and backup', subtitle: 'Export and cloud backup are not implemented.'),
          ])),
        ]),
      );
}

class _UnavailableSetting extends StatelessWidget {
  const _UnavailableSetting({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(children: [
        const Icon(Icons.remove_circle_outline, size: 18, color: ProfileColors.textMuted),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: ProfileColors.textPrimary)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: ProfileColors.textSecondary)),
        ])),
      ]);
}
