## Prompt
- Prompt ID: <!-- e.g. A3 / B2 / G3 -->
- Stage: <!-- Stage 0..8 -->

## Objective
<!-- State objective from prompt -->

## Scope
- Files changed:
  - <!-- path -->
- Change size:
  - Net LOC: <!-- value -->
  - File count: <!-- value -->

## Dependency Check
- [ ] All upstream dependent prompts are merged and green
- [ ] This prompt is not blocked by unresolved dependency risk
- [ ] High-risk prompt isolation rule applied (if routing/auth/progression)

## Test Evidence
### Static checks
- [ ] `dart format --set-exit-if-changed .`
- [ ] `flutter analyze` (zero new warnings)

### Unit tests
- [ ] Added/updated tests for new logic in this prompt
- [ ] Boundary tests added for critical engines when touched

### Integration/Smoke
- [ ] App boot smoke passed
- [ ] Touched route transitions validated
- [ ] Touched persistence read/write validated

### Manual script scenarios (3–5)
- [ ] Scenario 1:
- [ ] Scenario 2:
- [ ] Scenario 3:

## Acceptance Checklist
- [ ] One prompt per branch rule followed (or justified non-overlap pair)
- [ ] No refactor+feature mix in this prompt
- [ ] Stop-and-test checkpoint completed before merge
- [ ] No passing tests removed without replacement
- [ ] Feature flags used for risky adaptive/progression flows (if applicable)

## Failure / Rollback Plan
- Rollback trigger(s):
  - [ ] App cannot boot
  - [ ] Auth loop
  - [ ] Data corruption risk
  - [ ] Critical smoke failure
- Rollback action:
  - <!-- revert commit / narrow reissue plan -->

## Postmortem (if this prompt had failures)
- Cause:
- Missed test:
- New guardrail added:

