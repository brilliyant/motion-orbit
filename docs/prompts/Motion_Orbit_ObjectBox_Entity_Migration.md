# Motion Orbit — ObjectBox Entity Separation & Data Migration

**Status:** Mandatory implementation requirement  
**Scope:** Flutter Android, offline-first persistence, ObjectBox  
**Purpose:** Replace the current shared JSON key-value persistence for domain data with separate, queryable ObjectBox entities **and migrate existing local data safely**.

## 1. Context and confirmed evidence

The ObjectBox Admin currently shows **one type, `ProfileBoxEntity`**, with these records:

| Key | Current value | Destination domain |
|---|---|---|
| `settings/measurement_units` | `metric` | Settings |
| `profile/snapshot` | JSON containing `version`, `completed`, and `profile` | Profile / onboarding |
| `profile/measurements` | JSON array | Body Measurements |
| `training/plans` | JSON array, including `sample-upper-body` | Training Plans |

The full JSON schemas, source code, repository boundaries, and existing migration implementation have **not** been supplied. The coding agent must inspect only the relevant files before implementing anything; do not assume the illustrative property names below match the project.

## 2. Non-negotiable requirements

1. **Separate persistable domain data into dedicated ObjectBox `@Entity` classes.** Do not use one `ProfileBoxEntity` / generic `key` + JSON value as storage for unrelated domain features.
2. **Actually migrate existing data**; simply introducing entities while leaving existing records untouched does not fulfill this request.
3. Preserve existing user-created data, IDs, onboarding completion state, measurement timestamps, plan/exercise relationships, and sample flags, according to the actual stored schema.
4. Each logical record should be independently addressable and queryable (e.g., each Training Plan; each Body Measurement). Do not replace one giant JSON array with another giant JSON array in a differently named entity.
5. Use a **single ObjectBox Store** with multiple feature-specific entity boxes. Do not create a separate database per bottom navigation tab.
6. Keep presentation/domain-layer behavior and public repository contracts stable unless an essential change is required; confine migrations and persistence implementation to the smallest relevant scope.
7. Settings may remain key-value **only for genuinely simple preferences**. Do not use the generic store for Profile, Measurements, Training Plans, Workout Sessions, or other domain records.
8. Support offline operation; no login, network, new dependency, or remote synchronization is required for this migration.
9. Do not clear the database, reset the app profile, delete users' records, or unconditionally seed samples on upgrade.
10. Do not claim success unless the migration is wired into actual app startup and old data can be read through the new repositories.

## 3. Desired entities: derive exact classes from actual persisted data

### Required now (based on observed records)

| Concern | Expected target | Migration |
|---|---|---|
| Profile and onboarding | `ProfileEntity` (or consistent existing project naming) | Decode `profile/snapshot`; persist profile fields as typed properties where supported, plus completed/onboarding metadata in the appropriate typed location |
| Body Measurements | `BodyMeasurementEntity` | Decode `profile/measurements` and persist **each measurement as its own record** |
| Training Plans | `TrainingPlanEntity` | Decode `training/plans` and persist **each plan as its own record** |
| Plan exercises / tasks / schedules | Dedicated child entities and relationships **where such structures truly exist** | Inspect the plan JSON; migrate nested independently managed objects, preserve order, references, sets/reps/durations and other stored properties |
| Measurement units / basic preferences | `AppSettingsEntity` or narrowly scoped settings key-value store | Migrate/retain `settings/measurement_units` without changing semantics |

### Later / only if currently persisted

Separate entities for `WorkoutSession`, `ExerciseSet`, `FitnessAssessment`, `TrainingSchedule`, `Reminder`, `RunningSession`, `WalkingSession`, `CyclingSession`, `MealLog`, `SleepLog`, `RecoveryLog`, and similar domains **when those features and persisted data exist**. Do **not** create empty speculative tables, stub feature implementations, or refactor unrelated modules in this migration.

**Entity boundaries follow persisted domain aggregates and query needs, not merely UI tabs.** `Home` is an aggregator and should not own persistence belonging to Nutrition, Sleep, Recovery, Running, or Training.

### Entity design rules

- Use ObjectBox `@Entity()` and `@Id()` (`int`) for local storage identity. Preserve the existing stable string business ID as a separate field wherever it exists.
- Where appropriate, define uniqueness constraints for stable business IDs; do not blindly make optional/null legacy values unique.
- Use typed fields for data queried or updated individually. Use `ToOne` / `ToMany` only when justified by real persisted relationships and existing code conventions.
- Preserve original local date/time semantics and units; avoid timezone shifts and numerical rounding.
- Do not silently discard unknown keys. Map the complete observed schema; if fields cannot be represented, stop destructive cleanup and report the unmapped fields.
- Keep ObjectBox persistence entities inside feature `data` layers; do not expose them as domain models in UI APIs.
- Use the project's current mapper / datasource / repository patterns. Avoid unrelated renames or directory moves.

## 4. Mandatory safe migration workflow

### Phase A — Narrow audit before any edit

1. Locate `ProfileBoxEntity` and its generated ObjectBox model metadata.
2. Find all **reads and writes** for the exact four keys above and any other usages of the same shared entity.
3. Find Store initialization, startup flow, existing migration/versioning mechanisms, seed/sample initialization, and relevant feature repository/datastore mappings.
4. Determine the **actual** payload shapes, required/optional fields, stable IDs, nesting, and serialization rules from code and relevant fixtures. Treat the Admin preview as **truncated evidence**, not the full schema.
5. List the minimal files that must change. If additional shared-entity keys are present, document them before deciding what to migrate.

### Phase B — Typed persistence

1. Implement dedicated entities for existing Profile, Body Measurements, Training Plan, and nested independently managed plan records where needed.
2. Add mappers with lossless conversion between existing serialized domain models and new persistence entities, using project conventions.
3. Implement feature-specific ObjectBox datasource / repository storage operations so reads, inserts, updates, deletes, and relevant queries use the dedicated boxes.
4. Do not load and rewrite an entire collection merely to edit a single plan or measurement.
5. Preserve sample-vs-user-created distinction and prevent duplicates from seed data.

### Phase C — Startup migration (must run)

1. Define an idempotent migration marker/version, or use an existing proven migration mechanism.
2. On opening the existing Store, **before repositories expose user data or sample seeds execute**, detect legacy values and migration state.
3. Decode legacy JSON and validate the structures before any changes. Keep legacy payloads intact while migrating.
4. In a **single ObjectBox write transaction when feasible**, upsert typed records by stable legacy IDs, preserving all fields and child links; write the migration completion marker **only after** successful migration of all required records. If transaction scope cannot cover all work, design recoverable per-domain checkpoints and explain them.
5. If a payload is corrupt or fields cannot be mapped, do **not** erase the legacy data or mark that domain as migrated. Surface a recoverable error, retain legacy records, and avoid accidental blank-profile onboarding or overwritten plans.
6. On app restart, migration must be safe to retry and not duplicate plans, measurements, or child entities.
7. Only after successful migration **and confirmed new-store readback**, remove obsolete reads/writes for the migrated domain. Prefer retaining legacy records for a rollback window; never delete them in the same first-upgrade migration without an explicit retention/removal requirement.
8. Future writes must use new entity boxes exclusively for migrated domains; do not continue dual-writing large legacy JSON arrays.
9. Seed defaults and sample training plans only when truly missing, after considering migrated IDs and legacy sample flags.

### Phase D — Integration and developer visibility

1. Verify the app's normal startup path invokes the migration before profile completion checks or training-plan loading.
2. Ensure feature repositories read only from their respective new boxes after migration.
3. Ensure the ObjectBox model includes the new entities and schema changes are versioned consistently with project tools.
4. ObjectBox Admin should show separate entity types; `ProfileBoxEntity` may temporarily remain solely as a legacy migration source / simple preferences store.
5. Document what happens on first launch after update, on second launch, and when data is malformed.

## 5. Expected outcomes / acceptance criteria

- [ ] Existing completed onboarding remains completed; profile fields match the previous snapshot.
- [ ] Measurements are individual `BodyMeasurementEntity` records; each retains values, IDs, and dates.
- [ ] Training Plans are individual `TrainingPlanEntity` records; each retains title, sample flag, exercise content, order, and other existing fields.
- [ ] Settings still show the same measurement units.
- [ ] Old data is visible through the original screens after migration without manual re-entry.
- [ ] Add/edit/delete one plan or measurement does not rewrite the entire legacy collection JSON.
- [ ] Repeated launches do not produce duplicates, re-seed unwanted samples, or reset the user.
- [ ] A failed migration does not destroy legacy records or incorrectly record completion.
- [ ] ObjectBox Admin shows the new entity types with per-record rows.
- [ ] No data is silently lost, especially data absent from the truncated Admin preview.

## 6. Execution constraints (Motion Orbit / Codex)

- Inspect only relevant files; **do not scan the entire repository**.
- Make minimal changes; do not refactor unrelated code, move/rename unrelated files, or add dependencies.
- Reuse the current Flutter Clean Architecture / feature-first patterns.
- Prefer guard clauses / early returns where reasonable.
- **Do not create or run unit tests or other tests** unless explicitly requested.
- **Do not run build, analyze, pub get, or code generation** unless explicitly requested. If generated ObjectBox files must be regenerated, make the necessary source changes and clearly report the required generation command as a pending manual step; do not run it unrequested.
- Ignore unrelated existing warnings.
- Do not delete data or remove fallback/legacy storage until preservation and migration are resolved.

## 7. Codex work order

> Implement the **ObjectBox entity separation and existing-data migration** specified in this document. The migration is mandatory, not a suggestion. First inspect only the relevant files for the existing `ProfileBoxEntity`, the four legacy keys, ObjectBox Store startup, feature repositories, and sample seeding. Identify the smallest edit set and then implement typed entities, mappings, repository integration, and an idempotent startup migration that preserves every legacy profile, measurement, training plan, nested plan record, ID, timestamp, and sample flag. Leave legacy payloads untouched until successful migration and readback. Do not rewrite unrelated features or add speculative entity types. Do not run tests, build, analyze, pub get, or code generation without an explicit follow-up request. At completion, report changed files, exact migration behavior, any unmapped fields/data-risk blockers, and manual generation steps if required.

## 8. Implementation report format

At the end, report:

1. **Existing issue found:** actual shared-entity storage/read/write paths.
2. **Files changed:** brief reason for each.
3. **Entities created:** and how source keys map to them.
4. **Migration:** marker/version, trigger timing, retry behavior, corruption handling, and retention policy.
5. **Preservation:** how business IDs, children/order, date/time, sample flags, and settings are retained.
6. **Pending steps:** only commands that the user must explicitly authorize, if any.
7. **Unverified items:** especially when no tests/build/code generation were run.
