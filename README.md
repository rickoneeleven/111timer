# 111 Timer

DATETIME of last agent review: 16 Aug 2026 15:51 (Europe/London)

`111 Timer` is a task-reminder addon for World of Warcraft 3.3.5a that counts active play instead of ordinary clock time.

## Stack

- World of Warcraft 3.3.5a addon API (`Interface: 30300`)
- Lua 5.1-compatible addon code
- Node.js with `npx` and Fengari for the development test harness

## Quick Start

Install this repository as a folder named `111timer` inside:

```text
World of Warcraft/Interface/AddOns/111timer
```

Restart World of Warcraft or run `/reload`. Use `/111timer` or right-click the countdown to open settings.

## Use

- The countdown runs while the character is moving or in combat and for 15 seconds after recognised activity.
- White text means the timer is running, grey means it is idle, and orange means a reminder is due.
- Drag the countdown or reminder to reposition it.
- Choose one of the three reminder durations when the **Check tasks** window appears.
- Configure the three durations, login default, countdown visibility, and window positions in settings.

Settings and window positions are account-wide through `OneElevenTimerDB`. Timer progress is session-only: login, character changes, and `/reload` start a fresh default timer. Reminders due during combat appear when combat ends.

## Development

Run the behavioural harness from the repository root:

```sh
npx --yes --package=fengari-node-cli fengari tests/test.lua
```

The harness simulates the WoW API and verifies login reset, idle pausing, movement, the activity tail, combat queuing, reminder buttons, and settings persistence.

## Licence

MIT; see `LICENSE`.

## Agent Docs

- Runtime map: `ops/manifest.yaml`
- Testing map: `ops/TESTING.md`
- Agent-skill routing: `docs/agents/domain.md`
- Security review: `ops/SECURITY_REVIEW.md`
