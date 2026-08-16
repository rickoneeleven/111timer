# 111 Timer

`111 Timer` is a small task-reminder addon for World of Warcraft 3.3.5a.

It counts active play rather than ordinary clock time. The countdown runs while your character is moving or in combat, and for 15 seconds after recognised activity. Standing idle does not consume the timer.

When the timer expires, a movable **Check tasks** window appears out of combat. If it expires during combat, the reminder waits until combat ends. Entering combat while the reminder is open hides it temporarily.

## Defaults

- Reminder buttons: 5 minutes, 10 minutes, 30 minutes
- Login default: 10 minutes
- Draggable countdown: visible
- Sound: none

All three durations and the nominated login default can be changed in the settings window.

## Installation

Install the repository as a folder named `111timer` inside:

```text
World of Warcraft/Interface/AddOns/111timer
```

Restart WoW or reload its interface after installation. The addon targets the 3.3.5a interface (`30300`).

## Use

- Drag the countdown to place it.
- White countdown text means the timer is running.
- Grey text means it is paused because the character is idle.
- Orange text means the reminder is due.
- Right-click the countdown or enter `/111timer` to open settings.
- The reminder itself can be dragged and cannot be dismissed without choosing a duration.

Window positions and settings are account-wide. Timer progress is deliberately session-only: logging out, changing character or running `/reload` starts a fresh default timer.

## Licence

MIT

## Development check

The lightweight test harness exercises login reset, idle pausing, movement, the activity tail, combat queuing and reminder buttons without needing a WoW client:

```sh
npx --yes --package=fengari-node-cli fengari tests/test.lua
```
