# Active Validation

## Feature: WoW 3.3.5a countdown compatibility fix

- Status: Validating
- Target env: local ChromieCraft WoW 3.3.5a client
- Created: 16 Aug 2026
- Last touched: 16 Aug 2026
- Last validation run: 16 Aug 2026 (automated harness only)

### Problem

- `math.mod` is absent in the real client, so countdown formatting throws at login and repeatedly from `OnUpdate`.
- The visible timer remains frozen and repeated errors plausibly account for the reported FPS loss.

### Implementation

- Use Lua's `%` operator for countdown and duration remainders.
- Remove the test-only `math.mod` compatibility shim that concealed the client failure.
- Exercise whole-hour duration formatting through the settings Interface.

### Validation Checklist

- [x] Automated behavioural suite
  - Command: `npx --yes --package=fengari-node-cli fengari tests/test.lua`
  - Expect: `111timer behavioural tests passed`
  - Evidence: Passed locally on 16 Aug 2026.

- [ ] Real-client Lua errors and countdown behavior
  - Command: install the candidate addon, run `/console scriptErrors 1`, then `/reload`; test idle, movement, combat, and 15 seconds after activity.
  - Expect: no BugSack errors; countdown decreases during movement/combat and the activity tail, then pauses while idle.
  - Evidence: Pending user verification.

- [ ] Real-client FPS comparison
  - Command: compare displayed FPS in the same scene for at least 30 seconds with the addon disabled and enabled.
  - Expect: less than 1 FPS variance and no accumulating BugSack errors.
  - Evidence: Pending user verification.

- [ ] Reminder and settings regression
  - Command: expire a short timer in and out of combat; test reminder buttons, `/111timer`, dragging, and `/reload`.
  - Expect: combat queues/hides the reminder; settings and positions persist; `/reload` starts the nominated default timer.
  - Evidence: Pending user verification.

### Release Gate

- Do not bump the version or tag a release until the real-client checks pass.
- Remove this section when every validation item is complete.
