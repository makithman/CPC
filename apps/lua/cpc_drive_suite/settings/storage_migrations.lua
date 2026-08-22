return [====[
  hudOpacity = 0.94,
  hudAnimation = 1.0,
  hudSpeedMph = false,
  hudShowWheel = true,
  hudShowPedals = true,
  hudShowCamera = true,
  hudShowRPM = true,
  hudShowStatus = true,
  hudShowGMeter = true,
  hudShowShiftLights = true,
  settingsVersion = 0
}

-- Import the former Dynamic 6DOF tuning once. Missing legacy storage simply
-- yields the same defaults, so first-time users follow the same path safely.
ac.storageSetPath('cpc-dynamic-6dof-live')
local legacyNeck = ac.storage({
  dynamicMovement = true,
  overallSpeed = 1.0,
  gForceAtFull = 1.5,
  effectSpeedCap = 20,
  effectSpeedCapMph = false,
  moveXDistance = 0.035,
  moveXSpeed = 9,
  moveYDistance = 0.015,
  moveYSpeed = 12,
  moveZDistance = 0.040,
  moveZSpeed = 9,
  yawAngle = 10,
  yawSpeed = 8,
  pitchAngle = 8,
  pitchSpeed = 9,
  rollAngle = 10,
  rollSpeed = 9,
  driftYawAngle = 12,
  driftYawSpeed = 9,
  roadPitchAngle = 8,
  roadPitchSpeed = 7,
  bankRollAngle = 10,
  bankRollSpeed = 8,
  speedAngleStartKmh = 20,
  speedAngleFullKmh = 180,
  speedPitchAngle = 5,
  speedPitchSpeed = 6,
  speedYawAngle = 8,
  speedYawSpeed = 8,
  speedRollAngle = 8,
  speedRollSpeed = 8,
  hiddenJerkAtFull = 8,
  hiddenYawRateAtFull = 1.0,
  hiddenYawAngle = 3,
  hiddenYawSpeed = 12,
  hiddenPitchAngle = 2.5,
  hiddenPitchSpeed = 14,
  hiddenRollAngle = 3,
  hiddenRollSpeed = 14,
  mixYawToRoll = 0.20,
  mixRollToYaw = 0.10,
  mixPitchToRoll = 0.05,
  mixRollToPitch = 0.10,
  mixXToZ = 0.15,
  mixZToX = 0.10,
  mixYToZ = 0.15,
  mixZToY = 0.20,
  slideFollowing = true,
  slidingLookMult = 0.5,
  trackFollowing = true,
  trackFollowingMult = 0.7,
  steeringMult = 0.7,
  lookaheadDistance = 20
})

ac.storageSetPath('cpc-drive-suite-v1')
local storageOk, settings = pcall(ac.storage, DEFAULTS)
if not storageOk then
  ac.storageSetPath('cpc-drive-suite-v2')
  settings = ac.storage(DEFAULTS)
end
if settings.settingsVersion < 1 then
  local legacyMap = {
    neckDynamicMovement = 'dynamicMovement',
    neckOverallSpeed = 'overallSpeed',
    neckGForceAtFull = 'gForceAtFull',
    neckEffectSpeedCap = 'effectSpeedCap',
    neckEffectSpeedCapMph = 'effectSpeedCapMph',
    neckMoveXDistance = 'moveXDistance', neckMoveXSpeed = 'moveXSpeed',
    neckMoveYDistance = 'moveYDistance', neckMoveYSpeed = 'moveYSpeed',
    neckMoveZDistance = 'moveZDistance', neckMoveZSpeed = 'moveZSpeed',
    neckYawAngle = 'yawAngle', neckYawSpeed = 'yawSpeed',
    neckPitchAngle = 'pitchAngle', neckPitchSpeed = 'pitchSpeed',
    neckRollAngle = 'rollAngle', neckRollSpeed = 'rollSpeed',
    neckDriftYawAngle = 'driftYawAngle', neckDriftYawSpeed = 'driftYawSpeed',
    neckRoadPitchAngle = 'roadPitchAngle', neckRoadPitchSpeed = 'roadPitchSpeed',
    neckBankRollAngle = 'bankRollAngle', neckBankRollSpeed = 'bankRollSpeed',
    neckSpeedAngleStartKmh = 'speedAngleStartKmh',
    neckSpeedAngleFullKmh = 'speedAngleFullKmh',
    neckSpeedPitchAngle = 'speedPitchAngle', neckSpeedPitchSpeed = 'speedPitchSpeed',
    neckSpeedYawAngle = 'speedYawAngle', neckSpeedYawSpeed = 'speedYawSpeed',
    neckSpeedRollAngle = 'speedRollAngle', neckSpeedRollSpeed = 'speedRollSpeed',
    neckHiddenJerkAtFull = 'hiddenJerkAtFull',
    neckHiddenYawRateAtFull = 'hiddenYawRateAtFull',
    neckHiddenYawAngle = 'hiddenYawAngle', neckHiddenYawSpeed = 'hiddenYawSpeed',
    neckHiddenPitchAngle = 'hiddenPitchAngle', neckHiddenPitchSpeed = 'hiddenPitchSpeed',
    neckHiddenRollAngle = 'hiddenRollAngle', neckHiddenRollSpeed = 'hiddenRollSpeed',
    neckMixYawToRoll = 'mixYawToRoll', neckMixRollToYaw = 'mixRollToYaw',
    neckMixPitchToRoll = 'mixPitchToRoll', neckMixRollToPitch = 'mixRollToPitch',
    neckMixXToZ = 'mixXToZ', neckMixZToX = 'mixZToX',
    neckMixYToZ = 'mixYToZ', neckMixZToY = 'mixZToY',
    neckSlideFollowing = 'slideFollowing',
    neckSlidingLookMult = 'slidingLookMult',
    neckTrackFollowing = 'trackFollowing',
    neckTrackFollowingMult = 'trackFollowingMult',
    neckSteeringMult = 'steeringMult',
    neckLookaheadDistance = 'lookaheadDistance'
  }
  for newKey, oldKey in pairs(legacyMap) do settings[newKey] = legacyNeck[oldKey] end
  settings.settingsVersion = 1
end

-- Throttle-sync migration: keep every 3.5+/custom feature, but replace the
-- overlapping base FOV/fore-aft controls with the synchronized five-control setup.
if settings.settingsVersion < 2 then
  settings.throttleRestingFov = 45
  settings.throttleMaximumFov = 145
  settings.throttleForwardDistance = 0.350
  settings.throttleBackDistance = 0.250
  settings.throttleTransitionSpeed = 12
  settings.throttleFovWidenSpeed = 12
  settings.throttleFovReturnSpeed = 12
  settings.throttleForwardSpeed = 12
  settings.throttleForwardFovLink = false
  settings.settingsVersion = 2
end

-- 3.7.7 compatibility migration.
if settings.settingsVersion < 3 then
  settings.throttleSpeedForwardStartKmh = 0
  settings.throttleSpeedForwardFullKmh = 70
  settings.throttleSpeedForwardCurve = 1.0
  settings.settingsVersion = 3
end

-- 3.9.2: speed Z and speed FOV now share one absolute vehicle-speed curve.
-- They build slowly while the real accelerator is pressed and release to zero
-- when the pedal is lifted, leaving the base FOV free to reach Resting FOV.
if settings.settingsVersion < 4 then
  settings.throttleSpeedFovWiden = 22.0
  settings.throttleSpeedForwardFullKmh = 180
  settings.throttleSpeedLayerSpeed = 2.5
  settings.settingsVersion = 4
end

-- FOV hard safety range and FOV blend speed become independent settings,
-- decoupled from the previously shared 20/170 constant and Z transition speed.
if settings.settingsVersion < 5 then
  settings.throttleFovHardMin = 20
  settings.throttleFovHardMax = 170
  settings.throttleFovTransitionSpeed = settings.throttleTransitionSpeed
  settings.settingsVersion = 5
end

-- Automatic gearing assist: RPM- and speed-aware shift timing, opt-in.
if settings.settingsVersion < 6 then
  settings.autoGearEnabled = false
  settings.autoGearMinSpeed = 8
  settings.autoGearOverrunProtect = true
  settings.autoGearMinShiftInterval = 0.35
  settings.settingsVersion = 6
end

-- Auto gear switched to timer-based sequential shifting: hold each gear for
-- its own configured seconds, then step up; a throttle-off timer steps down.
if settings.settingsVersion < 7 then
  settings.autoGearShiftTime1 = 2.0
  settings.autoGearShiftTime2 = 2.5
  settings.autoGearShiftTime3 = 3.0
  settings.autoGearShiftTime4 = 3.5
  settings.autoGearShiftTime5 = 4.0
  settings.autoGearThrottleOffDelay = 1.5
  settings.settingsVersion = 7
]====]
