-- CPC Drive Suite 3.9.2 — Per-frame update, recovery and release hooks
-- Generated from the former monolithic core. Shared runtime values live in __CPC.

return function(__CPC)
  function script.update(dt)
    dt = __CPC.Math.clamp(dt or 0, 0, 0.05)
    __CPC.elapsedTime = __CPC.elapsedTime + dt
    __CPC.actionFlash = math.max(0, __CPC.actionFlash - dt * 1.8)
    local car = ac.getCar(__CPC.PLAYER)
    __CPC.updateGearShiftIsolation(dt, car)
    __CPC.syncNeckLink()
    __CPC.updateAdaptiveClutch(dt, car)
    __CPC.updateThrottleCamera(dt, car)
    __CPC.updateAutoGear(dt, car)
  end

  function script.recover()
    __CPC.resetClutchRuntime(nil)
    __CPC.resetThrottleCameraSession()
    __CPC.resetGearShiftIsolation(nil)
    __CPC.resetAutoGearRuntime(nil)
    __CPC.throttleWasEnabled = false
    __CPC.disableNeckLink()
  end

  ac.onRelease(function()
    __CPC.exportSettingsJson()
    __CPC.releaseClutch('App unloaded')
    __CPC.restoreThrottleOutputs()
    __CPC.disableNeckLink()
  end)

end
