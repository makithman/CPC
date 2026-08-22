return [====[
-- CPC Drive Suite 3.9.2 — Suite presets, reset actions and tuning helpers
-- Generated from the former monolithic core. Shared runtime values live in __CPC.

return function(__CPC)
  -- Presets and resets ---------------------------------------------------------

  function __CPC.applyRoadClutchPreset()
    __CPC.settings.clutchEnabled = true
    __CPC.settings.clutchLaunchRPMPercent = 22
    __CPC.settings.clutchAntiStallMargin = 420
    __CPC.settings.clutchReleaseRate = 4.5
    __CPC.settings.clutchShiftHold = 0.075
    __CPC.settings.clutchShiftRelease = 0.17
    __CPC.settings.clutchKickEnabled = false
  end

  function __CPC.applyDriftClutchPreset()
    __CPC.settings.clutchEnabled = true
    __CPC.settings.clutchLaunchRPMPercent = 30
    __CPC.settings.clutchAntiStallMargin = 520
    __CPC.settings.clutchReleaseRate = 6.5
    __CPC.settings.clutchShiftHold = 0.065
    __CPC.settings.clutchShiftRelease = 0.12
    __CPC.settings.clutchKickEnabled = true
    __CPC.settings.clutchKickRPMPercent = 52
    __CPC.settings.clutchKickThrottle = 0.60
    __CPC.settings.clutchKickSteer = 0.32
    __CPC.settings.clutchKickMinSpeed = 18
    __CPC.settings.clutchKickDuration = 0.09
    __CPC.settings.clutchKickCooldown = 0.55
    __CPC.settings.clutchKickRPMDrop = 500
  end

  function __CPC.applyThrottleSpeedPreset()
    __CPC.settings.throttleEnabled = true
    __CPC.settings.throttleOverallSpeed = 0.85
    __CPC.settings.throttleRestingFov = 45
    __CPC.settings.throttleMaximumFov = 145
    __CPC.settings.throttleFovWidenSpeed = 12
    __CPC.settings.throttleFovReturnSpeed = 12
    __CPC.settings.throttleTransitionSpeed = 12
    __CPC.settings.throttleFovTransitionSpeed = 12
    __CPC.settings.throttleDeadzone = 0.02
    __CPC.settings.throttleCurve = 1.10
    __CPC.settings.throttleEffectSpeedCap = __CPC.settings.throttleEffectSpeedCapMph and 62 or 100
    __CPC.settings.throttleForwardDistance = 0.350
    __CPC.settings.throttleBackDistance = 0.250
    __CPC.settings.throttleForwardFovLink = false
    __CPC.settings.throttleForwardSpeed = 12
    __CPC.settings.throttleVerticalDistance = -0.004
    __CPC.settings.throttleVerticalSpeed = 5.0
    __CPC.settings.throttleLateralDistance = 0.006
    __CPC.settings.throttleLateralSpeed = 5.0
    __CPC.settings.throttleSteeringAtFull = 360
    __CPC.settings.throttlePitchAngle = 1.5
    __CPC.settings.throttlePitchSpeed = 4.5
    __CPC.settings.throttleYawAngle = 2.0
    __CPC.settings.throttleYawSpeed = 4.5
    __CPC.settings.throttleFovForwardMix = 2.5
    __CPC.settings.throttleFovForwardLimit = 6.0
    __CPC.settings.throttleFovVerticalMix = 0.3
    __CPC.settings.throttleFovVerticalLimit = 3.0
    __CPC.settings.throttleFovLateralMix = 0.5
    __CPC.settings.throttleFovLateralLimit = 3.0
    __CPC.settings.throttleFovPitchMix = 0.6
    __CPC.settings.throttleFovPitchLimit = 3.0
    __CPC.settings.throttleFovYawMix = 0.4
    __CPC.settings.throttleFovYawLimit = 3.0
    __CPC.settings.throttleFovSpeedMix = 3.0
    __CPC.settings.throttleFovSpeedLimit = 5.0
    __CPC.settings.throttleFovSpeedStartKmh = 40
    __CPC.settings.throttleFovSpeedFullKmh = 220
    __CPC.settings.throttleFovSpeedCurve = 1.15
    __CPC.settings.throttleFovAccelGMix, __CPC.settings.throttleFovAccelGLimit = 0.8, 2.5
    __CPC.settings.throttleFovBrakeGMix, __CPC.settings.throttleFovBrakeGLimit = -0.6, 2.5
    __CPC.settings.throttleFovHeaveMix, __CPC.settings.throttleFovHeaveLimit = 0.15, 1.5
    __CPC.settings.throttleFovDriftMix, __CPC.settings.throttleFovDriftLimit = 0.4, 2.0
    __CPC.settings.throttleFovImpactMix, __CPC.settings.throttleFovImpactLimit = -0.8, 2.0
    __CPC.settings.throttleFovMixStrength = 0.85
    __CPC.settings.throttleFovMixSpeed = 4.0
    __CPC.settings.throttleFovMixLimit = 8
    __CPC.resetThrottleMotion()
  end

  function __CPC.applyNeckSpeedPreset()
    __CPC.settings.neckEnabled = true
    __CPC.settings.neckDynamicMovement = true
    __CPC.settings.neckOverallSpeed = 0.85
    __CPC.settings.neckGForceAtFull = 1.7
    __CPC.settings.neckEffectSpeedCap = __CPC.settings.neckEffectSpeedCapMph and 16 or 25
    __CPC.settings.neckMoveXDistance, __CPC.settings.neckMoveXSpeed = 0.024, 5.5
    __CPC.settings.neckMoveYDistance, __CPC.settings.neckMoveYSpeed = 0.007, 7.0
    __CPC.settings.neckMoveZDistance, __CPC.settings.neckMoveZSpeed = 0.030, 5.0
    __CPC.settings.neckYawAngle, __CPC.settings.neckYawSpeed = 5.5, 4.8
    __CPC.settings.neckPitchAngle, __CPC.settings.neckPitchSpeed = 4.5, 5.2
    __CPC.settings.neckRollAngle, __CPC.settings.neckRollSpeed = 5.5, 5.0
    __CPC.settings.neckDriftYawAngle, __CPC.settings.neckDriftYawSpeed = 7.5, 4.2
    __CPC.settings.neckRoadPitchAngle, __CPC.settings.neckRoadPitchSpeed = 2.5, 3.8
    __CPC.settings.neckBankRollAngle, __CPC.settings.neckBankRollSpeed = 4.0, 4.0
    __CPC.settings.neckSpeedAngleStartKmh, __CPC.settings.neckSpeedAngleFullKmh = 50, 220
    __CPC.settings.neckSpeedPitchAngle, __CPC.settings.neckSpeedPitchSpeed = 2.0, 4.0
    __CPC.settings.neckSpeedYawAngle, __CPC.settings.neckSpeedYawSpeed = 3.0, 4.2
    __CPC.settings.neckSpeedRollAngle, __CPC.settings.neckSpeedRollSpeed = 3.5, 4.2
    __CPC.settings.neckHiddenJerkAtFull = 10
    __CPC.settings.neckHiddenYawRateAtFull = 1.25
    __CPC.settings.neckHiddenYawAngle, __CPC.settings.neckHiddenYawSpeed = 1.3, 7.0
    __CPC.settings.neckHiddenPitchAngle, __CPC.settings.neckHiddenPitchSpeed = 1.1, 7.5
    __CPC.settings.neckHiddenRollAngle, __CPC.settings.neckHiddenRollSpeed = 1.4, 7.5
    __CPC.settings.neckMixYawToRoll, __CPC.settings.neckMixRollToYaw = 0.12, 0.06
    __CPC.settings.neckMixPitchToRoll, __CPC.settings.neckMixRollToPitch = 0.03, 0.06
    __CPC.settings.neckMixXToZ, __CPC.settings.neckMixZToX = 0.08, 0.06
    __CPC.settings.neckMixYToZ, __CPC.settings.neckMixZToY = 0.08, 0.10
    __CPC.settings.neckSlideFollowing = true
    __CPC.settings.neckSlidingLookMult = 0.45
    __CPC.settings.neckTrackFollowing = true
    __CPC.settings.neckTrackFollowingMult = 0.50
    __CPC.settings.neckSteeringMult = 0.40
    __CPC.settings.neckLookaheadDistance = 24
  end

  function __CPC.setStaticNeck()
    __CPC.settings.neckDynamicMovement = false
    __CPC.settings.neckSlideFollowing = false
    __CPC.settings.neckTrackFollowing = false
    local zeroKeys = {
      'neckMoveXDistance', 'neckMoveYDistance', 'neckMoveZDistance',
      'neckYawAngle', 'neckPitchAngle', 'neckRollAngle',
      'neckDriftYawAngle', 'neckRoadPitchAngle', 'neckBankRollAngle',
      'neckSpeedPitchAngle', 'neckSpeedYawAngle', 'neckSpeedRollAngle',
      'neckHiddenYawAngle', 'neckHiddenPitchAngle', 'neckHiddenRollAngle',
      'neckMixYawToRoll', 'neckMixRollToYaw', 'neckMixPitchToRoll',
      'neckMixRollToPitch', 'neckMixXToZ', 'neckMixZToX',
      'neckMixYToZ', 'neckMixZToY', 'neckSlidingLookMult',
      'neckTrackFollowingMult', 'neckSteeringMult'
    }
    for _, key in ipairs(zeroKeys) do __CPC.settings[key] = 0 end
  end

  function __CPC.matchThrottleSpeeds()
    local speed = __CPC.settings.throttleTransitionSpeed or __CPC.settings.throttleForwardSpeed
    __CPC.settings.throttleTransitionSpeed = speed
    __CPC.settings.throttleForwardSpeed = speed
    __CPC.settings.throttleFovTransitionSpeed = speed
    __CPC.settings.throttleFovWidenSpeed = speed
    __CPC.settings.throttleFovReturnSpeed = speed
    __CPC.settings.throttleVerticalSpeed = speed
    __CPC.settings.throttleLateralSpeed = speed
    __CPC.settings.throttlePitchSpeed = speed
    __CPC.settings.throttleYawSpeed = speed
    __CPC.settings.throttleFovMixSpeed = speed
    for index = 1, #__CPC.LINEAR_CHANNELS do
      local keys = __CPC.LINEAR_CHANNELS[index].keys
      __CPC.settings[keys.speed] = speed
      __CPC.settings[keys.releaseSpeed] = 0
    end
  end

  function __CPC.clearThrottleReleaseOverrides()
    for _, key in ipairs({ 'throttleForwardReleaseSpeed', 'throttleVerticalReleaseSpeed',
        'throttleLateralReleaseSpeed', 'throttlePitchReleaseSpeed',
        'throttleYawReleaseSpeed', 'throttleFovMixReturnSpeed' }) do
      __CPC.settings[key] = 0
    end
    for index = 1, #__CPC.LINEAR_CHANNELS do
      local keys = __CPC.LINEAR_CHANNELS[index].keys
      if keys.releaseSpeed ~= 'throttleImpactRecoverySpeed' then
        __CPC.settings[keys.releaseSpeed] = 0
      end
    end
  end

  function __CPC.clearThrottleChannelClamps()
    for _, key in ipairs({ 'throttleForwardLimit', 'throttleVerticalLimit',
        'throttleLateralLimit', 'throttlePitchLimit', 'throttleYawLimit' }) do
      __CPC.settings[key] = 0
    end
    for index = 1, #__CPC.LINEAR_CHANNELS do
      __CPC.settings[__CPC.LINEAR_CHANNELS[index].keys.limit] = 0
    end
  end
]====]
