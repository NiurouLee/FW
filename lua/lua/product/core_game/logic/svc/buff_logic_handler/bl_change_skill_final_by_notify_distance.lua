_class("BuffLogicChangeSkillFinalByNotifyDistance", BuffLogicBase)
---@class BuffLogicChangeSkillFinalByNotifyDistance: BuffLogicBase
BuffLogicChangeSkillFinalByNotifyDistance = BuffLogicChangeSkillFinalByNotifyDistance

function BuffLogicChangeSkillFinalByNotifyDistance:Constructor(buffInstance, logicParam)
    self._distanceRate = logicParam.distanceRate --5% 填0.05
    self._effectList = logicParam.effectList
    self._buffInstance.BuffLogicChangeSkillFinalByNotifyDistance_RunCount = 0
end

---@param notify NTHitBackEnd
function BuffLogicChangeSkillFinalByNotifyDistance:DoLogic(notify)
    self._buffInstance.BuffLogicChangeSkillFinalByNotifyDistance_RunCount = self._buffInstance.BuffLogicChangeSkillFinalByNotifyDistance_RunCount + 1
    self._buffInstance._effectList = self._effectList

    local distance = notify:GetDistance()
    local rate = self._distanceRate * distance

    local val = rate * self._buffInstance.BuffLogicChangeSkillFinalByNotifyDistance_RunCount
    for _, paramType in ipairs(self._effectList) do
        self._buffLogicService:ChangeSkillFinalParam(
            self._entity,
            self:GetBuffSeq(),
            paramType,
            val
        )
    end

end

_class("BuffLogicRevertSkillFinalByNotifyDistance", BuffLogicBase)
---@class BuffLogicRevertSkillFinalByNotifyDistance: BuffLogicBase
BuffLogicRevertSkillFinalByNotifyDistance = BuffLogicRevertSkillFinalByNotifyDistance

function BuffLogicRevertSkillFinalByNotifyDistance:DoLogic()
    self._buffInstance.BuffLogicChangeSkillFinalByNotifyDistance_RunCount = 0

    for _, paramType in ipairs(self._buffInstance._effectList) do
        self._buffLogicService:RemoveSkillFinalParam(self._entity, self:GetBuffSeq(), paramType)
    end
end
