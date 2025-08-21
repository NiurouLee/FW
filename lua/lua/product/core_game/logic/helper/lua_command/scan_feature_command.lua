--[[https://wiki.h3d.com.cn/pages/viewpage.action?pageId=77138576]]
require("match_message")

_class("ScanFeatureCommand", IEntityCommand)
---@class ScanFeatureCommand : IEntityCommand
ScanFeatureCommand = ScanFeatureCommand

ScanFeatureCommand.CommandType = "ScanFeatureCommand"

---@param teamEntity Entity
function ScanFeatureCommand:Constructor(teamEntityID, skillType, trapID)
    self.EntityID = teamEntityID
    ---@type ScanFeatureActiveSkillType
    self._activeSkillType = skillType
    ---@type number|nil
    self._trapID = trapID
end

function ScanFeatureCommand:GetActiveSkillType()
    return self._activeSkillType
end

function ScanFeatureCommand:GetScanTrapID()
    return self._trapID
end

function ScanFeatureCommand:GetExecStateID(runAtClient)
    return GameStateID.WaitInput
end

function ScanFeatureCommand:GetCommandType()
    return ScanFeatureCommand.CommandType
end

function ScanFeatureCommand:ToNetMessage()
    ---@type CEventScanFeatureCommand
    local msg = CEventScanFeatureCommand:New()
    msg.EntityID = self.EntityID
    msg.ActiveSkillType = self._activeSkillType
    msg.TrapID = self._trapID
    return msg
end

---@param msg CEventScanFeatureCommand
function ScanFeatureCommand:FromNetMessage(msg)
    self.EntityID = msg.EntityID
    self._activeSkillType = msg.ActiveSkillType
    self._trapID = msg.TrapID
end
