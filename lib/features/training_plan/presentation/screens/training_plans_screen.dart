import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/datasources/training_plan_local_data_source.dart';
import '../../../training/presentation/widgets/training_overview_palette.dart';
import '../models/training_plan.dart';
import 'training_plan_detail_screen.dart';
import 'training_plan_editor_screen.dart';

const _samplePlans = [
  TrainingPlan(
    id: 'sample-upper-body',
    isSample: true,
    title: 'Upper Body - Race Week',
    type: 'Strength',
    focus: 'Pre-Race Taper',
    date: 'Oct 19',
    duration: '50 min',
    volume: '3 exercises',
    effort: 'Target RPE 5-6 (RIR 3-4)',
    icon: Icons.fitness_center,
    accent: Color(0xFF84CC16),
    rpe: 'RPE 6',
    warmUp: [
      TrainingPlanActivity(
        name: 'Treadmill Walking',
        duration: '5 min',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Arm Circles',
        duration: '30 sec',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Band Pull-Apart',
        muscles: 'Upper back',
        sets: '2',
        reps: '15',
        rest: '30s',
      ),
    ],
    exercises: [
      TrainingPlanActivity(
        name: 'Chest Press Machine',
        muscles: 'Chest',
        sets: '2',
        reps: '10',
        rest: '90s',
        notes: 'Easy taper effort; stop well before failure.',
      ),
      TrainingPlanActivity(
        name: 'Lat Pulldown',
        muscles: 'Back',
        sets: '2',
        reps: '10',
        rest: '90s',
        notes: 'Smooth, controlled reps.',
      ),
      TrainingPlanActivity(
        name: 'Seated Cable Row',
        muscles: 'Back',
        sets: '2',
        reps: '10',
        rest: '90s',
        notes: 'Keep the load light before race day.',
      ),
    ],
    coolDown: [
      TrainingPlanActivity(
        name: 'Easy Walking',
        duration: '3 min',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Chest Stretch',
        duration: '30 sec',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Shoulder Stretch',
        duration: '30 sec',
        sets: '',
        reps: '',
        rest: '',
      ),
    ],
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBNPkpz72GGnV9ZoCZv4AuzFcb3T8eurCvQYyL4yVFIaaGZFl0ZBPNBS3U4utPAHI8R_2DlURSgMAh0E-CHzaJf8z8MpZmfho_4uVkT_qspYwueHqjyC9x0SN2HCb8MwOQnPrRsw5-r2cWxV9jjdA9bo1-qkE__3ojqWtvUgX_xqkw1rdUaTDklI6u0A6dvXxtZcnJ7sx6GpAcrBbodUUxxG-lHky94DU2WIiMvbcAhkkZzZOSHSubZ',
  ),
  TrainingPlan(
    id: 'sample-push-day',
    isSample: true,
    title: 'Push Day - Hypertrophy',
    type: 'Strength',
    focus: 'Chest & Shoulders',
    date: 'Oct 14',
    duration: '65 min',
    volume: '3 exercises',
    effort: 'Target RPE 8-9 (High Intensity)',
    icon: Icons.sports_gymnastics,
    accent: Color(0xFF84CC16),
    rpe: 'RPE 9',
    warmUp: [
      TrainingPlanActivity(
        name: 'Rower',
        duration: '4 min',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Band External Rotation',
        muscles: 'Shoulders',
        sets: '2',
        reps: '12',
        rest: '30s',
      ),
    ],
    exercises: [
      TrainingPlanActivity(
        name: 'Barbell Bench Press',
        muscles: 'Chest, triceps',
        sets: '4',
        reps: '6-8',
        rest: '150s',
        notes: 'Leave 1-2 reps in reserve.',
      ),
      TrainingPlanActivity(
        name: 'Incline Dumbbell Press',
        muscles: 'Upper chest, shoulders',
        sets: '3',
        reps: '8-10',
        rest: '120s',
      ),
      TrainingPlanActivity(
        name: 'Dumbbell Lateral Raise',
        muscles: 'Shoulders',
        sets: '3',
        reps: '12-15',
        weight: '12 kg',
        rest: '60s',
      ),
    ],
    coolDown: [
      TrainingPlanActivity(
        name: 'Easy Walking',
        duration: '3 min',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Chest Stretch',
        duration: '30 sec',
        sets: '',
        reps: '',
        rest: '',
      ),
    ],
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBVNggMhSVO9bdFGe29tT4cHqNjN8vQsT5la6iVqDdGE_-bmjMO_bMNVdqGfmvvkIomP6lZlIKgDbG1KJuQTyRsMPKvMHweUI4Z6pjGXRWrk2EeQ4X6XRHvqyuYvFDQrPxlMXts90VgHDKPh_WCFhBLJdgbZp1q4pCGreI5zOyuBbx0e65BU31bJBoJAmPeOaUgvltQgqXssi0HCzQbrSOHLHqyKvVoQvET7MZljSXMQO5tJxnjbEBP',
  ),
  TrainingPlan(
    id: 'sample-running-5k',
    isSample: true,
    title: 'Running 5K Pace Prep',
    type: 'Running',
    focus: 'Tempo Intervals',
    date: 'Oct 11',
    duration: '35 min',
    volume: '4 sections',
    effort: 'Target RPE 7 (Threshold)',
    icon: Icons.directions_run,
    accent: Color(0xFF34D399),
    rpe: 'RPE 7',
    warmUp: [
      TrainingPlanActivity(
        name: 'Brisk Walk',
        duration: '5 min',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Leg Swings',
        muscles: 'Hips',
        sets: '2',
        reps: '10 each side',
        rest: '30s',
      ),
    ],
    exercises: [
      TrainingPlanActivity(
        name: 'Easy Warm-up Jog',
        sets: '1',
        reps: '8 min',
        rest: '',
      ),
      TrainingPlanActivity(
        name: '5K Pace Intervals',
        sets: '4',
        reps: '3 min',
        rest: '2 min easy jog',
        notes: 'Run at controlled 5K effort.',
      ),
      TrainingPlanActivity(
        name: 'Recovery Jog',
        sets: '4',
        reps: '2 min',
        rest: 'Easy pace',
      ),
      TrainingPlanActivity(
        name: 'Cool-down Jog',
        sets: '1',
        reps: '5 min',
        rest: '',
      ),
    ],
    coolDown: [
      TrainingPlanActivity(
        name: 'Easy Walking',
        duration: '4 min',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Calf Stretch',
        duration: '30 sec each side',
        sets: '',
        reps: '',
        rest: '',
      ),
    ],
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA7ewEAi9PCDgySOIFiNdXj_annwj253pt1EykF0AWjVz6OqoKeThjJAJHraxfFWojhBVkhHKyAHLw-rB0FRlP-mwdQ0_4zMnSo5EmDYxDSThwcKPQHVVVrrkK6rf8o409OLQ6GAxHgY01hsUBfWe9wy826twtItCxP9qE_hOesOU8ujKjKA2Wgh5bXiW5Qt3MODr5F7bzF18N53jhGJsQfw3yW-LBmQazl9HAi02CAtS_huKJdxsH8',
  ),
  TrainingPlan(
    id: 'sample-leg-day',
    isSample: true,
    title: 'Leg Day & Core Stability',
    type: 'Strength',
    focus: 'Quads & Hams',
    date: 'Oct 08',
    duration: '55 min',
    volume: '3 exercises',
    effort: 'Target RPE 8 (Stability Focus)',
    icon: Icons.sports_gymnastics,
    accent: Color(0xFF84CC16),
    rpe: 'RPE 8',
    warmUp: [
      TrainingPlanActivity(
        name: 'Stationary Bike',
        duration: '5 min',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Bodyweight Squat',
        muscles: 'Legs',
        sets: '2',
        reps: '10',
        rest: '30s',
      ),
    ],
    exercises: [
      TrainingPlanActivity(
        name: 'Goblet Squat',
        muscles: 'Quads, glutes',
        sets: '4',
        reps: '8-10',
        weight: '16 kg',
        rest: '120s',
      ),
      TrainingPlanActivity(
        name: 'Romanian Deadlift',
        muscles: 'Hamstrings, glutes',
        sets: '3',
        reps: '10',
        rest: '120s',
      ),
      TrainingPlanActivity(
        name: 'Dead Bug',
        muscles: 'Core',
        sets: '3',
        reps: '10 each side',
        rest: '60s',
      ),
    ],
    coolDown: [
      TrainingPlanActivity(
        name: 'Easy Walking',
        duration: '3 min',
        sets: '',
        reps: '',
        rest: '',
      ),
      TrainingPlanActivity(
        name: 'Hamstring Stretch',
        duration: '30 sec each side',
        sets: '',
        reps: '',
        rest: '',
      ),
    ],
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD1lVOIkS-Q86LUxHVKlaITRTcGI_MIYDc0eoGyR7DNGE11GOGd65owoiCVxuHGZmUOuPZ_0vitOPX2Kjhd5_j_ffyKmdmgqn1bAc4gXC62gUw9fF1ALuO4jkWLQ5kaAqATB2EoC6Bb-pHVQcJCNLY0toAND7lQnPmW5jIVGdA_3xN0Ph--4suEXBuISeJHcjJ8gFPHeTaeJlWyMzaLxgOx0C8KYMChoi4v2YWC4xV2rAnSlCXcSEp1',
  ),
];

class TrainingPlansScreen extends StatefulWidget {
  const TrainingPlansScreen({super.key});

  @override
  State<TrainingPlansScreen> createState() => _TrainingPlansScreenState();
}

class _TrainingPlansScreenState extends State<TrainingPlansScreen> {
  final _dataSource = TrainingPlanLocalDataSource();
  List<TrainingPlan> _plans = _samplePlans;
  Map<String, int> _planTypeCounts = const {'All': 0};
  String _query = '';
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _loadPlans() {
    try {
      final saved = _dataSource.readPlans();
      if (saved == null) {
        _dataSource.writePlans(
          _samplePlans.map((plan) => plan.toJson()).toList(),
        );
        setState(() => _planTypeCounts = _dataSource.readPlanTypeCounts());
        return;
      }
      setState(() {
        _plans = saved.map(TrainingPlan.fromJson).toList();
        _planTypeCounts = _dataSource.readPlanTypeCounts();
      });
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showMessage('Saved plans could not be loaded.');
      });
    }
  }

  Future<void> _savePlans(List<TrainingPlan> plans) async {
    try {
      _dataSource.writePlans(plans.map((plan) => plan.toJson()).toList());
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _planTypeCounts = _dataSource.readPlanTypeCounts();
      });
      _showMessage('Training plans saved on this device.');
    } catch (_) {
      _showMessage('Could not save training plans locally.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _createPlan() async {
    final plan = await Navigator.of(context).push<TrainingPlan>(
      MaterialPageRoute(builder: (_) => const TrainingPlanEditorScreen()),
    );
    if (plan == null) return;
    await _savePlans([..._plans, plan]);
  }

  Future<void> _editPlan(TrainingPlan plan) async {
    final edited = await Navigator.of(context).push<TrainingPlan>(
      MaterialPageRoute(builder: (_) => TrainingPlanEditorScreen(plan: plan)),
    );
    if (edited == null) return;
    await _savePlans([
      for (final item in _plans)
        if (item.id == plan.id) edited else item,
    ]);
  }

  Future<void> _duplicatePlan(TrainingPlan plan) async {
    final duplicate = plan.copyWith(
      id: 'plan-${DateTime.now().microsecondsSinceEpoch}',
      title: '${plan.title} (Copy)',
    );
    await _savePlans([..._plans, duplicate]);
  }

  Future<void> _restorePlans() => _savePlans(_samplePlans);

  TrainingPlan _planFor(String id) =>
      _plans.firstWhere((plan) => plan.id == id);

  Future<void> _openPlan(_PlanCardData card) async {
    final plan = _planFor(card.id);
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TrainingPlanDetailScreen(
          plan: plan,
          onEdit: () {
            Navigator.of(context).pop();
            _editPlan(plan);
          },
          onDuplicate: () {
            Navigator.of(context).pop();
            _duplicatePlan(plan);
          },
          onStart: () =>
              _showMessage('Workout recording is not available yet.'),
        ),
      ),
    );
  }

  Future<void> _deletePlan(TrainingPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete training plan?'),
        content: Text('“${plan.title}” will be removed from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _savePlans(_plans.where((item) => item.id != plan.id).toList());
  }

  Future<void> _importPlans() async {
    final controller = TextEditingController();
    final payload = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .85,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: StatefulBuilder(
            builder: (context, setSheetState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.code, color: Color(0xFF34D399)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Import Workout JSON',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Text(
                  'Paste a Motion Orbit plan or a list of plans. Imported data is saved on this device.',
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Browse .json file · Coming soon'),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setSheetState(
                      () => controller.text = JsonEncoder.withIndent('  ')
                          .convert({
                            'version': 2,
                            'plans': [
                              {
                                'name': 'Sprint Cycle',
                                'type': 'Running',
                                'duration': 35,
                                'focus': 'Tempo intervals',
                                'rpe': 7,
                                'warmUp': [
                                  {'name': 'Easy jog', 'duration': '8 min'},
                                ],
                                'exercises': [
                                  {
                                    'name': 'Tempo interval',
                                    'sets': 4,
                                    'reps': '3 min',
                                    'rest': '2 min',
                                  },
                                ],
                                'coolDown': [
                                  {'name': 'Easy walk', 'duration': '5 min'},
                                ],
                              },
                            ],
                          }),
                    ),
                    child: const Text('Insert Sample'),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: controller,
                    minLines: 8,
                    maxLines: 14,
                    expands: false,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      hintText: '{"version": 2, "planName": "Sprint Cycle", "exercises": [...]}',
                      filled: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, controller.text),
                        icon: const Icon(Icons.download_done),
                        label: const Text('Parse & Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    controller.dispose();
    if (payload == null || payload.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(payload);
      final rawPlans = switch (decoded) {
        List() => decoded,
        Map() when decoded['plans'] is List => decoded['plans'] as List,
        Map() => [decoded],
        _ => throw const FormatException('Expected a plan or a plans list.'),
      };
      final imported = rawPlans.map((item) {
        if (item is! Map) {
          throw const FormatException('Each plan must be a JSON object.');
        }
        return TrainingPlan.fromJson(Map<String, dynamic>.from(item));
      }).toList();
      if (imported.isEmpty) {
        throw const FormatException('The JSON contains no plans.');
      }
      await _savePlans([..._plans, ...imported]);
    } on FormatException catch (error) {
      _showMessage(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = TrainingPalette(
      Theme.of(context).brightness == Brightness.dark,
    );
    final cards = _plans.map(_PlanCardData.fromPlan).where((card) {
      final matchesCategory = _category == 'All' || card.type == _category;
      final searchText =
          '${card.title} ${card.type} ${card.focus} ${card.effort}'
              .toLowerCase();
      final matchesQuery = searchText.contains(_query.trim().toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PlansHeader(palette: palette),
              const SizedBox(height: 16),
              _PlanSearchField(
                palette: palette,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              _PlanFilters(
                selected: _category,
                palette: palette,
                counts: _planTypeCounts,
                onSelected: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 12),
              _PlanActions(
                palette: palette,
                onCreate: _createPlan,
                onImport: _importPlans,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: cards.isEmpty
                    ? _NoMatchingPlans(
                        palette: palette,
                        isEmpty: _plans.isEmpty,
                        onCreate: _createPlan,
                        onImport: _importPlans,
                        onRestore: _restorePlans,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: kToolbarHeight),
                        itemCount: cards.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _TrainingPlanCard(
                          plan: cards[index],
                          palette: palette,
                          onEdit: () => _editPlan(_planFor(cards[index].id)),
                          onDuplicate: () =>
                              _duplicatePlan(_planFor(cards[index].id)),
                          onDelete: () =>
                              _deletePlan(_planFor(cards[index].id)),
                          onOpen: () => _openPlan(cards[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlansHeader extends StatelessWidget {
  const _PlansHeader({required this.palette});

  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Material(
        color: palette.container,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: 'Back to Training',
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: palette.text, size: 20),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR WORKOUTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: palette.dark
                    ? const Color(0xFF84CC16)
                    : const Color(0xFF65A30D),
              ),
            ),
            Text(
              'My Training Plans',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -.3,
                color: palette.text,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 44),
    ],
  );
}

class _PlanSearchField extends StatelessWidget {
  const _PlanSearchField({required this.palette, required this.onChanged});

  final TrainingPalette palette;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onChanged,
    style: TextStyle(color: palette.text, fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Search saved plans, exercises, or tags...',
      prefixIcon: Icon(Icons.search, size: 20, color: palette.secondary),
      filled: true,
      fillColor: palette.container,
      hintStyle: TextStyle(color: palette.secondary, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF84CC16)),
      ),
    ),
  );
}

class _PlanFilters extends StatelessWidget {
  const _PlanFilters({
    required this.selected,
    required this.palette,
    required this.counts,
    required this.onSelected,
  });

  final String selected;
  final TrainingPalette palette;
  final Map<String, int> counts;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = ['All', 'Strength', 'Running', 'Walking', 'Cycling'];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selected == category;
          final count = counts[category] ?? 0;
          final foreground = isSelected
              ? (palette.dark ? const Color(0xFF0F172A) : Colors.white)
              : palette.secondary;

          return Material(
            color: isSelected ? const Color(0xFF84CC16) : palette.container,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => onSelected(category),
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '$count',
                        style: TextStyle(
                          color: foreground.withValues(alpha: .8),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlanCardData {
  const _PlanCardData({
    required this.id,
    required this.isSample,
    required this.title,
    required this.type,
    required this.focus,
    required this.date,
    required this.duration,
    required this.volume,
    required this.effort,
    required this.icon,
    required this.accent,
    required this.rpe,
    required this.imageUrl,
  });

  factory _PlanCardData.fromPlan(TrainingPlan plan) => _PlanCardData(
    id: plan.id,
    isSample: plan.isSample,
    title: plan.title,
    type: plan.type,
    focus: plan.focus,
    date: plan.date,
    duration: plan.duration,
    volume: plan.volume,
    effort: plan.effort,
    icon: plan.icon,
    accent: plan.accent,
    rpe: plan.rpe,
    imageUrl: plan.imageUrl,
  );

  final String id;
  final bool isSample;
  final String title;
  final String type;
  final String focus;
  final String date;
  final String duration;
  final String volume;
  final String effort;
  final IconData icon;
  final Color accent;
  final String rpe;
  final String imageUrl;
}

class _PlanActions extends StatelessWidget {
  const _PlanActions({
    required this.palette,
    required this.onCreate,
    required this.onImport,
  });

  final TrainingPalette palette;
  final VoidCallback onCreate;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final primary = palette.dark
        ? const Color(0xFF84CC16)
        : const Color(0xFF65A30D);
    final onPrimary = palette.dark ? const Color(0xFF0F172A) : Colors.white;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Create Plan', maxLines: 1, softWrap: false),
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: onPrimary,
                disabledBackgroundColor: primary.withValues(alpha: .35),
                disabledForegroundColor: onPrimary.withValues(alpha: .8),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.data_object, size: 18),
              label: const Text('Import JSON', maxLines: 1, softWrap: false),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.secondary,
                side: BorderSide(color: palette.border),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(fontSize: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrainingPlanCard extends StatelessWidget {
  const _TrainingPlanCard({
    required this.plan,
    required this.palette,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onOpen,
  });

  final _PlanCardData plan;
  final TrainingPalette palette;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = plan.accent;

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: palette.container,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.border.withValues(alpha: .7)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              left: 0,
              right: null,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 5, color: accent),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                plan.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _PlanImageFallback(
                                  palette: palette,
                                  icon: plan.icon,
                                  accent: accent,
                                ),
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black87,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    plan.rpe,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan.type.toUpperCase(),
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: .7,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.circle,
                                  size: 4,
                                  color: palette.disabled,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    plan.focus,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: palette.secondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                Text(
                                  plan.date,
                                  style: TextStyle(
                                    color: palette.secondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 16,
                                height: 1.15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Wrap(
                              spacing: 7,
                              runSpacing: 3,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _PlanMetric(
                                  icon: Icons.timer_outlined,
                                  label: plan.duration,
                                  palette: palette,
                                ),
                                Text(
                                  '·',
                                  style: TextStyle(color: palette.secondary),
                                ),
                                _PlanMetric(
                                  icon: plan.type == 'Running'
                                      ? Icons.directions_run
                                      : Icons.fitness_center,
                                  label: plan.volume,
                                  palette: palette,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(Icons.bolt, size: 15, color: accent),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          plan.effort,
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (plan.isSample)
                        const Text(
                          'SAMPLE',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .7,
                          ),
                        ),
                    ],
                  ),
                  Divider(height: 18, color: palette.border),
                  Row(
                    children: [
                      _PlanIconAction(
                        icon: Icons.edit_outlined,
                        label: 'Edit plan',
                        onPressed: onEdit,
                      ),
                      const SizedBox(width: 6),
                      _PlanIconAction(
                        icon: Icons.content_copy,
                        label: 'Duplicate plan',
                        onPressed: onDuplicate,
                      ),
                      const SizedBox(width: 6),
                      _PlanIconAction(
                        icon: Icons.delete_outline,
                        label: 'Delete plan',
                        onPressed: onDelete,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onOpen,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Start Plan'),
                            const SizedBox(width: 2),
                            const Icon(Icons.chevron_right, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanMetric extends StatelessWidget {
  const _PlanMetric({
    required this.icon,
    required this.label,
    required this.palette,
  });

  final IconData icon;
  final String label;
  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 13,
        color: palette.dark ? const Color(0xFF34D399) : const Color(0xFF059669),
      ),
      const SizedBox(width: 3),
      Text(label, style: TextStyle(fontSize: 10, color: palette.text)),
    ],
  );
}

class _PlanImageFallback extends StatelessWidget {
  const _PlanImageFallback({
    required this.palette,
    required this.icon,
    required this.accent,
  });

  final TrainingPalette palette;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    color: palette.dark ? const Color(0xFF252A38) : const Color(0xFFE2E8F0),
    child: Icon(icon, color: accent, size: 30),
  );
}

class _PlanIconAction extends StatelessWidget {
  const _PlanIconAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    tooltip: label,
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints.tightFor(width: 34, height: 34),
    style: IconButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    icon: Icon(icon, size: 17),
  );
}

class _NoMatchingPlans extends StatelessWidget {
  const _NoMatchingPlans({
    required this.palette,
    required this.isEmpty,
    required this.onCreate,
    required this.onImport,
    required this.onRestore,
  });

  final TrainingPalette palette;
  final bool isEmpty;
  final VoidCallback onCreate, onImport, onRestore;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: palette.container,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: palette.border),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isEmpty ? Icons.folder_off_outlined : Icons.search_off,
          size: 36,
          color: palette.secondary,
        ),
        const SizedBox(height: 12),
        Text(
          isEmpty
              ? 'No training plans saved yet'
              : 'No plans match your search',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: palette.text,
          ),
        ),
        if (isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Create a workout plan or import JSON to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.secondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create Plan'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.data_object),
              label: const Text('Import from JSON'),
            ),
          ),
          TextButton(
            onPressed: onRestore,
            child: const Text('Restore sample plans'),
          ),
        ],
      ],
    ),
  );
}
