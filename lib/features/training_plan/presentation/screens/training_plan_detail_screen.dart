import 'package:flutter/material.dart';

import '../../../training/presentation/widgets/training_overview_palette.dart';
import '../models/training_plan.dart';

class TrainingPlanDetailScreen extends StatelessWidget {
  const TrainingPlanDetailScreen({
    super.key,
    required this.plan,
    required this.onEdit,
    required this.onDuplicate,
    required this.onStart,
  });

  final TrainingPlan plan;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onStart;

  static const _lime = Color(0xFFC9F300);
  static const _cyan = Color(0xFF00DBE9);
  static const _surface = Color(0xFF111317);
  static const _low = Color(0xFF1A1C1F);
  static const _container = Color(0xFF1E2023);
  static const _high = Color(0xFF282A2D);
  static const _onSurface = Color(0xFFE2E2E6);
  static const _muted = Color(0xFFC5C9AC);
  static const _outline = Color(0xFF444933);

  @override
  Widget build(BuildContext context) {
    final palette = TrainingPalette(
      Theme.of(context).brightness == Brightness.dark,
    );
    final colors = _DetailColors(palette.dark);
    final activityCount =
        plan.warmUp.length + plan.exercises.length + plan.coolDown.length;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _DetailHeader(colors: colors),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  _PlanSummaryCard(
                    plan: plan,
                    activityCount: activityCount,
                    colors: colors,
                  ),
                  if (plan.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _DirectivesCard(notes: plan.notes, colors: colors),
                  ],
                  const SizedBox(height: 18),
                  _FocusBanner(plan: plan, colors: colors),
                  if (plan.warmUp.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _ActivitySection(
                      title: 'Warm-Up',
                      activities: plan.warmUp,
                      colors: colors,
                      icon: Icons.monitor_heart_outlined,
                      accent: colors.cyan,
                      isDetailed: false,
                    ),
                  ],
                  const SizedBox(height: 20),
                  _ActivitySection(
                    title: plan.type == 'Running'
                        ? 'Main Run / Intervals'
                        : 'Main Exercises',
                    activities: plan.exercises,
                    colors: colors,
                    icon: plan.type == 'Running'
                        ? Icons.directions_run
                        : Icons.fitness_center,
                    accent: colors.lime,
                    isDetailed: true,
                  ),
                  if (plan.coolDown.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _ActivitySection(
                      title: 'Cool-Down Recovery',
                      activities: plan.coolDown,
                      colors: colors,
                      icon: Icons.self_improvement,
                      accent: colors.cyan,
                      isDetailed: false,
                    ),
                  ],
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _DetailActions(
        colors: colors,
        onStart: onStart,
        onEdit: onEdit,
        onDuplicate: onDuplicate,
      ),
    );
  }
}

class _DetailColors {
  const _DetailColors(this.dark);

  final bool dark;

  Color get background =>
      dark ? TrainingPlanDetailScreen._surface : const Color(0xFFF8FAFC);
  Color get card => dark ? TrainingPlanDetailScreen._low : Colors.white;
  Color get container =>
      dark ? TrainingPlanDetailScreen._container : const Color(0xFFF1F5F9);
  Color get high =>
      dark ? TrainingPlanDetailScreen._high : const Color(0xFFE2E8F0);
  Color get text =>
      dark ? TrainingPlanDetailScreen._onSurface : const Color(0xFF0F172A);
  Color get muted =>
      dark ? TrainingPlanDetailScreen._muted : const Color(0xFF64748B);
  Color get border =>
      dark ? TrainingPlanDetailScreen._outline : const Color(0xFFE2E8F0);
  Color get lime =>
      dark ? TrainingPlanDetailScreen._lime : const Color(0xFF65A30D);
  Color get cyan =>
      dark ? TrainingPlanDetailScreen._cyan : const Color(0xFF0891B2);
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.colors});

  final _DetailColors colors;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back, color: colors.text),
          ),
          Expanded(
            child: Text(
              'Routine Detail',
              style: TextStyle(
                color: colors.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -.25,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: colors.container,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off, size: 14, color: colors.cyan),
                const SizedBox(width: 5),
                Text(
                  'LOCAL SYNC',
                  style: TextStyle(
                    color: colors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          CircleAvatar(
            radius: 15,
            backgroundColor: colors.text,
            child: Icon(Icons.person, size: 17, color: colors.background),
          ),
          const SizedBox(width: 6),
        ],
      ),
    ),
  );
}

class _PlanSummaryCard extends StatelessWidget {
  const _PlanSummaryCard({
    required this.plan,
    required this.activityCount,
    required this.colors,
  });

  final TrainingPlan plan;
  final int activityCount;
  final _DetailColors colors;

  @override
  Widget build(BuildContext context) {
    final scheduled = plan.scheduledDate == null
        ? plan.date
        : trainingPlanDateLabel(plan.scheduledDate!);

    return _SurfaceCard(
      colors: colors,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: 14, color: colors.lime),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Scheduled: $scheduled',
                  style: TextStyle(
                    color: colors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            plan.title,
            style: TextStyle(
              color: colors.text,
              fontSize: 20,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),
          if (plan.description.trim().isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              plan.description,
              style: TextStyle(color: colors.muted, fontSize: 11, height: 1.3),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'DURATION',
                  value: plan.duration,
                  accent: colors.text,
                  colors: colors,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SummaryMetric(
                  label: 'INTENSITY',
                  value: plan.rpe,
                  accent: colors.lime,
                  colors: colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'ACTIVITIES',
                  value: '$activityCount total',
                  accent: colors.text,
                  colors: colors,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SummaryMetric(
                  label: 'TARGET PHASE',
                  value: plan.focus.isEmpty ? plan.type : plan.focus,
                  accent: colors.cyan,
                  colors: colors,
                ),
              ),
            ],
          ),
          if (plan.targetEvent.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _TargetEvent(plan: plan, colors: colors),
          ],
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.accent,
    required this.colors,
  });

  final String label;
  final String value;
  final Color accent;
  final _DetailColors colors;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 51),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    decoration: BoxDecoration(
      color: colors.container,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent == colors.text ? colors.text : accent,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _TargetEvent extends StatelessWidget {
  const _TargetEvent({required this.plan, required this.colors});

  final TrainingPlan plan;
  final _DetailColors colors;

  String? get _timeUntilEvent {
    final eventDate = plan.eventDate;
    if (eventDate == null) return null;
    final today = DateTime.now();
    final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final days = eventDay.difference(todayDate).inDays;
    if (days < 0) return null;
    if (days == 0) return 'Today';
    return '${days}d Out';
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = plan.eventDate == null
        ? ''
        : ' · ${trainingPlanDateLabel(plan.eventDate!)}';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.high,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: colors.cyan.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flag_outlined, size: 17, color: colors.cyan),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRIMARY TARGET',
                  style: TextStyle(
                    color: colors.cyan,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
                Text(
                  '${plan.targetEvent}$dateLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_timeUntilEvent case final label?) ...[
            const SizedBox(width: 6),
            _SmallPill(label: label, colors: colors, accent: colors.lime),
          ],
        ],
      ),
    );
  }
}

class _DirectivesCard extends StatelessWidget {
  const _DirectivesCard({required this.notes, required this.colors});

  final String notes;
  final _DetailColors colors;

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    colors: colors,
    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
    accent: colors.lime,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology_outlined, size: 17, color: colors.lime),
            const SizedBox(width: 6),
            Text(
              'PLAN NOTES',
              style: TextStyle(
                color: colors.lime,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          notes,
          style: TextStyle(color: colors.text, fontSize: 12, height: 1.4),
        ),
      ],
    ),
  );
}

class _FocusBanner extends StatelessWidget {
  const _FocusBanner({required this.plan, required this.colors});

  final TrainingPlan plan;
  final _DetailColors colors;

  @override
  Widget build(BuildContext context) {
    final imageUrl = plan.imageUrl.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 92,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colors.high, colors.card, colors.background],
                ),
              ),
              child: Icon(
                plan.icon,
                size: 42,
                color: colors.muted.withValues(alpha: .3),
              ),
            ),
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.card.withValues(alpha: .86),
                    colors.card.withValues(alpha: .25),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'TRAINING FOCUS',
                    style: TextStyle(
                      color: colors.cyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    plan.focus.isEmpty ? plan.type : plan.focus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
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

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({
    required this.title,
    required this.activities,
    required this.colors,
    required this.icon,
    required this.accent,
    required this.isDetailed,
  });

  final String title;
  final List<TrainingPlanActivity> activities;
  final _DetailColors colors;
  final IconData icon;
  final Color accent;
  final bool isDetailed;

  String get _durationSummary {
    final durations = activities
        .map((activity) => activity.duration.trim())
        .where((duration) => duration.isNotEmpty)
        .toList();
    if (durations.isEmpty) return '${activities.length} Activities';
    return '${activities.length} Activities · ${durations.join(' + ')}';
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 19, color: accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: colors.text,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _SmallPill(
            label: isDetailed
                ? '${activities.length} Exercises'
                : _durationSummary,
            colors: colors,
            accent: colors.muted,
          ),
        ],
      ),
      if (activities.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _SurfaceCard(
            colors: colors,
            padding: const EdgeInsets.all(14),
            child: Text(
              'No ${title.toLowerCase()} added to this plan yet.',
              style: TextStyle(color: colors.muted, fontSize: 12),
            ),
          ),
        )
      else ...[
        const SizedBox(height: 8),
        ...activities.indexed.map((entry) {
          final (index, activity) = entry;
          if (isDetailed) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ExerciseCard(
                activity: activity,
                index: index,
                colors: colors,
                accent: index < 3 ? accent : colors.border,
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _ActivityRow(
              activity: activity,
              colors: colors,
              accent: accent,
              fallbackIcon: icon,
            ),
          );
        }),
      ],
    ],
  );
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.activity,
    required this.colors,
    required this.accent,
    required this.fallbackIcon,
  });

  final TrainingPlanActivity activity;
  final _DetailColors colors;
  final Color accent;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (activity.duration.trim().isNotEmpty) activity.duration.trim(),
      if (activity.sets.trim().isNotEmpty && activity.reps.trim().isNotEmpty)
        '${activity.sets} sets × ${activity.reps} reps',
      if (activity.muscles.trim().isNotEmpty) activity.muscles.trim(),
      if (activity.notes.trim().isNotEmpty) activity.notes.trim(),
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.container,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(fallbackIcon, size: 18, color: accent),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (details.isNotEmpty)
                  Text(
                    details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 10,
                      height: 1.3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.check_circle_outline, size: 17, color: colors.muted),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.activity,
    required this.index,
    required this.colors,
    required this.accent,
  });

  final TrainingPlanActivity activity;
  final int index;
  final _DetailColors colors;
  final Color accent;

  String get _volume {
    if (activity.duration.trim().isNotEmpty) return activity.duration.trim();
    if (activity.sets.trim().isEmpty && activity.reps.trim().isEmpty) {
      return 'Not set';
    }
    if (activity.reps.trim().isEmpty) return '${activity.sets} sets';
    if (activity.sets.trim().isEmpty) return activity.reps;
    return '${activity.sets} × ${activity.reps}';
  }

  String get _load => activity.weight.trim().isEmpty
      ? (activity.muscles.trim().isEmpty ? 'Not set' : activity.muscles.trim())
      : activity.weight.trim();

  @override
  Widget build(BuildContext context) => _SurfaceCard(
    colors: colors,
    padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
    accent: accent,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXERCISE ${(index + 1).toString().padLeft(2, '0')} · ${activity.muscles.isEmpty ? 'PLAN ACTIVITY' : activity.muscles.toUpperCase()}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent == colors.border ? colors.muted : accent,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: .6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          activity.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ExerciseMetric(
                label: 'VOLUME',
                value: _volume,
                colors: colors,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _ExerciseMetric(
                label: 'REST',
                value: activity.rest.trim().isEmpty ? 'Not set' : activity.rest,
                colors: colors,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: _ExerciseMetric(
                label: activity.weight.trim().isEmpty ? 'TARGET' : 'LOAD',
                value: _load,
                colors: colors,
                accent: accent,
              ),
            ),
          ],
        ),
        if (activity.notes.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, size: 14, color: colors.cyan),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  activity.notes,
                  style: TextStyle(
                    color: colors.muted,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _ExerciseMetric extends StatelessWidget {
  const _ExerciseMetric({
    required this.label,
    required this.value,
    required this.colors,
    this.accent,
  });

  final String label;
  final String value;
  final _DetailColors colors;
  final Color? accent;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 46),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    decoration: BoxDecoration(
      color: colors.container,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.muted,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accent ?? colors.text,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ],
    ),
  );
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({
    required this.label,
    required this.colors,
    required this.accent,
  });

  final String label;
  final _DetailColors colors;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 150),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: colors.container,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w700),
    ),
  );
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.colors,
    required this.padding,
    required this.child,
    this.accent,
  });

  final _DetailColors colors;
  final EdgeInsets padding;
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: colors.dark ? Colors.transparent : colors.border,
      ),
    ),
    child: accent == null
        ? child
        : IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: child),
              ],
            ),
          ),
  );
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.colors,
    required this.onStart,
    required this.onEdit,
    required this.onDuplicate,
  });

  final _DetailColors colors;
  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: .97),
        border: Border(
          top: BorderSide(
            color: colors.dark ? Colors.transparent : colors.border,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 46,
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.lime,
                foregroundColor: const Color(0xFF171E00),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text(
                'Start Workout',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _SecondaryAction(
                  label: 'Edit Plan',
                  icon: Icons.edit_outlined,
                  colors: colors,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SecondaryAction(
                  label: 'Duplicate Plan',
                  icon: Icons.content_copy,
                  colors: colors,
                  onPressed: onDuplicate,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final _DetailColors colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.text,
        backgroundColor: colors.high,
        side: BorderSide(
          color: colors.dark ? Colors.transparent : colors.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 5),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
