return [====[
    local requestedGear = raw and raw.requestedGearIndex or 0
    local gearButtonEdge = (gearUp and not __CPC.previousGearUp) or (gearDown and not __CPC.previousGearDown)
    local directGearEdge = requestedGear ~= 0 and requestedGear ~= __CPC.previousRequestedGear
    local gearChanged = __CPC.clutchHistoryReady
      and (car.gear ~= __CPC.previousGear or car.engagedGear ~= __CPC.previousEngagedGear)
    if __CPC.settings.clutchShiftEnabled and __CPC.clutchHistoryReady
        and not __CPC.launchControlArmed
        and (gearButtonEdge or directGearEdge or gearChanged) then
      __CPC.shiftElapsed, __CPC.shiftActive = 0, true
    end

    local target, reason, kind = 1, 'Clutch coupled', 'active'
    local inGear = car.gear ~= 0 or car.engagedGear ~= 0

    if launchHold then
      target, reason, kind = launchHold.target, launchHold.reason, launchHold.kind
    elseif __CPC.settings.clutchLaunchEnabled and inGear and speed < __CPC.settings.clutchLaunchEndSpeed then
      local speedFactor = __CPC.Math.saturate(speed / math.max(__CPC.settings.clutchLaunchEndSpeed, 1))
      local launchStartRPM = idleRPM + math.min(260, __CPC.settings.clutchAntiStallMargin * 0.55)
      local rpmFactor = __CPC.Math.saturate((car.rpm - launchStartRPM) /
        math.max(launchRPM - launchStartRPM, 200))
      if gas < __CPC.settings.clutchLaunchThrottle then
        target = speed < 1.5 and 0 or speedFactor
        reason = brake >= __CPC.settings.clutchBrakeThreshold
          and 'Holding clutch at stop' or 'Waiting for launch throttle'
      else
        target = math.max(speedFactor, rpmFactor)
        if target < 0.98 then reason = 'Adaptive launch slip' end
      end
      if brake >= __CPC.settings.clutchBrakeThreshold and speed < 2.5 then
        target, reason = 0, 'Brake hold - clutch disengaged'
      end
      if target < 0.98 then kind = 'action' end
    end

    if not launchHold then
      if __CPC.settings.clutchAntiStallEnabled and inGear and speed < __CPC.settings.clutchAntiStallSpeed then
        local steerLoad = __CPC.Math.saturate((math.abs(steer) - __CPC.settings.clutchTurnLoadStart) /
          math.max(1 - __CPC.settings.clutchTurnLoadStart, 0.05))
        local turnRPM = __CPC.settings.clutchTurnAware and steerLoad * __CPC.settings.clutchTurnExtraMargin or 0
        local brakeRPM = brake >= __CPC.settings.clutchBrakeThreshold and 100 * brake or 0
        local threshold = idleRPM + __CPC.settings.clutchAntiStallMargin + turnRPM + brakeRPM
        local predictedRPM = car.rpm + math.min(__CPC.rpmTrend, 0) * __CPC.settings.clutchRPMLookahead
        local loadingEngine = brake >= __CPC.settings.clutchBrakeThreshold or gas < 0.38
          or __CPC.rpmTrend < -250 or car.rpm < idleRPM + 130
        if predictedRPM < threshold and loadingEngine then
          local danger = __CPC.Math.saturate((threshold - predictedRPM) /
            math.max(__CPC.settings.clutchAntiStallMargin, 120))
          local antiStallTarget = 1 - danger
          if car.rpm < idleRPM + 90 then antiStallTarget = 0 end
          if antiStallTarget < target then
            target = antiStallTarget
            reason = math.abs(steer) >= __CPC.settings.clutchTurnLoadStart
              and 'Turn-aware anti-stall' or 'Predictive anti-stall'
            kind = 'action'
          end
        end
      end

      local kickCondition = __CPC.settings.clutchKickEnabled and inGear
        and speed >= __CPC.settings.clutchKickMinSpeed
        and gas >= __CPC.settings.clutchKickThrottle and brake < 0.25
        and math.abs(steer) >= __CPC.settings.clutchKickSteer and car.rpm < kickRPM
        and (__CPC.rpmTrend <= -__CPC.settings.clutchKickRPMDrop or directionChanged)
      if kickCondition and __CPC.kickCooldownRemaining <= 0 and __CPC.kickRemaining <= 0 then
        __CPC.kickRemaining = __CPC.settings.clutchKickDuration
        __CPC.kickCooldownRemaining = __CPC.settings.clutchKickCooldown
      end
      if __CPC.kickRemaining > 0 then
        target = 0
        reason = directionChanged and 'Direction-change clutch kick' or 'Low-RPM clutch kick'
        kind = 'action'
        __CPC.kickRemaining = math.max(0, __CPC.kickRemaining - dt)
      end

      if __CPC.shiftActive then
        local total = __CPC.settings.clutchShiftHold + __CPC.settings.clutchShiftRelease
        local shiftTarget = __CPC.shiftElapsed < __CPC.settings.clutchShiftHold and 0
          or __CPC.Math.saturate((__CPC.shiftElapsed - __CPC.settings.clutchShiftHold) /
            math.max(__CPC.settings.clutchShiftRelease, 0.02))
        target = math.min(target, shiftTarget)
        reason = __CPC.shiftElapsed < __CPC.settings.clutchShiftHold
          and 'Shift - clutch pressed' or 'Shift - clutch releasing'
        kind = 'action'
        __CPC.shiftElapsed = __CPC.shiftElapsed + dt
        if __CPC.shiftElapsed >= total then __CPC.shiftActive = false end
      end
    end

    if __CPC.settings.clutchHandbrakeEnabled and handbrake > 0.05 then
      target = 0
      reason = 'Handbrake - clutch disengaged'
      kind = 'action'
    end

    __CPC.clutchTarget = __CPC.Math.saturate(target)
    local rate = __CPC.clutchTarget < __CPC.clutchCommand
      and __CPC.settings.clutchPressRate or __CPC.settings.clutchReleaseRate
    __CPC.setClutchOverride(__CPC.Math.moveTowards(__CPC.clutchCommand, __CPC.clutchTarget,
      math.max(rate, 0.1) * dt))
    if kind == 'action' and (__CPC.clutchStatusKind ~= 'action' or __CPC.clutchStatus ~= reason) then
      __CPC.actionFlash = 1
    end
    __CPC.clutchStatus, __CPC.clutchStatusKind = reason, kind
    __CPC.updateClutchHistory(car, raw, strongTurn)
  end

end
]====]
