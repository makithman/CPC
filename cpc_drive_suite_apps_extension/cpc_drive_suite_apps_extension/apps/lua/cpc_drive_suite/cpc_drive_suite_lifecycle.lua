-- CPC Drive Suite 3.9.2 — Per-frame update, recovery and release hooks
-- Generated from the former monolithic core. Shared runtime values live in __CPC.

return function(__CPC)
  __CPC.motionUpdateAccumulator = 0

  function __CPC.nextMotionDelta(dt)
    local fps = __CPC.Math.clamp(__CPC.Math.finiteNumber(__CPC.settings.motionUpdateFps, 120), 30, 280)
    local step = 1 / fps
    if dt >= step then
      __CPC.motionUpdateAccumulator = 0
      return dt
    end
    __CPC.motionUpdateAccumulator = math.min(__CPC.motionUpdateAccumulator + dt, 0.05)
    if __CPC.motionUpdateAccumulator < step then return 0 end
    local elapsed = __CPC.motionUpdateAccumulator
    __CPC.motionUpdateAccumulator = 0
    return elapsed
  end

  function script.update(dt)
    dt = __CPC.Math.clamp(dt or 0, 0, 0.05)
    __CPC.elapsedTime = __CPC.elapsedTime + dt
    __CPC.actionFlash = math.max(0, __CPC.actionFlash - dt * 1.8)
    local car = ac.getCar(__CPC.PLAYER)
    __CPC.updateGearShiftIsolation(dt, car)
    __CPC.syncNeckLink()
    __CPC.updateAdaptiveClutch(dt, car)
    local motionDt = __CPC.nextMotionDelta(dt)
    if motionDt > 0 then __CPC.updateThrottleCamera(motionDt, car) end
    __CPC.updateAutoGear(dt, car)
  end

  function script.recover()
    __CPC.resetClutchRuntime(nil)
    __CPC.resetThrottleCameraSession()
    __CPC.resetGearShiftIsolation(nil)
    __CPC.resetAutoGearRuntime(nil)
    __CPC.throttleWasEnabled = false
    __CPC.motionUpdateAccumulator = 0
    __CPC.disableNeckLink()
  end

  ac.onRelease(function()
    __CPC.exportSettingsJson()
    __CPC.releaseClutch('App unloaded')
    __CPC.restoreThrottleOutputs()
    __CPC.disableNeckLink()
  end)

end
