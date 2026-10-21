import 'package:flutter/material.dart';

import 'training_overview_palette.dart';

const _heroImage =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuALtBdF6tvfRGLU8MFwvVvh5bfVwOU-kX0XB9YVAEXxJI70U2BU0KtIIIUG61auvoz84jaf_80lgP96Xu-gieHAROyNgez45XKKSN5QA968_JhSlBp33Rh80hNxabbnL8FfVVDQbgvwj14DFiQAeyRC-ymeXUa2dPj9uxHWIDQx1zNxZqh3vmKmyx1WCH7Z9_uM0ZaprsvZHU27wFN2fU0hqjQs9wX0oJjET3t05JYc6X03TEQF_a0Z';

class ActivePlanCard extends StatelessWidget {
  const ActivePlanCard({super.key, required this.palette});
  final TrainingPalette palette;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: palette.card,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: palette.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 176,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                _heroImage,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const HeroFallback(),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, palette.card],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusPill(label: 'ACTIVE PLAN', palette: palette),
                    TrainingBadge(label: '5 of 12 Done', palette: palette),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Strength & Endurance',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: palette.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Phase 1 • Week 2 of 8',
                style: TextStyle(fontSize: 12, color: palette.secondary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Plan Progress',
                    style: TextStyle(color: palette.secondary),
                  ),
                  const Text(
                    '42% completed',
                    style: TextStyle(color: Color(0xFF65A30D)),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: .42,
                  minHeight: 8,
                  backgroundColor: palette.container,
                  color: const Color(0xFF84CC16),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: 'Adherence',
                      value: '92%',
                      hint: 'on track',
                      palette: palette,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MetricCard(
                      label: 'Total Volume',
                      value: '19,840',
                      hint: 'kg',
                      palette: palette,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => showTrainingMessage(
                  context,
                  'Your full training plan is coming soon.',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(42),
                  backgroundColor: palette.container,
                  foregroundColor: palette.text,
                  side: BorderSide(color: palette.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Text(
                      'View Full Plan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward, size: 17),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
