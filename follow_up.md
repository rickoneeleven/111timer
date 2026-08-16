# Active Validation

## Feature: Immediate idle pause

- Status: Validating
- Target env: local ChromieCraft WoW 3.3.5a client
- Created: 16 Aug 2026
- Last touched: 16 Aug 2026
- Last validation run: 16 Aug 2026 (automated harness passed)

### Problem

- The timer continued counting for 15 seconds after movement or combat stopped.
- The activity tail is no longer wanted; idle time must stop the countdown immediately.

### Implementation

- Count down only while movement or combat is detected.
- Remove activity-tail state, unrelated activity events, and their registrations.
- Update the settings description and runtime documentation.

### Validation Checklist

- [x] Automated behavioural suite
  - Command: `npx --yes --package=fengari-node-cli fengari tests/test.lua`
  - Expect: `111timer behavioural tests passed`
  - Evidence: Passed locally on 16 Aug 2026.

- [ ] Real-client immediate pause
  - Command: move until the countdown changes, stop moving out of combat, then remain idle for at least 10 seconds.
  - Expect: the countdown turns grey and does not lose another displayed second after movement stops.
  - Evidence: Pending user verification.

- [ ] Combat transition
  - Command: observe the countdown while entering combat without moving, then leave combat and remain still.
  - Expect: it counts during combat and pauses immediately when combat ends.
  - Evidence: Pending user verification.

### Release Gate

- Keep direct pre-stable commit/push testing until the user declares the addon stable.
- Remove this section when the real-client checks pass.
