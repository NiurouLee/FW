require("skill_damage_effect_param")

_class("SkillEffectPetMinosGhostDamageParam", SkillDamageEffectParam)
---@class SkillEffectPetMinosGhostDamageParam: SkillDamageEffectParam
SkillEffectPetMinosGhostDamageParam = SkillEffectPetMinosGhostDamageParam

function SkillEffectPetMinosGhostDamageParam:Constructor(t)
end

function SkillEffectPetMinosGhostDamageParam:GetEffectType()
    return SkillEffectType.PetMinosGhostDamage
end