--[[
    根据buff layer层数提升AI行动力
]]
_class("BuffLogicAddAIMobilityByLayer", BuffLogicBase)
---@class BuffLogicAddAIMobilityByLayer:BuffLogicBase
BuffLogicAddAIMobilityByLayer = BuffLogicAddAIMobilityByLayer

function BuffLogicAddAIMobilityByLayer:Constructor(buffInstance, logicParam)
    self._layerType = logicParam.layerType or self._buffInstance:GetBuffEffectType()
    self._addValuePerLayer = logicParam.addValuePerLayer or 0
end

function BuffLogicAddAIMobilityByLayer:DoLogic()
    ---@type Entity
    local e = self._buffInstance:Entity()
    if not e:HasMonsterID() then
        return
    end
    ---@type BuffLogicService
    local svc = self._world:GetService("BuffLogic")
    local curMarkLayer = svc:GetBuffLayer(e, self._layerType)

    e:Attributes():RemoveModify("Mobility", self._buffInstance:BuffSeq())

    local addVal = self._addValuePerLayer * curMarkLayer
    if addVal ~= 0 then
        e:Attributes():Modify("Mobility", addVal, self._buffInstance:BuffSeq(), MultModifyOperator.PLUS)
    end
end

function BuffLogicAddAIMobilityByLayer:DoOverlap()
    self:DoLogic()
end
