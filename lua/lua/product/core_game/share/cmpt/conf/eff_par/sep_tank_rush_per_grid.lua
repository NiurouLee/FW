require("skill_effect_param_base")

_class("SkillEffectParam_TankRushPerGrid", SkillEffectParamBase)
---@class SkillEffectParam_TankRushPerGrid : SkillEffectParamBase
SkillEffectParam_TankRushPerGrid = SkillEffectParam_TankRushPerGrid

function SkillEffectParam_TankRushPerGrid:Constructor(t, petId, effectIndex, skillType, grade, awaking)
    ---@private
    self._damageParam = SkillDamageEffectParam:New(t.damageParam, petId, effectIndex, skillType, grade, awaking)
    ---@private
    self._hitbackParam = SkillHitBackEffectParam:New(t.hitbackParam, petId, effectIndex, skillType, grade, awaking)
end

function SkillEffectParam_TankRushPerGrid:GetEffectType()
    return SkillEffectType.TankRushPerGrid
end

---@return SkillDamageEffectParam
function SkillEffectParam_TankRushPerGrid:GetDamageParam()
    return self._damageParam
end

---@return SkillHitBackEffectParam
function SkillEffectParam_TankRushPerGrid:GetHitBackParam()
    return self._hitbackParam
end
