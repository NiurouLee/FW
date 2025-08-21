require "ai_node_new"
---@class ActionSkillSelectFromAIComponent:AINewNode
_class("ActionSkillSelectFromAIComponent", AINewNode)
ActionSkillSelectFromAIComponent = ActionSkillSelectFromAIComponent

function ActionSkillSelectFromAIComponent:Update()
    return AINewNodeStatus.Success
end

function ActionSkillSelectFromAIComponent:GetActionSkillID()
    ---@type AIComponentNew
    local cAI = self.m_entityOwn:AI()
    if not cAI then
        return 0
    end

    local nSelectedSkillID = cAI:GetSelectSkillID()
    if nSelectedSkillID == 0 then
        return self:GetConfigSkillID(1, 1)
    end

    return nSelectedSkillID
end
