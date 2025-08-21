--[[----------------------------------------------------------------
    2020-02-20  韩玉信添加
    SkillPhaseParam_GridReturn : 从格子出发返回角色身上
--]]----------------------------------------------------------------
require "skill_phase_param_base"

--- @class SkillPhaseParam_GridReturn_TargetType
local SkillPhaseParam_GridReturn_TargetType = {
    RandAttack = 0,
    Damage = 1,
    AllRangeGrid = 2,
}
_enum("SkillPhaseParam_GridReturn_TargetType", SkillPhaseParam_GridReturn_TargetType)
----------------------------------------------------------------
---@class SkillPhaseParam_GridReturn: SkillPhaseParamBase
_class("SkillPhaseParam_GridReturn", SkillPhaseParamBase)
SkillPhaseParam_GridReturn = SkillPhaseParam_GridReturn

function SkillPhaseParam_GridReturn:Constructor(t)
    self._castAnimation = t.castAnimation
    self._castEffectID = t.castEffectID
    self._castEffectTime = t.castEffectTime
    ---@type SkillPhaseParam_GridReturn_TargetType
    self._targetType = t.targetType ---目标类型，2020-02-20只接受普攻目标，可以自定义扩展
    self._trajectoryType = t.trajectoryType

    self._bornEffectID = t.bornEffectID;
    self._bornEffectTime = t.bornEffectTime;

    self._gridEffectID = t.gridEffectID
    self._finishDelayTime = t.finishDelayTime

	self._startHigh = t.startHigh
	self._endHigh = t.endHigh
    self._flyTotalTime = t.flyTotalTime
    self._flySpeed = t.flySpeed     ---飞行一格的时间

    self._deltaAngle = t.deltaAngle

	self._audioID = t.audioID or 0
    self._audioWaitTime = t.audioWaitTime or 0
    
    self._castEndEffectID = t.castEndEffectID --吸魂结束后施法者身上啵一个特效
end

function SkillPhaseParam_GridReturn:GetCacheTable()
    local listID = {}
    self:AddEffectIDToListID(listID, self._gridEffectID)
    return self:GetCacheTableFromListID(listID)
end

function SkillPhaseParam_GridReturn:GetSoundCacheTable()
	if not self._audioID or self._audioID <= 0 then
		return
	end
	return {self._audioID}
end

function SkillPhaseParam_GridReturn:GetPhaseType()
    return SkillViewPhaseType.GridReturn
end

function SkillPhaseParam_GridReturn:GetCastAnimationEffect()
    return  self._castAnimation, self._castEffectID, self._castEffectTime
end

function SkillPhaseParam_GridReturn:GetTargetType()
    return self._targetType or 0
end

function SkillPhaseParam_GridReturn:GetTrajectoryType()
    return self._trajectoryType or 1
end

function SkillPhaseParam_GridReturn:GetBornEffectID()
    return self._bornEffectID
end
function SkillPhaseParam_GridReturn:GetBornEffectTime()
    return self._bornEffectTime
end

function SkillPhaseParam_GridReturn:GetGridEffectID()
    return self._gridEffectID
end

---@return number
function SkillPhaseParam_GridReturn:GetFinishDelayTime()
    return self._finishDelayTime
end
--------------------------------
function SkillPhaseParam_GridReturn:GetStartHigh()
	return  self._startHigh
end
function SkillPhaseParam_GridReturn:GetEndHigh()
	return  self._endHigh
end

function SkillPhaseParam_GridReturn:GetFlyTotalTime()
	return self._flyTotalTime
end

function SkillPhaseParam_GridReturn:GetFlySpeed()
	return self._flySpeed
end

function SkillPhaseParam_GridReturn:GetDeltaAngle()
	return self._deltaAngle
end

function SkillPhaseParam_GridReturn:GetAudioID()
	return self._audioID
end

function SkillPhaseParam_GridReturn:GetAudioWaitTime()
	return self._audioWaitTime
end

function SkillPhaseParam_GridReturn:GetEndEffectID()
    return self._castEndEffectID
end
