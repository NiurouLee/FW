--[[
    根据光灵的传说光灵能量属性叠加层数 
]]
require "buff_logic_base"
_class("BuffLogicAddLayerByLegendPower", BuffLogicBase)
---@class BuffLogicAddLayerByLegendPower:BuffLogicBase
BuffLogicAddLayerByLegendPower = BuffLogicAddLayerByLegendPower

function BuffLogicAddLayerByLegendPower:Constructor(buffInstance, logicParam)
    self._layerType = logicParam.layerType or self._buffInstance:GetBuffEffectType()
    self._buffInstance._buffLayerName = self._buffInstance._buffsvc:GetBuffLayerName(self._layerType)
    self._dontDisplay = logicParam.dontDisplay
end

---@param notify NotifyAttackBase
function BuffLogicAddLayerByLegendPower:DoLogic(notify)
    ---@type BuffLogicService
    local svc = self._world:GetService("BuffLogic")

    local petEntity = self._buffInstance:Entity()
    ---@type AttributesComponent
    local attributeCmpt = petEntity:Attributes()

    local curLegendPower = attributeCmpt:GetAttribute("LegendPower")

    local curMarkLayer = svc:AddBuffLayer(self._entity, self._layerType, curLegendPower)
    local buffResult = BuffResultAddLayer:New(curMarkLayer, self._dontDisplay)
    return buffResult
end
