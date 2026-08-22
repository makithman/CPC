return [====[
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
]====]
