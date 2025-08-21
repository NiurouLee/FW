--[[
    ----------------------------------------------------------------
    SkillEffectResult_DimensionTransport DimensionTransport技能结果
    ----------------------------------------------------------------
]]
require("skill_effect_result_teleport")

_class("SkillEffectResult_DimensionTransport", SkillEffectResult_Teleport)
---@class SkillEffectResult_DimensionTransport: SkillEffectResult_Teleport
SkillEffectResult_DimensionTransport = SkillEffectResult_DimensionTransport

function SkillEffectResult_DimensionTransport:GetEffectType()
    return SkillEffectType.DimensionTransport
end
