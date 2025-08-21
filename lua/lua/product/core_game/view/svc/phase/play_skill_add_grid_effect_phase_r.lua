require "play_skill_phase_base_r"
---@class PlaySkillAddGridEffectPhase: Object
_class("PlaySkillAddGridEffectPhase", PlaySkillPhaseBase)
PlaySkillAddGridEffectPhase = PlaySkillAddGridEffectPhase

function PlaySkillAddGridEffectPhase:PlayFlight(TT, casterEntity, phaseParam)
    ---@type SkillPhaseAddGridEffectParam
    local addGridEffectParam = phaseParam
    local castEffectIDArray = addGridEffectParam:GetEffectIDArray()

    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()
    ---@type SkillAddGridEffectResult
    local result = skillEffectResultContainer:GetEffectResultByArray(SkillEffectType.AddGridEffect)
    local gridList = result:GetTargetGridArray()
    local convertTypes = result:GetGridConvertTypes()
    local traps = result:GetSummonTraps()

    local last = addGridEffectParam:GetLastTime()
    local gridEffectDelayTime = addGridEffectParam:GetGridEffectDelayTime()

    --启动攻击特效播放
    for i, effectID in ipairs(castEffectIDArray) do
        for i = 1, #gridList do
            self._world:GetService("Effect"):CreateWorldPositionEffect(effectID, gridList[i])
        end
    end

    if last < gridEffectDelayTime then
        last = gridEffectDelayTime
    end

    ---@type PieceServiceRender
    local pieceService = self._world:GetService("Piece")
    local tConvertInfo = {}


    for _, v2Pos in ipairs(gridList) do
        local nOldGridType = PieceType.None
        local gridEntity = pieceService:FindPieceEntity(v2Pos)
        ---@type PieceComponent
        local pieceCmpt = gridEntity:Piece()
        nOldGridType = pieceCmpt:GetPieceType()

        local convertType = result:GetGridConvertType(v2Pos)
        if convertType then
            local convertInfo = NTGridConvert_ConvertInfo:New(v2Pos, nOldGridType, convertType)
            table.insert(tConvertInfo, convertInfo)
        end
    end

    local taskID = nil
    if gridEffectDelayTime > 0 then
        taskID =
            GameGlobal.TaskManager():CoreGameStartTask(
                function(TT)
                    YIELD(TT, gridEffectDelayTime)
                    self:_AddGridEffect(TT, gridList, convertTypes, traps)
                end
            )
    else
        self:_AddGridEffect(TT, gridList, convertTypes, traps)
    end

    YIELD(TT, last)

    if taskID then
        while not TaskHelper:GetInstance():IsTaskFinished(taskID) do
            YIELD(TT)
        end
    end

    ---@type PlayBuffService
    local svcPlayBuff = self._world:GetService("PlayBuff")

    if #tConvertInfo > 0 then
        local notify = NTGridConvert:New(casterEntity, tConvertInfo)
        notify:SetConvertEffectType(SkillEffectType.AddGridEffect)
        notify.__attackPosMatchRequired = true
        svcPlayBuff:PlayBuffView(TT, notify)
    end
end

---@param gridList table<int, Entity>
function PlaySkillAddGridEffectPhase:_AddGridEffect(TT, gridList, convertTypes, traps)
    ---@type TrapServiceRender
    local trapServiceRender = self._world:GetService("TrapRender")
    ---@type BoardServiceRender
    local boardServiceR = self._world:GetService("BoardRender")
    ---@type PieceServiceRender
    local pieceSvc = self._world:GetService("Piece")
    for i = 1, #gridList do
        local gridPos = gridList[i]
        local trapId = traps[Vector2.Pos2Index(gridPos)]
        local trap = self._world:GetEntityByID(trapId)
        trapServiceRender:CreateSingleTrapRender(TT, trap)
        local piece = pieceSvc:FindPieceEntity(gridPos)
        local convertType = convertTypes[Vector2.Pos2Index(gridPos)] 
        if piece and convertType then
            boardServiceR:ReCreateGridEntity(convertType, gridPos)
        end
    end
end
