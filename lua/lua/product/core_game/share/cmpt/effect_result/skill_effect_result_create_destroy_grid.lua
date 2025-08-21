--[[
    ----------------------------------------------------------------
    SkillEffectResult_CreateDestroyGrid CreateDestroyGrid 技能结果
    ----------------------------------------------------------------
]]
require("skill_effect_result_base")

_class("SkillEffectResult_CreateDestroyGrid", SkillEffectResultBase)
---@class SkillEffectResult_CreateDestroyGrid: SkillEffectResultBase
SkillEffectResult_CreateDestroyGrid = SkillEffectResult_CreateDestroyGrid

function SkillEffectResult_CreateDestroyGrid:GetEffectType()
    return SkillEffectType.CreateDestroyGrid
end

---@param isCreate boolean
---@param scopeRange Vector2[]
function SkillEffectResult_CreateDestroyGrid:Constructor(isCreate, scopeRange)
    self._isCreate = isCreate
    self._scopeRange = scopeRange
end

---@return boolean
function SkillEffectResult_CreateDestroyGrid:GetIsCreate()
    return self._isCreate
end

---@return Vector2[]
function SkillEffectResult_CreateDestroyGrid:GetScopeRange()
    return self._scopeRange
end
