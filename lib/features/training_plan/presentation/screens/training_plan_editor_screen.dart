import 'package:flutter/material.dart';

import '../models/training_plan.dart';

const _editorBackground = Color(0xFF111317);
const _editorSurfaceLow = Color(0xFF1A1C1F);
const _editorSurface = Color(0xFF1E2023);
const _editorSurfaceHigh = Color(0xFF282A2D);
const _editorSurfaceHighest = Color(0xFF333538);
const _editorText = Color(0xFFE2E2E6);
const _editorMuted = Color(0xFFC5C9AC);
const _editorLime = Color(0xFFC9F300);
const _editorCyan = Color(0xFF00DBE9);

class TrainingPlanEditorScreen extends StatefulWidget {
  const TrainingPlanEditorScreen({super.key, this.plan});

  final TrainingPlan? plan;

  @override
  State<TrainingPlanEditorScreen> createState() => _TrainingPlanEditorScreenState();
}

class _TrainingPlanEditorScreenState extends State<TrainingPlanEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _focus;
  late final TextEditingController _duration;
  late final TextEditingController _rpe;
  late final TextEditingController _notes;
  late final TextEditingController _event;
  late String _type;
  late List<TrainingPlanActivity> _warmUp;
  late List<TrainingPlanActivity> _exercises;
  late List<TrainingPlanActivity> _coolDown;
  late DateTime _scheduledDate;
  DateTime? _eventDate;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    _name = TextEditingController(text: plan?.title ?? '');
    _focus = TextEditingController(text: plan?.focus ?? '');
    _duration = TextEditingController(
      text: plan?.duration.replaceAll(RegExp(r'[^0-9]'), '') ?? '50',
    );
    _rpe = TextEditingController(
      text: plan?.rpe.replaceAll(RegExp(r'[^0-9]'), '') ?? '6',
    );
    _notes = TextEditingController(text: plan?.notes ?? '');
    _event = TextEditingController(text: plan?.targetEvent ?? '');
    _type = plan?.type ?? 'Strength';
    _scheduledDate = plan?.scheduledDate ?? DateTime.now();
    _eventDate = plan?.eventDate;
    _warmUp = [...?plan?.warmUp];
    _exercises = [...?plan?.exercises];
    _coolDown = [...?plan?.coolDown];
  }

  @override
  void dispose() {
    _name.dispose();
    _focus.dispose();
    _duration.dispose();
    _rpe.dispose();
    _notes.dispose();
    _event.dispose();
    super.dispose();
  }

  Future<void> _addActivity(
    List<TrainingPlanActivity> list, {
    bool exercise = false,
  }) async {
    final activity = await showDialog<TrainingPlanActivity>(
      context: context,
      builder: (_) => _ActivityDialog(exercise: exercise),
    );
    if (activity == null) return;
    setState(() => list.add(activity));
  }

  Future<void> _editActivity(
    List<TrainingPlanActivity> list,
    int index, {
    bool exercise = false,
  }) async {
    final activity = await showDialog<TrainingPlanActivity>(
      context: context,
      builder: (_) =>
          _ActivityDialog(exercise: exercise, activity: list[index]),
    );
    if (activity == null) return;
    setState(() => list[index] = activity);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final previous = widget.plan;
    final running = _type == 'Running';
    final plan = TrainingPlan(
      id: previous?.id ?? 'plan-${DateTime.now().microsecondsSinceEpoch}',
      isSample: false,
      title: _name.text.trim(),
      type: _type,
      focus: _focus.text.trim().isEmpty ? _type : _focus.text.trim(),
      date: trainingPlanDateLabel(_scheduledDate),
      duration: '${int.parse(_duration.text)} min',
      volume: running
          ? '${_exercises.length} sections'
          : '${_exercises.length} exercises',
      effort: 'Target RPE ${_rpe.text}',
      icon: running ? Icons.directions_run : Icons.fitness_center,
      accent: running ? const Color(0xFF34D399) : const Color(0xFF84CC16),
      rpe: 'RPE ${_rpe.text}',
      imageUrl: previous?.imageUrl ?? '',
      description: previous?.description ?? '',
      notes: _notes.text.trim(),
      targetEvent: _event.text.trim(),
      eventDate: _eventDate,
      scheduledDate: _scheduledDate,
      warmUp: _warmUp,
      exercises: _exercises,
      coolDown: _coolDown,
    );
    Navigator.of(context).pop(plan);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _editorLime;
    const field = _editorSurfaceHigh;
    final editorTheme = Theme.of(context).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _editorBackground,
      colorScheme: Theme.of(context).colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: _editorLime,
        onPrimary: const Color(0xFF171E00),
        secondary: _editorCyan,
        onSecondary: const Color(0xFF002022),
        surface: _editorSurface,
        onSurface: _editorText,
        surfaceContainerHighest: _editorSurfaceHighest,
        outline: const Color(0xFF8F9379),
      ),
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: _editorText,
        displayColor: _editorText,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: _editorMuted),
        hintStyle: TextStyle(color: _editorMuted),
        floatingLabelStyle: TextStyle(color: _editorLime),
      ),
      sliderTheme: SliderTheme.of(context).copyWith(
        activeTrackColor: _editorLime,
        thumbColor: _editorLime,
        inactiveTrackColor: _editorSurfaceHighest,
        overlayColor: _editorLime.withValues(alpha: .16),
      ),
    );
    final inputStyle = InputDecoration(
      filled: true,
      fillColor: field,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
    Widget panel(Widget child) => Container(
      decoration: BoxDecoration(
        color: _editorSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );

    return Theme(data: editorTheme, child: Scaffold(
      backgroundColor: _editorBackground,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: _editorBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _editorText,
        titleSpacing: 0,
        leadingWidth: 52,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Routine Detail',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: _editorSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.cloud_off, size: 14, color: _editorCyan),
                SizedBox(width: 5),
                Text(
                  'LOCAL SYNC',
                  style: TextStyle(
                    color: _editorMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 17,
            backgroundColor: _editorSurfaceHigh,
            child: Icon(Icons.person_outline, size: 18, color: _editorMuted),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
            children: [
              panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 4, height: 18, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('General Information', style: TextStyle(color: _editorText, fontSize: 16, fontWeight: FontWeight.w700))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: _editorSurfaceHigh, borderRadius: BorderRadius.circular(20)), child: const Text('REQUIRED', style: TextStyle(color: _editorLime, fontSize: 9, fontWeight: FontWeight.w800))),
                ]),
                const SizedBox(height: 14),
                const Text('Workout Name *', style: TextStyle(color: _editorMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(controller: _name, decoration: inputStyle.copyWith(hintText: 'e.g., Heavy Push & Core', suffixIcon: const Icon(Icons.fitness_center, size: 18)), validator: (value) => value == null || value.trim().isEmpty ? 'Enter a workout name' : null),
                const SizedBox(height: 12),
                const Text('Workout Modality', style: TextStyle(color: _editorMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 7),
                Wrap(spacing: 7, runSpacing: 7, children: [
                  for (final type in const ['Strength', 'Running', 'Walking', 'Cycling', 'Custom'])
                    ChoiceChip(
                      label: Text(type),
                      selected: _type == type,
                      showCheckmark: false,
                      selectedColor: accent,
                      backgroundColor: field,
                      labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _type == type ? const Color(0xFF171E00) : _editorText),
                      onSelected: (_) => setState(() => _type = type),
                    ),
                ]),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Scheduled Date', style: TextStyle(color: _editorMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    SizedBox(width: double.infinity, child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(context: context, initialDate: _scheduledDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (date != null) setState(() => _scheduledDate = date);
                      },
                      icon: const Icon(Icons.calendar_today, size: 15),
                      label: Text(trainingPlanDateLabel(_scheduledDate), maxLines: 1, overflow: TextOverflow.ellipsis),
                      style: OutlinedButton.styleFrom(backgroundColor: field, foregroundColor: _editorText, side: BorderSide.none, padding: const EdgeInsets.symmetric(vertical: 14)),
                    )),
                  ])),
                  const SizedBox(width: 9),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Duration', style: TextStyle(color: _editorMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(height: 48, decoration: BoxDecoration(color: field, borderRadius: BorderRadius.circular(10)), child: Row(children: [
                      IconButton(onPressed: () { final value = int.tryParse(_duration.text) ?? 50; _duration.text = '${(value - 5).clamp(5, 600)}'; }, icon: const Icon(Icons.remove, size: 18)),
                      Expanded(child: TextFormField(controller: _duration, textAlign: TextAlign.center, keyboardType: TextInputType.number, decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero), validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1 ? 'Enter minutes' : null)),
                      const Text('MIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                      IconButton(onPressed: () { final value = int.tryParse(_duration.text) ?? 50; _duration.text = '${(value + 5).clamp(5, 600)}'; }, icon: const Icon(Icons.add, size: 18)),
                    ])),
                  ])),
                ]),
                const SizedBox(height: 12),
                Row(children: [const Expanded(child: Text('Target Intensity (RPE & RIR)', style: TextStyle(color: _editorMuted, fontSize: 11, fontWeight: FontWeight.w600))), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: _editorCyan.withValues(alpha: .14), borderRadius: BorderRadius.circular(20)), child: Text('RPE ${_rpe.text}', style: const TextStyle(color: _editorCyan, fontSize: 10, fontWeight: FontWeight.w800)))]),
                const SizedBox(height: 7),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: field, borderRadius: BorderRadius.circular(10)), child: Column(children: [
                  Slider(value: (int.tryParse(_rpe.text) ?? 6).toDouble(), min: 1, max: 10, divisions: 9, activeColor: accent, label: 'RPE ${_rpe.text}', onChanged: (value) => setState(() => _rpe.text = value.round().toString())),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('RPE 1 (Rest)', style: TextStyle(color: _editorMuted, fontSize: 9)), Text('${(10 - (int.tryParse(_rpe.text) ?? 6)).clamp(0, 9)} RIR', style: const TextStyle(color: _editorCyan, fontSize: 9, fontWeight: FontWeight.w700)), const Text('RPE 10 (Max)', style: TextStyle(color: _editorMuted, fontSize: 9))]),
                ])),
              ])),
              const SizedBox(height: 12),
              _ActivitySection(title: 'Warm-up', subtitle: 'Preparation exercises', icon: Icons.timer_outlined, activities: _warmUp, exercise: false, accent: _editorCyan, onAdd: () => _addActivity(_warmUp), onEdit: (i) => _editActivity(_warmUp, i), onRemove: (i) => setState(() => _warmUp.removeAt(i))),
              const SizedBox(height: 12),
              _ActivitySection(title: _type == 'Running' ? 'Main Run / Intervals' : 'Main Exercises', subtitle: 'Planned exercises', icon: Icons.fitness_center, activities: _exercises, exercise: true, accent: accent, onAdd: () => _addActivity(_exercises, exercise: true), onEdit: (i) => _editActivity(_exercises, i, exercise: true), onRemove: (i) => setState(() => _exercises.removeAt(i))),
              if (_type == 'Strength') Padding(padding: const EdgeInsets.only(top: 8), child: OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.library_add), label: const Text('Select from Exercise Library · Coming soon'))),
              const SizedBox(height: 12),
              _ActivitySection(title: 'Cool-down', subtitle: 'Post-session routines', icon: Icons.self_improvement, activities: _coolDown, exercise: false, accent: _editorCyan, onAdd: () => _addActivity(_coolDown), onEdit: (i) => _editActivity(_coolDown, i), onRemove: (i) => setState(() => _coolDown.removeAt(i))),
              const SizedBox(height: 12),
              panel(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Container(width: 4, height: 18, decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 8), const Text('Target Event & Notes', style: TextStyle(color: _editorText, fontSize: 16, fontWeight: FontWeight.w700))]),
                const SizedBox(height: 14),
                const Text('Workout Tactical Notes', style: TextStyle(color: _editorMuted, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(controller: _notes, minLines: 3, maxLines: 4, decoration: inputStyle.copyWith(hintText: 'Specific form cues, prep notes or tapering directives...')),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _event, decoration: inputStyle.copyWith(labelText: 'Target Event', hintText: 'Optional event', prefixIcon: const Icon(Icons.flag_outlined, size: 18)))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: () async {
                    final date = await showDatePicker(context: context, initialDate: _eventDate ?? _scheduledDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (date != null) setState(() => _eventDate = date);
                  }, icon: const Icon(Icons.event, size: 16), label: Text(_eventDate == null ? 'Event Date' : trainingPlanDateLabel(_eventDate!), maxLines: 1, overflow: TextOverflow.ellipsis), style: OutlinedButton.styleFrom(backgroundColor: field, foregroundColor: _editorText, side: BorderSide.none, padding: const EdgeInsets.symmetric(vertical: 16)))),
                ]),
              ])),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: _editorBackground.withValues(alpha: .96),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Save Training Plan'),
            style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: const Color(0xFF171E00), minimumSize: const Size.fromHeight(52), textStyle: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    ));
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.activities,
    required this.exercise,
    required this.accent,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
  });

  final String title, subtitle;
  final IconData icon;
  final List<TrainingPlanActivity> activities;
  final bool exercise;
  final Color accent;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit, onRemove;

  @override
  Widget build(BuildContext context) {
    const surface = _editorSurfaceHigh;
    return Material(
      color: _editorSurface,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Container(width: 30, height: 30, decoration: BoxDecoration(color: accent.withValues(alpha: .13), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 17, color: accent)),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        subtitle: Text('$subtitle · ${activities.length} ${activities.length == 1 ? 'item' : 'items'}', style: const TextStyle(fontSize: 10, color: _editorMuted)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (activities.isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(20)), child: Text('${activities.length} ${exercise ? 'Exercises' : 'items'}', style: const TextStyle(fontSize: 9, color: _editorMuted))),
          const SizedBox(width: 5),
          const Icon(Icons.expand_more),
        ]),
        children: [
          if (activities.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Align(alignment: Alignment.centerLeft, child: Text('No activities added yet.', style: const TextStyle(fontSize: 12, color: _editorMuted)))),
          for (var i = 0; i < activities.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: exercise
                  ? _ExerciseActivityCard(activity: activities[i], index: i, accent: accent, onEdit: () => onEdit(i), onRemove: () => onRemove(i))
                  : _RoutineActivityCard(activity: activities[i], onEdit: () => onEdit(i), onRemove: () => onRemove(i)),
            ),
          if (exercise)
            Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: onAdd, icon: Icon(Icons.add_circle, color: accent, size: 18), label: Text('Add Exercise', style: TextStyle(color: accent, fontWeight: FontWeight.w700))))
          else
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: Text('Add $title Activity'))),
        ],
      ),
    );
  }
}

class _ExerciseActivityCard extends StatelessWidget {
  const _ExerciseActivityCard({required this.activity, required this.index, required this.accent, required this.onEdit, required this.onRemove});
  final TrainingPlanActivity activity;
  final int index;
  final Color accent;
  final VoidCallback onEdit, onRemove;

  @override
  Widget build(BuildContext context) {
    const surface = _editorSurfaceHigh;
    return Container(
      decoration: BoxDecoration(color: _editorSurfaceHigh, borderRadius: BorderRadius.circular(9), border: Border(left: BorderSide(color: accent, width: 3))),
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 9),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.drag_handle, color: _editorMuted, size: 20),
          const SizedBox(width: 7),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('EXERCISE ${(index + 1).toString().padLeft(2, '0')}', style: TextStyle(fontSize: 8, color: accent, fontWeight: FontWeight.w800, letterSpacing: .6)),
            Text(activity.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ])),
          IconButton(visualDensity: VisualDensity.compact, onPressed: onEdit, icon: const Icon(Icons.more_vert, size: 18, color: _editorMuted)),
          IconButton(visualDensity: VisualDensity.compact, onPressed: onRemove, icon: const Icon(Icons.delete_outline, size: 18, color: _editorMuted)),
        ]),
        if (activity.muscles.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 27, bottom: 7), child: Text(activity.muscles, style: const TextStyle(color: _editorCyan, fontSize: 9, fontWeight: FontWeight.w700))),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(9)),
          child: Row(children: [
            _ActivityMetric(label: 'SETS', value: activity.sets),
            _ActivityMetric(label: 'REPS', value: activity.reps),
            _ActivityMetric(label: 'TARGET WT', value: activity.weight.isEmpty ? '—' : activity.weight, valueColor: accent),
            _ActivityMetric(label: 'REST', value: activity.rest.isEmpty ? '—' : activity.rest),
          ]),
        ),
        if (activity.notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 7), child: Text(activity.notes, style: const TextStyle(color: _editorMuted, fontSize: 10))),
      ]),
    );
  }
}

class _ActivityMetric extends StatelessWidget {
  const _ActivityMetric({required this.label, required this.value, this.valueColor});
  final String label, value;
  final Color? valueColor;
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [Text(label, style: const TextStyle(color: _editorMuted, fontSize: 7, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: valueColor ?? _editorText, fontSize: 12, fontWeight: FontWeight.w700))]));
}

class _RoutineActivityCard extends StatelessWidget {
  const _RoutineActivityCard({required this.activity, required this.onEdit, required this.onRemove});
  final TrainingPlanActivity activity;
  final VoidCallback onEdit, onRemove;
  @override
  Widget build(BuildContext context) {
    const surface = _editorSurfaceHigh;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(9)),
      child: Row(children: [
        const Icon(Icons.drag_indicator, size: 18, color: _editorMuted),
        const SizedBox(width: 7),
        Expanded(child: InkWell(onTap: onEdit, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(activity.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), if (activity.notes.isNotEmpty) Text(activity.notes, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _editorMuted, fontSize: 9))]))),
        if (activity.duration.isNotEmpty || activity.reps.isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: _editorSurface, borderRadius: BorderRadius.circular(6)), child: Text(activity.duration.isNotEmpty ? activity.duration : activity.reps, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700))),
        IconButton(visualDensity: VisualDensity.compact, onPressed: onRemove, icon: const Icon(Icons.delete_outline, size: 17, color: _editorMuted)),
      ]),
    );
  }
}
class _ActivityDialog extends StatefulWidget {
  const _ActivityDialog({required this.exercise, this.activity});
  final bool exercise;
  final TrainingPlanActivity? activity;
  @override
  State<_ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<_ActivityDialog> {
  late final TextEditingController _name;
  late final TextEditingController _muscles;
  late final TextEditingController _sets;
  late final TextEditingController _reps;
  late final TextEditingController _weight;
  late final TextEditingController _rest;
  late final TextEditingController _duration;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    _name = TextEditingController(text: activity?.name ?? '');
    _muscles = TextEditingController(text: activity?.muscles ?? '');
    _sets = TextEditingController(
      text: activity?.sets ?? (widget.exercise ? '3' : ''),
    );
    _reps = TextEditingController(
      text: activity?.reps ?? (widget.exercise ? '8-12' : ''),
    );
    _weight = TextEditingController(text: activity?.weight ?? '');
    _rest = TextEditingController(
      text: activity?.rest ?? (widget.exercise ? '90s' : ''),
    );
    _duration = TextEditingController(text: activity?.duration ?? '');
    _notes = TextEditingController(text: activity?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _muscles.dispose();
    _sets.dispose();
    _reps.dispose();
    _weight.dispose();
    _rest.dispose();
    _duration.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.exercise ? 'Add exercise' : 'Add activity'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          if (widget.exercise) ...[
            TextField(
              controller: _muscles,
              decoration: const InputDecoration(labelText: 'Target muscles'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sets,
                    decoration: const InputDecoration(labelText: 'Sets'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _reps,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weight,
                    decoration: const InputDecoration(
                      labelText: 'Target weight',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _rest,
                    decoration: const InputDecoration(labelText: 'Rest'),
                  ),
                ),
              ],
            ),
          ] else
            TextField(
              controller: _duration,
              decoration: const InputDecoration(labelText: 'Duration'),
            ),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notes / cues'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (_name.text.trim().isEmpty) return;
          Navigator.pop(
            context,
            TrainingPlanActivity(
              name: _name.text.trim(),
              muscles: _muscles.text.trim(),
              sets: _sets.text.trim(),
              reps: _reps.text.trim(),
              weight: _weight.text.trim(),
              rest: _rest.text.trim(),
              duration: _duration.text.trim(),
              notes: _notes.text.trim(),
            ),
          );
        },
        child: Text(widget.activity == null ? 'Add' : 'Save'),
      ),
    ],
  );
}


