import 'package:flutter/material.dart';

import 'training_overview_palette.dart';

class PastWorkoutsSection extends StatelessWidget {
  const PastWorkoutsSection({super.key, required this.palette});
  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Past Workouts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: palette.text)),
          TextButton(
            onPressed: () => showTrainingMessage(context, 'Workout history is coming soon.'),
            child: const Text('View All', style: TextStyle(fontSize: 11, color: Color(0xFF65A30D), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      WorkoutHistoryRow(icon: Icons.check_circle, title: 'Upper Body Strength', detail: 'Yesterday • 18 sets • 48 mins', color: const Color(0xFF059669), palette: palette),
      const SizedBox(height: 8),
      WorkoutHistoryRow(icon: Icons.directions_run, title: 'Morning Recovery Run', detail: '2 days ago • 4.2 km • 24 mins', color: const Color(0xFF65A30D), palette: palette),
    ],
  );
}

class WorkoutHistoryRow extends StatelessWidget {
  const WorkoutHistoryRow({super.key, required this.icon, required this.title, required this.detail, required this.color, required this.palette});
  final IconData icon;
  final String title;
  final String detail;
  final Color color;
  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: palette.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: palette.border)),
    child: Row(
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.text)),
              const SizedBox(height: 3),
              Text(detail, style: TextStyle(fontSize: 10, color: palette.secondary)),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: palette.disabled, size: 19),
      ],
    ),
  );
}

class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({super.key, required this.palette});
  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: palette.card.withValues(alpha: .8), borderRadius: BorderRadius.circular(12), border: Border.all(color: palette.border)),
    child: Row(
      children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: palette.container, borderRadius: BorderRadius.circular(9)), child: Icon(Icons.videocam_outlined, color: palette.secondary, size: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Form Analyzer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: palette.text)),
              const SizedBox(height: 3),
              Text('Posture and rep guidance in an upcoming update', style: TextStyle(fontSize: 9, color: palette.secondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(color: palette.container, borderRadius: BorderRadius.circular(20), border: Border.all(color: palette.border)),
          child: Text('Coming Soon', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: palette.secondary)),
        ),
      ],
    ),
  );
}
