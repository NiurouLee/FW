--[[
    ShowWarningArea = 29, ---显示预警范围： 范围是配置的技能的攻击范围
]]
---@class SkillEffectCalc_ShowWarningArea: Object
_class("SkillEffectCalc_ShowWarningArea", Object)
SkillEffectCalc_ShowWarningArea = SkillEffectCalc_ShowWarningArea

function SkillEffectCalc_ShowWarningArea:Constructor(world)
    ---@type MainWorld
    self._world = world
end

---@param skillEffectCalcParam SkillEffectCalcParam
function SkillEffectCalc_ShowWarningArea:DoSkillEffectCalculator(skillEffectCalcParam)
    ---@type SkillEffectParam_ShowWarningArea
    local effectParam = skillEffectCalcParam.skillEffectParam

    local casterEntity = self._world:GetEntityByID(skillEffectCalcParam.casterEntityID)
    local posCaster = casterEntity:GridLocation().Position

    local effectResult = SkillEffectResult_ShowWarningArea:New()

    if not effectParam:IsGetScopeResultFromAI() then
        effectResult:ComputeWarningArea(self._world, casterEntity, effectParam)
    else
        local cAI = casterEntity:AI()
        ---@type SkillScopeResult
        local scopeResult = cAI:GetSkillScopeResult(true)
        effectResult.m_listPosWarning = scopeResult:GetAttackRange()
    end

    return effectResult
end
