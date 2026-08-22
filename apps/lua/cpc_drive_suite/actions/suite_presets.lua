return [====[

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
]====]
