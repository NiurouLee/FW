require("skill_damage_effect_param")

_class("SkillEffectParam_DynamicScopeChainDamage", SkillDamageEffectParam)
---@class SkillEffectParam_DynamicScopeChainDamage : SkillDamageEffectParam
SkillEffectParam_DynamicScopeChainDamage = SkillEffectParam_DynamicScopeChainDamage

function SkillEffectParam_DynamicScopeChainDamage:GetEffectType()
    return SkillEffectType.DynamicScopeChainDamage
end
