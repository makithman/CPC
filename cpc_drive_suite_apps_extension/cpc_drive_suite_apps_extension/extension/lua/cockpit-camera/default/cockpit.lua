-- CPC Drive Suite 3.9.2 — NeckFX Cockpit Backend
-- Select this script in CSP NeckFX. The shelf app sends live settings through
-- a typed global connection; this script applies them to NeckFX every frame.

local sim = ac.getSim()

-- Oval XY movement: positive X is right and positive Y is up.
local ovalEnabled = true
local ovalWidth = 0.035
local ovalHeight = 0.015
local ovalSpeed = 0.65
local ovalClockwise = true

local link = ac.connect({
  ac.StructItem.key('cpc.drive.suite.neckfx.v3'),
  appSequence = ac.StructItem.uint32(),
  backendSequence = ac.StructItem.uint32(),
  backendPresent = ac.StructItem.boolean(),
  suiteEnabled = ac.StructItem.boolean(),
  neckEnabled = ac.StructItem.boolean(),
  neckDynamicMovement = ac.StructItem.boolean(),
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

local state = {
  x = 0, y = 0, z = 0,
  yaw = 0, pitch = 0, roll = 0,
  driftYaw = 0, roadPitch = 0, bankRoll = 0,
  hiddenYaw = 0, hiddenPitch = 0, hiddenRoll = 0,
  lastAccelX = 0, lastAccelY = 0, lastAccelZ = 0,
  lastYawRate = 0,
  rollShakePhase = 0,
  ovalPhase = 0,
  ready = false
}

local function finite(v, fallback)
  if type(v) ~= 'number' or v ~= v or v == math.huge or v == -math.huge then
    return fallback or 0
  end
  return v
end

local function clamp(v, lo, hi)
  v, lo, hi = finite(v, lo), finite(lo, 0), finite(hi, lo)
  if hi < lo then lo, hi = hi, lo end
  return math.max(lo, math.min(v, hi))
end

local function saturate(v)
  return clamp(v, 0, 1)
end

local function smooth(current, target, speed, dt)
  local alpha = 1 - math.exp(-math.max(finite(speed, 1), 0.01) * math.max(dt, 0))
  return current + (target - current) * alpha
end

local function speedBlend(speedKmh)
  local cap = math.max(finite(link.neckEffectSpeedCap, 20), 1)
  if link.neckEffectSpeedCapMph then cap = cap * 1.609344 end
  return saturate(math.abs(speedKmh) / cap)
end

local function speedAngleBlend(speedKmh)
  local startKmh = math.max(finite(link.neckSpeedAngleStartKmh, 20), 0)
  local fullKmh = math.max(finite(link.neckSpeedAngleFullKmh, 180), startKmh + 1)
  return saturate((math.abs(speedKmh) - startKmh) / (fullKmh - startKmh))
end

local function clearOutputs(dt)
  local s = math.max(finite(link.neckOverallSpeed, 1), 0.1) * 14
  state.x = smooth(state.x, 0, s, dt)
  state.y = smooth(state.y, 0, s, dt)
  state.z = smooth(state.z, 0, s, dt)
  state.yaw = smooth(state.yaw, 0, s, dt)
  state.pitch = smooth(state.pitch, 0, s, dt)
  state.roll = smooth(state.roll, 0, s, dt)
  state.driftYaw = smooth(state.driftYaw, 0, s, dt)
  state.roadPitch = smooth(state.roadPitch, 0, s, dt)
  state.bankRoll = smooth(state.bankRoll, 0, s, dt)
  state.hiddenYaw = smooth(state.hiddenYaw, 0, s, dt)
  state.hiddenPitch = smooth(state.hiddenPitch, 0, s, dt)
  state.hiddenRoll = smooth(state.hiddenRoll, 0, s, dt)
  state.rollShakePhase = 0
  state.ovalPhase = 0
end

local function publish(effectStrength, x, y, z, yaw, pitch, roll)
  link.backendPresent = true
  link.backendSequence = link.appSequence
  link.neckEffectStrength = finite(effectStrength, 0)
  link.neckOutputX = finite(x, 0)
  link.neckOutputY = finite(y, 0)
  link.neckOutputZ = finite(z, 0)
  link.neckOutputYaw = finite(yaw, 0)
  link.neckOutputPitch = finite(pitch, 0)
  link.neckOutputRoll = finite(roll, 0)
end

function script.update(dt, mode, turnMix)
  dt = clamp(dt or 0, 0, 0.05)
  turnMix = finite(turnMix, 1)
  link.backendPresent = true
  link.backendSequence = link.appSequence

  if not car then
    clearOutputs(dt)
    publish(0, 0, 0, 0, 0, 0, 0)
    return
  end

  local enabled = link.suiteEnabled and link.neckEnabled and link.neckDynamicMovement
  if not enabled then
    clearOutputs(dt)
    publish(0, 0, 0, 0, 0, 0, 0)
    state.ready = false
    return
  end

  local overall = clamp(link.neckOverallSpeed, 0.1, 3)
  local gAtFull = math.max(math.abs(finite(link.neckGForceAtFull, 1.5)), 0.1)
  local speedKmh = math.abs(finite(car.speedMs, 0) * 3.6)
  local strength = speedBlend(speedKmh)
  local angleSpeedBlend = speedAngleBlend(speedKmh)
  local gearFilter = link.neckGearFilterEnabled and link.neckGearFilterActive

  local ax = finite(car.acceleration and car.acceleration.x, 0)
  local ay = finite(car.acceleration and car.acceleration.y, 0)
  local az = finite(car.acceleration and car.acceleration.z, 0)
  if gearFilter then az = state.lastAccelZ end

  local lateral = clamp(-ax / gAtFull, -1, 1)
  local vertical = clamp(ay / gAtFull, -1, 1)
  local longitudinal = clamp(-az / gAtFull, -1, 1)

  local xTarget = lateral * finite(link.neckMoveXDistance, 0) * strength
  local yTarget = vertical * finite(link.neckMoveYDistance, 0) * strength
  local zTarget = longitudinal * finite(link.neckMoveZDistance, 0) * strength

  if ovalEnabled then
    local direction = ovalClockwise and -1 or 1
    state.ovalPhase = (state.ovalPhase + direction * dt * math.pi * 2
      * math.max(finite(link.neckOvalSpeed, ovalSpeed), 0)) % (math.pi * 2)
    xTarget = xTarget + math.cos(state.ovalPhase)
      * math.max(finite(link.neckOvalWidth, ovalWidth), 0) * strength
    yTarget = yTarget + math.sin(state.ovalPhase)
      * math.max(finite(link.neckOvalHeight, ovalHeight), 0) * strength
  end

  local sliding = finite(car.localVelocity and car.localVelocity.x, 0)
    / math.max(3, math.abs(finite(car.speedMs, 0)))
  local slipAngle = math.deg(math.atan(sliding))
  local slideNorm = clamp(slipAngle / 35, -1, 1)
  local steerNorm = clamp(finite(car.steer, 0) / 360, -1, 1)
  local yawRate = finite(car.localAngularVelocity and car.localAngularVelocity.y, 0)

  local yawTarget = lateral * finite(link.neckYawAngle, 0) * strength
  local driftYawTarget = 0
  local driftRollTarget = 0
  if link.neckSlideFollowing then
    driftYawTarget = slideNorm * finite(link.neckDriftYawAngle, 0)
      * finite(link.neckSlidingLookMult, 0.5) * strength
    driftRollTarget = slideNorm * finite(link.neckDriftRollAngle, 0) * strength
    local driftBackDirection = link.neckDriftYawBackReverse and 1 or -1
    zTarget = zTarget + driftBackDirection * math.abs(slideNorm)
      * math.max(finite(link.neckDriftYawBackDistance, 0), 0)
      * strength
  end
  yawTarget = yawTarget + steerNorm * finite(link.neckSteeringMult, 0.7)
    * finite(link.neckYawAngle, 0) * strength
  yawTarget = yawTarget + math.sign(yawRate) * finite(link.neckSpeedYawAngle, 0)
    * angleSpeedBlend * math.min(math.abs(yawRate), 1)

  local bankRollTarget = 0
  if link.neckTrackFollowing and sim.trackLengthM and sim.trackLengthM > 1
      and car.splinePosition then
    local lookahead = math.max(finite(link.neckLookaheadDistance, 20), 1)
    local p0 = ac.trackProgressToWorldCoordinate(car.splinePosition)
    local p1 = ac.trackProgressToWorldCoordinate((car.splinePosition + lookahead / sim.trackLengthM) % 1)
    if p0 and p1 and p0 ~= vec3(-1, -1, -1) and p1 ~= vec3(-1, -1, -1) then
      local road = p1:sub(p0):normalize()
      local follow = finite(link.neckTrackFollowingMult, 0.7) * strength
      yawTarget = yawTarget + math.deg(math.asin(clamp(math.dot(road, car.side), -1, 1))) * follow
      bankRollTarget = math.deg(math.asin(clamp(math.dot(car.groundNormal or car.up, car.side), -1, 1)))
        * follow * finite(link.neckBankRollAngle, 0) / 10
    end
  end

  local rollTarget = 0
  if link.neckTraditionalRollEnabled then
    rollTarget = lateral * finite(link.neckRollAngle, 0) * strength
      + bankRollTarget
      + lateral * finite(link.neckSpeedRollAngle, 0) * angleSpeedBlend
  end
  if link.neckRollShakeEnabled then
    state.rollShakePhase = (state.rollShakePhase + dt
      * math.max(finite(link.neckRollShakeSpeed, 0.65), 0) * math.pi * 2) % (math.pi * 2)
    local shakeAmount = math.abs(finite(link.neckRollAngle, 0)) * strength
    if link.neckCombineRollShake then
      shakeAmount = math.max(math.abs(rollTarget), shakeAmount * 0.5)
    end
    rollTarget = rollTarget + math.sin(state.rollShakePhase)
      * shakeAmount
  end

  local jerkScale = math.max(finite(link.neckHiddenJerkAtFull, 8), 0.1)
  local yawRateScale = math.max(finite(link.neckHiddenYawRateAtFull, 1), 0.05)
  local jerkX = 0
  if state.ready and dt > 0.0001 then
    jerkX = clamp((ax - state.lastAccelX) / dt / jerkScale, -1, 1)
  end
  local hiddenYawTarget = clamp(yawRate / yawRateScale, -1, 1) * finite(link.neckHiddenYawAngle, 0)
  local hiddenRollTarget = -jerkX * finite(link.neckHiddenRollAngle, 0)

  state.x = smooth(state.x, xTarget, finite(link.neckMoveXSpeed, 9) * overall, dt)
  state.y = smooth(state.y, yTarget, finite(link.neckMoveYSpeed, 12) * overall, dt)
  state.z = smooth(state.z, zTarget, finite(link.neckMoveZSpeed, 9) * overall, dt)
  state.yaw = smooth(state.yaw, yawTarget, finite(link.neckYawSpeed, 8) * overall, dt)
  state.driftYaw = smooth(state.driftYaw, driftYawTarget, finite(link.neckDriftYawSpeed, 9) * overall, dt)
  state.bankRoll = smooth(state.bankRoll, driftRollTarget, finite(link.neckDriftRollSpeed, 9) * overall, dt)
  state.roll = smooth(state.roll, rollTarget, finite(link.neckRollSpeed, 9) * overall, dt)
  state.hiddenYaw = smooth(state.hiddenYaw, hiddenYawTarget, finite(link.neckHiddenYawSpeed, 12) * overall, dt)
  state.hiddenRoll = smooth(state.hiddenRoll, hiddenRollTarget, finite(link.neckHiddenRollSpeed, 14) * overall, dt)

  local outX, outY, outZ = state.x, state.y, state.z
  local outYaw = state.yaw + state.driftYaw + state.hiddenYaw
  local outPitch = 0
  local outRoll = state.roll + state.bankRoll + state.hiddenRoll

  -- Cross-axis mixing is applied after each primary axis has been smoothed.
  local mixX, mixY, mixZ = outX, outY, outZ
  outX = mixX + mixZ * finite(link.neckMixZToX, 0)
  outY = mixY + mixZ * finite(link.neckMixZToY, 0)
  outZ = mixZ + mixX * finite(link.neckMixXToZ, 0) + mixY * finite(link.neckMixYToZ, 0)
  local mixYaw, mixRoll = outYaw, outRoll
  outYaw = mixYaw + mixRoll * finite(link.neckMixRollToYaw, 0)
  outRoll = mixRoll + mixYaw * finite(link.neckMixYawToRoll, 0)

  neck.position:addScaled(car.side, outX)
  neck.position:addScaled(car.up, outY)
  neck.position:addScaled(car.look, outZ)
  neck.look:addScaled(car.side, math.radians(outYaw) * turnMix)
  neck.up:addScaled(car.side, math.radians(outRoll))

  publish(strength, outX, outY, outZ, outYaw, outPitch, outRoll)

  state.lastAccelX, state.lastAccelY, state.lastAccelZ = ax, ay, az
  state.lastYawRate = yawRate
  state.ready = true
end
