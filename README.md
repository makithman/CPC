# CPC Drive Suite

CPC Drive Suite is a modular Lua app for Assetto Corsa and Custom Shaders Patch (CSP). It combines adaptive clutch assistance, launch control, cockpit camera and FOV motion, Dynamic 6DOF NeckFX output, gear tracking, telemetry, and a configurable driver HUD in one interface.

Current version: **3.10.0**

## Features

- Adaptive clutch assistance with standing-launch, anti-stall, shift, handbrake, and drift-kick controls.
- Hold-to-dump launch control with configurable bite and throttle targets.
- Throttle-driven cockpit position and FOV movement.
- Additional acceleration, braking, steering, road, RPM, slip, impact, and shift camera effects.
- Dynamic 6DOF NeckFX movement with independent position, rotation, response, mixing, and following controls.
- Automatic gear-tracking and configurable shift-cycle timing.
- Full, input-focused, minimal, and circular HUD layouts.
- Live telemetry for pedals, steering, RPM, speed, gear, camera output, and NeckFX output.
- Red, blue, green, amber, and purple full-menu themes.
- Resizable main wheel, subwheel, and slider-title text.
- JSON import, export, editable defaults, and per-control reset support.

## Requirements

- Assetto Corsa for Windows.
- Custom Shaders Patch with Lua app support.
- CSP control override support for clutch and gear automation.
- The matching **CPC Drive Suite - NeckFX Backend** for Dynamic 6DOF output.

No exact CSP version is enforced by the project. If a required CSP API is unavailable, the app reports the affected feature as unavailable instead of silently failing.

## Installation

1. Copy the `cpc_drive_suite` directory to:

   ```text
   assettocorsa/apps/lua/cpc_drive_suite
   ```

2. Confirm that `manifest.ini` and `cpc_drive_suite.lua` are directly inside that directory.
3. Enable CPC Drive Suite in Content Manager/CSP and open it from the in-game app shelf.
4. Install the matching cockpit-camera/NeckFX backend supplied with the release.
5. In CSP NeckFX settings, select **CPC Drive Suite - NeckFX Backend**, enable scripted NeckFX, and reload the session.

The shelf app and NeckFX backend are separate components. The backend is required only for the Dynamic 6DOF layer; the rest of the suite can still load without it.

## First setup

1. Open the app and use the Home button in the center of the main wheel.
2. Enable **CPC Drive Suite** and only the systems you want to use.
3. Disable Assetto Corsa's built-in auto-clutch if using the adaptive clutch system.
4. Disable other apps that directly change cockpit seat position or first-person FOV.
5. Use the main wheel to choose a system and the subwheel below it to choose a control group.
6. Start with presets, then make smaller adjustments with the sliders.
7. Right-click any slider to restore its default value.

## Interface

The default full interface is designed for a 2560×1440 display:

- The main navigation wheel is on the left.
- The context-sensitive subwheel remains below it.
- Main/basic settings appear in the first settings column.
- Selecting an additional subwheel page opens its extra controls in a second column to the right.
- The two sliders beneath the wheels adjust overall wheel size and slider-title font size.
- Panel borders, headings, navigation, and sliders follow the selected appearance theme.

Compact mode remains available from the display settings for a smaller driving-focused control surface.

## Settings files

The app reads and writes these files in its installation directory:

- `CPC_DRIVE_SUITE_SETTINGS.JSON` — current user settings.
- `CPC_DRIVE_SUITE_DEFAULTS.JSON` — editable startup and reset defaults.

The Home page provides buttons to save, load, preview, and open the settings folder. Imported values are accepted only when their keys and data types match known settings.

## Controls and safety

- The physical clutch pedal retains priority over the automated clutch command.
- Launch control can raise throttle to its configured floor, but it cannot reduce a fully pressed physical accelerator.
- Camera output is limited by configurable movement and FOV safety bounds.
- A full reset requires confirmation.
- Runtime and UI failures are caught and displayed by the safe loader where possible.

## Project structure

| Path | Purpose |
| --- | --- |
| `cpc_drive_suite.lua` | Safe entry point and window callbacks |
| `cpc_drive_suite_core.lua` | Loads and initializes suite modules |
| `source_loader.lua` | Joins generated source fragments into modules |
| `ui/` | Navigation, settings pages, controls, appearance, and window layout |
| `clutch/` | Adaptive clutch and launch-control runtime |
| `throttle/` | Cockpit camera, FOV, and motion channels |
| `neck/` | NeckFX connection and telemetry controls |
| `autogear/` | Gear tracker and shift-cycle runtime |
| `hud/` | HUD primitives, gauges, pedals, and layouts |
| `settings/` | Defaults and storage migrations |
| `presets/` | Preset definitions for major systems |
| `actions/` | Shared actions and driving helpers |

The UI and several runtime modules are stored as source fragments. `source_loader.lua` concatenates them into normal Lua chunks at runtime, keeping individual project files below the established 200-line limit.

## Troubleshooting

### NeckFX reports backend offline

Select **CPC Drive Suite - NeckFX Backend** in CSP, enable scripted NeckFX, and reload the session. Ensure the companion backend remains in its required CSP cockpit-camera location.

### Clutch or gear override is unavailable

Confirm that CSP is active and supports the required control override APIs. Disable overlapping clutch or gearbox-assistance apps while testing.

### Camera movement does not appear

Use cockpit view, enable the throttle camera, and press **Rebase Camera / FOV** on the Home page. Disable other apps that directly edit cockpit position or FOV.

### The app shows an error instead of the menu

Read the displayed safe-loader error first. Verify the complete directory was copied, including every subdirectory and Lua fragment.

### Settings behave unexpectedly

Right-click an individual slider, use the relevant section reset, or restore `CPC_DRIVE_SUITE_DEFAULTS.JSON`. Back up custom JSON settings before using the full reset.

## Development notes

- Keep individual Lua fragments at or below 200 lines.
- Add new settings to the Lua defaults and both JSON files when they must persist.
- Preserve the safe-loader behavior so UI failures remain visible in-game.
- Test clutch, gear, camera, and NeckFX changes independently because each uses different CSP APIs.

## License

No license file is currently included. Add a license before distributing modified versions or accepting external contributions.
