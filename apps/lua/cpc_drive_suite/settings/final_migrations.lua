return [====[
end

-- Auto gear now coordinates with the adaptive clutch: it presses the clutch
-- before each shift and releases it after, reusing the CLUTCH page's own
-- shift hold/release timing so the two features stay in sync.
if settings.settingsVersion < 8 then
  settings.autoGearClutchAssist = true
  settings.settingsVersion = 8
end

-- Optional instant downshift on throttle release straight to a chosen gear,
-- bypassing the normal throttle-off delay.
if settings.settingsVersion < 9 then
  settings.autoGearInstantDownshiftEnabled = false
  settings.autoGearInstantDownshiftGear = 2
  settings.settingsVersion = 9
end

-- Instant downshift can now trigger on a partial throttle lift, not just a
-- full release, via its own configurable reduction threshold.
if settings.settingsVersion < 10 then
  settings.autoGearInstantDownshiftThreshold = 0.15
  settings.settingsVersion = 10
end

-- RPM-based upshifts use engine speed and avoid shifting during heavy cornering;
-- the existing per-gear timers remain available as an explicit fallback mode.
if settings.settingsVersion < 11 then
  settings.autoGearRPMMode = true
  settings.autoGearUpshiftRPMPercent = 0.90
  settings.autoGearUpshiftConfirmTime = 0.08
  settings.autoGearMinThrottle = 0.30
  settings.autoGearBrakeDownshiftThreshold = 0.15
  settings.autoGearOverrunMargin = 0.95
  settings.autoGearCorneringGThreshold = 0.45
  settings.autoGearCorneringSteerThreshold = 0.45
  settings.settingsVersion = 11
end

-- Auto clutch coordination now waits for the actual gear change before
-- releasing, with separate release timing for upshifts and downshifts.
if settings.settingsVersion < 12 then
  settings.autoGearShiftConfirmTimeout = 0.25
  settings.autoGearUpshiftRelease = 0.14
  settings.autoGearDownshiftRelease = 0.24
  settings.settingsVersion = 12
end

-- Car-aware auto gear (ratio-based landing RPM, per-gear targets, H-pattern
-- refusal), downshift throttle blip, and hold-to-dump launch control.
if settings.settingsVersion < 13 then
  local globalUp = settings.autoGearUpshiftRPMPercent
  settings.autoGearPerGearTargets = true
  settings.autoGearUpshiftRPMGear1 = math.max(0.80, globalUp - 0.02)
  settings.autoGearUpshiftRPMGear2 = globalUp
  settings.autoGearUpshiftRPMGear3 = math.min(0.98, globalUp + 0.01)
  settings.autoGearUpshiftRPMGear4 = math.min(0.98, globalUp + 0.02)
  settings.autoGearUpshiftRPMGear5 = math.min(0.98, globalUp + 0.03)
  settings.autoGearUpshiftRPMGear6 = math.min(0.98, globalUp + 0.04)
  settings.autoGearDownshiftRPMPercent = 0.68
  settings.autoGearBlipEnabled = true
  settings.autoGearBlipAmount = 0.55
  settings.autoGearBlipDuration = 0.12
  settings.clutchLaunchControlEnabled = false
  settings.clutchLaunchControlBite = 0.28
  settings.clutchLaunchControlThrottle = 0.60
  settings.settingsVersion = 13
end

if settings.settingsVersion < 14 then
  settings.clutchHandbrakeEnabled = false
  settings.settingsVersion = 14
end

if settings.settingsVersion < 16 then
  settings.neckDriftYawBackDistance = 0.020
  settings.settingsVersion = 16
end

if settings.settingsVersion < 17 then
  settings.neckDriftYawBackReverse = false
  settings.settingsVersion = 17
end

if settings.settingsVersion < 18 then
  settings.neckDriftRollAngle = 8
  settings.neckDriftRollReverse = false
  settings.neckDriftRollSpeed = 9
  settings.settingsVersion = 18
end

return {
  defaults = DEFAULTS,
  settings = settings
}
]====]
