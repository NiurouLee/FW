--[[-------------------------------------
    ActionAddTrapRound 更新倒计时
--]] -------------------------------------
require "ai_node_new"

---@class ActionAddTrapRound : AINewNode
_class("ActionAddTrapRound", AINewNode)
ActionAddTrapRound = ActionAddTrapRound

function ActionAddTrapRound:OnBegin()
    --如果机关能能量属性  每回合加到1
    ---@type AttributesComponent
    local attributeCmpt = self.m_entityOwn:Attributes()
    if attributeCmpt then
        local round = attributeCmpt:GetAttribute("CurrentRound")
        local total = attributeCmpt:GetAttribute("TotalRound")
        if round and total then
            round = round + 1
            if round == total + 1 then
                round = 1
            end
            attributeCmpt:Modify("CurrentRound", round)
        end

        local res = DataAttributeResult:New(self.m_entityOwn:GetID(), "CurrentRound", round)
        self._world:EventDispatcher():Dispatch(GameEventType.DataLogicResult, 0, res)
    end
end

function ActionAddTrapRound:OnUpdate()
    return AINewNodeStatus.Success
end
