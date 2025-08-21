--[[
    设置机关状态
]]
require "buff_logic_base"
_class("BuffLogicSetTrapOpenState", BuffLogicBase)
---@class BuffLogicSetTrapOpenState:BuffLogicBase
BuffLogicSetTrapOpenState = BuffLogicSetTrapOpenState

function BuffLogicSetTrapOpenState:Constructor(buffInstance, logicParam)
    self._state =  logicParam.state or  1
end

function BuffLogicSetTrapOpenState:DoLogic()
    local entity = self._buffInstance:Entity()
    if not entity:HasTrapID() then
        return
    end
    ----@type AttributesComponent
    local attributeCmpt = entity:Attributes()
    --@type BuffComponent
    local buffComp = entity:BuffComponent()
    attributeCmpt:Modify("OpenState",self._state)
    local res = DataAttributeResult:New(entity:GetID(), "OpenState", self._state)
    self._world:EventDispatcher():Dispatch(GameEventType.DataLogicResult, 0, res)
end