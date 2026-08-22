CPC Drive Suite 3.9.2 — fully modular core

Keep every .lua file in the same CSP app folder.

SETTINGS FILE
-------------
The Home page JSON tools save to:
  apps/lua/cpc_drive_suite/CPC_DRIVE_SUITE_SETTINGS.JSON
The shipped reset/default profile is:
  apps/lua/cpc_drive_suite/CPC_DRIVE_SUITE_DEFAULTS.JSON
The path is resolved from the Assetto Corsa root folder, so the project does not
depend on a specific drive, Steam library, or user account name. Save and Load
use this project location only; they do not redirect settings to another folder.

Entry points:
  cpc_drive_suite.lua       safe loader
  cpc_drive_suite_core.lua  tiny module orchestrator

Core modules:
  cpc_drive_suite_neck.lua       NeckFX link/bootstrap
  cpc_drive_suite_clutch.lua     clutch + telemetry + gear isolation
  cpc_drive_suite_camera.lua     throttle camera + linear channels
  cpc_drive_suite_actions.lua    runtime presets/reset actions
  cpc_drive_suite_lifecycle.lua  update/recover/release hooks
  cpc_drive_suite_ui.lua         settings/dashboard UI
  cpc_drive_suite_hud.lua        telemetry HUD

Data/helper modules:
  cpc_drive_suite_settings.lua
  cpc_drive_suite_math.lua
  cpc_drive_suite_presets.lua
  cpc_drive_suite_theme.lua

The modules share one __CPC runtime table. This removes the large number of
chunk-level locals from the old core while keeping the existing CSP script
callbacks and safe-loader behavior.

NECKFX BACKEND
--------------
This package now includes a matching cockpit NeckFX backend in:
  neckfx_backend/CPC_Drive_Suite_NeckFX_Backend/
See NECKFX_INSTALL.txt. The shelf app alone cannot move NeckFX; the backend must be selected in CSP NeckFX.

THROTTLE LOGIC MODULE
---------------------
All throttle-controlled cockpit behavior is now in:
  cpc_drive_suite_throttle.lua

This file owns accelerator input shaping, base FOV, forward/back Z movement,
speed-forward/FOV behavior and the throttle-driven advanced linear effects.
`cpc_drive_suite_camera.lua` remains only as a compatibility shim for older code.

NECKFX MODULE SPLIT
-------------------
NeckFX effect math is now isolated in:
  neckfx_backend/CPC_Drive_Suite_NeckFX_Backend/cpc_drive_suite_neck_effects.lua

The backend cockpit.lua is only a safe loader. Edit cpc_drive_suite_neck_effects.lua
for head movement, G-force, drift/steering look, road following, speed-angle,
hidden jerk/yaw, axis mixing and NeckFX output behavior.

The root cpc_drive_suite_neck.lua remains the shelf-app side shared-link/telemetry
bridge and does not contain the cockpit effect simulation.
