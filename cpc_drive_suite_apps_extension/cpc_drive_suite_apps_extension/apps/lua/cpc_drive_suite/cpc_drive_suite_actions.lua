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

  function __CPC.openThrottleSpeedGates()
    __CPC.settings.throttleEffectSpeedFloor = 0
    for index = 1, #__CPC.LINEAR_CHANNELS do
      local keys = __CPC.LINEAR_CHANNELS[index].keys
      __CPC.settings[keys.gateStart] = 0
      __CPC.settings[keys.gateFull] = 1
      __CPC.settings[keys.gateCurve] = 1.0
    end
  end

  function __CPC.applySimpleSuitePreset()
    __CPC.settings.suiteEnabled = true
    __CPC.settings.throttleEnabled = true
    __CPC.settings.neckEnabled = true

    -- Camera: throttle FOV plus a single forward translation, nothing else.
    __CPC.settings.throttleOverallSpeed = 1.0
    __CPC.settings.throttleSmoothingMode = 1
    __CPC.settings.throttleMasterTranslationScale = 1.0
    __CPC.settings.throttleMasterAngleScale = 1.0
    __CPC.settings.throttleRestingFov = 45
    __CPC.settings.throttleMaximumFov = 145
    __CPC.settings.throttleFovWidenSpeed = 12
    __CPC.settings.throttleFovReturnSpeed = 12
    __CPC.settings.throttleTransitionSpeed = 12
    __CPC.settings.throttleFovTransitionSpeed = 12
    __CPC.settings.throttleForwardFovLink = false
    __CPC.settings.throttleForwardFovRatio = 0.0025
    __CPC.settings.throttleForwardFovLive = true
    __CPC.settings.throttleForwardFovLiveGain = 1.0
    __CPC.settings.throttleForwardFovLiveFloor = 0
    __CPC.settings.throttleForwardDistance = 0.350
    __CPC.settings.throttleBackDistance = 0.250
    __CPC.settings.throttleForwardReverse = false
    __CPC.settings.throttleForwardSpeed = 12
    __CPC.settings.throttleForwardReleaseSpeed = 5
    __CPC.settings.throttleForwardCurve = 1.0
    __CPC.settings.throttleForwardLimit = 0
    __CPC.settings.throttleVerticalDistance = 0
    __CPC.settings.throttleLateralDistance = 0
    __CPC.settings.throttlePitchAngle = 0
    __CPC.settings.throttleYawAngle = 0
    __CPC.settings.throttleEffectSpeedFloor = 0
    __CPC.settings.throttleEffectSpeedCap = 20
    __CPC.settings.throttleSpeedGateCurve = 1.0

    -- No linear channels and no mixed FOV: the FOV comes from throttle only.
    __CPC.settings.throttleDynamicsEnabled = false
    __CPC.settings.throttleLinearMasterEnabled = false
    for key in pairs(__CPC.DEFAULTS) do
      if string.sub(key, 1, 11) == 'throttleFov' and string.sub(key, -3) == 'Mix' then
        __CPC.settings[key] = 0
      end
    end
    __CPC.settings.throttleFovMixLimit = 12
    __CPC.settings.throttleFovMixDeadzone = 0

    -- NeckFX: four axes only - longitudinal, lateral, vertical and yaw.
    __CPC.settings.neckDynamicMovement = true
    __CPC.settings.neckOverallSpeed = 1.0
    __CPC.settings.neckGForceAtFull = 1.5
    __CPC.settings.neckMoveScale = 1.0
    __CPC.settings.neckAngleScale = 1.0
    __CPC.settings.neckHiddenScale = 0
    __CPC.settings.neckMixScale = 0
    __CPC.settings.neckFollowScale = 1.0
    __CPC.settings.neckMoveZDistance = 0.035
    __CPC.settings.neckMoveZSpeed = 8
    __CPC.settings.neckMoveXDistance = 0.030
    __CPC.settings.neckMoveXSpeed = 8
    __CPC.settings.neckMoveYDistance = 0.012
    __CPC.settings.neckMoveYSpeed = 10
    __CPC.settings.neckYawAngle = 8
    __CPC.settings.neckYawSpeed = 8
    for _, key in ipairs({ 'neckPitchAngle', 'neckRollAngle', 'neckRoadPitchAngle',
        'neckBankRollAngle', 'neckSpeedPitchAngle', 'neckSpeedYawAngle',
        'neckSpeedRollAngle', 'neckHiddenYawAngle', 'neckHiddenPitchAngle',
        'neckHiddenRollAngle' }) do
      __CPC.settings[key] = 0
    end

    -- Drift yaw look: the head turns into the slide and holds the exit.
    __CPC.settings.neckDriftYawAngle = 11
    __CPC.settings.neckDriftYawSpeed = 6.0
    __CPC.settings.neckDriftYawReverse = false
    __CPC.settings.neckSlideFollowing = true
    __CPC.settings.neckSlidingLookMult = 0.55
    __CPC.settings.neckSteeringMult = 0.30
    __CPC.settings.neckTrackFollowing = false
    __CPC.settings.neckTrackFollowingMult = 0
    __CPC.settings.neckLookaheadDistance = 24

    -- Direction is owned by the preset.
    for key in pairs(__CPC.DEFAULTS) do
      if string.sub(key, -7) == 'Reverse' then __CPC.settings[key] = false end
    end
    __CPC.resetThrottleMotion()
  end

  function __CPC.applyLinearOverdrivePreset()
    __CPC.settings.suiteEnabled = true
    __CPC.settings.throttleEnabled = true
    __CPC.settings.throttleDynamicsEnabled = true
    __CPC.settings.throttleLinearMasterEnabled = true
    __CPC.settings.throttleSmoothingMode = 2
    __CPC.settings.throttleMasterTranslationScale = 1.25
    __CPC.settings.throttleMasterAngleScale = 1.0
    __CPC.settings.throttleLinearMasterScale = 1.35
    __CPC.settings.throttleOutputLimitX = 0.14
    __CPC.settings.throttleOutputLimitY = 0.10
    __CPC.settings.throttleOutputLimitZ = 0.20
    __CPC.settings.throttleEffectSpeedFloor = 0
    __CPC.settings.throttleSpeedGateCurve = 0.85
    __CPC.settings.throttleFovMixReturnSpeed = 5.0
    __CPC.settings.throttleFovMixDeadzone = 0.15

    local tuning = {
      AccelG = { d = -0.030, full = 0.85, atk = 8.0, rel = 5.0, curve = 0.90, lim = 0.045 },
      BrakeDive = { d = 0.038, full = 0.95, atk = 9.0, rel = 6.0, curve = 0.90, lim = 0.055 },
      CornerG = { d = -0.024, full = 1.25, atk = 8.0, rel = 5.5, curve = 0.95, lim = 0.040 },
      Heave = { d = 0.014, full = 0.90, atk = 10.0, rel = 7.0, curve = 1.00, lim = 0.026 },
      Downforce = { d = -0.016, full = 230, atk = 3.0, rel = 2.5, curve = 1.30, lim = 0.024 },
      RoadRumble = { d = 0.007, full = 0.50, atk = 20.0, rel = 9.0, curve = 1.00, lim = 0.016, hz = 20 },
      DriftTranslation = { d = 0.026, full = 12, atk = 8.0, rel = 5.0, curve = 0.90, lim = 0.045 },
      SteerKick = { d = 0.010, full = 1.30, atk = 20.0, rel = 7.0, curve = 1.00, lim = 0.020 },
      YawSway = { d = 0.014, full = 0.70, atk = 9.0, rel = 6.0, curve = 0.95, lim = 0.028 },
      SpeedDraw = { d = -0.028, full = 240, atk = 4.0, rel = 3.0, curve = 1.05, lim = 0.045 },
      Boost = { d = -0.012, full = 1.10, atk = 10.0, rel = 6.0, curve = 1.00, lim = 0.020 },
      RPMShake = { d = 0.0022, full = 0.95, atk = 12.0, rel = 8.0, curve = 1.70, lim = 0.005, hz = 4.5 },
      Impact = { d = 0.030, full = 2.0, atk = 45.0, rel = 13.0, curve = 1.00, lim = 0.050 },
      ShiftJolt = { d = -0.016, full = 0.90, atk = 30.0, rel = 10.0, curve = 1.00, lim = 0.030 },
      SlipJudder = { d = 0.006, full = 1.10, atk = 14.0, rel = 7.0, curve = 1.00, lim = 0.012, hz = 26 },
      BrakePulse = { d = 0.007, full = 0.90, atk = 24.0, rel = 10.0, curve = 1.00, lim = 0.014, hz = 15 }
    }

    for index = 1, #__CPC.LINEAR_CHANNELS do
      local channel = __CPC.LINEAR_CHANNELS[index]
      local keys = channel.keys
      local values = tuning[channel.base]
      __CPC.settings[keys.enabled] = true
      __CPC.settings[keys.reverse] = false
      if values then
        __CPC.settings[keys.distance] = values.d
        __CPC.settings[keys.atFull] = values.full
        __CPC.settings[keys.speed] = values.atk
        __CPC.settings[keys.releaseSpeed] = values.rel
        __CPC.settings[keys.curve] = values.curve
        __CPC.settings[keys.limit] = values.lim
        if values.hz and __CPC.settings[keys.frequency] ~= nil then
          __CPC.settings[keys.frequency] = values.hz
        end
      end
    end
    __CPC.resetThrottleMotion()
  end

  function __CPC.zeroThrottleStartPose()
    __CPC.settings.throttleStartX, __CPC.settings.throttleStartY = 0, 0
    __CPC.settings.throttleStartZ, __CPC.settings.throttleStartPitch = 0, 0
  end

  function __CPC.applyRoadSuitePreset()
    __CPC.settings.suiteEnabled = true
    __CPC.applyRoadClutchPreset()
    __CPC.applyThrottleSpeedPreset()
    __CPC.applyNeckSpeedPreset()
  end

  function __CPC.applyDriftSuitePreset()
    __CPC.settings.suiteEnabled = true
    __CPC.applyDriftClutchPreset()
    __CPC.applyThrottleSpeedPreset()
    __CPC.applyNeckSpeedPreset()
    __CPC.settings.neckTrackFollowingMult = 0.35
    __CPC.settings.neckSlidingLookMult = 0.70
    __CPC.settings.neckDriftYawAngle = 10
  end

  function __CPC.applyArcadeOverdrivePreset()
    __CPC.settings.suiteEnabled = true

    -- Fast, forgiving clutch assists with every intervention enabled.
    __CPC.applyDriftClutchPreset()
    __CPC.settings.clutchLaunchEnabled = true
    __CPC.settings.clutchAntiStallEnabled = true
    __CPC.settings.clutchShiftEnabled = true
    __CPC.settings.clutchTurnAware = true
    __CPC.settings.clutchKickEnabled = true
    __CPC.settings.clutchLaunchRPMPercent = 34
    __CPC.settings.clutchLaunchEndSpeed = 24
    __CPC.settings.clutchLaunchThrottle = 0.08
    __CPC.settings.clutchAntiStallMargin = 620
    __CPC.settings.clutchAntiStallSpeed = 52
    __CPC.settings.clutchPressRate = 30
    __CPC.settings.clutchReleaseRate = 9.0
    __CPC.settings.clutchShiftHold = 0.050
    __CPC.settings.clutchShiftRelease = 0.085
    __CPC.settings.clutchKickRPMPercent = 62
    __CPC.settings.clutchKickThrottle = 0.48
    __CPC.settings.clutchKickSteer = 0.24
    __CPC.settings.clutchKickMinSpeed = 14
    __CPC.settings.clutchKickDuration = 0.11
    __CPC.settings.clutchKickCooldown = 0.35
    __CPC.settings.clutchKickRPMDrop = 350

    -- Direct camera: movement-led arcade response with restrained wheel input.
    __CPC.settings.throttleEnabled = true
    __CPC.settings.throttleOverallSpeed = 1.10
    __CPC.settings.throttleRestingFov = 45
    __CPC.settings.throttleMaximumFov = 145
    __CPC.settings.throttleFovWidenSpeed = 12
    __CPC.settings.throttleFovReturnSpeed = 12
    __CPC.settings.throttleTransitionSpeed = 12
    __CPC.settings.throttleFovTransitionSpeed = 12
    __CPC.settings.throttleDeadzone = 0.01
    __CPC.settings.throttleCurve = 0.95
    __CPC.settings.throttleEffectSpeedCap = __CPC.settings.throttleEffectSpeedCapMph and 43 or 70
    __CPC.settings.throttleGearIsolationEnabled = true
    __CPC.settings.throttleGearIsolationFov = true
    __CPC.settings.throttleGearIsolationGForce = true
    __CPC.settings.throttleGearIsolationTime = 0.28
    __CPC.settings.throttleDynamicsEnabled = true
    __CPC.settings.throttleAccelGEnabled = true
    __CPC.settings.throttleAccelGDistance = -0.028
    __CPC.settings.throttleAccelGAtFull = 0.80
    __CPC.settings.throttleAccelGSpeed = 6.0
    __CPC.settings.throttleBrakeDiveEnabled = true
    __CPC.settings.throttleBrakeDiveDistance = 0.035
    __CPC.settings.throttleBrakeDiveAtFull = 0.90
    __CPC.settings.throttleBrakeDiveSpeed = 7.0
    __CPC.settings.throttleHeaveEnabled = true
    __CPC.settings.throttleHeaveDistance = 0.012
    __CPC.settings.throttleHeaveAtFull = 0.90
    __CPC.settings.throttleHeaveSpeed = 8.0
    __CPC.settings.throttleDriftTranslationEnabled = true
    __CPC.settings.throttleDriftTranslationDistance = 0.020
    __CPC.settings.throttleDriftAngleAtFull = 12
    __CPC.settings.throttleDriftTranslationSpeed = 7.0
    __CPC.settings.throttleImpactEnabled = true
    __CPC.settings.throttleImpactDistance = 0.025
    __CPC.settings.throttleImpactGThreshold = 2.2
    __CPC.settings.throttleImpactRecoverySpeed = 12
    __CPC.settings.throttleForwardDistance = 0.350
    __CPC.settings.throttleBackDistance = 0.250
    __CPC.settings.throttleForwardFovLink = false
    __CPC.settings.throttleForwardSpeed = 12
    __CPC.settings.throttleVerticalDistance = -0.006
    __CPC.settings.throttleVerticalSpeed = 7.0
    __CPC.settings.throttleLateralDistance = 0.008
    __CPC.settings.throttleLateralSpeed = 6.0
    __CPC.settings.throttleSteeringAtFull = 420
    __CPC.settings.throttlePitchAngle = 3.0
    __CPC.settings.throttlePitchSpeed = 6.0
    __CPC.settings.throttleYawAngle = 2.5
    __CPC.settings.throttleYawSpeed = 6.0

    -- Motion-weighted FOV with modest wheel-derived position and angle sources.
    __CPC.settings.throttleFovForwardMix, __CPC.settings.throttleFovForwardLimit = 3.0, 4.0
    __CPC.settings.throttleFovVerticalMix, __CPC.settings.throttleFovVerticalLimit = 0.6, 1.5
    __CPC.settings.throttleFovLateralMix, __CPC.settings.throttleFovLateralLimit = 0.5, 1.2
    __CPC.settings.throttleFovPitchMix, __CPC.settings.throttleFovPitchLimit = 0.7, 1.5
    __CPC.settings.throttleFovYawMix, __CPC.settings.throttleFovYawLimit = 0.4, 1.0
    __CPC.settings.throttleFovSpeedMix, __CPC.settings.throttleFovSpeedLimit = 5.0, 6.0
    __CPC.settings.throttleFovSpeedStartKmh = 30
    __CPC.settings.throttleFovSpeedFullKmh = 200
    __CPC.settings.throttleFovSpeedCurve = 1.0
    __CPC.settings.throttleFovAccelGMix, __CPC.settings.throttleFovAccelGLimit = 2.0, 2.5
    __CPC.settings.throttleFovBrakeGMix, __CPC.settings.throttleFovBrakeGLimit = -1.5, 2.0
    __CPC.settings.throttleFovHeaveMix, __CPC.settings.throttleFovHeaveLimit = 0.4, 0.8
    __CPC.settings.throttleFovDriftMix, __CPC.settings.throttleFovDriftLimit = 1.0, 1.5
    __CPC.settings.throttleFovImpactMix, __CPC.settings.throttleFovImpactLimit = -1.25, 2.0
    __CPC.settings.throttleFovMixStrength = 0.90
    __CPC.settings.throttleFovMixSpeed = 6.0
    __CPC.settings.throttleFovMixLimit = 10

    -- NeckFX follows measured car motion; steering is only a small fallback.
    __CPC.settings.neckEnabled = true
    __CPC.settings.neckDynamicMovement = true
    __CPC.settings.neckOverallSpeed = 1.0
    __CPC.settings.neckGForceAtFull = 1.25
    __CPC.settings.neckEffectSpeedCap = __CPC.settings.neckEffectSpeedCapMph and 37 or 60
    __CPC.settings.neckMoveXDistance, __CPC.settings.neckMoveXSpeed = 0.035, 8.5
    __CPC.settings.neckMoveYDistance, __CPC.settings.neckMoveYSpeed = 0.012, 10
    __CPC.settings.neckMoveZDistance, __CPC.settings.neckMoveZSpeed = 0.045, 8.5
    __CPC.settings.neckYawAngle, __CPC.settings.neckYawSpeed = 8, 7.5
    __CPC.settings.neckPitchAngle, __CPC.settings.neckPitchSpeed = 7, 8.0
    __CPC.settings.neckRollAngle, __CPC.settings.neckRollSpeed = 9, 8.0
    __CPC.settings.neckDriftYawAngle, __CPC.settings.neckDriftYawSpeed = 10, 7.5
    __CPC.settings.neckRoadPitchAngle, __CPC.settings.neckRoadPitchSpeed = 5, 7.0
    __CPC.settings.neckBankRollAngle, __CPC.settings.neckBankRollSpeed = 8, 7.5
    __CPC.settings.neckSpeedAngleStartKmh, __CPC.settings.neckSpeedAngleFullKmh = 40, 200
    __CPC.settings.neckSpeedPitchAngle, __CPC.settings.neckSpeedPitchSpeed = 4, 6.5
    __CPC.settings.neckSpeedYawAngle, __CPC.settings.neckSpeedYawSpeed = 5, 7.0
    __CPC.settings.neckSpeedRollAngle, __CPC.settings.neckSpeedRollSpeed = 6, 7.0
    __CPC.settings.neckHiddenJerkAtFull = 8.0
    __CPC.settings.neckHiddenYawRateAtFull = 1.10
    __CPC.settings.neckHiddenYawAngle, __CPC.settings.neckHiddenYawSpeed = 2.5, 12
    __CPC.settings.neckHiddenPitchAngle, __CPC.settings.neckHiddenPitchSpeed = 2.0, 13
    __CPC.settings.neckHiddenRollAngle, __CPC.settings.neckHiddenRollSpeed = 2.5, 13
    __CPC.settings.neckMixYawToRoll, __CPC.settings.neckMixRollToYaw = 0.15, 0.08
    __CPC.settings.neckMixPitchToRoll, __CPC.settings.neckMixRollToPitch = 0.05, 0.08
    __CPC.settings.neckMixXToZ, __CPC.settings.neckMixZToX = 0.12, 0.08
    __CPC.settings.neckMixYToZ, __CPC.settings.neckMixZToY = 0.10, 0.12
    __CPC.settings.neckSlideFollowing = true
    __CPC.settings.neckSlidingLookMult = 0.55
    __CPC.settings.neckTrackFollowing = true
    __CPC.settings.neckTrackFollowingMult = 0.45
    __CPC.settings.neckSteeringMult = 0.25
    __CPC.settings.neckLookaheadDistance = 24

    -- Extended linear channels are part of the arcade feel as well.
    __CPC.settings.throttleLinearMasterEnabled = true
    __CPC.settings.throttleLinearMasterScale = 1.15
    __CPC.settings.throttleSmoothingMode = 2
    __CPC.settings.throttleMasterTranslationScale = 1.10
    __CPC.settings.throttleCornerGDistance, __CPC.settings.throttleCornerGAtFull = -0.020, 1.30
    __CPC.settings.throttleSteerKickDistance, __CPC.settings.throttleSteerKickAtFull = 0.009, 1.40
    __CPC.settings.throttleYawSwayDistance, __CPC.settings.throttleYawSwayAtFull = 0.013, 0.75
    __CPC.settings.throttleDownforceDistance, __CPC.settings.throttleDownforceAtFull = -0.014, 240
    __CPC.settings.throttleSpeedDrawDistance, __CPC.settings.throttleSpeedDrawAtFull = -0.026, 240
    __CPC.settings.throttleBoostDistance, __CPC.settings.throttleBoostAtFull = -0.011, 1.15
    __CPC.settings.throttleRoadRumbleDistance, __CPC.settings.throttleRoadRumbleAtFull = 0.006, 0.50
    __CPC.settings.throttleSlipJudderDistance, __CPC.settings.throttleSlipJudderAtFull = 0.005, 1.15
    __CPC.settings.throttleBrakePulseDistance, __CPC.settings.throttleBrakePulseAtFull = 0.006, 0.95
    __CPC.settings.throttleShiftJoltDistance, __CPC.settings.throttleShiftJoltAtFull = -0.015, 0.90
    __CPC.settings.throttleRPMShakeDistance, __CPC.settings.throttleRPMShakeAtFull = 0.0020, 0.95

    -- The preset owns direction so a previous reverse checkbox cannot cancel it.
    for key in pairs(__CPC.DEFAULTS) do
      if string.sub(key, -7) == 'Reverse' then __CPC.settings[key] = false end
    end
    __CPC.resetThrottleMotion()
  end

end
