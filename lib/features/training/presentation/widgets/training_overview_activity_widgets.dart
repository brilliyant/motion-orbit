import 'package:flutter/material.dart';

import '../../../training_plan/presentation/screens/training_plans_screen.dart';
import 'training_overview_palette.dart';

class TodayWorkoutSection extends StatelessWidget {
  const TodayWorkoutSection({super.key, required this.palette});
  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(title: "Today's Workout", trailing: 'Est. 50 mins', palette: palette),
      const SizedBox(height: 9),
      TrainingCard(
        palette: palette,
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('UPPER BODY STRENGTH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .7, color: Color(0xFF65A30D))),
                      const SizedBox(height: 4),
                      Text('5 movements • 17 working sets', style: TextStyle(fontSize: 11, color: palette.secondary)),
                    ],
                  ),
                ),
                TrainingBadge(label: 'Moderate Heavy', palette: palette),
              ],
            ),
            const SizedBox(height: 15),
            const Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ExerciseChip('Bench Press', '4×6'),
                ExerciseChip('Overhead Press', '3×8'),
                ExerciseChip('Bent-Over Row', '4×8'),
                ExerciseChip('Incline DB Press', '3×10'),
                ExerciseChip('Cable Pushdowns', '3×12'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => showTrainingMessage(context, 'Workout tracking is coming soon.'),
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('Start Workout'),
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF84CC16), foregroundColor: const Color(0xFF0F172A), minimumSize: const Size(0, 48)),
                  ),
                ),
                const SizedBox(width: 9),
                OutlinedButton.icon(
                  onPressed: () => showTrainingMessage(context, 'Exercise preview is coming soon.'),
                  icon: const Icon(Icons.visibility_outlined, size: 17),
                  label: const Text('Preview'),
                  style: OutlinedButton.styleFrom(foregroundColor: palette.chipText, side: BorderSide(color: palette.border), minimumSize: const Size(0, 48)),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class ExerciseChip extends StatelessWidget {
  const ExerciseChip(this.name, this.sets, {super.key});
  final String name;
  final String sets;

  @override
  Widget build(BuildContext context) {
    final palette = TrainingPalette(Theme.of(context).brightness == Brightness.dark);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(color: palette.container, borderRadius: BorderRadius.circular(8), border: Border.all(color: palette.border)),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 10, color: palette.chipText, fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily),
          children: [
            TextSpan(text: '$name  '),
            TextSpan(text: sets, style: TextStyle(color: palette.dark ? const Color(0xFFA3E635) : const Color(0xFF4D7C0F), fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class QuickWorkoutSection extends StatelessWidget {
  const QuickWorkoutSection({super.key, required this.palette});
  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Start Training', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: palette.text)),
      const SizedBox(height: 2),
      Text('Choose a plan or start a quick workout', style: TextStyle(fontSize: 11, color: palette.secondary)),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child: QuickWorkoutTile(title: 'Plans', subtitle: 'Saved plans', icon: Icons.assignment_outlined, tint: const Color(0xFF65A30D), palette: palette, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TrainingPlansScreen())))),
          const SizedBox(width: 9),
          Expanded(child: QuickWorkoutTile(title: 'Lifting', subtitle: 'Free log', icon: Icons.fitness_center, tint: const Color(0xFF65A30D), palette: palette)),
          const SizedBox(width: 9),
          Expanded(child: QuickWorkoutTile(title: 'Running', subtitle: 'GPS pace', icon: Icons.directions_run, tint: const Color(0xFF059669), palette: palette)),
          const SizedBox(width: 9),
          Expanded(child: QuickWorkoutTile(title: 'Cardio', subtitle: 'Timer', icon: Icons.favorite, tint: const Color(0xFFD97706), palette: palette)),
        ],
      ),
    ],
  );
}

class QuickWorkoutTile extends StatelessWidget {
  const QuickWorkoutTile({super.key, required this.title, required this.subtitle, required this.icon, required this.tint, required this.palette, this.onTap});
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final TrainingPalette palette;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: palette.card,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap ?? () => showTrainingMessage(context, '$title logging is coming soon.'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: palette.border)),
        child: Column(
          children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: tint.withValues(alpha: .13), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: tint, size: 21)),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.text)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 9, color: palette.secondary)),
          ],
        ),
      ),
    ),
  );
}

class UtilityActions extends StatelessWidget {
  const UtilityActions({super.key, required this.palette});
  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: UtilityButton(icon: Icons.event_note, label: 'Schedule', palette: palette, onTap: () => showTrainingMessage(context, 'Your training schedule is coming soon.'))),
      const SizedBox(width: 10),
      Expanded(child: UtilityButton(icon: Icons.notifications_none, label: 'Reminders · 06:30', palette: palette, tint: const Color(0xFFF59E0B), onTap: () => showTrainingMessage(context, 'Reminder settings are coming soon.'))),
    ],
  );
}

class UtilityButton extends StatelessWidget {
  const UtilityButton({super.key, required this.icon, required this.label, required this.palette, required this.onTap, this.tint = const Color(0xFF65A30D)});
  final IconData icon;
  final String label;
  final TrainingPalette palette;
  final VoidCallback onTap;
  final Color tint;

  @override
  Widget build(BuildContext context) => Material(
    color: palette.card,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: palette.border)),
        child: Row(
          children: [
            Icon(icon, size: 18, color: tint),
            const SizedBox(width: 7),
            Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: palette.text))),
            if (label == 'Schedule') const Icon(Icons.circle, size: 7, color: Color(0xFF10B981)),
          ],
        ),
      ),
    ),
  );
}
