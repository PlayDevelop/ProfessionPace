# ProfessionPace

A lightweight World of Warcraft: Forever addon that tracks profession skills against your character level.

## Features

- Lists learned primary and secondary professions, skill and trained skill cap.
- Shows how many skill points you are ahead of or behind your target.
- Skinning guidance shows the highest standard beast level your base skill supports.
- Skill-cap reminders, a movable panel and a draggable minimap button.
- Per-character preferences and automatic updates on skill and level gains.
- English interface. No required addon dependencies.

## Targets

Skinning uses standard beast requirements: level 1–10 requires skill 1, levels
11–20 require `(level - 10) * 10`, and higher levels require `level * 5`.
Individual creatures may have exceptions.

Other professions use a configurable **guideline**, `min(300, level * 5)` by
default. These targets have an asterisk; they are not universal recipe, node or
fishing-area requirements. Comparisons use base skill without temporary bonuses.

Example: level 24 with Skinning 87 gives a target of 120, **33 points behind**,
and enough skill for standard beasts up to level 18.

## Installation

Copy the `ProfessionPace` directory into your Forever client's `Interface/AddOns/`
directory. Restart WoW after first installation. Use `/reload` for updates to an
already loaded addon.

Version 0.2.0 was submitted to CurseForge as a beta for Forever 1.60.1
(interface 16001). Moderation was pending at submission. Other WoW clients are
not currently supported.

## Controls

| Control | Action |
| --- | --- |
| Minimap left-click | Show/hide panel |
| Minimap right-click | Lock/unlock panel |
| Drag minimap icon | Move icon around minimap |
| Drag unlocked panel | Move panel |
| `/pp` | Show/hide panel |
| `/pp refresh` | Refresh profession data |
| `/pp lock` | Lock/unlock panel |
| `/pp reset` | Show, unlock and center panel |
| `/pp minimap` | Show/hide minimap icon |
| `/pp target 5` | Set non-skinning guideline multiplier (1–10) |
| `/pp help` | Show commands |

## Development

- `ProfessionPace/Logic.lua`: target calculations.
- `ProfessionPace/ProfessionPace.lua`: skill reading, UI and commands.
- `tests/`: Lua tests using Fengari and a lightweight mocked WoW UI.
- `curseforge/`: project description, changelog and original project icon.

Run with Node.js 22 or later:

```sh
node tests/run-tests.cjs
```

The runner downloads fixed versions of its test dependencies into the ignored
`tests/.tools/` directory. Tests cover 38 checks plus 300 Skinning boundary cases,
UI output, profession API fallbacks, level updates and minimap click controls.
Mock tests do not replace testing in the actual game client.

Forever's `C_SkillInfo.GetSkillLineInfoByID` is preferred, with profession and
skill-list API fallbacks. The direct ID lookup handles collapsed Skills headers.

To report an issue, include the client version, profession, base skill, character
level, reproduction steps and any Lua error. Contributions are welcome.

## License

[MIT](LICENSE).
