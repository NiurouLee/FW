require("skill_effect_param_base")

---@class SkillEffectParamAddCollectDropNum : SkillEffectParamBase
_class("SkillEffectParamAddCollectDropNum", SkillEffectParamBase)
SkillEffectParamAddCollectDropNum = SkillEffectParamAddCollectDropNum

function SkillEffectParamAddCollectDropNum:Constructor(t)
end

function SkillEffectParamAddCollectDropNum:GetEffectType()
    return SkillEffectType.AddCollectDropNum
end
