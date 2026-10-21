# Motion Orbit — Product and Feature Guidelines

> These product rules apply to the Motion Orbit Flutter Android application. The Codex execution rules below remain mandatory. This document describes intended feature scope; it does **not** authorize implementing all features in a single task.

## Product Identity

- **App:** Motion Orbit — *Train Smart. Move Better.*
- **Positioning:** Offline-first personal fitness and lifestyle tracker, with **Training Plans as the core product experience**. It is a tracker and planning tool, not an application that constantly pressures the user to exercise.
- **Platform:** Android, Flutter. Follow existing project patterns and its current storage technology (ObjectBox where already established); do not introduce packages or reorganize architecture without a task-specific need.
- **Offline-first:** Primary flows must work without internet. Persist personal data locally. Do not require sign-in.
- **Authentication roadmap (not current implementation scope):** MVP local/guest profile; later local export/import; then optional Google Sign-In, cloud backup, and cross-device sync. Never gate local tracking behind Google login.
- **Branding direction:** Electric Blue `#2563EB`, Deep Navy `#0F172A`; consistent light/dark theming including relevant icons, illustrations, surfaces, and states. Follow an existing design system when present rather than forcing these colors.

## Navigation Contract — Exactly Four Primary Tabs

The main navigation must expose these four primary destinations, in this order:

1. **Home** — daily overview and shortcuts.
2. **Training** — plans and recording actual physical activities.
3. **Explore** — muscles, exercises, and learning.
4. **Profile** — personal baseline, body progress, goals, and settings.

Use **Training**, not **Workout**, for the second main tab. Do not create separate bottom tabs for Nutrition, Sleep, Running, AI Coach, Progress, or Settings. All four tabs must have recognizable selected/unselected states, consistent navigation behavior, and meaningful empty states. Do not invent a fifth primary destination.

## Home — Daily Overview, Not a Feature Monolith

The Home screen should aggregate today's relevant information and offer clear entry points:

- **Today's Training:** prominent next scheduled workout or rest day; link to the corresponding Training Plan / session. This is the primary call-to-action when applicable.
- **Daily Overview:** summary of actual logged activity and progress for the day.
- **Nutrition:** meal logs and basic nutrition summaries.
- **Sleep:** sleep logging, duration, quality, and history.
- **Recovery:** user-provided recovery indicators and related summaries; avoid pretending they are clinically measured values.
- **Recommendations:** contextual, non-prescriptive AI/rule-based suggestions embedded where relevant, not a new main tab.
- **Quick Add:** Meal, Sleep, Run, Weight, with shortcuts to the appropriate existing feature flows.

Home owns the dashboard/presentation and routing only. Nutrition, Sleep, Recovery, Running, and Strength Training remain independently owned feature modules where applicable; **do not implement their domain and storage logic inside `home`**.

## Training — The Highest-Priority Feature

**Training Plans (first priority):** Users should be able to view their plan, scheduled sessions, intended exercise details, and session completion/history. Build create/edit/record flows only as the task explicitly requests. Preserve distinction between planned training and completed training.

Other destinations under Training:

- **Strength Workout:** gym, calisthenics, and bodyweight; exercise sets, reps, weights, rest, and workout history as relevant to the requested screen.
- **Running:** tracking planned/completed runs and, where data exist, distance, duration, pace, and run/walk intervals.
- **Walking / Cycling:** separate activity types sharing appropriate tracking patterns.
- **Schedule:** calendar of training sessions; support rest days.
- **Reminders / Alarms:** notifications and countdowns only when implemented and permissioned; do not imply an alarm is active if it is not.
- **AI Form Analyzer:** assistive camera-based exercise-form indications for self-training. It is not a medical assessment or guaranteed correctness rating; use realistic labels such as "form indication". Offline inference is the design target; task-specific models may require a one-time download. A missing model must not block standard tracking.
- **Activity History:** actual completed sessions, distinct from planned sessions.

If space is limited in the Training landing screen, make **Training Plans** the leading and most prominent section; other activities should be accessible without turning the page into an unstructured button wall.

## Explore — Learn, Inspect, Choose

- **3D Muscle Explorer:** interactive muscle visualization (when supported); selecting a muscle surfaces exercises targeting it.
- **Exercise Library:** searchable/browsable exercises with technique guidance, equipment, and targeted muscles where recorded.
- **Exercise by Muscle:** muscle-group browsing leading to relevant exercises and optional addition to a plan.
- **Training Education:** form tips, recovery basics, and other relevant training guidance.
- The connection must be **bidirectional**: exercise -> targeted muscles; muscle -> relevant exercises.
- Muscle activity/progress visualization may summarize training exposure based on logs, but **must not claim to measure exact muscle gain or hypertrophy** from workout records alone.
- A static placeholder is acceptable where a real 3D renderer/model is not yet available, but label it honestly and do not fabricate working interactivity.

## Profile — User-Owned Data and Longitudinal Progress

- **Personal Information:** local profile and preferences.
- **Fitness Assessment / Baseline:** initial capabilities and periodic reassessment (e.g. push-up, sit-up, pull-up, stamina/running).
- **Body Measurements:** weight and user-entered circumferences/measurements with dates.
- **Fitness Progress:** longitudinal trends derived from logged data and assessments, with clear measurement units and time periods.
- **Goals:** user-selected targets and their tracked status.
- **Settings:** appearance/theme, units, data/privacy and relevant application preferences.

Before the first populated dashboard, onboarding collects the necessary basic profile, fitness baseline, goals, and training availability/preferences in a progressive, skippable-where-appropriate flow. On subsequent launches, restore locally saved onboarding/profile state and go to the dashboard; do not require login. Do not fake personal health measurements to populate the UI.

## Cross-Feature Rules

- **Single source of truth:** Every session/meal/sleep/measurement belongs to its own feature/domain; dashboard cards and progress views read existing records rather than maintaining duplicate state.
- **Navigation:** Every visible action goes to a relevant screen or is explicitly disabled/marked "Coming soon". Never expose nonworking "Start", "Save", or "Analyze" actions as if functional.
- **Empty/loading/error states:** distinguish no data from failure and from features not implemented; avoid fabricated achievements or metrics.
- **Time and units:** dates, training duration, kilograms, distance, and pace must be consistent and user-understandable; never confuse planned vs recorded values.
- **AI placement:** AI recommendations belong within Home, Training, and progress-oriented contexts; no separate AI Coach bottom tab. AI suggestions must not overwrite source data.
- **User control:** allow rest days and manual logging; no guilt-oriented copy, automatic workout creation, or forced training prompts.
- **UX and accessibility:** use readable typography, adequate touch targets, consistent labels, and light/dark-appropriate icons/illustrations rather than recoloring only the background.
- **Development scope:** This document is a product contract, not a blanket instruction to build every feature. Implement the user's requested scope only; reuse current code, style, conventions, and navigation.

## Suggested Feature Ownership (Conceptual Only)

`home` aggregates. Independent concerns may map to existing or eventual features such as `training_plans`, `strength_training`, `running`, `nutrition`, `sleep`, `recovery`, `explore`, `profile`, and `fitness_progress`. **These are conceptual boundaries, not instructions to create directories, new layers, or dependencies.** Examine only files relevant to the explicit task.

## Scope and Delivery Checklist

Before writing code, identify (1) user-requested tab/flow, (2) affected existing files, (3) existing components/models that can be reused, and (4) any unavailable data/models that require an honest empty state. After editing, summarize changed files and behavior, and disclose what was **not** validated. Do not run tests, builds, analysis, or package installation unless expressly requested.

---

# Codex Instructions

## Strict Execution Rules

* **File boundary:** For code tasks, create, edit, move, and delete files only inside `lib/` unless the user explicitly requests changes to a specific path outside `lib/`. A file being related to the requested feature does not authorize changing it. Never delete or modify design documents, documentation, assets, configuration, or other out-of-`lib/` files as cleanup.
* Do NOT run unit tests, widget tests, integration tests, `flutter test`, or any test command unless explicitly requested.
* Do NOT run `flutter build`, `flutter analyze`, `dart analyze`, or `flutter pub get` unless explicitly requested.
* Do NOT inspect the entire repository.
* Only open files directly related to the requested task.
* Do NOT refactor unrelated code.
* Do NOT rename or move files unless required by the task.
* Do NOT introduce new architecture, abstractions, helpers, or dependencies unless necessary.
* Reuse the existing project architecture and patterns.
* Make the minimum code changes required to complete the task.
* Before editing, identify the smallest set of files that need modification.
* Reuse existing implementations instead of creating duplicate implementations.
* Ignore unrelated warnings, lint issues, and cleanup opportunities.

## Working Style

* Prefer targeted edits over broad refactors.
* Every public `StatelessWidget` and `StatefulWidget` constructor must accept a named `Key? key` and forward it to `super` (prefer `super.key`).
* Do not explore unrelated features or directories.
* Do not modify files outside the task scope.
* When a reference implementation already exists, follow that pattern.
* Preserve existing naming conventions and project structure.

## Conditional Logic

* Avoid unnecessary `if` / `else` chains.
* Avoid deeply nested conditional logic.
* Prefer early returns and guard clauses to keep logic flat.
* Prefer `switch` expressions or `switch` statements when handling multiple known states, enums, statuses, or result types.
* Prefer extracting complex conditions into clearly named boolean variables when that improves readability.
* Prefer existing enums, mappings, or project patterns when they naturally reduce repetitive branching.
* Do NOT introduce unnecessary classes, helpers, strategies, extensions, or abstractions solely to eliminate a simple `if`.
* A simple and readable `if` is acceptable when it is clearer than the alternative.
* Keep conditional logic flat, readable, predictable, and easy to maintain.

### Prefer Early Return

Preferred:

```dart
if (employee == null) return;

saveEmployee(employee);
```

Avoid:

```dart
if (employee != null) {
  saveEmployee(employee);
}
```

Preferred:

```dart
if (!isLoggedIn) {
  return const LoginPage();
}

return const DashboardPage();
```

Avoid:

```dart
if (isLoggedIn) {
  return const DashboardPage();
} else {
  return const LoginPage();
}
```

Preferred:

```dart
if (response.statusCode != 200) {
  return handleHttpError(response);
}

if (response.data.status != 1) {
  return handleBusinessError(response.data);
}

return handleSuccess(response.data);
```

Avoid:

```dart
if (response.statusCode == 200) {
  if (response.data.status == 1) {
    return handleSuccess(response.data);
  } else {
    return handleBusinessError(response.data);
  }
} else {
  return handleHttpError(response);
}
```

### Prefer `switch` for Known States

Preferred:

```dart
switch (status) {
  case WorkPlanStatus.pending:
    return const PendingView();

  case WorkPlanStatus.approved:
    return const ApprovedView();

  case WorkPlanStatus.rejected:
    return const RejectedView();
}
```

Avoid:

```dart
if (status == WorkPlanStatus.pending) {
  return const PendingView();
} else if (status == WorkPlanStatus.approved) {
  return const ApprovedView();
} else if (status == WorkPlanStatus.rejected) {
  return const RejectedView();
}
```

### Prefer Flat Validation

Preferred:

```dart
if (employee == null) return;
if (schedule == null) return;
if (tasks.isEmpty) return;

submitWorkPlan();
```

Avoid:

```dart
if (employee != null) {
  if (schedule != null) {
    if (tasks.isNotEmpty) {
      submitWorkPlan();
    }
  }
}
```

### Prefer Named Conditions for Complex Logic

Preferred:

```dart
final canEditSchedule =
    !_editing &&
    employee != null &&
    selectedSchedule != null;

if (!canEditSchedule) return;
```

Avoid:

```dart
if (!_editing &&
    employee != null &&
    selectedSchedule != null) {
  // large block of logic
}
```

### Do Not Over-Engineer Simple Conditions

Preferred:

```dart
if (status == WorkPlanStatus.approved) {
  showApprovedMessage();
}
```

Avoid creating unnecessary abstractions such as:

```dart
abstract class StatusHandler {
  void handle();
}
```

or:

```dart
bool shouldShowApprovedMessage(WorkPlanStatus status) {
  return status == WorkPlanStatus.approved;
}
```

when the condition is simple, used only once, and already readable.

## General Principle

Prefer:

```text
guard clause
guard clause
guard clause
main logic
```

over:

```text
if
  if
    if
      main logic
```

The goal is not to eliminate every `if`.

The goal is to avoid:

* deeply nested conditions
* long `if / else if / else` chains
* duplicated conditions
* unnecessary branching
* unreadable control flow

Use the simplest readable solution.
