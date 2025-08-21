--[[------------------------------------------------------------------------------------------
    SkillActiveAttackData : 做一个宝宝的主动技攻击数据
]] --------------------------------------------------------------------------------------------

---@class SkillActiveAttackData: Object
_class("SkillActiveAttackData", Object)
SkillActiveAttackData = SkillActiveAttackData

function SkillActiveAttackData:Constructor()
    self._attackGridRange = {}
    self._entityDamageValue = {}
end

function SkillActiveAttackData:ClearActiveAttackData()
    self._attackGridRange = {}
    self._entityDamageValue = {}
end

function SkillActiveAttackData:GetActiveAttackGridRange()
    return self._attackGridRange
end

function SkillActiveAttackData:SetActiveAttackGridRange(attackData)
    self._attackGridRange = attackData
end
function SkillActiveAttackData:AddDamageData(entityid, fdamagevalue)
    self._entityDamageValue[entityid] = fdamagevalue
end
