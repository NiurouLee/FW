--[[
        修改传说星灵能量表现
]]
_class("BuffViewAddLegendPowerByMonsterDead", BuffViewBase)
BuffViewAddLegendPowerByMonsterDead = BuffViewAddLegendPowerByMonsterDead

function BuffViewAddLegendPowerByMonsterDead:PlayView(TT)
    local petPstID = self._buffResult:GetPetPstID()
    local curPower = self._buffResult:GetNewPower()
    local ready = self._buffResult:GetReady()
    local entityID = self._buffResult:GetPetEntityID()
    local requireNTPowerReady = self._buffResult:IsNTPowerReadyRequired()

    --改变CD
    GameGlobal.EventDispatcher():Dispatch(GameEventType.PetLegendPowerChange, petPstID, curPower, true)
    --可以释放
    if ready then
        GameGlobal.EventDispatcher():Dispatch(GameEventType.PetActiveSkillGetReady, petPstID, ready)
    else
        GameGlobal:EventDispatcher():Dispatch(GameEventType.PetActiveSkillCancelReady, petPstID)
    end

    if requireNTPowerReady then
        local notify = NTPowerReady:New(self._world:GetEntityByID(entityID))
        self._world:GetService("PlayBuff"):PlayBuffView(TT, notify)
    end
end
