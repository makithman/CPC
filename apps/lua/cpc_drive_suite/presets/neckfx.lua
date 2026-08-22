return [====[
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
]====]
