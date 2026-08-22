-- CPC Drive Suite — UI preset data
local SECTION_PRESETS = {
  syncedBase = {
    { label = 'LIGHT', values = {
      throttleRestingFov = 55, throttleMaximumFov = 95,
      throttleForwardDistance = 0.120, throttleBackDistance = 0.060,
      throttleTransitionSpeed = 6,
      throttleSpeedForwardEnabled = true, throttleSpeedForwardDistance = 0.100,
      throttleSpeedFovWiden = 10, throttleSpeedForwardStartKmh = 10,
      throttleSpeedForwardFullKmh = 180, throttleSpeedForwardCurve = 1.20,
      throttleSpeedLayerSpeed = 1.8,
      throttleSyncedYEnabled = true, throttleSyncedYDownDistance = 0.020,
      throttleSyncedYUpDistance = 0.015
    }},
    { label = 'BALANCED', values = {
      throttleRestingFov = 45, throttleMaximumFov = 145,
      throttleForwardDistance = 0.350, throttleBackDistance = 0.250,
      throttleTransitionSpeed = 12,
      throttleSpeedForwardEnabled = true, throttleSpeedForwardDistance = 0.250,
      throttleSpeedFovWiden = 22, throttleSpeedForwardStartKmh = 0,
      throttleSpeedForwardFullKmh = 180, throttleSpeedForwardCurve = 1.00,
      throttleSpeedLayerSpeed = 2.5,
      throttleSyncedYEnabled = true, throttleSyncedYDownDistance = 0.050,
      throttleSyncedYUpDistance = 0.035
    }},
    { label = 'STRONG', values = {
      throttleRestingFov = 35, throttleMaximumFov = 170,
      throttleForwardDistance = 0.650, throttleBackDistance = 0.450,
      throttleTransitionSpeed = 20,
      throttleSpeedForwardEnabled = true, throttleSpeedForwardDistance = 0.500,
      throttleSpeedFovWiden = 35, throttleSpeedForwardStartKmh = 0,
      throttleSpeedForwardFullKmh = 150, throttleSpeedForwardCurve = 0.75,
      throttleSpeedLayerSpeed = 3.2,
      throttleSyncedYEnabled = true, throttleSyncedYDownDistance = 0.100,
      throttleSyncedYUpDistance = 0.075
    }}
  },

  clutchAssists = {
    { label = 'LIGHT', values = {
      clutchLaunchEnabled = true, clutchAntiStallEnabled = true,
      clutchShiftEnabled = true, clutchTurnAware = false, clutchKickEnabled = false
    }},
    { label = 'BALANCED', values = {
      clutchLaunchEnabled = true, clutchAntiStallEnabled = true,
      clutchShiftEnabled = true, clutchTurnAware = true, clutchKickEnabled = false
    }},
    { label = 'STRONG', values = {
      clutchLaunchEnabled = true, clutchAntiStallEnabled = true,
      clutchShiftEnabled = true, clutchTurnAware = true, clutchKickEnabled = true
    }}
  },

  clutchLaunch = {
    { label = 'LIGHT', values = {
      clutchLaunchRPMPercent = 22, clutchLaunchEndSpeed = 14, clutchLaunchThrottle = 0.16
    }},
    { label = 'BALANCED', values = {
      clutchLaunchRPMPercent = 24, clutchLaunchEndSpeed = 16, clutchLaunchThrottle = 0.12
    }},
    { label = 'STRONG', values = {
      clutchLaunchRPMPercent = 34, clutchLaunchEndSpeed = 20, clutchLaunchThrottle = 0.08
    }}
  },

  clutchAntiStall = {
    { label = 'LIGHT', values = {
      clutchAntiStallMargin = 300, clutchAntiStallSpeed = 28, clutchRPMLookahead = 0.09,
      clutchBrakeThreshold = 0.16, clutchTurnLoadStart = 0.30, clutchTurnExtraMargin = 150
    }},
    { label = 'BALANCED', values = {
      clutchAntiStallMargin = 420, clutchAntiStallSpeed = 38, clutchRPMLookahead = 0.14,
      clutchBrakeThreshold = 0.12, clutchTurnLoadStart = 0.22, clutchTurnExtraMargin = 260
    }},
    { label = 'STRONG', values = {
      clutchAntiStallMargin = 650, clutchAntiStallSpeed = 55, clutchRPMLookahead = 0.20,
      clutchBrakeThreshold = 0.08, clutchTurnLoadStart = 0.14, clutchTurnExtraMargin = 500
    }}
  },

  clutchTiming = {
    { label = 'LIGHT', values = {
      clutchPressRate = 16, clutchReleaseRate = 3.5,
      clutchShiftHold = 0.090, clutchShiftRelease = 0.220
    }},
    { label = 'BALANCED', values = {
      clutchPressRate = 22, clutchReleaseRate = 5.0,
      clutchShiftHold = 0.075, clutchShiftRelease = 0.160
    }},
    { label = 'STRONG', values = {
      clutchPressRate = 34, clutchReleaseRate = 10.0,
      clutchShiftHold = 0.045, clutchShiftRelease = 0.080
    }}
  },

  clutchKick = {
    { label = 'LIGHT', values = {
      clutchKickEnabled = true, clutchKickRPMPercent = 45, clutchKickThrottle = 0.70,
      clutchKickSteer = 0.45, clutchKickMinSpeed = 25, clutchKickDuration = 0.060,
      clutchKickCooldown = 0.90, clutchKickRPMDrop = 900
    }},
    { label = 'BALANCED', values = {
      clutchKickEnabled = true, clutchKickRPMPercent = 52, clutchKickThrottle = 0.60,
      clutchKickSteer = 0.32, clutchKickMinSpeed = 18, clutchKickDuration = 0.090,
      clutchKickCooldown = 0.55, clutchKickRPMDrop = 500
    }},
    { label = 'STRONG', values = {
      clutchKickEnabled = true, clutchKickRPMPercent = 65, clutchKickThrottle = 0.45,
      clutchKickSteer = 0.20, clutchKickMinSpeed = 10, clutchKickDuration = 0.140,
      clutchKickCooldown = 0.30, clutchKickRPMDrop = 250
    }}
  },

  throttleMaster = {
    { label = 'LIGHT', values = {
      throttleOverallSpeed = 0.70, throttleDeadzone = 0.025, throttleCurve = 1.30,
      throttleInputAttackSpeed = 4, throttleInputReleaseSpeed = 3,
      throttleEffectSpeedCapMph = false, throttleEffectSpeedFloor = 10,
      throttleEffectSpeedCap = 90, throttleSpeedGateCurve = 1.40
    }},
    { label = 'BALANCED', values = {
      throttleOverallSpeed = 1.00, throttleDeadzone = 0.010, throttleCurve = 1.00,
      throttleInputAttackSpeed = 0, throttleInputReleaseSpeed = 0,
      throttleEffectSpeedCapMph = false, throttleEffectSpeedFloor = 0,
      throttleEffectSpeedCap = 20, throttleSpeedGateCurve = 1.00
    }},
    { label = 'STRONG', values = {
      throttleOverallSpeed = 1.50, throttleDeadzone = 0.000, throttleCurve = 0.70,
      throttleInputAttackSpeed = 18, throttleInputReleaseSpeed = 14,
      throttleEffectSpeedCapMph = false, throttleEffectSpeedFloor = 0,
      throttleEffectSpeedCap = 8, throttleSpeedGateCurve = 0.70
    }}
  },

  startPose = {
    { label = 'LIGHT', values = {
      throttleStartX = 0, throttleStartY = -0.020, throttleStartZ = -0.020,
      throttleStartPitch = -1.0
    }},
    { label = 'BALANCED', values = {
      throttleStartX = 0, throttleStartY = 0, throttleStartZ = 0,
      throttleStartPitch = 0
    }},
    { label = 'STRONG', values = {
      throttleStartX = 0, throttleStartY = 0.040, throttleStartZ = 0.050,
      throttleStartPitch = 2.5
    }}
  },

  baseAxes = {
    { label = 'LIGHT', values = {
      throttleForwardReverse = false, throttleForwardLimit = 0,
      throttleVerticalDistance = 0.006, throttleVerticalReverse = false,
      throttleVerticalSpeed = 5, throttleVerticalReleaseSpeed = 4,
      throttleVerticalCurve = 1.20, throttleVerticalLimit = 0.030,
      throttleLateralDistance = 0.008, throttleLateralReverse = false,
      throttleLateralSpeed = 5, throttleLateralReleaseSpeed = 4,
      throttleLateralCurve = 1.20, throttleLateralLimit = 0.030,
      throttleSteeringAtFull = 540
    }},
    { label = 'BALANCED', values = {
      throttleForwardReverse = false, throttleForwardLimit = 0,
      throttleVerticalDistance = 0.015, throttleVerticalReverse = false,
      throttleVerticalSpeed = 8, throttleVerticalReleaseSpeed = 0,
      throttleVerticalCurve = 1.00, throttleVerticalLimit = 0,
      throttleLateralDistance = 0.025, throttleLateralReverse = false,
      throttleLateralSpeed = 8, throttleLateralReleaseSpeed = 0,
      throttleLateralCurve = 1.00, throttleLateralLimit = 0,
      throttleSteeringAtFull = 360
    }},
    { label = 'STRONG', values = {
      throttleForwardReverse = false, throttleForwardLimit = 0.800,
      throttleVerticalDistance = 0.050, throttleVerticalReverse = false,
      throttleVerticalSpeed = 15, throttleVerticalReleaseSpeed = 10,
      throttleVerticalCurve = 0.80, throttleVerticalLimit = 0.120,
      throttleLateralDistance = 0.080, throttleLateralReverse = false,
      throttleLateralSpeed = 15, throttleLateralReleaseSpeed = 10,
      throttleLateralCurve = 0.80, throttleLateralLimit = 0.150,
      throttleSteeringAtFull = 180
    }}
  },

  throttlePitch = {
    { label = 'LIGHT', values = {
      throttlePitchAngle = 2, throttlePitchReverse = false, throttlePitchSpeed = 5,
      throttlePitchReleaseSpeed = 4, throttlePitchCurve = 1.20, throttlePitchLimit = 6
    }},
    { label = 'BALANCED', values = {
      throttlePitchAngle = 4, throttlePitchReverse = false, throttlePitchSpeed = 8,
      throttlePitchReleaseSpeed = 0, throttlePitchCurve = 1.00, throttlePitchLimit = 0
    }},
    { label = 'STRONG', values = {
      throttlePitchAngle = 12, throttlePitchReverse = false, throttlePitchSpeed = 16,
      throttlePitchReleaseSpeed = 10, throttlePitchCurve = 0.75, throttlePitchLimit = 20
    }}
  },

  throttleYaw = {
    { label = 'LIGHT', values = {
      throttleYawAngle = 2, throttleYawReverse = false, throttleYawSpeed = 5,
      throttleYawReleaseSpeed = 4, throttleYawCurve = 1.20, throttleYawLimit = 6
    }},
    { label = 'BALANCED', values = {
      throttleYawAngle = 6, throttleYawReverse = false, throttleYawSpeed = 8,
      throttleYawReleaseSpeed = 0, throttleYawCurve = 1.00, throttleYawLimit = 0
    }},
    { label = 'STRONG', values = {
      throttleYawAngle = 18, throttleYawReverse = false, throttleYawSpeed = 16,
      throttleYawReleaseSpeed = 10, throttleYawCurve = 0.75, throttleYawLimit = 30
    }}
  },

  fovMaster = {
    { label = 'LIGHT', values = {
      throttleFovMixStrength = 0.35, throttleFovMixSpeed = 5, throttleFovMixLimit = 5
    }},
    { label = 'BALANCED', values = {
      throttleFovMixStrength = 1.00, throttleFovMixSpeed = 8, throttleFovMixLimit = 12
    }},
    { label = 'STRONG', values = {
      throttleFovMixStrength = 1.75, throttleFovMixSpeed = 15, throttleFovMixLimit = 30
    }}
  },

  speedFov = {
    { label = 'LIGHT', values = {
      throttleFovSpeedMix = 1.0, throttleFovSpeedLimit = 2,
      throttleFovSpeedStartKmh = 50, throttleFovSpeedFullKmh = 220,
      throttleFovSpeedCurve = 1.30
    }},
    { label = 'BALANCED', values = {
      throttleFovSpeedMix = 2.0, throttleFovSpeedLimit = 6,
      throttleFovSpeedStartKmh = 20, throttleFovSpeedFullKmh = 180,
      throttleFovSpeedCurve = 1.00
    }},
    { label = 'STRONG', values = {
      throttleFovSpeedMix = 8.0, throttleFovSpeedLimit = 12,
      throttleFovSpeedStartKmh = 0, throttleFovSpeedFullKmh = 120,
      throttleFovSpeedCurve = 0.70
    }}
  },

  positionFov = {
    { label = 'LIGHT', values = {
      throttleFovForwardMix = 1.5, throttleFovForwardLimit = 3,
      throttleFovVerticalMix = 0.20, throttleFovVerticalLimit = 1,
      throttleFovLateralMix = 0.25, throttleFovLateralLimit = 1
    }},
    { label = 'BALANCED', values = {
      throttleFovForwardMix = 3.0, throttleFovForwardLimit = 8,
      throttleFovVerticalMix = 0.50, throttleFovVerticalLimit = 4,
      throttleFovLateralMix = 0.75, throttleFovLateralLimit = 4
    }},
    { label = 'STRONG', values = {
      throttleFovForwardMix = 8.0, throttleFovForwardLimit = 15,
      throttleFovVerticalMix = 2.0, throttleFovVerticalLimit = 6,
      throttleFovLateralMix = 2.5, throttleFovLateralLimit = 6
    }}
  },

  angleFov = {
    { label = 'LIGHT', values = {
      throttleFovPitchMix = 0.25, throttleFovPitchLimit = 1,
      throttleFovYawMix = 0.25, throttleFovYawLimit = 1
    }},
    { label = 'BALANCED', values = {
      throttleFovPitchMix = 0.75, throttleFovPitchLimit = 4,
      throttleFovYawMix = 0.75, throttleFovYawLimit = 4
    }},
    { label = 'STRONG', values = {
      throttleFovPitchMix = 3.0, throttleFovPitchLimit = 8,
      throttleFovYawMix = 3.0, throttleFovYawLimit = 8
    }}
  },

  dynamicFov = {
    { label = 'LIGHT', values = {
      throttleFovAccelGMix = 0.30, throttleFovAccelGLimit = 1,
      throttleFovBrakeGMix = -0.20, throttleFovBrakeGLimit = 1,
      throttleFovHeaveMix = 0.05, throttleFovHeaveLimit = 0.5,
      throttleFovDriftMix = 0.15, throttleFovDriftLimit = 1,
      throttleFovImpactMix = -0.25, throttleFovImpactLimit = 1
    }},
    { label = 'BALANCED', values = {
      throttleFovAccelGMix = 1.00, throttleFovAccelGLimit = 3,
      throttleFovBrakeGMix = -0.75, throttleFovBrakeGLimit = 3,
      throttleFovHeaveMix = 0.20, throttleFovHeaveLimit = 2,
      throttleFovDriftMix = 0.50, throttleFovDriftLimit = 3,
      throttleFovImpactMix = -1.00, throttleFovImpactLimit = 3
    }},
    { label = 'STRONG', values = {
      throttleFovAccelGMix = 2.50, throttleFovAccelGLimit = 6,
      throttleFovBrakeGMix = -2.00, throttleFovBrakeGLimit = 6,
      throttleFovHeaveMix = 1.00, throttleFovHeaveLimit = 4,
      throttleFovDriftMix = 1.50, throttleFovDriftLimit = 5,
      throttleFovImpactMix = -3.00, throttleFovImpactLimit = 6
    }}
  },

  shiftIsolation = {
    { label = 'LIGHT', values = {
      throttleGearIsolationEnabled = true, throttleGearIsolationFov = false,
      throttleGearIsolationGForce = true, throttleGearIsolationTime = 0.18
    }},
    { label = 'BALANCED', values = {
      throttleGearIsolationEnabled = true, throttleGearIsolationFov = true,
      throttleGearIsolationGForce = true, throttleGearIsolationTime = 0.35
    }},
    { label = 'STRONG', values = {
      throttleGearIsolationEnabled = true, throttleGearIsolationFov = true,
      throttleGearIsolationGForce = true, throttleGearIsolationTime = 0.60
    }}
  },

  linearMaster = {
    { label = 'LIGHT', values = {
      throttleDynamicsEnabled = true, throttleLinearMasterEnabled = true,
      throttleLinearMasterScale = 0.50
    }},
    { label = 'BALANCED', values = {
      throttleDynamicsEnabled = true, throttleLinearMasterEnabled = true,
      throttleLinearMasterScale = 1.00
    }},
    { label = 'STRONG', values = {
      throttleDynamicsEnabled = true, throttleLinearMasterEnabled = true,
      throttleLinearMasterScale = 2.00
    }}
  },

  outputScaling = {
    { label = 'LIGHT', values = {
      throttleMasterTranslationScale = 0.65, throttleMasterAngleScale = 0.65,
      throttleLinearMasterScale = 0.65
    }},
    { label = 'BALANCED', values = {
      throttleMasterTranslationScale = 1.00, throttleMasterAngleScale = 1.00,
      throttleLinearMasterScale = 1.00
    }},
    { label = 'STRONG', values = {
      throttleMasterTranslationScale = 1.80, throttleMasterAngleScale = 1.60,
      throttleLinearMasterScale = 1.80
    }}
  },

  finalClamps = {
    { label = 'LIGHT', values = {
      throttleOutputLimitX = 0.12, throttleOutputLimitY = 0.10, throttleOutputLimitZ = 0.20
    }},
    { label = 'BALANCED', values = {
      throttleOutputLimitX = 0.25, throttleOutputLimitY = 0.20, throttleOutputLimitZ = 0.40
    }},
    { label = 'STRONG', values = {
      throttleOutputLimitX = 0.50, throttleOutputLimitY = 0.40, throttleOutputLimitZ = 0.70
    }}
  },

  mixedFovShape = {
    { label = 'LIGHT', values = {
      throttleFovMixReturnSpeed = 4, throttleFovMixDeadzone = 0.50
    }},
    { label = 'BALANCED', values = {
      throttleFovMixReturnSpeed = 0, throttleFovMixDeadzone = 0
    }},
    { label = 'STRONG', values = {
      throttleFovMixReturnSpeed = 12, throttleFovMixDeadzone = 0
    }}
  },

  neckMaster = {
    { label = 'LIGHT', values = {
      neckDynamicMovement = true, neckOverallSpeed = 0.70, neckGForceAtFull = 2.50,
      neckMoveScale = 0.60, neckAngleScale = 0.60, neckHiddenScale = 0.40,
      neckMixScale = 0.50, neckFollowScale = 0.50,
      neckEffectSpeedCapMph = false, neckEffectSpeedCap = 100
    }},
    { label = 'BALANCED', values = {
      neckDynamicMovement = true, neckOverallSpeed = 1.00, neckGForceAtFull = 1.50,
      neckMoveScale = 1.00, neckAngleScale = 1.00, neckHiddenScale = 1.00,
      neckMixScale = 1.00, neckFollowScale = 1.00,
      neckEffectSpeedCapMph = false, neckEffectSpeedCap = 20
    }},
    { label = 'STRONG', values = {
      neckDynamicMovement = true, neckOverallSpeed = 1.60, neckGForceAtFull = 0.75,
      neckMoveScale = 1.80, neckAngleScale = 1.70, neckHiddenScale = 1.50,
      neckMixScale = 1.40, neckFollowScale = 1.50,
      neckEffectSpeedCapMph = false, neckEffectSpeedCap = 10
    }}
  },

  neckX = {
    { label = 'LIGHT', values = {
      neckMoveXDistance = 0.018, neckMoveXReverse = false, neckMoveXSpeed = 6
    }},
    { label = 'BALANCED', values = {
      neckMoveXDistance = 0.035, neckMoveXReverse = false, neckMoveXSpeed = 9
    }},
    { label = 'STRONG', values = {
      neckMoveXDistance = 0.080, neckMoveXReverse = false, neckMoveXSpeed = 16
    }}
  },

  neckY = {
    { label = 'LIGHT', values = {
      neckMoveYDistance = 0.008, neckMoveYReverse = false, neckMoveYSpeed = 7
    }},
    { label = 'BALANCED', values = {
      neckMoveYDistance = 0.015, neckMoveYReverse = false, neckMoveYSpeed = 12
    }},
    { label = 'STRONG', values = {
      neckMoveYDistance = 0.050, neckMoveYReverse = false, neckMoveYSpeed = 18
    }}
  },

  neckZ = {
    { label = 'LIGHT', values = {
      neckMoveZDistance = 0.020, neckMoveZReverse = false, neckMoveZSpeed = 6
    }},
    { label = 'BALANCED', values = {
      neckMoveZDistance = 0.040, neckMoveZReverse = false, neckMoveZSpeed = 9
    }},
    { label = 'STRONG', values = {
      neckMoveZDistance = 0.100, neckMoveZReverse = false, neckMoveZSpeed = 16
    }}
  },

  neckPrimaryRotation = {
    { label = 'LIGHT', values = {
      neckYawAngle = 4, neckYawReverse = false, neckYawSpeed = 6,
      neckPitchAngle = 3, neckPitchReverse = false, neckPitchSpeed = 6,
      neckRollAngle = 4, neckRollReverse = false, neckRollSpeed = 6
    }},
    { label = 'BALANCED', values = {
      neckYawAngle = 10, neckYawReverse = false, neckYawSpeed = 8,
      neckPitchAngle = 8, neckPitchReverse = false, neckPitchSpeed = 9,
      neckRollAngle = 10, neckRollReverse = false, neckRollSpeed = 9
    }},
    { label = 'STRONG', values = {
      neckYawAngle = 25, neckYawReverse = false, neckYawSpeed = 16,
      neckPitchAngle = 18, neckPitchReverse = false, neckPitchSpeed = 16,
      neckRollAngle = 25, neckRollReverse = false, neckRollSpeed = 16
    }}
  },

  neckRoadRotation = {
    { label = 'LIGHT', values = {
      neckDriftYawAngle = 6, neckDriftYawReverse = false, neckDriftYawSpeed = 6,
      neckRoadPitchAngle = 3, neckRoadPitchReverse = false, neckRoadPitchSpeed = 6,
      neckBankRollAngle = 5, neckBankRollReverse = false, neckBankRollSpeed = 6
    }},
    { label = 'BALANCED', values = {
      neckDriftYawAngle = 12, neckDriftYawReverse = false, neckDriftYawSpeed = 9,
      neckRoadPitchAngle = 8, neckRoadPitchReverse = false, neckRoadPitchSpeed = 7,
      neckBankRollAngle = 10, neckBankRollReverse = false, neckBankRollSpeed = 8
    }},
    { label = 'STRONG', values = {
      neckDriftYawAngle = 30, neckDriftYawReverse = false, neckDriftYawSpeed = 16,
      neckRoadPitchAngle = 18, neckRoadPitchReverse = false, neckRoadPitchSpeed = 14,
      neckBankRollAngle = 25, neckBankRollReverse = false, neckBankRollSpeed = 15
    }}
  },

  neckSpeedWindow = {
    { label = 'LIGHT', values = {
      neckSpeedAngleStartKmh = 80, neckSpeedAngleFullKmh = 250,
      neckSpeedPitchAngle = 2, neckSpeedPitchReverse = false, neckSpeedPitchSpeed = 5,
      neckSpeedYawAngle = 3, neckSpeedYawReverse = false, neckSpeedYawSpeed = 5,
      neckSpeedRollAngle = 3, neckSpeedRollReverse = false, neckSpeedRollSpeed = 5
    }},
    { label = 'BALANCED', values = {
      neckSpeedAngleStartKmh = 20, neckSpeedAngleFullKmh = 180,
      neckSpeedPitchAngle = 5, neckSpeedPitchReverse = false, neckSpeedPitchSpeed = 6,
      neckSpeedYawAngle = 8, neckSpeedYawReverse = false, neckSpeedYawSpeed = 8,
      neckSpeedRollAngle = 8, neckSpeedRollReverse = false, neckSpeedRollSpeed = 8
    }},
    { label = 'STRONG', values = {
      neckSpeedAngleStartKmh = 0, neckSpeedAngleFullKmh = 100,
      neckSpeedPitchAngle = 15, neckSpeedPitchReverse = false, neckSpeedPitchSpeed = 14,
      neckSpeedYawAngle = 20, neckSpeedYawReverse = false, neckSpeedYawSpeed = 14,
      neckSpeedRollAngle = 20, neckSpeedRollReverse = false, neckSpeedRollSpeed = 14
    }}
  },

  neckTransient = {
    { label = 'LIGHT', values = {
      neckHiddenJerkAtFull = 15, neckHiddenYawRateAtFull = 1.8,
      neckHiddenYawAngle = 1.0, neckHiddenYawReverse = false, neckHiddenYawSpeed = 8,
      neckHiddenPitchAngle = 0.8, neckHiddenPitchReverse = false, neckHiddenPitchSpeed = 8,
      neckHiddenRollAngle = 1.0, neckHiddenRollReverse = false, neckHiddenRollSpeed = 8
    }},
    { label = 'BALANCED', values = {
      neckHiddenJerkAtFull = 8, neckHiddenYawRateAtFull = 1.0,
      neckHiddenYawAngle = 3.0, neckHiddenYawReverse = false, neckHiddenYawSpeed = 12,
      neckHiddenPitchAngle = 2.5, neckHiddenPitchReverse = false, neckHiddenPitchSpeed = 14,
      neckHiddenRollAngle = 3.0, neckHiddenRollReverse = false, neckHiddenRollSpeed = 14
    }},
    { label = 'STRONG', values = {
      neckHiddenJerkAtFull = 3, neckHiddenYawRateAtFull = 0.5,
      neckHiddenYawAngle = 8.0, neckHiddenYawReverse = false, neckHiddenYawSpeed = 20,
      neckHiddenPitchAngle = 6.0, neckHiddenPitchReverse = false, neckHiddenPitchSpeed = 20,
      neckHiddenRollAngle = 8.0, neckHiddenRollReverse = false, neckHiddenRollSpeed = 20
    }}
  },

  neckAngleMix = {
    { label = 'LIGHT', values = {
      neckMixYawToRoll = 0.05, neckMixRollToYaw = 0.03,
      neckMixPitchToRoll = 0.02, neckMixRollToPitch = 0.03
    }},
    { label = 'BALANCED', values = {
      neckMixYawToRoll = 0.20, neckMixRollToYaw = 0.10,
      neckMixPitchToRoll = 0.05, neckMixRollToPitch = 0.10
    }},
    { label = 'STRONG', values = {
      neckMixYawToRoll = 0.60, neckMixRollToYaw = 0.35,
      neckMixPitchToRoll = 0.25, neckMixRollToPitch = 0.35
    }}
  },

  neckPositionMix = {
    { label = 'LIGHT', values = {
      neckMixXToZ = 0.05, neckMixZToX = 0.03,
      neckMixYToZ = 0.05, neckMixZToY = 0.05
    }},
    { label = 'BALANCED', values = {
      neckMixXToZ = 0.15, neckMixZToX = 0.10,
      neckMixYToZ = 0.15, neckMixZToY = 0.20
    }},
    { label = 'STRONG', values = {
      neckMixXToZ = 0.50, neckMixZToX = 0.35,
      neckMixYToZ = 0.50, neckMixZToY = 0.60
    }}
  },

  neckFollow = {
    { label = 'LIGHT', values = {
      neckSlideFollowing = true, neckSlidingLookMult = 0.25,
      neckTrackFollowing = true, neckTrackFollowingMult = 0.35,
      neckLookaheadDistance = 15, neckSteeringMult = 0.25
    }},
    { label = 'BALANCED', values = {
      neckSlideFollowing = true, neckSlidingLookMult = 0.50,
      neckTrackFollowing = true, neckTrackFollowingMult = 0.70,
      neckLookaheadDistance = 20, neckSteeringMult = 0.70
    }},
    { label = 'STRONG', values = {
      neckSlideFollowing = true, neckSlidingLookMult = 0.95,
      neckTrackFollowing = true, neckTrackFollowingMult = 1.10,
      neckLookaheadDistance = 30, neckSteeringMult = 1.20
    }}
  },

  simpleFourAxis = {
    { label = 'LIGHT', values = {
      neckGForceAtFull = 2.50, neckOverallSpeed = 0.70,
      neckMoveZDistance = 0.020, neckMoveXDistance = 0.018,
      neckMoveYDistance = 0.008, neckYawAngle = 5
    }},
    { label = 'BALANCED', values = {
      neckGForceAtFull = 1.50, neckOverallSpeed = 1.00,
      neckMoveZDistance = 0.040, neckMoveXDistance = 0.035,
      neckMoveYDistance = 0.015, neckYawAngle = 10
    }},
    { label = 'STRONG', values = {
      neckGForceAtFull = 0.80, neckOverallSpeed = 1.60,
      neckMoveZDistance = 0.090, neckMoveXDistance = 0.080,
      neckMoveYDistance = 0.040, neckYawAngle = 25
    }}
  },

  driftLook = {
    { label = 'LIGHT', values = {
      neckDriftYawAngle = 6, neckDriftYawReverse = false, neckDriftYawSpeed = 6,
      neckSlideFollowing = true, neckSlidingLookMult = 0.25,
      neckSteeringMult = 0.25, neckFollowScale = 0.60
    }},
    { label = 'BALANCED', values = {
      neckDriftYawAngle = 12, neckDriftYawReverse = false, neckDriftYawSpeed = 9,
      neckSlideFollowing = true, neckSlidingLookMult = 0.50,
      neckSteeringMult = 0.70, neckFollowScale = 1.00
    }},
    { label = 'STRONG', values = {
      neckDriftYawAngle = 30, neckDriftYawReverse = false, neckDriftYawSpeed = 18,
      neckSlideFollowing = true, neckSlidingLookMult = 1.10,
      neckSteeringMult = 1.40, neckFollowScale = 1.80
    }}
  },

  hudLayout = {
    { label = 'LIGHT', values = {
      hudMode = 3, hudOpacity = 0.65, hudAnimation = 0.25, hudSpeedMph = false
    }},
    { label = 'BALANCED', values = {
      hudMode = 1, hudOpacity = 0.94, hudAnimation = 1.00, hudSpeedMph = false
    }},
    { label = 'STRONG', values = {
      hudMode = 1, hudOpacity = 1.00, hudAnimation = 1.50, hudSpeedMph = false
    }}
  },

  hudSections = {
    { label = 'LIGHT', values = {
      hudShowRPM = true, hudShowWheel = false, hudShowPedals = false,
      hudShowCamera = false, hudShowStatus = true,
      hudShowGMeter = false, hudShowShiftLights = false
    }},
    { label = 'BALANCED', values = {
      hudShowRPM = true, hudShowWheel = true, hudShowPedals = true,
      hudShowCamera = false, hudShowStatus = true,
      hudShowGMeter = false, hudShowShiftLights = true
    }},
    { label = 'STRONG', values = {
      hudShowRPM = true, hudShowWheel = true, hudShowPedals = true,
      hudShowCamera = true, hudShowStatus = true,
      hudShowGMeter = true, hudShowShiftLights = true
    }}
  },

  autoGearShiftPoints = {
    { label = 'ECONOMY', values = {
      autoGearShiftTime1 = 1.5, autoGearShiftTime2 = 1.8, autoGearShiftTime3 = 2.0,
      autoGearShiftTime4 = 2.2, autoGearShiftTime5 = 2.5, autoGearThrottleOffDelay = 1.0
    }},
    { label = 'BALANCED', values = {
      autoGearShiftTime1 = 2.0, autoGearShiftTime2 = 2.5, autoGearShiftTime3 = 3.0,
      autoGearShiftTime4 = 3.5, autoGearShiftTime5 = 4.0, autoGearThrottleOffDelay = 1.5
    }},
    { label = 'TRACK', values = {
      autoGearShiftTime1 = 3.0, autoGearShiftTime2 = 3.8, autoGearShiftTime3 = 4.5,
      autoGearShiftTime4 = 5.2, autoGearShiftTime5 = 6.0, autoGearThrottleOffDelay = 2.5
    }}
  }
}

return SECTION_PRESETS
