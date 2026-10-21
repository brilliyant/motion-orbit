import 'package:flutter/material.dart';

import 'training_overview_palette.dart';

class WeekSection extends StatelessWidget {
  const WeekSection({super.key, required this.palette});
  final TrainingPalette palette;

  static const _days = [
    ('Mon', 'Upper', Icons.check, true),
    ('Tue', 'Run', Icons.check, true),
    ('Wed', 'Rest', Icons.circle, false),
    ('Thu', 'Today', Icons.fitness_center, true),
    ('Fri', 'Rest', Icons.circle, false),
    ('Sat', 'Tempo', Icons.directions_run, true),
    ('Sun', 'Stretch', Icons.self_improvement, true),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SectionHeading(title: 'This Week', trailing: 'Oct 14 – 20', palette: palette),
      const SizedBox(height: 9),
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            for (var i = 0; i < _days.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == _days.length - 1 ? 0 : 4),
                  child: DayCell(day: _days[i], today: i == 3, palette: palette),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

class DayCell extends StatelessWidget {
  const DayCell({super.key, required this.day, required this.today, required this.palette});
  final (String, String, IconData, bool) day;
  final bool today;
  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) {
    final muted = day.$2 == 'Rest';
    final accent = const Color(0xFF84CC16);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 1),
      decoration: BoxDecoration(
        color: today ? accent : muted ? palette.subtle.withValues(alpha: .65) : palette.subtle,
        borderRadius: BorderRadius.circular(12),
        border: today ? Border.all(color: const Color(0xFFA3E635), width: 2) : null,
      ),
      child: Column(
        children: [
          Text(day.$1, style: TextStyle(fontSize: 10, fontWeight: today ? FontWeight.w800 : FontWeight.w600, color: today ? const Color(0xFF0F172A) : muted ? palette.disabled : palette.secondary)),
          const SizedBox(height: 6),
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: today ? Colors.black.withValues(alpha: .13) : day.$3 == Icons.check ? const Color(0xFFD1FAE5) : muted ? palette.container : Colors.transparent,
              shape: BoxShape.circle,
              border: !today && !muted && day.$3 != Icons.check ? Border.all(color: palette.border) : null,
            ),
            child: Icon(day.$2 == 'Rest' ? Icons.circle : day.$3, size: muted ? 6 : 15, color: today ? const Color(0xFF0F172A) : day.$3 == Icons.check ? const Color(0xFF059669) : muted ? palette.disabled : palette.secondary),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(day.$2, maxLines: 1, style: TextStyle(fontSize: 9, fontWeight: today ? FontWeight.w800 : FontWeight.w500, color: today ? const Color(0xFF0F172A) : muted ? palette.disabled : palette.secondary)),
          ),
        ],
      ),
    );
  }
}
