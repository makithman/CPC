return [====[
    neckLink.neckOverallSpeed = settings.neckOverallSpeed
    neckLink.neckGForceAtFull = settings.neckGForceAtFull
    neckLink.neckEffectSpeedCap = settings.neckEffectSpeedCap
    neckLink.neckEffectSpeedCapMph = settings.neckEffectSpeedCapMph
    neckLink.neckGearFilterEnabled = settings.throttleGearIsolationEnabled
      and settings.throttleGearIsolationGForce
    neckLink.neckGearFilterActive = __CPC.gearIsolationActive
    neckLink.neckMoveXDistance = directionalValue('neckMoveXDistance', 'neckMoveXReverse', moveScale)
    neckLink.neckMoveXSpeed = settings.neckMoveXSpeed
    neckLink.neckMoveYDistance = directionalValue('neckMoveYDistance', 'neckMoveYReverse', moveScale)
    neckLink.neckMoveYSpeed = settings.neckMoveYSpeed
    neckLink.neckMoveZDistance = directionalValue('neckMoveZDistance', 'neckMoveZReverse', moveScale)
    neckLink.neckMoveZSpeed = settings.neckMoveZSpeed
    neckLink.neckOvalWidth = Math.finiteNumber(settings.neckOvalWidth, 0.035) * moveScale
    neckLink.neckOvalHeight = Math.finiteNumber(settings.neckOvalHeight, 0.015) * moveScale
    neckLink.neckOvalSpeed = math.max(Math.finiteNumber(settings.neckOvalSpeed, 0.65), 0)
    neckLink.neckYawAngle = directionalValue('neckYawAngle', 'neckYawReverse', angleScale)
    neckLink.neckYawSpeed = settings.neckYawSpeed
    neckLink.neckPitchAngle = directionalValue('neckPitchAngle', 'neckPitchReverse', angleScale)
    neckLink.neckPitchSpeed = settings.neckPitchSpeed
    neckLink.neckRollAngle = directionalValue('neckRollAngle', 'neckRollReverse', angleScale)
    neckLink.neckRollSpeed = settings.neckRollSpeed
    neckLink.neckTraditionalRollEnabled = settings.neckTraditionalRollEnabled
    neckLink.neckRollShakeEnabled = settings.neckRollShakeEnabled
    neckLink.neckCombineRollShake = settings.neckCombineRollShake
    neckLink.neckRollShakeSpeed = settings.neckRollShakeSpeed
    neckLink.neckDriftYawAngle = directionalValue('neckDriftYawAngle', 'neckDriftYawReverse', angleScale)
    neckLink.neckDriftYawSpeed = settings.neckDriftYawSpeed
    neckLink.neckDriftRollAngle = directionalValue('neckDriftRollAngle', 'neckDriftRollReverse', angleScale)
    neckLink.neckDriftRollSpeed = settings.neckDriftRollSpeed
    neckLink.neckDriftYawBackDistance = Math.clamp(settings.neckDriftYawBackDistance, 0, 0.15) * moveScale
    neckLink.neckDriftYawBackReverse = settings.neckDriftYawBackReverse
    neckLink.neckRoadPitchAngle = directionalValue('neckRoadPitchAngle', 'neckRoadPitchReverse', angleScale)
    neckLink.neckRoadPitchSpeed = settings.neckRoadPitchSpeed
    neckLink.neckBankRollAngle = directionalValue('neckBankRollAngle', 'neckBankRollReverse', angleScale)
    neckLink.neckBankRollSpeed = settings.neckBankRollSpeed
    neckLink.neckSpeedAngleStartKmh = settings.neckSpeedAngleStartKmh
    neckLink.neckSpeedAngleFullKmh = settings.neckSpeedAngleFullKmh
    neckLink.neckSpeedPitchAngle = directionalValue('neckSpeedPitchAngle', 'neckSpeedPitchReverse', angleScale)
    neckLink.neckSpeedPitchSpeed = settings.neckSpeedPitchSpeed
    neckLink.neckSpeedYawAngle = directionalValue('neckSpeedYawAngle', 'neckSpeedYawReverse', angleScale)
    neckLink.neckSpeedYawSpeed = settings.neckSpeedYawSpeed
    neckLink.neckSpeedRollAngle = directionalValue('neckSpeedRollAngle', 'neckSpeedRollReverse', angleScale)
    neckLink.neckSpeedRollSpeed = settings.neckSpeedRollSpeed
    neckLink.neckHiddenJerkAtFull = settings.neckHiddenJerkAtFull
    neckLink.neckHiddenYawRateAtFull = settings.neckHiddenYawRateAtFull
    neckLink.neckHiddenYawAngle = directionalValue('neckHiddenYawAngle', 'neckHiddenYawReverse', hiddenScale)
    neckLink.neckHiddenYawSpeed = settings.neckHiddenYawSpeed
    neckLink.neckHiddenPitchAngle = directionalValue('neckHiddenPitchAngle', 'neckHiddenPitchReverse', hiddenScale)
    neckLink.neckHiddenPitchSpeed = settings.neckHiddenPitchSpeed
    neckLink.neckHiddenRollAngle = directionalValue('neckHiddenRollAngle', 'neckHiddenRollReverse', hiddenScale)
    neckLink.neckHiddenRollSpeed = settings.neckHiddenRollSpeed
    neckLink.neckMixYawToRoll = settings.neckMixYawToRoll * mixScale
    neckLink.neckMixRollToYaw = settings.neckMixRollToYaw * mixScale
    neckLink.neckMixPitchToRoll = settings.neckMixPitchToRoll * mixScale
    neckLink.neckMixRollToPitch = settings.neckMixRollToPitch * mixScale
    neckLink.neckMixXToZ = settings.neckMixXToZ * mixScale
    neckLink.neckMixZToX = settings.neckMixZToX * mixScale
    neckLink.neckMixYToZ = settings.neckMixYToZ * mixScale
    neckLink.neckMixZToY = settings.neckMixZToY * mixScale
    neckLink.neckSlideFollowing = settings.neckSlideFollowing
    neckLink.neckSlidingLookMult = settings.neckSlidingLookMult * followScale
    neckLink.neckTrackFollowing = settings.neckTrackFollowing
    neckLink.neckTrackFollowingMult = settings.neckTrackFollowingMult * followScale
    neckLink.neckSteeringMult = settings.neckSteeringMult * followScale
    neckLink.neckLookaheadDistance = settings.neckLookaheadDistance

    local ack = neckLink.backendSequence
    local previousSequence = __CPC.neckSequence == 0 and 4294967294 or __CPC.neckSequence - 1
    if ack ~= __CPC.neckLastAck and (ack == __CPC.neckSequence or ack == previousSequence) then
      __CPC.neckLastAck = ack
      __CPC.neckLastAckTime = os.preciseClock()
    end
    __CPC.neckTelemetry.effectStrength = Math.finiteNumber(neckLink.neckEffectStrength, 0)
    __CPC.neckTelemetry.outputX = Math.finiteNumber(neckLink.neckOutputX, 0)
    __CPC.neckTelemetry.outputY = Math.finiteNumber(neckLink.neckOutputY, 0)
    __CPC.neckTelemetry.outputZ = Math.finiteNumber(neckLink.neckOutputZ, 0)
    __CPC.neckTelemetry.outputYaw = Math.finiteNumber(neckLink.neckOutputYaw, 0)
    __CPC.neckTelemetry.outputPitch = Math.finiteNumber(neckLink.neckOutputPitch, 0)
    __CPC.neckTelemetry.outputRoll = Math.finiteNumber(neckLink.neckOutputRoll, 0)
  end

  function __CPC.disableNeckLink()
    __CPC.nextNeckSequence()
    __CPC.neckLink.appSequence = __CPC.neckSequence
    __CPC.neckLink.suiteEnabled = false
    __CPC.neckLink.neckEnabled = false
    __CPC.neckLink.neckDynamicMovement = false
  end

  __CPC.controlsOverride = ac.overrideCarControls and ac.overrideCarControls(__CPC.PLAYER) or nil






end
]====]
