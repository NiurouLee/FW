require "play_skill_phase_base_r"
---@class PlaySkillPhaseScopeTrajectory : PlaySkillPhaseBase
_class("PlaySkillPhaseScopeTrajectory", PlaySkillPhaseBase)
PlaySkillPhaseScopeTrajectory = PlaySkillPhaseScopeTrajectory

---@param casterEntity Entity
---@param phaseParam SkillPhaseParamScopeTrajectory
function PlaySkillPhaseScopeTrajectory:PlayFlight(TT, casterEntity, phaseParam)
    self._attackedPosArray = {}

    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()
    ---@type SkillScopeResult
    local scopeResult = skillEffectResultContainer:GetScopeResult()

    local isHorizontal = phaseParam:GetScopeHorizontalOrVertical()
    local attackRange = scopeResult:GetAttackRange()

    local casterPos = casterEntity:GetGridPosition()

    local targetGridList = InnerGameSortGridHelperRender:SortGrid(attackRange, casterPos)

    local abstractDamageResults = {}

    self:_CalcGridRenderMinAndMax()

    -- 根据方向，对每列/行分别记录最大和最小坐标
    local coordMinMax = self:_GetMinMaxInRange(attackRange, isHorizontal)

    local targetColumnOrRow = {}
    local sidesPos = {}
    if isHorizontal then
        for _, gridPos in ipairs(attackRange) do
            if not targetColumnOrRow[gridPos.y] then
                targetColumnOrRow[gridPos.y] = self:_GetHorizontalBeginAndTarget(casterPos, gridPos, coordMinMax)
            end

            if gridPos.x == casterPos.x then
                table.insert(sidesPos, gridPos)
            end
        end
    else
        for _, gridPos in ipairs(attackRange) do
            if not targetColumnOrRow[gridPos.x] then
                targetColumnOrRow[gridPos.x] = self:_GetVerticalBeginAndTarget(casterPos, gridPos, coordMinMax)
            end

            if gridPos.y == casterPos.y then
                table.insert(sidesPos, gridPos)
            end
        end
    end

    ---@type EffectService
    local effectService = self._world:GetService("Effect")

    if phaseParam:GetSidesEffectID() then
        local sidesEffectID = phaseParam:GetSidesEffectID()
        local v2CasterDir = casterEntity:Location():GetRenderGridDirection()
        for _, v2 in ipairs(sidesPos) do
            if v2 ~= casterPos then
                effectService:CreateCommonGridEffect(sidesEffectID, v2, v2CasterDir)
            end
        end
        YIELD(TT, phaseParam:SidesEffectDelay())
    end
    local sidesDamageDelay = phaseParam:GetSidesDamageDelay()
    YIELD(TT, sidesDamageDelay)

    -- 两侧怪物的伤害表现
    ---@type SkillDamageEffectResult[]
    local damageResultArray = skillEffectResultContainer:GetEffectResultsAsArray(SkillEffectType.Damage)
    if damageResultArray then
        for damageResultIndex, serDamage in ipairs(damageResultArray) do
            if (table.icontains(sidesPos, serDamage:GetGridPos())) then
                self:_DoHit(TT, phaseParam, casterEntity, serDamage, 0)
                table.insert(abstractDamageResults, self:_GetAbstractDamageResultString(serDamage, damageResultIndex))
            end
        end
    end

    local trajectoryCreateDelay = phaseParam:GetTrajectoryCreateDelay()
    trajectoryCreateDelay = math.max(0, trajectoryCreateDelay - sidesDamageDelay)
    YIELD(TT, trajectoryCreateDelay)

    local maxEndTime = 0

    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")

    local trajectoryEffectID = phaseParam:GetTrajectoryEffectID()
    ---@type PlaySkillPhase_ScopeTrajectory_TrajectoryInfo[]
    local trajectories = {}
    for _, posInfo in pairs(targetColumnOrRow) do
        maxEndTime = math.max(maxEndTime, self:_CreateTrajectories(posInfo, phaseParam, trajectories, casterPos))
    end

    -- 飞行前延迟
    local beginDelayTime = phaseParam:GetBeginDelayTime()
    beginDelayTime = beginDelayTime - trajectoryCreateDelay - sidesDamageDelay
    YIELD(TT, beginDelayTime)

    maxEndTime = maxEndTime + GameGlobal:GetInstance():GetCurrentTime()

    self:_InitFlyPosList()
    local finishEffEntities = {}
    local trajectoryFinishEffectID = phaseParam:GetTrajectoryFinishEffectID()
    for _, trajectoryInfo in ipairs(trajectories) do
        ---@type UnityEngine.Transform
        local trajectoryObject = trajectoryInfo.entity:View():GetGameObject()
        local transWork = trajectoryObject.transform
        local gridWorldpos = boardServiceRender:GridPos2RenderPos(trajectoryInfo.target --[[+ trajectoryInfo.direction * 0.0001]])
        local easeWork =
            transWork:DOMove(gridWorldpos, trajectoryInfo.flyTime, false):SetEase(DG.Tweening.Ease.InOutSine)

        local tailEntity = trajectoryInfo.tailEntity
        local tailObject, tailEaseWork
        if tailEntity then
            ---@type UnityEngine.Transform
            tailObject = trajectoryInfo.tailEntity:View():GetGameObject()
            local transWork = tailObject.transform
            local gridWorldpos = boardServiceRender:GridPos2RenderPos(trajectoryInfo.target --[[+ trajectoryInfo.direction * 0.0001]])
            tailEaseWork =
                transWork:DOMove(gridWorldpos, trajectoryInfo.flyTime, false):SetEase(DG.Tweening.Ease.InOutSine)
        end

        if easeWork then
            easeWork:OnComplete(
                function()
                    self._world:DestroyEntity(trajectoryInfo.entity)

                    if trajectoryFinishEffectID then
                        table.insert(
                            finishEffEntities,
                            effectService:CreateCommonGridEffect(trajectoryFinishEffectID, trajectoryInfo.target, trajectoryInfo.direction)
                        )
                    end
                end
            )
        end

        if tailEaseWork then
            tailEaseWork:OnComplete(
                function()
                    GameGlobal.TaskManager():CoreGameStartTask(
                        function(T2)
                            local tailDismissDelay = phaseParam:GetTailDismissDelay()
                            if tailDismissDelay then
                                YIELD(T2, tailDismissDelay)
                            end

                            if trajectoryInfo and trajectoryInfo.tailEntity then
                                self._world:DestroyEntity(trajectoryInfo.tailEntity)
                            end
                        end
                    )
                end
            )
        end
    end

    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()

    local taskIDArray = {}
    ---@type SkillDamageEffectResult[]
    local allDamageResult = skillEffectResultContainer:GetEffectResultsByType(SkillEffectType.Damage)

    local t = {}

    for _, trajectoryInfo in ipairs(trajectories) do
        local dir = trajectoryInfo.begin - trajectoryInfo.target
        local totalDis = Vector2.Distance(trajectoryInfo.begin, trajectoryInfo.target)
        for damageResultIndex, damageResult in ipairs(allDamageResult.array) do
            if
                not table.icontains(
                    abstractDamageResults,
                    self:_GetAbstractDamageResultString(damageResult, damageResultIndex)
                )
             then
                local gridPos = damageResult:GetGridPos()
                local vd = gridPos - trajectoryInfo.target
                local vs = gridPos - trajectoryInfo.begin
                if vs.x * vd.x <= 0 and vs.y * vd.y <= 0 then
                    local dis = Vector2.Distance(trajectoryInfo.begin, gridPos)
                    local time = 0
                    if totalDis > 0 then
                        local percent = (dis) / totalDis
                        time = percent * trajectoryInfo.flyTime * 1000
                    end
                    table.insert(
                        t,
                        GameGlobal.TaskManager():CoreGameStartTask(
                            self._DoHit,
                            self,
                            phaseParam,
                            casterEntity,
                            damageResult,
                            time --[[ + trajectoryCreateDelay]]
                        )
                    )

                    table.insert(
                        abstractDamageResults,
                        self:_GetAbstractDamageResultString(damageResult, damageResultIndex)
                    )
                end
            end
        end
    end

    local trajectoryFinishEffectTime = phaseParam:GetTrajectoryFinishEffectTime()
    YIELD(TT, trajectoryFinishEffectTime)

    -- 保底
    for damageResultIndex, damageResult in ipairs(allDamageResult.array) do
        if
            not table.icontains(
                abstractDamageResults,
                self:_GetAbstractDamageResultString(damageResult, damageResultIndex)
            )
         then
            Log.fatal(self._className, "存在未能正确播放的伤害")

            table.insert(
                t,
                GameGlobal.TaskManager():CoreGameStartTask(self._DoHit, self, phaseParam, casterEntity, damageResult, 0)
            )

            table.insert(abstractDamageResults, self:_GetAbstractDamageResultString(damageResult, damageResultIndex))
        end
    end

    local finishDelayTime = phaseParam:GetFinishDelayTime()
    if finishDelayTime then
        YIELD(TT, finishDelayTime)
    end

    for i = 1, #finishEffEntities do
        self._world:DestroyEntity(finishEffEntities[i])
    end
    finishEffEntities = {}

    return true
end

---@param range table<number, Vector2>
---@param isHorizontal boolean
function PlaySkillPhaseScopeTrajectory:_GetMinMaxInRange(range, isHorizontal)
    local coordMinMax = {}
    if isHorizontal then
        for _, gridPos in ipairs(range) do
            if not coordMinMax[gridPos.y] then
                coordMinMax[gridPos.y] = {
                    min = gridPos.x,
                    max = gridPos.x
                }
            end

            local tbl = coordMinMax[gridPos.y]
            tbl.min = math.min(tbl.min, gridPos.x)
            tbl.max = math.max(tbl.max, gridPos.x)
        end
    else
        for _, gridPos in ipairs(range) do
            if not coordMinMax[gridPos.x] then
                coordMinMax[gridPos.x] = {
                    min = gridPos.y,
                    max = gridPos.y
                }
            end

            local tbl = coordMinMax[gridPos.x]
            tbl.min = math.min(tbl.min, gridPos.y)
            tbl.max = math.max(tbl.max, gridPos.y)
        end
    end

    return coordMinMax
end

function PlaySkillPhaseScopeTrajectory:_GetFlyTimeInSecond(cfgTotalTime, cfgTrajectoryTime, target, begin)
    local totalTime = cfgTotalTime
    local flyTime = totalTime and totalTime * 0.001 or nil
    if not flyTime then
        local nTrajectoryTime = cfgTrajectoryTime
        local disx = math.abs(target.x - begin.x)
        local disy = math.abs(target.y - begin.y)
        local dis = math.sqrt(disx * disx + disy * disy)
        totalTime = dis * nTrajectoryTime
        flyTime = totalTime * 0.001
    end

    return flyTime, totalTime
end

function PlaySkillPhaseScopeTrajectory:_GetHorizontalBeginAndTarget(casterPos, gridPos, coordMinMax)
    -- x+方向为右，参考局内绝对坐标文档
    local beginLeftX = casterPos.x - 1
    local beginRightX = casterPos.x + 1
    local beginY = gridPos.y

    local minMax = coordMinMax[beginY]

    return {
        beginPosA = self:_TryGetValidPiecePos(beginLeftX, beginY),
        beginPosB = self:_TryGetValidPiecePos(beginRightX, beginY),
        targetPosA = self:_TryGetValidPiecePos(minMax.min, beginY),
        targetPosB = self:_TryGetValidPiecePos(minMax.max, beginY)
    }
end

function PlaySkillPhaseScopeTrajectory:_GetVerticalBeginAndTarget(casterPos, gridPos, coordMinMax)
    -- y+方向为上，参考局内绝对坐标文档
    local beginX = gridPos.x
    local beginUpY = casterPos.y + 1
    local beginDownY = casterPos.y - 1

    local minMax = coordMinMax[beginX]

    return {
        beginPosA = self:_TryGetValidPiecePos(beginX, beginDownY),
        beginPosB = self:_TryGetValidPiecePos(beginX, beginUpY),
        targetPosA = self:_TryGetValidPiecePos(beginX, minMax.min),
        targetPosB = self:_TryGetValidPiecePos(beginX, minMax.max)
    }
end

function PlaySkillPhaseScopeTrajectory:_TryGetValidPiecePos(x, y)
    ---@type UtilDataServiceShare
    local utilDataSvc = self._world:GetService("UtilData")
    local pos = Vector2.New(x, y)

    local boardMaxX = utilDataSvc:GetCurBoardMaxX()
    local boardMaxY = utilDataSvc:GetCurBoardMaxY()
    if x < 1 then
        pos.x = 1
    elseif x > boardMaxX then
        pos.x = boardMaxX
    end

    if y < 1 then
        pos.y = 1
    elseif y > boardMaxY then
        pos.y = boardMaxY
    end
    return pos
end

---@param phaseParam SkillPhaseParamScopeTrajectory
function PlaySkillPhaseScopeTrajectory:_CreateTrajectories(posInfo, phaseParam, trajectories, casterPos)
    ---@type EffectService
    local effectService = self._world:GetService("Effect")
    local trajectoryEffectID = phaseParam:GetTrajectoryEffectID()

    local beginPosA = posInfo.beginPosA
    local beginPosB = posInfo.beginPosB
    local targetPosA = posInfo.targetPosA
    local targetPosB = posInfo.targetPosB

    ---@type UtilScopeCalcServiceShare
    local utilScope = self._world:GetService("UtilScopeCalc")
    -- 如果起始点在棋盘外，把终点设置成起点，以便正确处理方向问题
    if not utilScope:IsValidPiecePos(beginPosA) then
        targetPosA = beginPosA
    end
    if not utilScope:IsValidPiecePos(beginPosB) then
        targetPosB = beginPosB
    end

    local trajectoryFollowingEffectID = phaseParam:GetTrajectoryFollowingEffectID()
    local cfgTotalTime = phaseParam:GetTotalTime()
    local cfgTrajectoryTime = phaseParam:GetTrajectoryTime()
    local isHorizontal = phaseParam:GetScopeHorizontalOrVertical()
    local trajectoryEndOffset = phaseParam:GetTrajectoryFlightEndOffset()

    local totalTimeA = 0
    local totalTimeB = 0
    if (beginPosA) and (targetPosA) then
        local trajectoryInfo, totalTime = self:_CreateSingleTrajectory(
            beginPosA,
            targetPosA,
            trajectoryEffectID,
            trajectoryFollowingEffectID,
            cfgTotalTime,
            cfgTrajectoryTime,
            isHorizontal,
            casterPos,
            trajectoryEndOffset
        )
        table.insert(trajectories, trajectoryInfo)
        totalTimeA = totalTime
    end
    if (beginPosB) and (targetPosB) then
        local trajectoryInfo, totalTime = self:_CreateSingleTrajectory(
            beginPosB,
            targetPosB,
            trajectoryEffectID,
            trajectoryFollowingEffectID,
            cfgTotalTime,
            cfgTrajectoryTime,
            isHorizontal,
            casterPos,
            trajectoryEndOffset
        )
        table.insert(trajectories, trajectoryInfo)
        totalTimeB = totalTime
    end

    return math.max(totalTimeA, totalTimeB)
end

---@class PlaySkillPhase_ScopeTrajectory_TrajectoryInfo
---@field entity Entity
---@field begin Vector2
---@field target Vector2
---@field flyTime number
---@field tailEntity Entity
---@field currentGridPos Vector2
---@field direction Vector2

---@return PlaySkillPhase_ScopeTrajectory_TrajectoryInfo, number
function PlaySkillPhaseScopeTrajectory:_CreateSingleTrajectory(
    beginPos,
    targetPos,
    fxID,
    trailFxID,
    cfgTotalTime,
    cfgTrajectoryTime,
    isHorizontal,
    casterPos,
    trajectoryEndOffset
)
    ---@type EffectService
    local effectService = self._world:GetService("Effect")

    local direction = targetPos - beginPos
    if direction == Vector2.zero then
        if isHorizontal then
            local minMax = self:_GetMinMaxGridXByGridY(targetPos.y)
            if targetPos.x >= minMax.max then
                direction.x = 1
            else
                direction.x = -1
            end
        else
            local minMax = self:_GetMinMaxGridYByGridX(targetPos.x)
            if targetPos.y >= minMax.max then
                direction.y = 1
            else
                direction.y = -1
            end
        end
    end
    if direction.x > 0 then
        direction.x = 1
    elseif direction.x < 0 then
        direction.x = -1
    end
    if direction.y > 0 then
        direction.y = 1
    elseif direction.y < 0 then
        direction.y = -1
    end

    local finalPos = targetPos + (direction * trajectoryEndOffset)

    local fxEntity = effectService:CreateWorldPositionDirectionEffect(fxID, beginPos, direction)

    local flyTime, totalTime = self:_GetFlyTimeInSecond(cfgTotalTime, cfgTrajectoryTime, finalPos, beginPos)

    local trailFxEntity
    if trailFxID then
        trailFxEntity = effectService:CreateWorldPositionDirectionEffect(trailFxID, beginPos, direction)
    end

    return {
        entity = fxEntity,
        begin = beginPos,
        target = finalPos,
        flyTime = flyTime,
        tailEntity = trailFxEntity,
        currentGridPos = beginPos,
        direction = direction
    }, totalTime
end

function PlaySkillPhaseScopeTrajectory:_CalcGridRenderMinAndMax()
    ---@type Entity
    local renderBoardEntity = self._world:GetRenderBoardEntity()
    ---@type RenderBoardComponent
    local renderBoardCmpt = renderBoardEntity:RenderBoard()
    local gridEntityTable = renderBoardCmpt:GetGridRenderEntityTable()

    local columnXMinMax = {}
    local rowYMinMax = {}
    for x, col in pairs(gridEntityTable) do
        for y, gridEntity in pairs(col) do
            if not columnXMinMax[y] then
                columnXMinMax[y] = {}
            end
            if (not columnXMinMax[y].min) or (columnXMinMax[y].min > x) then
                columnXMinMax[y].min = x
            end
            if (not columnXMinMax[y].max) or (columnXMinMax[y].max < x) then
                columnXMinMax[y].max = x
            end

            if not rowYMinMax[x] then
                rowYMinMax[x] = {}
            end
            if (not rowYMinMax[x].min) or (rowYMinMax[x].min > y) then
                rowYMinMax[x].min = y
            end
            if (not rowYMinMax[x].max) or (rowYMinMax[x].max < y) then
                rowYMinMax[x].max = y
            end
        end
    end

    self._columnXMinMax = columnXMinMax
    self._rowYMinMax = rowYMinMax
end

function PlaySkillPhaseScopeTrajectory:_GetMinMaxGridXByGridY(y)
    return self._columnXMinMax[y]
end

function PlaySkillPhaseScopeTrajectory:_GetMinMaxGridYByGridX(x)
    return self._rowYMinMax[x]
end

function PlaySkillPhaseScopeTrajectory:_GetEntityPosByView(entityWork)
    ---@type ViewComponent
    local effectViewCmpt = entityWork:View()
    if nil == effectViewCmpt then
        return nil
    end
    ---@type UnityEngine.GameObject
    local effectObject = effectViewCmpt:GetGameObject()
    if nil == effectObject then
        return nil
    end
    ---@type UnityEngine.Transform
    local effectTrans = effectObject.transform
    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    local posReturn = boardServiceRender:BoardRenderPos2GridPos(effectTrans.position)
    return posReturn
end

function PlaySkillPhaseScopeTrajectory:_PlayTargetEffect(TT, phaseParam, posStart, posEnd)
    local nEffectID = phaseParam:GetTargetEffectID()
    local nShowTime = phaseParam:GetTargetDelayTime()
    if nil == nEffectID or nEffectID <= 0 then
        return
    end
    ---@type EffectService
    local effectService = self._world:GetService("Effect")
    local posDirectory = posEnd - posStart
    local entityEffect = effectService:CreateWorldPositionDirectionEffect(nEffectID, posEnd, posDirectory)
    YIELD(TT, nShowTime)
end

---@param phaseParam SkillPhaseParam_Trajectory
---@param damageData DamageInfo
function PlaySkillPhaseScopeTrajectory:_PlayHitEffect(
    TT,
    phaseParam,
    entityCast,
    entityTarget,
    damageData,
    damagePos,
    isFinalHit,
    nSkillID)
    local hitAnimationName = phaseParam:GetHitAnimation()
    local hitEffectID = phaseParam:GetHitEffectID()
    ---@type PlaySkillService
    local skillService = self:SkillService()
    ---调用统一处理被击的逻辑
    local beHitParam = HandleBeHitParam:New()
        :SetHandleBeHitParam_CasterEntity(entityCast)
        :SetHandleBeHitParam_TargetEntity(entityTarget)
        :SetHandleBeHitParam_HitAnimName(hitAnimationName)
        :SetHandleBeHitParam_HitEffectID(hitEffectID)
        :SetHandleBeHitParam_DamageInfo(damageData)
        :SetHandleBeHitParam_DamagePos(damagePos)
        :SetHandleBeHitParam_DeathClear(phaseParam:IsClearBodyNow())
        :SetHandleBeHitParam_IsFinalHit(isFinalHit)
        :SetHandleBeHitParam_SkillID(nSkillID)

    skillService:HandleBeHit(TT, beHitParam)
end

---@param casterEntity Entity
---@param phaseParam SkillPhaseParamScopeTrajectory
---@param serDamage SkillDamageEffectResult
function PlaySkillPhaseScopeTrajectory:_DoHit(TT, phaseParam, casterEntity, serDamage, delay)
    if type(delay) == "number" and delay >= 0 then
        YIELD(TT, delay)
    end
    ---@type SkillEffectResultContainer
    local damageData = serDamage:GetDamageInfo(phaseParam:GetDamageIndex())
    if not damageData then
        return
    end

    local hitAnimationName = phaseParam:GetHitAnimation()
    local hitEffectID = phaseParam:GetHitEffectID()

    ---@type MainWorld
    local world = casterEntity:GetOwnerWorld()
    ---@type SkillEffectResultContainer
    local routineComponent = casterEntity:SkillRoutine():GetResultContainer()
    local playSkillService = self:SkillService()
    ---调用统一处理被击的逻辑
    local beHitParam = HandleBeHitParam:New()
        :SetHandleBeHitParam_CasterEntity(casterEntity)
        :SetHandleBeHitParam_TargetEntity(world:GetEntityByID(serDamage:GetTargetID()))
        :SetHandleBeHitParam_HitAnimName(hitAnimationName)
        :SetHandleBeHitParam_HitEffectID(hitEffectID)
        :SetHandleBeHitParam_DamageInfo(damageData)
        :SetHandleBeHitParam_DamagePos(serDamage:GetGridPos())
        :SetHandleBeHitParam_DeathClear(phaseParam:IsClearBodyNow())
        :SetHandleBeHitParam_IsFinalHit(routineComponent:IsFinalAttack())
        :SetHandleBeHitParam_SkillID(routineComponent:GetSkillID())

    playSkillService:HandleBeHit(TT, beHitParam)
end
---@type SkillEffectResultContainer
---弹道飞行命中目标
function PlaySkillPhaseScopeTrajectory:_OnFlyAttack(
    TT,
    nSkillID,
    phaseParam,
    entityCaster,
    entityTarget,
    damageData,
    posStart,
    posEnd,
    isFinalHit)
    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = entityCaster:SkillRoutine():GetResultContainer()
    local isFinalHit = skillEffectResultContainer:IsFinalAttack()
    self:_PlayTargetEffect(TT, phaseParam, posStart, posEnd)
    if damageData then
        self:_PlayHitEffect(TT, phaseParam, entityCaster, entityTarget, damageData, posEnd, isFinalHit, nSkillID)
    end
end
---检查是否命中，否则加入
function PlaySkillPhaseScopeTrajectory:_InitFlyPosList()
    self.m_listFlyPos = {}
end
function PlaySkillPhaseScopeTrajectory:_IsHaveFlyPosList(pos)
    if table.icontains(self.m_listFlyPos, pos) then
        return true
    end
    self.m_listFlyPos[#self.m_listFlyPos + 1] = pos
    return false
end

function PlaySkillPhaseScopeTrajectory:_FindFlyDamageResult(
    skillEffectResultContainer,
    posFly,
    posStart,
    posEnd,
    nCheckRange)
    local dir = posStart - posEnd
    local dirTemp = Vector2.New(math.abs(dir.x), math.abs(dir.y))
    if dirTemp.x > 0 then
        dir.x = dir.x / dirTemp.x
    end
    if dirTemp.y > 0 then
        dir.y = dir.y / dirTemp.y
    end
    local listDamageData = {}
    for i = 0, nCheckRange do
        local posNew = posFly + dir * (nCheckRange - i)
        if posNew.x > 0 and posNew.y > 0 then ---简单的数据有效性校验
            ---@type SkillDamageEffectResult
            local damageResult = skillEffectResultContainer:GetEffectResultByPos(SkillEffectType.Damage, posNew)
            if damageResult then
                if false == self:_IsHaveFlyPosList(posNew) then
                    listDamageData[posNew] = damageResult
                end
            end
        end
    end
    return listDamageData
end

function PlaySkillPhaseScopeTrajectory:_IsPosAttacked(pos)
    for _, v2 in ipairs(self._attackedPosArray) do
        if pos == v2 then
            return true
        end
    end

    return false
end

function PlaySkillPhaseScopeTrajectory:_AddAttackedPos(pos)
    table.insert(self._attackedPosArray, pos)
end

function PlaySkillPhaseScopeTrajectory:_GetAbstractDamageResultString(damageResult, damageResultIndex)
    return string.format(
        "%s_%s_%s",
        tostring(damageResult:GetTargetID()),
        tostring(damageResult:GetGridPos()),
        tostring(damageResultIndex)
    )
end
