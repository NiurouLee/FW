--[[

]]
---@class BuffLogicForceRefreshUnlockHP:BuffLogicBase
_class("BuffLogicForceRefreshUnlockHP", BuffLogicBase)
BuffLogicForceRefreshUnlockHP = BuffLogicForceRefreshUnlockHP

function BuffLogicForceRefreshUnlockHP:Constructor(buffInstance, logicParam)
end

function BuffLogicForceRefreshUnlockHP:DoLogic()
    local e = self._buffInstance:Entity()

    ---@type BattleStatComponent
    local battleStatCmpt = self._world:BattleStat()
    local round = battleStatCmpt:GetCurWaveTotalRoundCount()

    ---@type BuffComponent
    local buffCmpt = e:BuffComponent()
    buffCmpt:RecordUnlockHPIndex(buffCmpt:GetHPLockIndex())
    buffCmpt:RecordLastUnlockHPRound(round)
    buffCmpt:ResetHPLockState()
    local isUnlockHP = buffCmpt:GetBuffValue("IsUnlockHP")
    self._world:GetService("Trigger"):Notify(NTBreakHPLock:New(e, isUnlockHP))

    return true
end
