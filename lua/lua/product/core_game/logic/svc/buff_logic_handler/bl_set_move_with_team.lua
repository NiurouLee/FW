---@class HomeStoryEntityType
BLSetMoveWithTeamTargetTeamType = {
    OwnerTeam = 1,--(机关)召唤者队伍
}
_enum("BLSetMoveWithTeamTargetTeamType", BLSetMoveWithTeamTargetTeamType)

_class("BuffLogicSetMoveWithTeam", BuffLogicBase)
---@class BuffLogicSetMoveWithTeam : BuffLogicBase
BuffLogicSetMoveWithTeam = BuffLogicSetMoveWithTeam

function BuffLogicSetMoveWithTeam:Constructor(buffInstance, logicParam)
    local paramSet = tonumber(logicParam.bSet)
    self._bSet = (paramSet == 1)
    self._targetTeamType = tonumber(logicParam.targetTeamType)
end

function BuffLogicSetMoveWithTeam:DoLogic(notify)
    local teamEntity = nil
    if self._bSet then
        ---@type Entity
        teamEntity = self._world:Player():GetCurrentTeamEntity()
        if BLSetMoveWithTeamTargetTeamType.OwnerTeam == self._targetTeamType then
            if self._entity:HasSummoner() then 
                local ownerPet = self._entity:GetSummonerEntity()
                if ownerPet:HasPet() then
                    teamEntity = ownerPet:Pet():GetOwnerTeamEntity()
                end
            end
        end
        self._entity:AddSyncMoveWithTeam(teamEntity)
    else
        self._entity:RemoveSyncMoveWithTeam()
    end
    return BuffResultSetMoveWithTeam:New(self._bSet,teamEntity)
end
