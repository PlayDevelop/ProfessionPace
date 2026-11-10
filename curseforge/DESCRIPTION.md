# ProfessionPace

Keep your professions in step with your character level.

ProfessionPace gives you a compact overview of your learned professions, current
skill, skill cap and how many skill points you are ahead of or behind your target.
Open it from the minimap button or type `/pp`.

## Features

- Lists your learned primary and secondary professions.
- Shows current skill and the trained skill cap when available.
- Color-coded **ahead**, **behind** and **on track** indicators.
- Skinning shows the highest standard beast level your base skill can handle.
- Highlights a reached skill cap so you know to check your trainer.
- Movable panel and draggable minimap button.
- Updates as you gain skill points or character levels.
- Saves position and preferences separately for each character.
- No required addon dependencies.

## How targets work

**Skinning** uses the standard skill requirement for beasts at your character
level. For example, a level 24 character with Skinning 87 has a target of 120:
**33 skill points behind**, with enough base skill to skin standard beasts up to
level 18. Individual creatures can have exceptions.

**All other professions** use a configurable guideline: character level × 5,
capped at 300. These targets are marked with an asterisk. This is a progress
guideline, not a claim that every recipe, gathering node or fishing area at your
level requires that skill. Change the multiplier with `/pp target 4`, for example.

Comparisons use base skill, without temporary bonuses.

## Controls

| Action | Result |
| --- | --- |
| Minimap button: left-click | Show or hide the panel |
| Minimap button: right-click | Lock or unlock the panel |
| Drag the minimap button | Move it around the minimap |
| Drag the panel while unlocked | Move the panel |
| `/pp` | Show or hide the panel |
| `/pp refresh` | Refresh profession data |
| `/pp lock` | Lock or unlock the panel |
| `/pp reset` | Show, unlock and center the panel |
| `/pp minimap` | Show or hide the minimap button |
| `/pp target 5` | Set the guideline multiplier (1–10) |
| `/pp help` | List commands |

## Compatibility

Built for **World of Warcraft: Forever**, interface version **16001**.
Other WoW versions are not currently supported.

This is an early beta. If you report an issue, please include your WoW version,
profession, base skill, character level and any Lua error message. Check temporary
skill bonuses before comparing a tooltip with the base-skill target.

## Installation

Install with CurseForge, or extract the ZIP so the folder is
`Interface/AddOns/ProfessionPace/`. Restart WoW after installing the addon for the
first time. For updates to an already loaded installation, use `/reload`.
