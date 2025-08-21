require("base_ins_r")
---@class PlaySummonScanTrapInstruction: BaseInstruction
_class("PlaySummonScanTrapInstruction", BaseInstruction)
PlaySummonScanTrapInstruction = PlaySummonScanTrapInstruction

function PlaySummonScanTrapInstruction:Constructor(paramList)
    self._effectID = tonumber(paramList["effectID"])
end

function PlaySummonScanTrapInstruction:GetCacheResource()
    local t = {}
    if self._effectID then
        local cfgfx = Cfg.cfg_effect[self._effectID]
        if cfgfx then
            table.insert(t, {cfgfx.ResPath, 1})
        end
    end
    return t
end

---@param casterEntity Entity
---@param phaseContext SkillPhaseContext
function PlaySummonScanTrapInstruction:DoInstruction(TT, casterEntity, phaseContext)
    local resultIndex = phaseContext:GetCurResultIndexByType(SkillEffectType.SummonScanTrap)
    ---@type SkillEffectResultContainer
    local routineCmpt = casterEntity:SkillRoutine():GetResultContainer()
    local tResults = routineCmpt:GetEffectResultsAsArray(SkillEffectType.SummonScanTrap)
    if not tResults then
        return
    end
    ---@type SkillEffectResult_SummonScanTrap
    local result = tResults[resultIndex]

    ---@type MainWorld
    local world = casterEntity:GetOwnerWorld()
    ---@type TrapServiceRender
    local rsvcTrap = world:GetService("TrapRender")
    local tDestroyTrapInfo = result:GetDestroyTrapID()

    local playSkillSvc = world:GetService("PlaySkill")
    local configSvc = world:GetService("Config")

    local tDestroyEntity = {}
    for _, info in ipairs(tDestroyTrapInfo) do
        local id = info.entityID
        local e = world:GetEntityByID(id)
        if e then
            if info.replacingSkillContainer then
                local container = info.replacingSkillContainer
                e:SkillRoutine():SetResultContainer(container)
                local skillConfigData = configSvc:GetSkillConfigData(info.skillID, e)
                local skillPhaseArray = skillConfigData:GetSkillPhaseArray()
                playSkillSvc:_SkillRoutineTask(TT, e, skillPhaseArray, info.skillID)
            end

            table.insert(tDestroyEntity, e)
        end
    end

    if #tDestroyEntity > 0 then
        phaseContext:AddPhaseTask(TaskManager:GetInstance():CoreGameStartTask(
            rsvcTrap.PlayTrapDieSkill,
            rsvcTrap,
            tDestroyEntity
        ))
    end

    local eidNewTrap = result:GetSummonTrapEntityID()
    local eNewTrap = world:GetEntityByID(eidNewTrap)
    if not eNewTrap then
        --道理上不应该出现这种智障情况……吧……
        return
    end
    rsvcTrap:CreateSingleTrapRender(TT, eNewTrap, true)

    ---@type SkillBuffEffectResult[]
    local tAddBuffResults = result:GetAddBuffResults()
    if not tAddBuffResults then
        return
    end

    ---@type PlayBuffService
    local playBuffService = world:GetService("PlayBuff")

    for _, addBuffResult in ipairs(tAddBuffResults) do
        for _, seq in ipairs(addBuffResult:GetAddBuffResult()) do
            local buffViewInst = eNewTrap:BuffView():GetBuffViewInstance(seq)
            if buffViewInst then
                playBuffService:PlayAddBuff(TT, buffViewInst, eidNewTrap)
            end
        end
    end
end
