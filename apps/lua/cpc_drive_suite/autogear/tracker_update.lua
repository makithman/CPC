return [====[
      __CPC.autoGearStatusKind = 'idle'
      return
    end

    if __CPC.autoGearPreviousResetCounter ~= nil
        and car.resetCounter ~= __CPC.autoGearPreviousResetCounter then
      __CPC.resetAutoGearRuntime(car)
    end
    __CPC.autoGearPreviousResetCounter = car.resetCounter

    if __CPC.autoGearPulseClearPending and __CPC.controlsOverride and not __CPC.autoGearDirectRequest then
      clearShiftPulses()
      __CPC.autoGearPulseClearPending = false
    end

    if not __CPC.settings.suiteEnabled or not __CPC.settings.autoGearEnabled then
      __CPC.autoGearStatus = __CPC.settings.suiteEnabled and 'Gear tracker disabled' or 'Suite paused'
      __CPC.autoGearStatusKind = 'idle'
      __CPC.autoGearPreviousGear = car.gear
      finishTrackerCycle(false)
      return
    end

    if not __CPC.controlsOverride then
      __CPC.autoGearStatus = 'CSP gear override unavailable'
      __CPC.autoGearStatusKind = 'warning'
      __CPC.autoGearPreviousGear = car.gear
      return
    end

    if not car.physicsAvailable or car.isAIControlled or not car.isUserControlled then
      __CPC.autoGearStatus = 'Waiting for player physics'
      __CPC.autoGearStatusKind = 'idle'
      __CPC.autoGearPreviousGear = car.gear
      return
    end

    local gearCount = math.max(0, math.floor(__CPC.Math.finiteNumber(car.gearCount, 0) + 0.5))
    if gearCount < 2 or car.gear <= 0 then
      __CPC.autoGearStatus = car.gear < 0 and 'Reverse - tracker paused'
        or (car.gear == 0 and 'Neutral - waiting to engage' or 'No forward gears reported')
      __CPC.autoGearStatusKind = 'idle'
      __CPC.autoGearPreviousGear = car.gear
      finishTrackerCycle(false)
      return
    end

    if __CPC.autoGearPreviousGear ~= nil
        and car.gear ~= __CPC.autoGearPreviousGear
        and not __CPC.autoGearTrackerActive then
      beginTrackerCycle(car)
    end

    if __CPC.autoGearTrackerActive then
      updateTrackerCycle(dt, car, gearCount)
    else
      __CPC.autoGearStatus = string.format('Tracking gear %d - waiting for change', car.gear)
      __CPC.autoGearStatusKind = 'active'
    end

    if __CPC.autoGearPulseClearPending and __CPC.controlsOverride and __CPC.autoGearDirectRequest then
      clearShiftPulses()
      __CPC.autoGearPulseClearPending = false
    end

    __CPC.autoGearPreviousGear = car.gear
  end
end
]====]
