return [====[
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
]====]
