return [====[
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
]====]
