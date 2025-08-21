require "play_skill_phase_base_r"
---@class PlaySkillGridSpreadPhase: PlaySkillPhaseBase
_class("PlaySkillGridSpreadPhase", PlaySkillPhaseBase)
PlaySkillGridSpreadPhase = PlaySkillGridSpreadPhase

---@class SkillPhaseGridSpreadShapeType
local SkillPhaseGridSpreadShapeType = {
    diamond = 1,
    square = 2
}
_enum("SkillPhaseGridSpreadShapeType", SkillPhaseGridSpreadShapeType)

function PlaySkillGridSpreadPhase:PlayFlight(TT, casterEntity, phaseParam)
    ---@type SkillPhaseGridSpreadParam
    local gridSpreadParam = phaseParam
    local gridEffectID = gridSpreadParam:GetGridEffectID()
    local hitEffectID = gridSpreadParam:GetHitEffectID()
    local hitAnimationName = gridSpreadParam:GetHitAnimationName()
    local spreadIntervalTime = gridSpreadParam:GetSpreadIntervalTime()
    local spreadLayerCount = gridSpreadParam:GetSpreadLayerCount()
    local spreadShape = gridSpreadParam:GetSpreadShape()

    ---@type  UnityEngine.Vector2
    local castPos = casterEntity:GridLocation().Position

    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()
    local skillID = skillEffectResultContainer:GetSkillID()
    ---@type SkillScopeResult
    local scopeResult = skillEffectResultContainer:GetScopeResult()
    local gridDataArray = scopeResult:GetWholeGridRange()

    local layerGridList = self:_SortGrid(gridDataArray, castPos, spreadLayerCount, spreadShape)

    local isFinalAttack = skillEffectResultContainer:IsFinalAttack()
    if isFinalAttack then
        local damageResultArray = skillEffectResultContainer:GetEffectResultsAsArray(SkillEffectType.Damage)
        local targetEntityID = self:_SortDistanceForFinalAttack(castPos, damageResultArray)
        skillEffectResultContainer:SetFinalAttackEntityID(targetEntityID)
    end

    for i = 1, #layerGridList do
        local gridList = layerGridList[i]
        for j = 1, #gridList do
            local gridPos = gridList[j]
            local dirX = gridPos.x - castPos.x
            local dirY = gridPos.y - castPos.y
            if dirX > 0 then
                dirX = 1
            elseif dirX < 0 then
                dirX = -1
            end
            if dirY > 0 then
                dirY = 1
            elseif dirY < 0 then
                dirY = -1
            end
            local dir = Vector2(dirX, dirY)
            self._world:GetService("Effect"):CreateWorldPositionDirectionEffect(gridEffectID, gridPos, dir)

            local damageResult = skillEffectResultContainer:GetEffectResultByPos(SkillEffectType.Damage, gridPos)
            if damageResult then
                self:_ShowDamage(
                    damageResult,
                    skillEffectResultContainer,
                    hitAnimationName,
                    hitEffectID,
                    casterEntity,
                    gridPos,
                    gridSpreadParam:HitTurnToTarget(),
                    skillID
                )
            end
        end
        YIELD(TT, spreadIntervalTime)
    end
end

function PlaySkillGridSpreadPhase:_SortGrid(gridList, casterPos, spreadLayerCount, spreadShape)
    if spreadShape == SkillPhaseGridSpreadShapeType.diamond then
        local res = {}
        local maxLayer = 1
        for i = 1, #gridList do
            local grid = gridList[i]
            local layerIndex = math.abs(grid.x - casterPos.x) + math.abs(grid.y - casterPos.y)
            if spreadLayerCount > 1 then
                layerIndex = math.ceil(layerIndex / spreadLayerCount)
            end
            if not res[layerIndex] then
                res[layerIndex] = {}
            end
            local layerGridList = res[layerIndex]
            layerGridList[#layerGridList + 1] = grid
            if layerIndex > maxLayer then
                maxLayer = layerIndex
            end
        end
        for j = 1, maxLayer do
            if not res[j] then
                res[j] = {}
            end
        end
        return res
    elseif spreadShape == SkillPhaseGridSpreadShapeType.square then
        ---待有需求扩展
        return {}
    end
end

function PlaySkillGridSpreadPhase:_ShowDamage(
    damageResult,
    skillEffectResultContainer,
    hitAnimName,
    hitEffectID,
    casterEntity,
    gridPos,
    hitTurnToTarget,
    skillID)
    local targetEntityID = damageResult:GetTargetID()
    local targetEntity = self._world:GetEntityByID(targetEntityID)
    if targetEntity ~= nil then
        local targetDamage = damageResult:GetDamageInfo(1)

        ---调用统一处理被击的逻辑
        local beHitParam = HandleBeHitParam:New()
            :SetHandleBeHitParam_CasterEntity(casterEntity)
            :SetHandleBeHitParam_TargetEntity(targetEntity)
            :SetHandleBeHitParam_HitAnimName(hitAnimName)
            :SetHandleBeHitParam_HitEffectID(hitEffectID)
            :SetHandleBeHitParam_DamageInfo(targetDamage)
            :SetHandleBeHitParam_DamagePos(gridPos)
            :SetHandleBeHitParam_HitTurnTarget(hitTurnToTarget)
            :SetHandleBeHitParam_DeathClear(false)
            :SetHandleBeHitParam_IsFinalHit(skillEffectResultContainer:IsFinalAttack())
            :SetHandleBeHitParam_SkillID(skillID)

        GameGlobal.TaskManager():CoreGameStartTask(
            self:SkillService().HandleBeHit,
            self:SkillService(),
            beHitParam
        )
    end
end

---按照距离玩家远近来判定最后一击
---返回最远的那个目标的ID
function PlaySkillGridSpreadPhase:_SortDistanceForFinalAttack(castPos, damageResultArray)
    local function CmpDistancefunc(res1, res2)
        local dis1 = math.abs(castPos.x - res1:GetGridPos().x) + math.abs(castPos.y - res1:GetGridPos().y)
        local dis2 = math.abs(castPos.x - res2:GetGridPos().x) + math.abs(castPos.y - res2:GetGridPos().y)

        return dis1 > dis2
    end
    table.sort(damageResultArray, CmpDistancefunc)

    for _, v in ipairs(damageResultArray) do
        ---@type SkillDamageEffectResult
        local result = v
        local targetEntityID = result:GetTargetID()
        local targetEntity = self._world:GetEntityByID(targetEntityID)
        if targetEntity:HasDeadFlag() then
            return targetEntityID
        end
    end
end
