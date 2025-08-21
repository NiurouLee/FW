--[[
    ----------------------------------------------------------------
    SkillEffectMultiTractionResult: 多目标牵引
    ----------------------------------------------------------------
]]
require("skill_effect_result_base")

_class("SkillEffectMultiTractionResult", SkillEffectResultBase)
---@class SkillEffectMultiTractionResult: SkillEffectResultBase
SkillEffectMultiTractionResult = SkillEffectMultiTractionResult

function SkillEffectMultiTractionResult:Constructor(final, supplyPlayerPiece)
    ---@type SkillEffectCalc_MultiTraction_SingleTargetResult[]
    self._pullResultArray = final.array
    ---@type SkillEffectCalc_MultiTraction_GridPossessorMap
    self._gridPossessionMap = final
    self._supplyPlayerPiece = supplyPlayerPiece
end

function SkillEffectMultiTractionResult:GetEffectType()
    return SkillEffectType.MultiTraction
end

function SkillEffectMultiTractionResult:GetResultArray()
    return self._pullResultArray
end

function SkillEffectMultiTractionResult:GetSupplyPlayerPiece()
    return self._supplyPlayerPiece
end

function SkillEffectMultiTractionResult:SetSupplyPlayerPiece(supply)
    self._supplyPlayerPiece = supply
end

function SkillEffectMultiTractionResult:GetColorNew()
    return self._colorNew
end

function SkillEffectMultiTractionResult:SetColorNew(colorNew)
    self._colorNew = colorNew
end

function SkillEffectMultiTractionResult:SetDamageIncreaseRate(val)
    self._damageIncreaseRate = val
end

function SkillEffectMultiTractionResult:GetDamageIncreaseRate()
    return self._damageIncreaseRate
end

function SkillEffectMultiTractionResult:GetGridPossessorMap()
    return self._gridPossessionMap
end
function SkillEffectMultiTractionResult:SetTractionCenterPos(val)
    self._tractionCenterPos = val
end

function SkillEffectMultiTractionResult:GetTractionCenterPos()
    return self._tractionCenterPos
end
