import 'package:flutter/material.dart';

class TrainingPalette {
  const TrainingPalette(this.dark);
  final bool dark;

  Color get background =>
      dark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC);
  Color get card => dark ? const Color(0xFF181B26) : Colors.white;
  Color get container =>
      dark ? const Color(0xFF131620) : const Color(0xFFF1F5F9);
  Color get border => dark ? const Color(0xFF232738) : const Color(0xFFE2E8F0);
  Color get text => dark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  Color get secondary =>
      dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get disabled =>
      dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  Color get chipText =>
      dark ? const Color(0xFFE2E8F0) : const Color(0xFF334155);
  Color get subtle => dark ? const Color(0xFF1C2130) : const Color(0xFFF8FAFC);
}

class HeroFallback extends StatelessWidget {
  const HeroFallback({super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF334155), Color(0xFF65A30D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: const Center(
      child: Icon(Icons.fitness_center, size: 68, color: Colors.white70),
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.palette});
  final String label;
  final TrainingPalette palette;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: palette.card.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: const Color(0xFF84CC16).withValues(alpha: .4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF84CC16),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .7,
            color: Color(0xFF4D7C0F),
          ),
        ),
      ],
    ),
  );
}

class TrainingBadge extends StatelessWidget {
  const TrainingBadge({super.key, required this.label, required this.palette});
  final String label;
  final TrainingPalette palette;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: palette.card.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: palette.border),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: palette.secondary,
      ),
    ),
  );
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.palette,
  });
  final String label, value, hint;
  final TrainingPalette palette;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: palette.container,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: palette.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: palette.secondary)),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: palette.text,
              ),
            ),
            const SizedBox(width: 5),
            if (label == 'Adherence')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.dark
                      ? const Color(0xFF26351B)
                      : const Color(0xFFECFCCB),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF4D7C0F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else
              Text(
                hint,
                style: TextStyle(fontSize: 10, color: palette.secondary),
              ),
          ],
        ),
      ],
    ),
  );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.title,
    required this.trailing,
    this.palette,
  });
  final String title, trailing;
  final TrainingPalette? palette;
  @override
  Widget build(BuildContext context) {
    final colors =
        palette ??
        TrainingPalette(Theme.of(context).brightness == Brightness.dark);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.text,
          ),
        ),
        Text(
          trailing,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.secondary,
          ),
        ),
      ],
    );
  }
}

class TrainingCard extends StatelessWidget {
  const TrainingCard({
    super.key,
    required this.palette,
    required this.padding,
    required this.child,
  });
  final TrainingPalette palette;
  final EdgeInsets padding;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: palette.card,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: palette.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: palette.dark ? .1 : .025),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}
void showTrainingMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}
