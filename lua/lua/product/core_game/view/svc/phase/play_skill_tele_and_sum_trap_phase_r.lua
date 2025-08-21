require "play_skill_phase_base_r"

---@class PlaySkillTeleportAndSummonTrapPhase: PlaySkillPhaseBase
_class("PlaySkillTeleportAndSummonTrapPhase", PlaySkillPhaseBase)
PlaySkillTeleportAndSummonTrapPhase = PlaySkillTeleportAndSummonTrapPhase
---@param casterEntity Entity
function PlaySkillTeleportAndSummonTrapPhase:PlayFlight(TT, casterEntity, phaseParam)
    ---@type SkillPhaseTeleportAndSummonTrapParam
    local summonParam = phaseParam

    ---@type TrapServiceRender
    local trapServiceRender = self._world:GetService("TrapRender")
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()
    ---@type SkillEffectTeleportAndSummonTrapResult[]
    local resultArray = skillEffectResultContainer:GetEffectResultsAsArray(SkillEffectType.TeleportAndSummonTrap)
    if not resultArray then
        Log.fatal("### PlaySkillTeleportAndSummonTrapPhase TeleportAndSummonTrap result nil")
        return
    end
    local animNameList = summonParam:GetTeleportAnimList()
    local teleportEffectID = summonParam:GetTeleportEffectID()
    local teleportEffectPos = summonParam:GetTeleportEffectPos()
    local teleportEffectDelay = summonParam:GetTeleportEffectDelay()
    local gridEffectID = summonParam:GetGridEffectID()
    local gridEffectDelay = summonParam:GetGridEffectDelay()
    local teleportWaitTime = summonParam:GetTeleportWaitTime()
    local teleportOverTriggerName = summonParam:GetTeleportOverTriggerName()

    local audioID = summonParam:GetAudioID()
    local audioType = summonParam:GetAudioType()
    local audioDelay = summonParam:GetAudioDelay()

    ---@type EffectService
    local effectService = self._world:GetService("Effect")
    for index, result in ipairs(resultArray) do
        effectService:CreatePositionEffect(teleportEffectID,teleportEffectPos)
        GameGlobal.TaskManager():CoreGameStartTask(self.PlayAudio,self,audioID,audioType,audioDelay)
        if teleportEffectDelay ~=0 then
            YIELD(TT,teleportEffectDelay)
        end
        casterEntity:SetPosition(result:GetTeleportPos())
        casterEntity:SetAnimatorControllerTriggers({animNameList[index]})

        local trapIDList = result:GetTrapEntityIDList()
        local trapPosList = result:GetTrapPosList()
        for i = 1, #trapIDList do
            local pos = trapPosList[i]
            ---@type Entity
            local trapEntity = self._world:GetEntityByID(trapIDList[i])
            GameGlobal.TaskManager():CoreGameStartTask(self.CreateTrapAndEffect,self,trapEntity,pos,gridEffectID,gridEffectDelay)
        end
        if teleportWaitTime ~=0 then
            YIELD(TT,teleportWaitTime)
        end
    end
    casterEntity:SetAnimatorControllerTriggers(teleportOverTriggerName)
end

function PlaySkillTeleportAndSummonTrapPhase:CreateTrapAndEffect(TT,trapEntity,pos,effectID,effectDelay)
    ---@type EffectService
    local effectService = self._world:GetService("Effect")
    ---@type TrapServiceRender
    local trapServiceRender = self._world:GetService("TrapRender")
    effectService:CreateCommonGridEffect(effectID,pos,Vector2(0,0))
    if effectDelay ~=0 then
        YIELD(TT,effectDelay)
    end
    trapServiceRender:CreateSingleTrapRender(TT, trapEntity, true)
    trapEntity:SetPosition(Vector2(pos.x, pos.y))
end

function PlaySkillTeleportAndSummonTrapPhase:PlayAudio(TT,audioID,audioType,audioDelay)
    if audioDelay> 0 then
        YIELD(TT,audioDelay)
    end
    if audioType == SkillAudioType.Cast then
        AudioHelperController.PlayInnerGameSfx(audioID)
    elseif audioType == SkillAudioType.Voice then
        AudioHelperController.PlayInnerGameVoiceByAudioId(audioID)
    end
end