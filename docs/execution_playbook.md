# Prompt Execution Playbook

This repository follows strict dependency-first, risk-first execution controls.

## Stage Order (strict)
1. Stage 0: Baseline control
2. Stage 1: Foundation (A1–A6)
3. Stage 2: Auth/User (B1–B4)
4. Stage 3: Content (C1–C5)
5. Stage 4: Learning Engine (D1–D4)
6. Stage 5: Adaptive (E1–E4)
7. Stage 6: Progression (F1–F5)
8. Stage 7: UI Wiring (G1–G5)
9. Stage 8: Polish/Stability (H1–H5)

## Prompt Dependency Rule
- A prompt can run only when all upstream prompts it touches are merged and green.
- If dependency is uncertain, treat as blocked.
- High-risk prompts (routing/auth/progression guards) must run alone.

## Incremental Development Rules
- One prompt per branch by default.
- Two prompts together only if file overlap is zero and both are small.
- Preferred max size: <=15 files and <=400 net LOC per prompt.
- Stop-and-test after every prompt.
- No refactor + feature in the same prompt.
- If 2 consecutive prompt failures happen, pause and run root-cause review.

## Testing Strategy (required after each prompt)
1. Static checks
   - `dart format --set-exit-if-changed .`
   - `flutter analyze` with zero new warnings
2. Unit tests
   - New logic must include tests in the same prompt
   - Boundary tests required when touching scheduler/mastery/unlock logic
3. Integration/Smoke
   - App boot smoke
   - Touched route transitions
   - Touched persistence read/write
4. Manual scenario scripts (3–5)
   - Prompt-targeted user flows

Mandatory daily smoke script set:
- Cold start
- Resume
- Back navigation policy

## Error Handling / Breakage Protocol
- Freeze new prompt execution immediately on breakage.
- Classify failure: compile-time, runtime crash, logic regression, or state/routing loop.
- Reproduce with minimal steps and capture exact failing scenario.
- Isolate offending diff (file + commit).
- Fix in branch if small; else revert and reissue narrow prompt.

Automatic rollback criteria:
- App cannot boot
- Auth loop
- Data corruption risk
- Critical smoke tests fail

## Version Control Rules
- Branch naming:
  - `feat/<PromptID>-<slug>`
  - `fix/<PromptID>-<slug>`
- One PR per prompt.
- PR must include:
  - Prompt ID
  - Objective
  - Files changed
  - Test evidence
  - Rollback plan
- Tag milestones by stage (example: `stage-foundation-green`).

## Stability Rules
- Main branch must remain releasable.
- No direct pushes to `main`.
- Required merge checks:
  - formatter/analyzer
  - tests
  - smoke pass
- Risky adaptive/progression flows must remain behind feature flags until validated.
- No removal of passing tests without replacement.
- If a stage introduces more than 2 regressions, freeze feature work and stabilize.

## Performance and UX Validation
After routing/state prompts, validate:
- login -> home
- home -> lesson -> back
- practice resume after interruption
- logout stack reset

Validate no duplicate routes and no back-stack leaks.

Track frame timing on mid-range target and ensure no persistent jank in lesson/practice transitions.

## Operating Cadence
- Daily: max 3 prompts merged if all are green.
- Per stage: stage-exit checklist signoff.
- Weekly: one stabilization day (no new features; defects/perf/regressions only).

