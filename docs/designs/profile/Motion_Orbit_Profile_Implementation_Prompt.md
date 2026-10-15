# Motion Orbit — Profile Module Implementation (Codex / Copilot)

You are a Senior Flutter Engineer working on **Motion Orbit**, an offline-first Android fitness and lifestyle tracking application.

## 1. Design Reference

Project root (Windows):

`C:\Users\LENOVO\Documents\Flutter\motion_orbit`

Read the consolidated Stitch HTML design at this **project-relative path**:

`docs/designs/profile/motion_orbit_stitch_profile_combined.html`

The HTML contains 11 Profile module screens. It is the **primary visual reference**, not application source code.

- Preserve the intended visual hierarchy, colors, typography, spacing, icons, forms, cards, charts, and individual screen layouts.
- Treat the consolidated HTML's navigation/sidebar as a **preview-only wrapper**; do not reproduce that sidebar in the Android app.
- Extract each screen's design independently and map navigation based on the application's actual routes.
- Do **not** modify, move, rename, or delete the reference HTML.
- Do **not** create another design-reference folder.
- Do **not** use WebView, HTML rendering, React, or an embedded browser. Use native Flutter widgets.
- Resolve discrepancies between mock content and actual product behavior in favor of existing requirements and real local data.

If the specified file does not exist, report that precise missing path instead of inventing another location.

## 2. Screens to Implement

Implement the following **11 screens** in the existing Flutter project:

1. Profile Overview
2. Personal Information
3. Fitness Assessment Dashboard
4. Record Assessment
5. Assessment History
6. Body Measurements
7. Add Body Measurement
8. Progress Overview
9. Goals Overview
10. Create / Edit Goal
11. Settings

Use the Stitch designs for UI fidelity, while ensuring the screens work together as one coherent Profile experience.

## 3. Architecture and Scope

Follow the project's **existing feature-first Clean Architecture**. Before editing:

- Inspect only the smallest relevant set of files: app navigation, theme/shared widgets, Profile-related features, ObjectBox setup, storage/preferences, and relevant project requirements.
- Identify and reuse existing entities, models, controllers/state patterns, repositories, use cases, local data sources, widgets, and routes.
- Avoid duplicating or replacing working implementations.
- Do not refactor unrelated features, reorganize directories, or introduce new architectural conventions unnecessarily.

Feature ownership should follow existing project conventions. Where separate features already exist, use them; otherwise keep responsibilities clear:

| Feature | Responsibility |
| --- | --- |
| `profile` | Profile Overview, Personal Information, navigation hub |
| `fitness_assessment` | Assessment dashboard, recording, history/comparisons |
| `body_measurements` | Current measurements, adding and viewing history |
| `fitness_progress` | Progress overview derived from logged data |
| `goals` | Primary/secondary goals, create/edit, status and progress |
| `settings` | Appearance, units, language, reminders and privacy options |

Do not force these exact directory names if the repository already uses different patterns.

## 4. Local Persistence and Offline-First Behavior

- Keep the MVP usable **without login**; preserve the current local/guest user identity.
- Use the **existing ObjectBox** integration for persistent structured fitness/profile records.
- Use the existing **SharedPreferences** conventions only for suitable lightweight preferences.
- Never introduce mandatory Google Sign-In, cloud APIs, cloud sync, or authentication.
- Personal information, assessments, measurements, and goals must persist across application restarts.
- Calculate derived progress from actual stored records rather than arbitrary design placeholders.
- When there are no records, show honest, appropriate empty states.
- Keep body-composition and muscle-growth claims evidence-based; workout logs alone do not prove hypertrophy.

The Stitch HTML contains illustrative metrics, names, dates, progress percentages, and UI labels. These are **mock content**, not production records or business rules. Do not persist or claim them as real data. In particular, do not reproduce inaccurate storage/sync claims (for example, a mock SQLite database status when the project uses ObjectBox).

## 5. Navigation

Preserve the app's four main tabs:

**Home | Training | Explore | Profile**

- Integrate Profile Overview into the existing Profile tab without replacing the application's main navigation.
- Wire the 11 Profile screens to their intended routes, including back behavior.
- Maintain form state during appropriate in-module navigation.
- Use existing navigation/router patterns; do not add routing dependencies.
- Profile is an entry point and an overview, not the owner of every independent feature's data layer.

## 6. Native Flutter UI Requirements

- Use Flutter primitives such as `Scaffold`, `SafeArea`, `ListView` / `CustomScrollView`, `Card`, `TextFormField`, buttons, selectors, dialogs, and bottom sheets as appropriate.
- Reuse the current theme, color tokens, typography, icons, and shared components.
- Match the Stitch design's Lexend and Manrope visual styles when those fonts/assets are already available; do not add packages without approval.
- Reuse existing chart solutions. If a chart requires a new dependency, report the limitation instead of adding one silently.
- Preserve proper spacing, scrolling, keyboard handling, overflow safety, and common Android screen sizes/text scaling.
- No preview-only sidebar, Tailwind, DOM, or raw HTML in production Flutter.
- Treat externally hosted images in Stitch as design references; do not assume they work offline or are already licensed/bundled.

## 7. Screen Behaviors

### Profile Overview
- Present real user profile summary, measurements, training consistency if available, and links to relevant Profile subfeatures.
- Replace missing values with sensible empty states rather than fake telemetry.

### Personal Information
- Edit user details, relevant fitness background and equipment/preferences represented in the design.
- Validate applicable fields, save them locally, and reload them reliably.

### Fitness Assessment Dashboard / Record Assessment / History
- Support applicable assessment test types (e.g., push-up, sit-up, plank, pull-up, 12-minute run) with suitable units such as repetitions, time, and distance.
- Record assessment date and values with validation.
- Display chronological records and comparisons only when sufficient historical data exists.
- Keep camera-based rep tracking out of scope: manual entry for now.
- Do not fabricate percentile rankings or fitness indices without an established calculation rule.

### Body Measurements / Add Body Measurement
- Record measurements with dates and appropriate units.
- Show the latest recorded values and history-based changes.
- Calculate BMI from valid height and weight when available; do not present BMI as a direct body-composition measurement.

### Progress Overview
- Show progress and trends based on real local assessment, body, and training records.
- Handle time filters and insufficient data appropriately.
- Avoid guessed muscle-mass figures and unsupported physiological conclusions.

### Goals Overview / Create or Edit Goal
- Create and edit primary/secondary fitness goals, applicable measurable targets, dates, and supported status.
- Derive completion indicators from the correct logged metrics where possible.
- Goal changes may suggest reviewing the Training Plan but must **not silently overwrite** the user's workout schedule.

### Settings
- Implement and persist supported preferences using existing systems.
- Reuse existing theme/unit/language/reminder implementations if available.
- Do not claim permissions, export/backup, cloud sync, or notifications are functional when unimplemented.
- If an interaction requires an unavailable service or dependency, report it clearly instead of faking success.

## 8. Strict Execution Rules

- Do **not** create unit tests, widget tests, integration tests, or test files unless requested.
- Do **not** run tests, builds, `flutter analyze`, `flutter pub get`, or code-generation commands unless explicitly requested.
- Do **not** install new dependencies without approval.
- Do **not** inspect the whole repository; examine only relevant files.
- Do **not** refactor unrelated logic, rename/move existing files, or change unrelated public APIs.
- Make the smallest necessary code changes and reuse current patterns.
- Prefer early returns when appropriate; avoid unnecessarily nested `if/else` blocks.
- Ignore unrelated warnings.
- Do **not** implement AI Form Analyzer, camera tracking, or cloud features as part of this work.

## 9. Execution Plan

Proceed through the phases below in order, using the existing project patterns:

**Phase 1 — Inspect and map**
- Read the consolidated HTML and relevant implementation files.
- Identify each of the 11 embedded screens, their visual elements, and expected navigation.
- Identify reusable components, existing data ownership, and minimal file changes.

**Phase 2 — Foundation**
- Reuse or minimally extend design tokens, shared widgets, and routing needed by the Profile screens.

**Phase 3 — UI screens**
- Implement native Flutter UIs faithful to the 11 screen designs.
- Connect route navigation and form interactions.

**Phase 4 — Real local data**
- Integrate existing ObjectBox and preferences patterns as needed.
- Replace design mock data with real persisted records and empty states.
- Add only the minimum required entities, repositories, and use cases.

**Phase 5 — Static review (no tests/builds)**
- Review modified code and references without executing prohibited commands.
- Identify any incomplete screens, non-working interactions, missing assets, or blocked features.

Work incrementally; avoid rewriting the entire Profile module in a single oversized file. Implement the specified scope without expanding into unrelated modules.

## 10. Completion Report

At the end, report:

1. Implemented screens and their completeness.
2. Files created and modified.
3. Components and patterns reused.
4. Local entities/repositories/preferences integrated or added.
5. Navigation relationships implemented.
6. Remaining placeholders, unavailable dependencies, and limitations.
7. Explicit confirmation that no tests, builds, analysis, pub get, or code generation were run (if true).

Do not report mock functionality as complete. Start with the reference HTML and the smallest relevant existing Flutter files, then implement the requested Profile module.
