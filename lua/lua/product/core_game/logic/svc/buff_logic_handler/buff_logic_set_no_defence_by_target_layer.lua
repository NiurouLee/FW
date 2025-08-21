--[[
    
]]
require("buff_logic_base")
_class("BuffLogicSetNoDefenceByTargetLayer", BuffLogicBase)
---@class BuffLogicSetNoDefenceByTargetLayer:BuffLogicBase
BuffLogicSetNoDefenceByTargetLayer = BuffLogicSetNoDefenceByTargetLayer

function BuffLogicSetNoDefenceByTargetLayer:Constructor(buffInstance, logicParam)
    self._layerType = logicParam.layerType or self._buffInstance:GetBuffEffectType()
    self._oneLayerAddMulValue = logicParam.oneLayerAddMulValue or 0
    self._oneLayerAddValue = logicParam.oneLayerAddValue or 0

    self._minMulValue = logicParam.minMulValue
    self._maxMulValue = logicParam.maxMulValue
end

---@param notify NotifyAttackBase
function BuffLogicSetNoDefenceByTargetLayer:DoLogic(notify)
    local defenderEntity = notify:GetDefenderEntity()
    if not defenderEntity or not defenderEntity:Attributes() or defenderEntity:HasDeadMark() then
        return false
    end

    local buffOwner = self._buffInstance:Entity()
    ----@type AttributesComponent
    local attributeCmpt = buffOwner:Attributes()

    local targetMarkLayer = self._buffLogicService:GetBuffLayer(defenderEntity, self._layerType) or 0
    if targetMarkLayer == 0 then
        return false
    end

    if self._oneLayerAddMulValue ~= 0 then
        local change = self._oneLayerAddMulValue * targetMarkLayer
        change = self:_CalcValueLimit(change)
        attributeCmpt:SetSimpleAttribute("NoDefence", change)
    end
    if self._oneLayerAddValue ~= 0 then
        local change = math.floor(self._oneLayerAddValue * targetMarkLayer)
        change = self:_CalcValueLimit(change)
        attributeCmpt:SetSimpleAttribute("NoDefence", change)
    end
end

function BuffLogicSetNoDefenceByTargetLayer:_CalcValueLimit(value)
    if self._maxMulValue then
        if value > self._maxMulValue then
            value = self._maxMulValue
        end
    end
    if self._minMulValue then
        if value < self._minMulValue then
            value = self._minMulValue
        end
    end

    return value
end
