return [====[
-- CPC Drive Suite — Gear tracker assist
-- Detects a manual gear change, then runs a 6-step back/up shift cycle.

return function(__CPC)
  __CPC.autoGearStatus = 'Waiting for physics'
  __CPC.autoGearStatusKind = 'idle'
  __CPC.autoGearPreviousGear = nil
  __CPC.autoGearPreviousResetCounter = nil
  __CPC.autoGearShiftCooldown = 0
  __CPC.autoGearPulseClearPending = false
  __CPC.autoGearDirectRequest = false

  __CPC.autoGearTrackerActive = false
  __CPC.autoGearTrackerStepIndex = 0
  __CPC.autoGearTrackerAwaitingShift = false
  __CPC.autoGearTrackerRequestedGear = nil
  __CPC.autoGearTrackerWaitTimer = 0
  __CPC.autoGearTrackerStepTimer = 0

  local function clearShiftPulses()
    if not __CPC.controlsOverride then return end
    __CPC.controlsOverride.gearUp = false
    __CPC.controlsOverride.gearDown = false
    __CPC.controlsOverride.requestedGearIndex = 0
    __CPC.autoGearDirectRequest = false
  end

  local function usesDirectGearSelection(car)
    local sim = ac.getSim and ac.getSim() or nil
    return car.hShifter or (sim and sim.controlsWithShifter) or false
  end

  function __CPC.resetAutoGearRuntime(car)
    __CPC.autoGearStatus = 'Waiting for physics'
    __CPC.autoGearStatusKind = 'idle'
    __CPC.autoGearPreviousGear = car and car.gear or nil
    __CPC.autoGearShiftCooldown = 0
    __CPC.autoGearPulseClearPending = false
    __CPC.autoGearDirectRequest = false

    __CPC.autoGearTrackerActive = false
    __CPC.autoGearTrackerStepIndex = 0
    __CPC.autoGearTrackerAwaitingShift = false
    __CPC.autoGearTrackerRequestedGear = nil
    __CPC.autoGearTrackerWaitTimer = 0
    __CPC.autoGearTrackerStepTimer = 0

    clearShiftPulses()
  end

  function __CPC.autoGearStateColor()
    if __CPC.autoGearStatusKind == 'action' then return __CPC.Theme.COLOR_ACTION end
    if __CPC.autoGearStatusKind == 'warning' then return __CPC.Theme.COLOR_WARNING end
    if __CPC.autoGearStatusKind == 'active' then return __CPC.Theme.COLOR_ACTIVE end
    return __CPC.Theme.COLOR_MUTED
  end

  local function requestShift(direction, car, gearCount)
    if not __CPC.controlsOverride then return false end
    local targetGear = car.gear + direction
    if targetGear < 1 or targetGear > gearCount then return false end

    if usesDirectGearSelection(car) then
      __CPC.controlsOverride.requestedGearIndex = targetGear
      __CPC.autoGearDirectRequest = true
    elseif direction > 0 then
      __CPC.controlsOverride.gearUp = true
    else
      __CPC.controlsOverride.gearDown = true
    end

    __CPC.autoGearPulseClearPending = true
    __CPC.autoGearShiftCooldown = math.max(__CPC.settings.autoGearMinShiftInterval, 0.05)
    return true
  end

  local function finishTrackerCycle(setIdleStatus)
    __CPC.autoGearTrackerActive = false
    __CPC.autoGearTrackerStepIndex = 0
    __CPC.autoGearTrackerAwaitingShift = false
    __CPC.autoGearTrackerRequestedGear = nil
    __CPC.autoGearTrackerWaitTimer = 0
    __CPC.autoGearTrackerStepTimer = 0
    if setIdleStatus ~= false then
      __CPC.autoGearStatus = 'Gear tracker idle'
      __CPC.autoGearStatusKind = 'active'
    end
  end

  local function beginTrackerCycle(car)
    __CPC.autoGearTrackerActive = true
    __CPC.autoGearTrackerStepIndex = 0
    __CPC.autoGearTrackerAwaitingShift = false
    __CPC.autoGearTrackerRequestedGear = nil
    __CPC.autoGearTrackerWaitTimer = 0
    __CPC.autoGearTrackerStepTimer = 0
    __CPC.autoGearStatus = string.format('Gear change detected at %d - starting 6-step cycle', car.gear)
    __CPC.autoGearStatusKind = 'action'
  end

  local function trackerDirectionForStep(stepIndex)
    return stepIndex % 2 == 0 and -1 or 1
  end

  local function updateTrackerCycle(dt, car, gearCount)
    local totalSteps = math.max(2, math.floor((__CPC.settings.autoGearTrackerSteps or 6) + 0.5))

    if __CPC.autoGearTrackerStepIndex >= totalSteps then
      finishTrackerCycle()
      return
    end

    __CPC.autoGearShiftCooldown = math.max(0, __CPC.autoGearShiftCooldown - dt)
    __CPC.autoGearTrackerStepTimer = __CPC.autoGearTrackerStepTimer + dt

    if __CPC.autoGearTrackerAwaitingShift then
      __CPC.autoGearTrackerWaitTimer = __CPC.autoGearTrackerWaitTimer + dt
      local confirmed = car.gear == __CPC.autoGearTrackerRequestedGear
      local timedOut = __CPC.autoGearTrackerWaitTimer >=
        math.max(__CPC.settings.autoGearTrackerConfirmTimeout or 0.25, 0.05)
      if confirmed or timedOut then
        __CPC.autoGearTrackerAwaitingShift = false
        __CPC.autoGearTrackerRequestedGear = nil
        __CPC.autoGearTrackerWaitTimer = 0
        __CPC.autoGearTrackerStepTimer = 0
        __CPC.autoGearTrackerStepIndex = __CPC.autoGearTrackerStepIndex + 1
      else
        __CPC.autoGearStatus = string.format('Cycle %d/%d - waiting for gear change',
          __CPC.autoGearTrackerStepIndex + 1, totalSteps)
        __CPC.autoGearStatusKind = 'action'
      end
      return
    end

    if __CPC.autoGearShiftCooldown > 0 then
      __CPC.autoGearStatus = string.format('Cycle %d/%d - shift cooldown',
        __CPC.autoGearTrackerStepIndex + 1, totalSteps)
      __CPC.autoGearStatusKind = 'action'
      return
    end

    local stepInterval = math.max(__CPC.settings.autoGearTrackerStepInterval or 0.12, 0.02)
    if __CPC.autoGearTrackerStepTimer < stepInterval then
      __CPC.autoGearStatus = string.format('Cycle %d/%d - preparing next shift',
        __CPC.autoGearTrackerStepIndex + 1, totalSteps)
      __CPC.autoGearStatusKind = 'action'
      return
    end

    local direction = trackerDirectionForStep(__CPC.autoGearTrackerStepIndex)
    local target = car.gear + direction
    if target < 1 or target > gearCount then
      direction = -direction
      target = car.gear + direction
      if target < 1 or target > gearCount then
        __CPC.autoGearStatus = 'Cycle paused - no valid target gear'
        __CPC.autoGearStatusKind = 'warning'
        finishTrackerCycle(false)
        return
      end
    end

    if requestShift(direction, car, gearCount) then
      __CPC.autoGearTrackerAwaitingShift = true
      __CPC.autoGearTrackerRequestedGear = target
      __CPC.autoGearTrackerWaitTimer = 0
      __CPC.autoGearStatus = string.format('Cycle %d/%d - %s to %d',
        __CPC.autoGearTrackerStepIndex + 1, totalSteps,
        direction < 0 and 'back shift' or 'up shift', target)
      __CPC.autoGearStatusKind = 'action'
    else
      __CPC.autoGearStatus = 'Cycle paused - CSP shift override unavailable'
      __CPC.autoGearStatusKind = 'warning'
      finishTrackerCycle(false)
    end
  end

  function __CPC.updateAutoGear(dt, car)
    if not car then
      __CPC.autoGearStatus = 'No player car'
]====]
