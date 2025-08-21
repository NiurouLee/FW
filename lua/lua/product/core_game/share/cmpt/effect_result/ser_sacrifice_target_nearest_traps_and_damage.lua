require("skill_effect_result_base")

_class("SkillEffectSacrificeTargetNearestTrapsAndDamageResult", SkillEffectResultBase)
---@class SkillEffectSacrificeTargetNearestTrapsAndDamageResult: SkillEffectResultBase
SkillEffectSacrificeTargetNearestTrapsAndDamageResult = SkillEffectSacrificeTargetNearestTrapsAndDamageResult

function SkillEffectSacrificeTargetNearestTrapsAndDamageResult:Constructor(trapIDs, damageResultArray)
    self._trapIDs = trapIDs
    self._damageResultArray = damageResultArray
end

function SkillEffectSacrificeTargetNearestTrapsAndDamageResult:GetTrapIDArray()
    return self._trapIDs
end
function SkillEffectSacrificeTargetNearestTrapsAndDamageResult:GetDamageResultArray()
    return self._damageResultArray
end
function SkillEffectSacrificeTargetNearestTrapsAndDamageResult:GetEffectType()
    return SkillEffectType.SacrificeTargetNearestTrapsAndDamage
end
