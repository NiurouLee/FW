
require("skill_effect_param_base")

_class("SkillDamageCanRepeatEffectParam", SkillDamageEffectParam)
---@class SkillDamageCanRepeatEffectParam: SkillDamageEffectParam
SkillDamageCanRepeatEffectParam = SkillDamageCanRepeatEffectParam

---构造函数
function SkillDamageCanRepeatEffectParam:Constructor(t)
    ---目标被重复打击每次衰减的伤害系数
    self._dampPer = t.dampPer
    self._dampMax = t.dampMax
    self._finalEffectType = t.finalEffectType
end

function SkillDamageCanRepeatEffectParam:GetDampPer()
    return  self._dampPer
end

function SkillDamageCanRepeatEffectParam:GetDampMax()
    return self._dampMax
end

function SkillDamageCanRepeatEffectParam:GetFinalEffectType()
    return self._finalEffectType
end

function SkillDamageCanRepeatEffectParam:GetEffectType()
    return SkillEffectType.DamageTargetCanRepeat
end