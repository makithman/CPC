return [====[
-- CPC Drive Suite 3.9.2 — NeckFX shared-link and bootstrap state
-- Generated from the former monolithic core. Shared runtime values live in __CPC.

return function(__CPC)
  -- CPC Drive Suite 3.9.2 — Throttle-Release Z Kick Core
  -- One CSP shelf app for adaptive clutch control, a table-driven advanced
  -- linear (translation) camera engine, throttle camera effects, live NeckFX
  -- tuning and a custom-drawn telemetry HUD.
  --
  -- 3.5.0 adds per-channel curves, split attack/release, speed gates, output
  -- clamps and FOV routing to every movement channel, plus eleven new linear
  -- effects: cornering G sway, steering-rate kick, yaw sway, downforce squat,
  -- high-speed drawback, boost surge, engine shake, road rumble, slip judder,
  -- brake-lock pulse and gear-shift jolt.

  __CPC.PLAYER = 0
  __CPC.sim = ac.getSim()

  __CPC.Settings = require('cpc_drive_suite_settings')
  __CPC.DEFAULTS = __CPC.Settings.defaults
  __CPC.settings = __CPC.Settings.settings

  -- Storage is persistent but separate Lua runtimes do not get a live view of
  -- each other's storage proxies. Use a typed CSP connection for live NeckFX
  -- settings, heartbeat acknowledgement and rendered output telemetry.
  __CPC.neckLink = ac.connect({
    ac.StructItem.key('cpc.drive.suite.neckfx.v3'),
    appSequence = ac.StructItem.uint32(),
    backendSequence = ac.StructItem.uint32(),
    backendPresent = ac.StructItem.boolean(),
    suiteEnabled = ac.StructItem.boolean(),
    neckEnabled = ac.StructItem.boolean(),
    neckDynamicMovement = ac.StructItem.boolean(),
    motionUpdateFps = ac.StructItem.float(),
    neckOverallSpeed = ac.StructItem.float(),
    neckGForceAtFull = ac.StructItem.float(),
    neckEffectSpeedCap = ac.StructItem.float(),
    neckEffectSpeedCapMph = ac.StructItem.boolean(),
    neckGearFilterEnabled = ac.StructItem.boolean(),
    neckGearFilterActive = ac.StructItem.boolean(),
    neckMoveXDistance = ac.StructItem.float(),
    neckMoveXSpeed = ac.StructItem.float(),
    neckMoveYDistance = ac.StructItem.float(),
    neckMoveYSpeed = ac.StructItem.float(),
    neckMoveZDistance = ac.StructItem.float(),
    neckMoveZSpeed = ac.StructItem.float(),
    neckYawAngle = ac.StructItem.float(),
    neckYawSpeed = ac.StructItem.float(),
    neckPitchAngle = ac.StructItem.float(),
    neckPitchSpeed = ac.StructItem.float(),
    neckRollAngle = ac.StructItem.float(),
    neckRollSpeed = ac.StructItem.float(),
    neckDriftYawAngle = ac.StructItem.float(),
    neckDriftYawSpeed = ac.StructItem.float(),
    neckDriftRollAngle = ac.StructItem.float(),
    neckDriftRollSpeed = ac.StructItem.float(),
    neckDriftYawBackDistance = ac.StructItem.float(),
    neckDriftYawBackReverse = ac.StructItem.boolean(),
    neckRoadPitchAngle = ac.StructItem.float(),
    neckRoadPitchSpeed = ac.StructItem.float(),
    neckBankRollAngle = ac.StructItem.float(),
    neckBankRollSpeed = ac.StructItem.float(),
    neckSpeedAngleStartKmh = ac.StructItem.float(),
    neckSpeedAngleFullKmh = ac.StructItem.float(),
    neckSpeedPitchAngle = ac.StructItem.float(),
    neckSpeedPitchSpeed = ac.StructItem.float(),
    neckSpeedYawAngle = ac.StructItem.float(),
    neckSpeedYawSpeed = ac.StructItem.float(),
    neckSpeedRollAngle = ac.StructItem.float(),
    neckSpeedRollSpeed = ac.StructItem.float(),
    neckHiddenJerkAtFull = ac.StructItem.float(),
    neckHiddenYawRateAtFull = ac.StructItem.float(),
    neckHiddenYawAngle = ac.StructItem.float(),
    neckHiddenYawSpeed = ac.StructItem.float(),
    neckHiddenPitchAngle = ac.StructItem.float(),
    neckHiddenPitchSpeed = ac.StructItem.float(),
    neckHiddenRollAngle = ac.StructItem.float(),
    neckHiddenRollSpeed = ac.StructItem.float(),
    neckMixYawToRoll = ac.StructItem.float(),
    neckMixRollToYaw = ac.StructItem.float(),
    neckMixPitchToRoll = ac.StructItem.float(),
    neckMixRollToPitch = ac.StructItem.float(),
    neckMixXToZ = ac.StructItem.float(),
    neckMixZToX = ac.StructItem.float(),
    neckMixYToZ = ac.StructItem.float(),
    neckMixZToY = ac.StructItem.float(),
    neckSlideFollowing = ac.StructItem.boolean(),
    neckSlidingLookMult = ac.StructItem.float(),
    neckTrackFollowing = ac.StructItem.boolean(),
    neckTrackFollowingMult = ac.StructItem.float(),
    neckSteeringMult = ac.StructItem.float(),
    neckLookaheadDistance = ac.StructItem.float(),
    neckEffectStrength = ac.StructItem.float(),
    neckOutputX = ac.StructItem.float(),
    neckOutputY = ac.StructItem.float(),
    neckOutputZ = ac.StructItem.float(),
    neckOutputYaw = ac.StructItem.float(),
    neckOutputPitch = ac.StructItem.float(),
    neckOutputRoll = ac.StructItem.float(),
    neckOvalWidth = ac.StructItem.float(),
    neckOvalHeight = ac.StructItem.float(),
    neckOvalSpeed = ac.StructItem.float(),
    neckTraditionalRollEnabled = ac.StructItem.boolean(),
    neckRollShakeEnabled = ac.StructItem.boolean(),
    neckCombineRollShake = ac.StructItem.boolean(),
    neckRollShakeSpeed = ac.StructItem.float()
  }, true, ac.SharedNamespace.Global)

  __CPC.neckSequence = 0
  __CPC.neckLastAck = 0
  __CPC.neckLastAckTime = -1e9
  __CPC.neckTelemetry = {
    effectStrength = 0,
    outputX = 0,
    outputY = 0,
    outputZ = 0,
    outputYaw = 0,
    outputPitch = 0,
    outputRoll = 0
  }

  __CPC.gearIsolationRemaining = 0
  __CPC.gearIsolationHeldThrottle = 0
  __CPC.gearIsolationLastThrottle = 0
  __CPC.gearIsolationPreviousGear = nil
  __CPC.gearIsolationPreviousEngagedGear = nil
  __CPC.gearIsolationPreviousGearUp = false
  __CPC.gearIsolationPreviousGearDown = false
  __CPC.gearIsolationPreviousRequestedGear = 0
  __CPC.gearIsolationResetCounter = nil
  __CPC.gearIsolationReady = false
  __CPC.gearIsolationActive = false

  -- Speed-forward charge state. Only a real driver throttle-release edge can
  -- start the short reverse Z pulse. Gear changes and handbrake never reset,
  -- reverse or otherwise alter this dedicated speed-forward state.
  __CPC.speedForwardBaselineKmh = 0
  __CPC.speedForwardBaselineReady = false
  __CPC.speedForwardResetRequested = false
  __CPC.speedForwardReverseRemaining = 0
  __CPC.speedForwardThrottleReleased = nil

  __CPC.Math = require('cpc_drive_suite_math')

  function __CPC.directedMovement(value, reverseKey, scale)
    local magnitude = __CPC.Math.finiteNumber(value, 0)
    if __CPC.settings[reverseKey] then
      magnitude = -magnitude
    end
    if scale ~= nil then
      magnitude = magnitude * __CPC.Math.finiteNumber(scale, 1)
    end
    return magnitude
  end

  function __CPC.nextNeckSequence()
    __CPC.neckSequence = (__CPC.neckSequence + 1) % 4294967295
    return __CPC.neckSequence
  end

  function __CPC.syncNeckLink()
    local settings = __CPC.settings
    local neckLink = __CPC.neckLink
    local Math = __CPC.Math
    local function directionalValue(settingName, reverseKey, scale)
      return __CPC.directedMovement(settings[settingName], reverseKey, scale)
    end

    local moveScale = math.max(Math.finiteNumber(settings.neckMoveScale, 1), 0)
    local angleScale = math.max(Math.finiteNumber(settings.neckAngleScale, 1), 0)
    local hiddenScale = math.max(Math.finiteNumber(settings.neckHiddenScale, 1), 0)
    local mixScale = math.max(Math.finiteNumber(settings.neckMixScale, 1), 0)
    local followScale = math.max(Math.finiteNumber(settings.neckFollowScale, 1), 0)

    __CPC.nextNeckSequence()
    neckLink.appSequence = __CPC.neckSequence
    neckLink.suiteEnabled = settings.suiteEnabled
    neckLink.neckEnabled = settings.neckEnabled
    neckLink.neckDynamicMovement = settings.neckDynamicMovement
    neckLink.motionUpdateFps = Math.clamp(Math.finiteNumber(settings.motionUpdateFps, 120), 30, 280)
]====]
