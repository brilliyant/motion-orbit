# Motion Orbit — Codex / Antigravity Implementation Prompt

## Task
Implement **first-launch onboarding and local profile setup** in the existing **Motion Orbit** Android application. This is an **implementation task**, not a UI mockup or Google Stitch design request.

Motion Orbit is an **offline-first, workout plan-first** application. Optional camera-based AI form tracking belongs inside Workout, **not** in the bottom navigation.

## Reference files and directory setup
Before implementing code:
1. Inspect the existing project layout, and create only missing directories: `docs/requirements/`, `docs/prompts/`, and `docs/designs/onboarding/`.
2. Read `docs/requirements/functional_requirements.md` as the complete functional specification; **FTR-ONB** governs onboarding behavior.
3. Read this implementation prompt at `docs/prompts/onboarding_implementation.md`.
4. Use exported Stitch HTML, styles, assets and screenshots from `docs/designs/onboarding/` as **visual references**. They are not Flutter WebViews.
5. Do not overwrite, fabricate, or replace missing reference documents. If a required reference is absent, report the missing path.
6. Create or modify Flutter feature directories only during the implementation task, according to existing project patterns. Do not pre-create `lib/features/` or impose a new architecture.

## Implementation boundaries
- Work within the **existing repository**, framework, routing, state management, persistence, and design patterns. Do **not** assume a specific architecture before inspecting relevant files.
- Inspect only files needed for app startup/routing, current Home/Dashboard, navigation, theme, models, and local persistence. Identify the smallest edit set first.
- Make minimal, focused changes. Reuse existing widgets and infrastructure.
- Do not add dependencies, refactor unrelated code, rename/move files, or introduce cloud services.
- **Do not run tests, create tests, build, analyze, or run `pub get` unless explicitly requested.** Ignore unrelated warnings.
- Prefer guard clauses and early returns over deeply nested conditionals.
- If onboarding UI from Stitch is already present in the repo, **integrate/reuse it** rather than redesigning it.

## Expected startup behavior
1. When the app launches, read persistent **local onboarding completion state**.
2. If completed, route straight to the existing **Home Dashboard**.
3. Otherwise, launch **Welcome / Onboarding**.
4. If onboarding is partially completed, restore draft inputs and the appropriate last unfinished step.
5. When the required data is valid, save the profile to local storage and mark onboarding as complete **only after the save succeeds**.
6. Navigate to Home Dashboard, removing onboarding screens from the navigation stack so Back cannot reopen them.
7. On future app launches, skip onboarding unless the user intentionally resets onboarding/local data.
8. No network access, login, Google Sign-In, or AI model download is required.

## Onboarding screens

### 1. Welcome
- Motion Orbit branding and tagline: **Train Smart. Move Better.**
- Description: **Plan workouts, track your sets, and optionally check your exercise form with on-device AI.**
- Primary CTA: **Get Started**.
- Secondary text: **Works offline. No account required.**

### 2. About You — all optional
- Display Name
- Age Range **or** Date of Birth (choose whichever best fits the existing implementation)
- Height (cm)
- Current Weight (kg)
- Continue must work with all inputs empty.
- Use appropriate keyboards/validation for numeric fields; show errors for invalid provided values.

### 3. Your Fitness Starting Point — required
- **Primary Goal**, single choice: Build Muscle, Lose Fat, Improve Stamina, General Fitness.
- **Fitness Level**, single choice: Beginner, Intermediate, Advanced.
- Both values are required to finish onboarding; show clear inline validation if missing.
- They are preferences, **not** instructions to automatically generate a workout plan.

### 4. Your Workout Preferences — all optional
- Training Location: Home, Gym, Both
- Available Equipment: Bodyweight, Dumbbells, Barbell, Resistance Band (multiple selection)
- Preferred Workout Days: Monday–Sunday (multiple selection)
- Preferred Session Duration (optional; selected preset or supported custom value)
- Provide **Skip for Now** and **Finish Setup** actions. Skipping preserves required selections and completes setup.

### 5. Setup Complete (optional lightweight step)
- **You're All Set** / **Your profile is saved on this device.**
- **Go to Dashboard** if a confirmation screen is used. A brief confirmation followed by navigation is also acceptable.

## Data and storage requirements
- Save locally using the project's **existing persistence solution**; do not add one unless absolutely necessary and approved.
- Use an independently generated/stable **local profile ID** if the existing data model needs identity; it must not depend on authentication.
- Persist required profile data, optional fields if supplied, a completion flag, and an onboarding draft/step as appropriate.
- Keep profile data editable later from the **Profile** menu; if Profile editing is not implemented, preserve the model and entry point without building unrelated features.
- Never mark onboarding complete before the profile write succeeds. On failure, display a helpful error and allow retry without losing input.
- Do not fabricate a completed profile merely because stored data is malformed. Handle unreadable/corrupt state safely and provide a recovery path.
- Maintain compatibility with any existing locally stored profile and avoid wiping it.

## UX and navigation rules
- Keep design consistent with existing theme; preferred identity: Electric Blue `#2563EB`, Deep Navy `#0F172A`, Material 3-inspired styling where applicable.
- Onboarding must not include the 4-tab bottom navigation.
- After completion, maintain exactly four main tabs: **Home, Workout, Progress, Profile**.
- The AI form tracker is a **sub-feature of Workout**, not a fifth tab or onboarding requirement.
- Back navigation and process restarts preserve prior input; no unintended loss of draft state.
- Show step progress and consistent Back/Continue buttons.
- Do not add AI-generated workout prescriptions, subscriptions, login, streak pressure, or compulsory camera access.

## Core acceptance criteria
1. Fresh install/local state without completed onboarding goes to Welcome, not Home.
2. Required choices missing -> completion blocked with clear feedback.
3. Optional fields all blank -> setup is still allowed once required fields are chosen.
4. Completed onboarding -> direct entry to Home on subsequent launches.
5. Restart mid-onboarding -> previously entered values and progress are restored.
6. Failed local save -> does not mark onboarding complete or silently discard data.
7. No internet, account, or camera permission required to onboard.
8. Main navigation remains **Home / Workout / Progress / Profile**.

## Execution and response format
1. **Briefly inspect** the smallest relevant set of existing files and summarize the current startup and storage patterns.
2. Implement the full onboarding and routing flow in the existing codebase, reusing available UI from Stitch when present.
3. Do not create only static screens: wire actions, validation, draft persistence, startup check, and success navigation.
4. Do not run tests, builds, analyzers, or dependency installation unless asked.
5. Report the **files modified**, the **behavior implemented**, and **anything blocked by missing code or uncertain integration**. Clearly state that validation commands were not run.

## Source of truth
Follow the Motion Orbit Functional Requirements Specification (formerly FormFit AI), especially **FTR-ONB**, and the existing repo conventions. If exact screen visuals from Stitch are provided, match their styling while preserving the functional rules above. Do not change unrelated functionality.
