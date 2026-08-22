-- CPC Drive Suite — settings, defaults and migrations
local DEFAULTS = {
  suiteEnabled = true,

  -- Adaptive clutch.
  clutchEnabled = true,
  clutchLaunchEnabled = true,
  clutchAntiStallEnabled = true,
  clutchShiftEnabled = true,
  clutchTurnAware = true,
  clutchHandbrakeEnabled = false,
  clutchKickEnabled = false,
  clutchLaunchRPMPercent = 24,
  clutchLaunchEndSpeed = 16,
  clutchLaunchThrottle = 0.12,
  clutchLaunchControlEnabled = false,
  clutchLaunchControlBite = 0.28,
  clutchLaunchControlThrottle = 0.60,
  clutchAntiStallMargin = 420,
  clutchAntiStallSpeed = 38,
  clutchRPMLookahead = 0.14,
  clutchBrakeThreshold = 0.12,
  clutchTurnLoadStart = 0.22,
  clutchTurnExtraMargin = 260,
  clutchPressRate = 22,
  clutchReleaseRate = 5.0,
  clutchShiftHold = 0.075,
  clutchShiftRelease = 0.16,
  clutchKickRPMPercent = 50,
  clutchKickThrottle = 0.64,
  clutchKickSteer = 0.38,
  clutchKickMinSpeed = 20,
  clutchKickDuration = 0.085,
  clutchKickCooldown = 0.65,
  clutchKickRPMDrop = 650,

  -- Automatic gearing assist.
  autoGearEnabled = false,
  autoGearTrackerSteps = 6,
  autoGearTrackerStepInterval = 0.12,
  autoGearTrackerConfirmTimeout = 0.25,
  autoGearMinSpeed = 8,
  autoGearRPMMode = true,
  autoGearUpshiftRPMPercent = 0.90,
  autoGearUpshiftConfirmTime = 0.08,
  autoGearMinThrottle = 0.30,
  autoGearBrakeDownshiftThreshold = 0.15,
  autoGearOverrunMargin = 0.95,
  autoGearCorneringGThreshold = 0.45,
  autoGearCorneringSteerThreshold = 0.45,
  autoGearShiftTime1 = 2.0,
  autoGearShiftTime2 = 2.5,
  autoGearShiftTime3 = 3.0,
  autoGearShiftTime4 = 3.5,
  autoGearShiftTime5 = 4.0,
  autoGearThrottleOffDelay = 1.5,
  autoGearOverrunProtect = true,
  autoGearMinShiftInterval = 0.35,
  autoGearClutchAssist = true,
  autoGearShiftConfirmTimeout = 0.25,
  autoGearUpshiftRelease = 0.14,
  autoGearDownshiftRelease = 0.24,
  autoGearInstantDownshiftEnabled = false,
  autoGearInstantDownshiftGear = 2,
  autoGearInstantDownshiftThreshold = 0.15,
  autoGearPerGearTargets = true,
  autoGearUpshiftRPMGear1 = 0.88,
  autoGearUpshiftRPMGear2 = 0.90,
  autoGearUpshiftRPMGear3 = 0.91,
  autoGearUpshiftRPMGear4 = 0.92,
  autoGearUpshiftRPMGear5 = 0.93,
  autoGearUpshiftRPMGear6 = 0.94,
  autoGearDownshiftRPMPercent = 0.68,
  autoGearBlipEnabled = true,
  autoGearBlipAmount = 0.55,
  autoGearBlipDuration = 0.12,

  -- Direct onboard camera and FOV layer.
  throttleEnabled = true,
  throttleOverallSpeed = 1.0,
  throttleRestingFov = 45,
  throttleMaximumFov = 145,
  throttleFovHardMin = 20,
  throttleFovHardMax = 170,
  throttleFovWidenSpeed = 12,
  throttleFovReturnSpeed = 12,
  throttleDeadzone = 0.01,
  throttleCurve = 1.0,
  throttleEffectSpeedCap = 20,
  throttleEffectSpeedCapMph = false,
  throttleGearIsolationEnabled = true,
  throttleGearIsolationFov = true,
  throttleGearIsolationGForce = true,
  throttleGearIsolationTime = 0.35,
  throttleGearAnticipationEnabled = false,
  throttleGearAnticipationRpm = 0.88,
  throttleGearAnticipationThrottle = 0.35,
  throttleGearAnticipationDistance = -0.015,
  throttleGearAnticipationFov = 1.5,
  throttleGearAnticipationSpeed = 7.0,
  throttleDynamicsEnabled = true,
  throttleAccelGEnabled = true,
  throttleAccelGDistance = -0.012,
  throttleAccelGReverse = false,
  throttleAccelGAtFull = 0.8,
  throttleAccelGSpeed = 5.0,
  throttleBrakeDiveEnabled = true,
  throttleBrakeDiveDistance = 0.018,
  throttleBrakeDiveReverse = false,
  throttleBrakeDiveAtFull = 1.0,
  throttleBrakeDiveSpeed = 6.0,
  throttleHeaveEnabled = true,
  throttleHeaveDistance = 0.006,
  throttleHeaveReverse = false,
  throttleHeaveAtFull = 0.8,
  throttleHeaveSpeed = 6.0,
  throttleDriftTranslationEnabled = true,
  throttleDriftTranslationDistance = 0.010,
  throttleDriftTranslationReverse = false,
  throttleDriftAngleAtFull = 12,
  throttleDriftTranslationSpeed = 5.0,
  throttleImpactEnabled = true,
  throttleImpactDistance = 0.020,
  throttleImpactReverse = false,
  throttleImpactGThreshold = 2.2,
  throttleImpactRecoverySpeed = 12.0,
  throttleStartX = 0,
  throttleStartY = 0,
  throttleStartZ = 0,
  throttleStartPitch = 0,
  throttleForwardDistance = 0.350,
  throttleBackDistance = 0.250,
  throttleForwardReverse = false,
  throttleForwardSpeed = 12,
  throttleTransitionSpeed = 12,
  throttleFovTransitionSpeed = 12,
  -- Extra forward movement driven by vehicle speed, stacked on top of the
  -- throttle-synced fore/aft camera.
  throttleSpeedForwardEnabled = true,
  throttleSpeedForwardDistance = 0.250,
  throttleSpeedFovWiden = 22.0,
  throttleSpeedForwardStartKmh = 0,
  throttleSpeedForwardFullKmh = 180,
  throttleSpeedForwardCurve = 1.0,
  throttleSpeedLayerSpeed = 2.5,

  -- Vertical Y-force coupled to the exact same signed geometry as the two Z
  -- layers. Forward Z drives the seat down; backward/reverse Z drives it up.
  throttleSyncedYEnabled = true,
  throttleSyncedYDownDistance = 0.050,
  throttleSyncedYUpDistance = 0.035,

  throttleVerticalDistance = 0.015,
  throttleVerticalReverse = false,
  throttleVerticalSpeed = 8,
  throttleLateralDistance = 0.025,
  throttleLateralReverse = false,
  throttleLateralSpeed = 8,
  throttleSteeringAtFull = 360,
  throttlePitchAngle = 4,
  throttlePitchReverse = false,
  throttlePitchSpeed = 8,
  throttleYawAngle = 6,
  throttleYawReverse = false,
  throttleYawSpeed = 8,
  throttleFovForwardMix = 3.0,
  throttleFovForwardLimit = 8.0,
  throttleFovVerticalMix = 0.5,
  throttleFovVerticalLimit = 4.0,
  throttleFovLateralMix = 0.75,
  throttleFovLateralLimit = 4.0,
  throttleFovPitchMix = 0.75,
  throttleFovPitchLimit = 4.0,
  throttleFovYawMix = 0.75,
  throttleFovYawLimit = 4.0,
  throttleFovSpeedMix = 2.0,
  throttleFovSpeedLimit = 6.0,
  throttleFovSpeedStartKmh = 20,
  throttleFovSpeedFullKmh = 180,
  throttleFovSpeedCurve = 1.0,
  throttleFovAccelGMix = 1.0,
  throttleFovAccelGLimit = 3.0,
  throttleFovBrakeGMix = -0.75,
  throttleFovBrakeGLimit = 3.0,
  throttleFovHeaveMix = 0.20,
  throttleFovHeaveLimit = 2.0,
  throttleFovDriftMix = 0.50,
  throttleFovDriftLimit = 3.0,
  throttleFovImpactMix = -1.0,
  throttleFovImpactLimit = 3.0,
  throttleFovMixStrength = 1.0,
  throttleFovMixSpeed = 8,
  throttleFovMixLimit = 12,

  -- Braking into a turn and accelerating out of it can each add a separate,
  -- restrained camera response. They are opt-in so existing camera profiles
  -- stay exactly as configured.
  throttleCornerEntryEnabled = false,
  throttleCornerEntryDistance = 0.012,
  throttleCornerEntryFov = -1.0,
  throttleCornerEntrySpeed = 7.0,
  throttleCornerExitEnabled = false,
  throttleCornerExitDistance = -0.012,
  throttleCornerExitFov = 1.0,
  throttleCornerExitSpeed = 7.0,

  -- Advanced master shaping for the direct camera layer.
  throttleSmoothingMode = 1,
  throttleMasterTranslationScale = 1.0,
  throttleMasterAngleScale = 1.0,
  throttleLinearMasterEnabled = true,
  throttleLinearMasterScale = 1.0,
  throttleOutputLimitX = 0.25,
  throttleOutputLimitY = 0.2,
  throttleOutputLimitZ = 0.4,
  throttleEffectSpeedFloor = 0,
  throttleSpeedGateCurve = 1.0,
  throttleInputAttackSpeed = 0,
  throttleInputReleaseSpeed = 0,
  throttleFovMixReturnSpeed = 0,
  throttleFovMixDeadzone = 0,

  -- Split attack/release, response curves and hard clamps for the five
  -- original throttle-driven channels.
  throttleForwardReleaseSpeed = 0,
  throttleForwardCurve = 1.0,
  throttleForwardLimit = 0,
  throttleForwardFovLink = false,
  throttleForwardFovRatio = 0.0025,
  throttleForwardFovLive = true,
  throttleForwardFovLiveGain = 1.0,
  throttleForwardFovLiveFloor = 0,
  throttleVerticalReleaseSpeed = 0,
  throttleVerticalCurve = 1.0,
  throttleVerticalLimit = 0,
  throttleLateralReleaseSpeed = 0,
  throttleLateralCurve = 1.0,
  throttleLateralLimit = 0,
  throttlePitchReleaseSpeed = 0,
  throttlePitchCurve = 1.0,
  throttlePitchLimit = 0,
  throttleYawReleaseSpeed = 0,
  throttleYawCurve = 1.0,
  throttleYawLimit = 0,

  -- Advanced shaping added to the original dynamic linear channels.
  throttleAccelGReleaseSpeed = 0,
  throttleAccelGCurve = 1.0,
  throttleAccelGLimit = 0,
  throttleAccelGGateStart = 0,
  throttleAccelGGateFull = 1,
  throttleAccelGGateCurve = 1.0,
  throttleBrakeDiveReleaseSpeed = 0,
  throttleBrakeDiveCurve = 1.0,
  throttleBrakeDiveLimit = 0,
  throttleBrakeDiveGateStart = 0,
  throttleBrakeDiveGateFull = 1,
  throttleBrakeDiveGateCurve = 1.0,
  throttleHeaveReleaseSpeed = 0,
  throttleHeaveCurve = 1.0,
  throttleHeaveLimit = 0,
  throttleHeaveGateStart = 0,
  throttleHeaveGateFull = 1,
  throttleHeaveGateCurve = 1.0,
  throttleDriftTranslationReleaseSpeed = 0,
  throttleDriftTranslationCurve = 1.0,
  throttleDriftTranslationLimit = 0,
  throttleDriftTranslationGateStart = 0,
  throttleDriftTranslationGateFull = 1,
  throttleDriftTranslationGateCurve = 1.0,
  throttleImpactSpeed = 40,
  throttleImpactCurve = 1.0,
  throttleImpactLimit = 0,
  throttleImpactGateStart = 0,
  throttleImpactGateFull = 1,
  throttleImpactGateCurve = 1.0,

  -- Extended linear translation channels.
  throttleCornerGEnabled = true,
  throttleCornerGDistance = -0.014,
  throttleCornerGReverse = false,
  throttleCornerGAtFull = 1.4,
  throttleCornerGSpeed = 7.0,
  throttleCornerGReleaseSpeed = 0,
  throttleCornerGCurve = 1.0,
  throttleCornerGLimit = 0.06,
  throttleCornerGGateStart = 5,
  throttleCornerGGateFull = 45,
  throttleCornerGGateCurve = 1.0,
  throttleFovCornerGMix = 0.4,
  throttleFovCornerGLimit = 2.0,
  throttleSteerKickEnabled = true,
  throttleSteerKickDistance = 0.006,
  throttleSteerKickReverse = false,
  throttleSteerKickAtFull = 1.5,
  throttleSteerKickSpeed = 16.0,
  throttleSteerKickReleaseSpeed = 6.0,
  throttleSteerKickCurve = 1.0,
  throttleSteerKickLimit = 0.03,
  throttleSteerKickGateStart = 5,
  throttleSteerKickGateFull = 40,
  throttleSteerKickGateCurve = 1.0,
  throttleFovSteerKickMix = 0.2,
  throttleFovSteerKickLimit = 1.0,
  throttleYawSwayEnabled = true,
  throttleYawSwayDistance = 0.01,
  throttleYawSwayReverse = false,
  throttleYawSwayAtFull = 0.8,
  throttleYawSwaySpeed = 8.0,
  throttleYawSwayReleaseSpeed = 0,
  throttleYawSwayCurve = 1.0,
  throttleYawSwayLimit = 0.04,
  throttleYawSwayGateStart = 5,
  throttleYawSwayGateFull = 40,
  throttleYawSwayGateCurve = 1.0,
  throttleFovYawSwayMix = 0.3,
  throttleFovYawSwayLimit = 1.5,
  throttleDownforceEnabled = true,
  throttleDownforceDistance = -0.01,
  throttleDownforceReverse = false,
  throttleDownforceAtFull = 250,
  throttleDownforceSpeed = 3.0,
  throttleDownforceReleaseSpeed = 0,
  throttleDownforceCurve = 1.2,
  throttleDownforceLimit = 0.03,
  throttleDownforceGateStart = 0,
  throttleDownforceGateFull = 1,
  throttleDownforceGateCurve = 1.0,
  throttleFovDownforceMix = 0.2,
  throttleFovDownforceLimit = 1.0,
  throttleSpeedDrawEnabled = true,
  throttleSpeedDrawDistance = -0.02,
  throttleSpeedDrawReverse = false,
  throttleSpeedDrawAtFull = 260,
  throttleSpeedDrawSpeed = 3.5,
  throttleSpeedDrawReleaseSpeed = 0,
  throttleSpeedDrawCurve = 1.1,
  throttleSpeedDrawLimit = 0.06,
  throttleSpeedDrawGateStart = 0,
  throttleSpeedDrawGateFull = 1,
  throttleSpeedDrawGateCurve = 1.0,
  throttleFovSpeedDrawMix = 1.5,
  throttleFovSpeedDrawLimit = 4.0,
  throttleBoostEnabled = true,
  throttleBoostDistance = -0.008,
  throttleBoostReverse = false,
  throttleBoostAtFull = 1.2,
  throttleBoostSpeed = 9.0,
  throttleBoostReleaseSpeed = 5.0,
  throttleBoostCurve = 1.0,
  throttleBoostLimit = 0.03,
  throttleBoostGateStart = 5,
  throttleBoostGateFull = 60,
  throttleBoostGateCurve = 1.0,
  throttleFovBoostMix = 0.5,
  throttleFovBoostLimit = 2.0,
  throttleRPMShakeEnabled = true,
  throttleRPMShakeDistance = 0.0018,
  throttleRPMShakeReverse = false,
  throttleRPMShakeAtFull = 1.0,
  throttleRPMShakeSpeed = 10.0,
  throttleRPMShakeReleaseSpeed = 0,
  throttleRPMShakeCurve = 1.6,
  throttleRPMShakeLimit = 0.006,
  throttleRPMShakeFrequency = 4.0,
  throttleRPMShakeGateStart = 0,
  throttleRPMShakeGateFull = 1,
  throttleRPMShakeGateCurve = 1.0,
  throttleFovRPMShakeMix = 0.0,
  throttleFovRPMShakeLimit = 1.0,
  throttleRoadRumbleEnabled = true,
  throttleRoadRumbleDistance = 0.005,
  throttleRoadRumbleReverse = false,
  throttleRoadRumbleAtFull = 0.55,
  throttleRoadRumbleSpeed = 18.0,
  throttleRoadRumbleReleaseSpeed = 8.0,
  throttleRoadRumbleCurve = 1.0,
  throttleRoadRumbleLimit = 0.02,
  throttleRoadRumbleFrequency = 18.0,
  throttleRoadRumbleGateStart = 3,
  throttleRoadRumbleGateFull = 30,
  throttleRoadRumbleGateCurve = 1.0,
  throttleFovRoadRumbleMix = 0.15,
  throttleFovRoadRumbleLimit = 1.0,
  throttleSlipJudderEnabled = true,
  throttleSlipJudderDistance = 0.004,
  throttleSlipJudderReverse = false,
  throttleSlipJudderAtFull = 1.3,
  throttleSlipJudderSpeed = 12.0,
  throttleSlipJudderReleaseSpeed = 6.0,
  throttleSlipJudderCurve = 1.0,
  throttleSlipJudderLimit = 0.015,
  throttleSlipJudderFrequency = 24.0,
  throttleSlipJudderGateStart = 5,
  throttleSlipJudderGateFull = 40,
  throttleSlipJudderGateCurve = 1.0,
  throttleFovSlipJudderMix = 0.2,
  throttleFovSlipJudderLimit = 1.0,
  throttleBrakePulseEnabled = true,
  throttleBrakePulseDistance = 0.005,
  throttleBrakePulseReverse = false,
  throttleBrakePulseAtFull = 1.0,
  throttleBrakePulseSpeed = 20.0,
  throttleBrakePulseReleaseSpeed = 9.0,
  throttleBrakePulseCurve = 1.0,
  throttleBrakePulseLimit = 0.02,
  throttleBrakePulseFrequency = 14.0,
  throttleBrakePulseGateStart = 5,
  throttleBrakePulseGateFull = 40,
  throttleBrakePulseGateCurve = 1.0,
  throttleFovBrakePulseMix = -0.2,
  throttleFovBrakePulseLimit = 1.0,
  throttleShiftJoltEnabled = false,
  throttleShiftJoltDistance = -0.012,
  throttleShiftJoltReverse = false,
  throttleShiftJoltAtFull = 1.0,
  throttleShiftJoltSpeed = 26.0,
  throttleShiftJoltReleaseSpeed = 9.0,
  throttleShiftJoltCurve = 1.0,
  throttleShiftJoltLimit = 0.05,
  throttleShiftJoltGateStart = 0,
  throttleShiftJoltGateFull = 1,
  throttleShiftJoltGateCurve = 1.0,
  throttleFovShiftJoltMix = -0.6,
  throttleFovShiftJoltLimit = 2.0,

  -- NeckFX master scaling applied before the backend receives values.
  neckMoveScale = 1.0,
  neckAngleScale = 1.0,
  neckHiddenScale = 1.0,
  neckMixScale = 1.0,
  neckFollowScale = 1.0,

  -- NeckFX backend.
  neckEnabled = true,
  neckDynamicMovement = true,
  neckOverallSpeed = 1.0,
  neckGForceAtFull = 1.5,
  neckEffectSpeedCap = 20,
  neckEffectSpeedCapMph = false,
  neckMoveXDistance = 0.035,
  neckMoveXReverse = false,
  neckMoveXSpeed = 9,
  neckMoveYDistance = 0.015,
  neckMoveYReverse = false,
  neckMoveYSpeed = 12,
  neckMoveZDistance = 0.040,
  neckMoveZReverse = false,
  neckMoveZSpeed = 9,
  neckOvalWidth = 0.035,
  neckOvalHeight = 0.015,
  neckOvalSpeed = 0.65,
  neckYawAngle = 10,
  neckYawReverse = false,
  neckYawSpeed = 8,
  neckPitchAngle = 8,
  neckPitchReverse = false,
  neckPitchSpeed = 9,
  neckRollAngle = 10,
  neckTraditionalRollEnabled = true,
  neckRollShakeEnabled = false,
  neckCombineRollShake = true,
  neckRollShakeSpeed = 0.65,
  neckRollReverse = false,
  neckRollSpeed = 9,
  neckDriftYawAngle = 12,
  neckDriftYawReverse = false,
  neckDriftYawSpeed = 9,
  neckDriftRollAngle = 8,
  neckDriftRollReverse = false,
  neckDriftRollSpeed = 9,
  neckDriftYawBackDistance = 0.020,
  neckDriftYawBackReverse = false,
  neckRoadPitchAngle = 8,
  neckRoadPitchReverse = false,
  neckRoadPitchSpeed = 7,
  neckBankRollAngle = 10,
  neckBankRollReverse = false,
  neckBankRollSpeed = 8,
  neckSpeedAngleStartKmh = 20,
  neckSpeedAngleFullKmh = 180,
  neckSpeedPitchAngle = 5,
  neckSpeedPitchReverse = false,
  neckSpeedPitchSpeed = 6,
  neckSpeedYawAngle = 8,
  neckSpeedYawReverse = false,
  neckSpeedYawSpeed = 8,
  neckSpeedRollAngle = 8,
  neckSpeedRollReverse = false,
  neckSpeedRollSpeed = 8,
  neckHiddenJerkAtFull = 8,
  neckHiddenYawRateAtFull = 1.0,
  neckHiddenYawAngle = 3,
  neckHiddenYawReverse = false,
  neckHiddenYawSpeed = 12,
  neckHiddenPitchAngle = 2.5,
  neckHiddenPitchReverse = false,
  neckHiddenPitchSpeed = 14,
  neckHiddenRollAngle = 3,
  neckHiddenRollReverse = false,
  neckHiddenRollSpeed = 14,
  neckMixYawToRoll = 0.20,
  neckMixRollToYaw = 0.10,
  neckMixPitchToRoll = 0.05,
  neckMixRollToPitch = 0.10,
  neckMixXToZ = 0.15,
  neckMixZToX = 0.10,
  neckMixYToZ = 0.15,
  neckMixZToY = 0.20,
  neckSlideFollowing = true,
  neckSlidingLookMult = 0.5,
  neckTrackFollowing = true,
  neckTrackFollowingMult = 0.7,
  neckSteeringMult = 0.7,
  neckLookaheadDistance = 20,

  -- Values written by the NeckFX backend for status and HUD output.
  neckHeartbeat = 0,
  neckEffectStrength = 0,
  neckOutputX = 0,
  neckOutputY = 0,
  neckOutputZ = 0,
  neckOutputYaw = 0,
  neckOutputPitch = 0,
  neckOutputRoll = 0,

  -- UI and HUD preferences.
  uiPage = 1,
  clutchPage = 1,
  throttlePage = 1,
  throttleFovPage = 1,
  throttleDynamicsPage = 1,
  throttleLinearPage = 1,
  neckPage = 1,
  lookPage = 1,
  uiMode = 1,
  colorTheme = 1,
  uiScale = 1.0,
  hudMode = 1,
  hudOpacity = 0.94,
  hudAnimation = 1.0,
  hudSpeedMph = false,
  hudShowWheel = true,
  hudShowPedals = true,
  hudShowCamera = true,
  hudShowRPM = true,
  hudShowStatus = true,
  hudShowGMeter = true,
  hudShowShiftLights = true,
  settingsVersion = 0
}

-- Import the former Dynamic 6DOF tuning once. Missing legacy storage simply
-- yields the same defaults, so first-time users follow the same path safely.
ac.storageSetPath('cpc-dynamic-6dof-live')
local legacyNeck = ac.storage({
  dynamicMovement = true,
  overallSpeed = 1.0,
  gForceAtFull = 1.5,
  effectSpeedCap = 20,
  effectSpeedCapMph = false,
  moveXDistance = 0.035,
  moveXSpeed = 9,
  moveYDistance = 0.015,
  moveYSpeed = 12,
  moveZDistance = 0.040,
  moveZSpeed = 9,
  yawAngle = 10,
  yawSpeed = 8,
  pitchAngle = 8,
  pitchSpeed = 9,
  rollAngle = 10,
  rollSpeed = 9,
  driftYawAngle = 12,
  driftYawSpeed = 9,
  roadPitchAngle = 8,
  roadPitchSpeed = 7,
  bankRollAngle = 10,
  bankRollSpeed = 8,
  speedAngleStartKmh = 20,
  speedAngleFullKmh = 180,
  speedPitchAngle = 5,
  speedPitchSpeed = 6,
  speedYawAngle = 8,
  speedYawSpeed = 8,
  speedRollAngle = 8,
  speedRollSpeed = 8,
  hiddenJerkAtFull = 8,
  hiddenYawRateAtFull = 1.0,
  hiddenYawAngle = 3,
  hiddenYawSpeed = 12,
  hiddenPitchAngle = 2.5,
  hiddenPitchSpeed = 14,
  hiddenRollAngle = 3,
  hiddenRollSpeed = 14,
  mixYawToRoll = 0.20,
  mixRollToYaw = 0.10,
  mixPitchToRoll = 0.05,
  mixRollToPitch = 0.10,
  mixXToZ = 0.15,
  mixZToX = 0.10,
  mixYToZ = 0.15,
  mixZToY = 0.20,
  slideFollowing = true,
  slidingLookMult = 0.5,
  trackFollowing = true,
  trackFollowingMult = 0.7,
  steeringMult = 0.7,
  lookaheadDistance = 20
})

ac.storageSetPath('cpc-drive-suite-v1')
local storageOk, settings = pcall(ac.storage, DEFAULTS)
if not storageOk then
  ac.storageSetPath('cpc-drive-suite-v2')
  settings = ac.storage(DEFAULTS)
end
if settings.settingsVersion < 1 then
  local legacyMap = {
    neckDynamicMovement = 'dynamicMovement',
    neckOverallSpeed = 'overallSpeed',
    neckGForceAtFull = 'gForceAtFull',
    neckEffectSpeedCap = 'effectSpeedCap',
    neckEffectSpeedCapMph = 'effectSpeedCapMph',
    neckMoveXDistance = 'moveXDistance', neckMoveXSpeed = 'moveXSpeed',
    neckMoveYDistance = 'moveYDistance', neckMoveYSpeed = 'moveYSpeed',
    neckMoveZDistance = 'moveZDistance', neckMoveZSpeed = 'moveZSpeed',
    neckYawAngle = 'yawAngle', neckYawSpeed = 'yawSpeed',
    neckPitchAngle = 'pitchAngle', neckPitchSpeed = 'pitchSpeed',
    neckRollAngle = 'rollAngle', neckRollSpeed = 'rollSpeed',
    neckDriftYawAngle = 'driftYawAngle', neckDriftYawSpeed = 'driftYawSpeed',
    neckRoadPitchAngle = 'roadPitchAngle', neckRoadPitchSpeed = 'roadPitchSpeed',
    neckBankRollAngle = 'bankRollAngle', neckBankRollSpeed = 'bankRollSpeed',
    neckSpeedAngleStartKmh = 'speedAngleStartKmh',
    neckSpeedAngleFullKmh = 'speedAngleFullKmh',
    neckSpeedPitchAngle = 'speedPitchAngle', neckSpeedPitchSpeed = 'speedPitchSpeed',
    neckSpeedYawAngle = 'speedYawAngle', neckSpeedYawSpeed = 'speedYawSpeed',
    neckSpeedRollAngle = 'speedRollAngle', neckSpeedRollSpeed = 'speedRollSpeed',
    neckHiddenJerkAtFull = 'hiddenJerkAtFull',
    neckHiddenYawRateAtFull = 'hiddenYawRateAtFull',
    neckHiddenYawAngle = 'hiddenYawAngle', neckHiddenYawSpeed = 'hiddenYawSpeed',
    neckHiddenPitchAngle = 'hiddenPitchAngle', neckHiddenPitchSpeed = 'hiddenPitchSpeed',
    neckHiddenRollAngle = 'hiddenRollAngle', neckHiddenRollSpeed = 'hiddenRollSpeed',
    neckMixYawToRoll = 'mixYawToRoll', neckMixRollToYaw = 'mixRollToYaw',
    neckMixPitchToRoll = 'mixPitchToRoll', neckMixRollToPitch = 'mixRollToPitch',
    neckMixXToZ = 'mixXToZ', neckMixZToX = 'mixZToX',
    neckMixYToZ = 'mixYToZ', neckMixZToY = 'mixZToY',
    neckSlideFollowing = 'slideFollowing',
    neckSlidingLookMult = 'slidingLookMult',
    neckTrackFollowing = 'trackFollowing',
    neckTrackFollowingMult = 'trackFollowingMult',
    neckSteeringMult = 'steeringMult',
    neckLookaheadDistance = 'lookaheadDistance'
  }
  for newKey, oldKey in pairs(legacyMap) do settings[newKey] = legacyNeck[oldKey] end
  settings.settingsVersion = 1
end

-- Throttle-sync migration: keep every 3.5+/custom feature, but replace the
-- overlapping base FOV/fore-aft controls with the synchronized five-control setup.
if settings.settingsVersion < 2 then
  settings.throttleRestingFov = 45
  settings.throttleMaximumFov = 145
  settings.throttleForwardDistance = 0.350
  settings.throttleBackDistance = 0.250
  settings.throttleTransitionSpeed = 12
  settings.throttleFovWidenSpeed = 12
  settings.throttleFovReturnSpeed = 12
  settings.throttleForwardSpeed = 12
  settings.throttleForwardFovLink = false
  settings.settingsVersion = 2
end

-- 3.7.7 compatibility migration.
if settings.settingsVersion < 3 then
  settings.throttleSpeedForwardStartKmh = 0
  settings.throttleSpeedForwardFullKmh = 70
  settings.throttleSpeedForwardCurve = 1.0
  settings.settingsVersion = 3
end

-- 3.9.2: speed Z and speed FOV now share one absolute vehicle-speed curve.
-- They build slowly while the real accelerator is pressed and release to zero
-- when the pedal is lifted, leaving the base FOV free to reach Resting FOV.
if settings.settingsVersion < 4 then
  settings.throttleSpeedFovWiden = 22.0
  settings.throttleSpeedForwardFullKmh = 180
  settings.throttleSpeedLayerSpeed = 2.5
  settings.settingsVersion = 4
end

-- FOV hard safety range and FOV blend speed become independent settings,
-- decoupled from the previously shared 20/170 constant and Z transition speed.
if settings.settingsVersion < 5 then
  settings.throttleFovHardMin = 20
  settings.throttleFovHardMax = 170
  settings.throttleFovTransitionSpeed = settings.throttleTransitionSpeed
  settings.settingsVersion = 5
end

-- Automatic gearing assist: RPM- and speed-aware shift timing, opt-in.
if settings.settingsVersion < 6 then
  settings.autoGearEnabled = false
  settings.autoGearMinSpeed = 8
  settings.autoGearOverrunProtect = true
  settings.autoGearMinShiftInterval = 0.35
  settings.settingsVersion = 6
end

-- Auto gear switched to timer-based sequential shifting: hold each gear for
-- its own configured seconds, then step up; a throttle-off timer steps down.
if settings.settingsVersion < 7 then
  settings.autoGearShiftTime1 = 2.0
  settings.autoGearShiftTime2 = 2.5
  settings.autoGearShiftTime3 = 3.0
  settings.autoGearShiftTime4 = 3.5
  settings.autoGearShiftTime5 = 4.0
  settings.autoGearThrottleOffDelay = 1.5
  settings.settingsVersion = 7
end

-- Auto gear now coordinates with the adaptive clutch: it presses the clutch
-- before each shift and releases it after, reusing the CLUTCH page's own
-- shift hold/release timing so the two features stay in sync.
if settings.settingsVersion < 8 then
  settings.autoGearClutchAssist = true
  settings.settingsVersion = 8
end

-- Optional instant downshift on throttle release straight to a chosen gear,
-- bypassing the normal throttle-off delay.
if settings.settingsVersion < 9 then
  settings.autoGearInstantDownshiftEnabled = false
  settings.autoGearInstantDownshiftGear = 2
  settings.settingsVersion = 9
end

-- Instant downshift can now trigger on a partial throttle lift, not just a
-- full release, via its own configurable reduction threshold.
if settings.settingsVersion < 10 then
  settings.autoGearInstantDownshiftThreshold = 0.15
  settings.settingsVersion = 10
end

-- RPM-based upshifts use engine speed and avoid shifting during heavy cornering;
-- the existing per-gear timers remain available as an explicit fallback mode.
if settings.settingsVersion < 11 then
  settings.autoGearRPMMode = true
  settings.autoGearUpshiftRPMPercent = 0.90
  settings.autoGearUpshiftConfirmTime = 0.08
  settings.autoGearMinThrottle = 0.30
  settings.autoGearBrakeDownshiftThreshold = 0.15
  settings.autoGearOverrunMargin = 0.95
  settings.autoGearCorneringGThreshold = 0.45
  settings.autoGearCorneringSteerThreshold = 0.45
  settings.settingsVersion = 11
end

-- Auto clutch coordination now waits for the actual gear change before
-- releasing, with separate release timing for upshifts and downshifts.
if settings.settingsVersion < 12 then
  settings.autoGearShiftConfirmTimeout = 0.25
  settings.autoGearUpshiftRelease = 0.14
  settings.autoGearDownshiftRelease = 0.24
  settings.settingsVersion = 12
end

-- Car-aware auto gear (ratio-based landing RPM, per-gear targets, H-pattern
-- refusal), downshift throttle blip, and hold-to-dump launch control.
if settings.settingsVersion < 13 then
  local globalUp = settings.autoGearUpshiftRPMPercent
  settings.autoGearPerGearTargets = true
  settings.autoGearUpshiftRPMGear1 = math.max(0.80, globalUp - 0.02)
  settings.autoGearUpshiftRPMGear2 = globalUp
  settings.autoGearUpshiftRPMGear3 = math.min(0.98, globalUp + 0.01)
  settings.autoGearUpshiftRPMGear4 = math.min(0.98, globalUp + 0.02)
  settings.autoGearUpshiftRPMGear5 = math.min(0.98, globalUp + 0.03)
  settings.autoGearUpshiftRPMGear6 = math.min(0.98, globalUp + 0.04)
  settings.autoGearDownshiftRPMPercent = 0.68
  settings.autoGearBlipEnabled = true
  settings.autoGearBlipAmount = 0.55
  settings.autoGearBlipDuration = 0.12
  settings.clutchLaunchControlEnabled = false
  settings.clutchLaunchControlBite = 0.28
  settings.clutchLaunchControlThrottle = 0.60
  settings.settingsVersion = 13
end

if settings.settingsVersion < 14 then
  settings.clutchHandbrakeEnabled = false
  settings.settingsVersion = 14
end

if settings.settingsVersion < 16 then
  settings.neckDriftYawBackDistance = 0.020
  settings.settingsVersion = 16
end

if settings.settingsVersion < 17 then
  settings.neckDriftYawBackReverse = false
  settings.settingsVersion = 17
end

if settings.settingsVersion < 18 then
  settings.neckDriftRollAngle = 8
  settings.neckDriftRollReverse = false
  settings.neckDriftRollSpeed = 9
  settings.settingsVersion = 18
end

return {
  defaults = DEFAULTS,
  settings = settings
}
