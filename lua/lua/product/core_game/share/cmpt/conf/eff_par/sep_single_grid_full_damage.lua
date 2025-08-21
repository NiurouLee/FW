_class("SkillEffectParam_SingleGridFullDamage", SkillDamageEffectParam)
---@class SkillEffectParam_SingleGridFullDamage : SkillDamageEffectParam
SkillEffectParam_SingleGridFullDamage = SkillEffectParam_SingleGridFullDamage

function SkillEffectParam_SingleGridFullDamage:Constructor(t)
    self._multiGridDecreaseRate = t.multiGridDecreaseRate
end

function SkillEffectParam_SingleGridFullDamage:GetEffectType()
    return SkillEffectType.SingleGridFullDamage
end

function SkillEffectParam_SingleGridFullDamage:GetMultiGridDecreaseRate()
    return self._multiGridDecreaseRate
end
