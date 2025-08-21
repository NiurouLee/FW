--[[------------------------------------------------------------------------------------------
    RubikCube = 164, --魔方
]] --------------------------------------------------------------------------------------------
require("skill_effect_param_base")
_class("SkillEffectParamRubikCube", SkillEffectParamBase)
---@class SkillEffectParamRubikCube: SkillEffectParamBase
SkillEffectParamRubikCube = SkillEffectParamRubikCube

function SkillEffectParamRubikCube:Constructor(t)
    self._times = t.times or 1 --传送次数
end

function SkillEffectParamRubikCube:GetEffectType()
    return SkillEffectType.RubikCube
end

function SkillEffectParamRubikCube:GetTimes()
    return self._times
end
