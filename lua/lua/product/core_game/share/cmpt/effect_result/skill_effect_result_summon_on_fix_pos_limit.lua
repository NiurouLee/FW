require("skill_effect_result_base")

_class("SkillEffectResultSummonOnFixPosLimit", SkillEffectResultBase)
---@class SkillEffectResultSummonOnFixPosLimit: SkillEffectResultBase
SkillEffectResultSummonOnFixPosLimit = SkillEffectResultSummonOnFixPosLimit

function SkillEffectResultSummonOnFixPosLimit:Constructor(trapID, summonPosList)
    self._trapID = trapID
    self._summonPosList = summonPosList --创建新机关的范围

    self._destroyEntityIDList = {} --删除的机关
end

function SkillEffectResultSummonOnFixPosLimit:GetEffectType()
    return SkillEffectType.SummonOnFixPosLimit
end

function SkillEffectResultSummonOnFixPosLimit:GetTrapID()
    return self._trapID
end

function SkillEffectResultSummonOnFixPosLimit:GetSummonPosList()
    return self._summonPosList
end

function SkillEffectResultSummonOnFixPosLimit:GetDestroyEntityIDList()
    return self._destroyEntityIDList
end

function SkillEffectResultSummonOnFixPosLimit:SetDestroyEntityIDList(destroyEntityIDList)
    self._destroyEntityIDList = destroyEntityIDList
end

--apply应用成功的机关
function SkillEffectResultSummonOnFixPosLimit:SetTrapIDList(trapIDList)
    self._trapIDList = trapIDList
end

function SkillEffectResultSummonOnFixPosLimit:GetTrapIDList()
    return self._trapIDList
end
