--[[---------------------------------------------------------------
    ActionIsCasterInSelectSkillRange 检测施法者自己是否在技能范围内
--]] ---------------------------------------------------------------
require "action_is_base"
---------------------------------------------------------------
_class("ActionIsCasterInSelectSkillRange", ActionIsBase)
---@class ActionIsCasterInSelectSkillRange:ActionIsBase
ActionIsCasterInSelectSkillRange = ActionIsCasterInSelectSkillRange

function ActionIsCasterInSelectSkillRange:Constructor()
end

function ActionIsCasterInSelectSkillRange:OnUpdate()
    if AINewNode.IsEntityDead(self.m_entityOwn) then
        return AINewNodeStatus.Failure
    end
    local entityCaster = self.m_entityOwn
    local aiComponent = entityCaster:AI()
    if nil == aiComponent then
        return AINewNodeStatus.Failure
    end
    local nSkillID = self:GetLogicData(-1)
    local bSuccess = nSkillID > 0 and self:IsEntityInSkillRange(nSkillID, entityCaster)
    if bSuccess then
        return AINewNodeStatus.Success
    end
    return AINewNodeStatus.Failure
end
