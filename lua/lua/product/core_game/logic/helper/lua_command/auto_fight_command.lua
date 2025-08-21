--[[------------------------------------------------------------------------------------------
   AutoFightCommand 自动战斗
]] --------------------------------------------------------------------------------------------
require("entity_commands")

---@class AutoFightCommand:IEntityCommand
_class("AutoFightCommand", IEntityCommand)
AutoFightCommand = AutoFightCommand

function AutoFightCommand:Constructor()
    self._commandType = "AutoFight"
    self._enableAutoFight = false
end

function AutoFightCommand:GetCommandType()
    return self._commandType
end

function AutoFightCommand:GetExecStateID()
    return { GameStateID.WaitInput,GameStateID.WaitInputChain,GameStateID.PickUpChainSkillTarget, GameStateID.WaveResultAward, GameStateID.MirageWaitInput} --msg54377 GameStateID.WaveResultAward阶段，取消自动战斗消息无法通过判断导致流程卡住
end

function AutoFightCommand:IsExecExcluded()
    return 0
end

function AutoFightCommand:DependRoundCount()
    return false
end

function AutoFightCommand:GetCmdAutoFight()
    return self._enableAutoFight
end

function AutoFightCommand:SetCmdAutoFight(enableAutoFight)
    self._enableAutoFight = enableAutoFight
end

function AutoFightCommand:ToNetMessage()
    local msg = CEventAutoFightCommand:New()
    msg.EntityID = self.EntityID
    msg.RoundCount = self.RoundCount
    msg.ClientWaitInput = self.ClientWaitInput
    msg.CmdIndex = self.CmdIndex
    msg.IsAutoFight = self.IsAutoFight
    msg.EnableAutoFight = self._enableAutoFight

    return msg
end

function AutoFightCommand:FromNetMessage(msg)
    self.EntityID = msg.EntityID
    self.RoundCount = msg.RoundCount
    self.ClientWaitInput = msg.ClientWaitInput
    self.CmdIndex = msg.CmdIndex
    self.IsAutoFight = msg.IsAutoFight
    self._enableAutoFight = msg.EnableAutoFight
end
