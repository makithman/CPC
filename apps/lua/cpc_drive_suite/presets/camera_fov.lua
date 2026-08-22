return [====[
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
]====]
