--[[
    
]]
_class("BuffLogicAddTeamLeaderEffect", BuffLogicBase)
---@class BuffLogicAddTeamLeaderEffect: BuffLogicBase
BuffLogicAddTeamLeaderEffect = BuffLogicAddTeamLeaderEffect

function BuffLogicAddTeamLeaderEffect:Constructor(buffInstance, logicParam)
    self._effectID = logicParam.effectID
    self._remove = logicParam.remove or 0
    self._removeAnim = logicParam.removeAnim
    self._removeAnimTime = logicParam.removeAnimTime
end

function BuffLogicAddTeamLeaderEffect:DoLogic(notify)
    ---@type Entity
    local entity = self._buffInstance:Entity()

    if not entity:HasTeam() then
        return
    end

    local teamLeader = entity:Team():GetTeamLeaderEntity()

    --卸载掉旧队长身上的特效
    local oldTeamLeaderID = nil
    if notify and notify:GetNotifyType() == NotifyType.ChangeTeamLeader then
        oldTeamLeaderID = notify:GetOldTeamLeader():GetID()
    end

    local buffResult =
        BuffResultAddTeamLeaderEffect:New(
        oldTeamLeaderID,
        teamLeader:GetID(),
        self._effectID,
        self._remove,
        self._removeAnim,
        self._removeAnimTime
    )

    return buffResult
end
