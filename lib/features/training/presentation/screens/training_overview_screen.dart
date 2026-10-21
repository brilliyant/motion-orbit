import 'package:flutter/material.dart';

import '../widgets/training_overview_activity_widgets.dart';
import '../widgets/training_overview_history_widgets.dart';
import '../widgets/training_overview_palette.dart';
import '../widgets/training_overview_plan_widgets.dart';
import '../widgets/training_overview_schedule_widgets.dart';

class TrainingOverviewScreen extends StatelessWidget {
  const TrainingOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final palette = TrainingPalette(dark);

    return ColoredBox(
      color: palette.background,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ActivePlanCard(palette: palette),
                const SizedBox(height: 22),
                WeekSection(palette: palette),
                const SizedBox(height: 22),
                TodayWorkoutSection(palette: palette),
                const SizedBox(height: 22),
                QuickWorkoutSection(palette: palette),
                const SizedBox(height: 16),
                UtilityActions(palette: palette),
                const SizedBox(height: 22),
                PastWorkoutsSection(palette: palette),
                const SizedBox(height: 16),
                ComingSoonCard(palette: palette),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

