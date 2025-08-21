--[[
    弹道飞向施法者的技能表现，在版边则不播放
]]
require "play_skill_phase_base_r"

---@class PlaySkillPhaseBulletFlyCaster:PlaySkillPhaseBase
_class("PlaySkillPhaseBulletFlyCaster", PlaySkillPhaseBase)
PlaySkillPhaseBulletFlyCaster = PlaySkillPhaseBulletFlyCaster

function PlaySkillPhaseBulletFlyCaster:Constructor()
    self._directions = {
        [1] = Vector3(0, 0, 1), --上
        [2] = Vector3(1, 0, 0), --右
        [3] = Vector3(0, 0, -1), --下
        [4] = Vector3(-1, 0, 0), --左
        [5] = Vector3.New(-1, 0, 1), --左上
        [6] = Vector3.New(-1, 0, -1), --左下
        [7] = Vector3.New(1, 0, 1), --右上
        [8] = Vector3.New(1, 0, -1), --右下
    }
end

---@param casterEntity Entity
---@param phaseParam PlaySkillParamBulletFlyToCaster
function PlaySkillPhaseBulletFlyCaster:PlayFlight(TT, casterEntity, phaseParam)
    local cfgDir = phaseParam:GetDirection()
    local casterGridPos = casterEntity:GetGridPosition()
    local bodyArea = casterEntity:BodyArea():GetArea()

    if self:IsCloseToEdge(casterGridPos, bodyArea, cfgDir) then
        Log.notice("在版边，没有弹道: ", cfgDir)
        return
    end

    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()
    local skillResult = skillEffectResultContainer
    ---@type SkillScopeResult
    local scopeResult = skillEffectResultContainer:GetScopeResult()
    local skillRange = scopeResult:GetAttackRange()
    local targets = scopeResult:GetTargetIDs()

    local edgeDistance = phaseParam:GetDistanceToEdge()
    local flyDuration = phaseParam:GetBulletDuration()
    local casterPos = casterEntity:View():GetGameObject().transform.position

    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    local boardRect = boardServiceRender:GetBoardRect()
    local startPos, speed = self:_GetStartPosAndSpeedByDir(cfgDir, casterPos, boardRect, edgeDistance, flyDuration)
    local yieldScedule = self:_GetBulletScheduleByDir(casterEntity, cfgDir, startPos, speed, targets)

    ---@type EffectService
    local eftSvc = self._world:GetService("Effect")

    local effectDir = self._directions[cfgDir]

    local bornEffect = eftSvc:CreatePositionEffect(phaseParam:GetBornEffect(), startPos)
    bornEffect:SetDirection(effectDir)
    YIELD(TT, phaseParam:GetBornDuration())
    bornEffect:SetViewVisible(false)

    local bulletEffect = eftSvc:CreatePositionEffect(phaseParam:GetBulletEffect(), startPos)
    bulletEffect:SetDirection(effectDir)

    while (not bulletEffect:HasView()) do
        YIELD(TT)
    end

    bulletEffect:View():GetGameObject().transform:DOMove(casterPos, flyDuration / 1000):SetEase(DG.Tweening.Ease.Linear)

    table.sort(
        yieldScedule,
        function(a, b)
            return a.beHitDelay < b.beHitDelay
        end
    )

    local beHitTask = {}
    if #yieldScedule > 0 then
        ---@type PlaySkillService
        local playSkillSvc = self._world:GetService("PlaySkill")

        local timer = 0
        local idx = 1
        ---@type TimeService
        local timeSvc = self._world:GetService("Time")

        while timer < flyDuration do
            if idx <= #yieldScedule then
                local scedule = yieldScedule[idx]
                if timer > scedule.beHitDelay then
                    ---调用统一处理被击的逻辑
                    local beHitParam = HandleBeHitParam:New()
                        :SetHandleBeHitParam_CasterEntity(casterEntity)
                        :SetHandleBeHitParam_TargetEntity(scedule.beHitEntity)
                        :SetHandleBeHitParam_HitAnimName(phaseParam:GetBeHitAnim())
                        :SetHandleBeHitParam_HitEffectID(phaseParam:GetBeHitEffect())
                        :SetHandleBeHitParam_DamageInfo(scedule.damageInfo:GetDamageInfo(1))
                        :SetHandleBeHitParam_DamagePos(scedule.beHitEntity:GetGridPosition())
                        :SetHandleBeHitParam_HitTurnTarget(phaseParam:GetTurnToTarget())
                        :SetHandleBeHitParam_DeathClear(phaseParam:GetDeathClear())
                        :SetHandleBeHitParam_IsFinalHit(skillEffectResultContainer:IsFinalAttack())
                        :SetHandleBeHitParam_SkillID(skillEffectResultContainer:GetSkillID())


                    beHitTask[#beHitTask + 1] = GameGlobal.TaskManager():CoreGameStartTask(
                        playSkillSvc.HandleBeHit,
                        playSkillSvc,
                        beHitParam
                    )
                    idx = idx + 1
                end
            end
            timer = timer + timeSvc:GetDeltaTimeMs()
            YIELD(TT)
        end
        bulletEffect:SetViewVisible(false)
        self._world:DestroyEntity(bulletEffect)
    else
        YIELD(TT, flyDuration)
        bulletEffect:SetViewVisible(false)
        self._world:DestroyEntity(bulletEffect)
    end

    while not TaskHelper:GetInstance():IsAllTaskFinished(beHitTask) do
        YIELD(TT)
    end
end

--是否靠近版边
function PlaySkillPhaseBulletFlyCaster:IsCloseToEdge(gridPos, bodeArea, direction)
    ---@type UtilDataServiceShare
    local utilDataSvc = self._world:GetService("UtilData")
    local boardMaxX = utilDataSvc:GetCurBoardMaxX()
    local boardMaxY = utilDataSvc:GetCurBoardMaxY()
    for _, offset in ipairs(bodeArea) do
        local pos = gridPos + offset
        if direction == 1 then
            --上
            if pos.y >= boardMaxY then
                return true
            end
        elseif direction == 2 then
            --右
            if pos.x >= boardMaxX then
                return true
            end
        elseif direction == 3 then
            --下
            if pos.y <= 1 then
                return true
            end
        elseif direction == 4 then
            --左
            if pos.x <= 1 then
                return true
            end
        elseif direction == 5 then
            if pos.x <= 1 or pos.y >= boardMaxY then
                return true
            end
        elseif direction == 6 then
            if pos.x <= 1 or pos.y <= 1 then
                return true
            end
        elseif direction == 7 then
            if pos.x >= boardMaxX or pos.y >= boardMaxY then
                return true
            end
        elseif direction == 8 then
            if pos.x >= boardMaxX or pos.y <= 1 then
                return true
            end
        end
    end
    return false
end

---@param dir number TODO: replace it with an enum
---@param casterPos Vector3 <-v3居然没有类型注释
---@param boardRect UnityEngine.Rect
---@param edgeDistance number
---@param flyDuration number
function PlaySkillPhaseBulletFlyCaster:_GetStartPosAndSpeedByDir(dir, casterPos, boardRect, edgeDistance, flyDuration)
    local startPos, speed
    if dir == 1 then
        startPos = Vector3.New(casterPos.x, 0, boardRect.w + edgeDistance)
        speed = (boardRect.w + edgeDistance - casterPos.z) / flyDuration
    elseif dir == 2 then
        startPos = Vector3.New(boardRect.z + edgeDistance, 0, casterPos.z)
        speed = (boardRect.z + edgeDistance - casterPos.x) / flyDuration
    elseif dir == 3 then
        startPos = Vector3.New(casterPos.x, 0, boardRect.y - edgeDistance)
        speed = (casterPos.z - boardRect.y + edgeDistance) / flyDuration
    elseif dir == 4 then
        startPos = Vector3.New(boardRect.x - edgeDistance, 0, casterPos.z)
        speed = (casterPos.x - boardRect.x + edgeDistance) / flyDuration
    elseif dir == 5 then
        startPos = Vector3.New(boardRect.x - edgeDistance, 0, boardRect.w + edgeDistance)
        local distance = math.sqrt(((casterPos.x - boardRect.x + edgeDistance) ^ 2) + ((boardRect.w + edgeDistance - casterPos.z) ^ 2))
        speed = distance / flyDuration
    elseif dir == 6 then
        startPos = Vector3.New(boardRect.x - edgeDistance, 0, boardRect.y - edgeDistance)
        local distance = math.sqrt(((casterPos.x - boardRect.x + edgeDistance) ^ 2) + ((casterPos.z - boardRect.y + edgeDistance) ^ 2))
        speed = distance / flyDuration
    elseif dir == 7 then
        startPos = Vector3.New(boardRect.z + edgeDistance, 0, boardRect.w + edgeDistance)
        local distance = math.sqrt(((boardRect.z + edgeDistance - casterPos.x) ^ 2) + ((boardRect.w + edgeDistance - casterPos.z) ^ 2))
        speed = distance / flyDuration
    elseif dir == 8 then
        startPos = Vector3.New(boardRect.z + edgeDistance, 0, boardRect.y - edgeDistance)
        local distance = math.sqrt(((boardRect.z + edgeDistance - casterPos.x) ^ 2) + ((casterPos.z - boardRect.y + edgeDistance) ^ 2))
        speed = distance / flyDuration
    end

    return startPos, speed
end

function PlaySkillPhaseBulletFlyCaster:_IsTargetHitByThisBullet(dir, area, targetPos)
    if dir == 1 then
        return targetPos.x == area.x and targetPos.y > area.y
    elseif dir == 2 then
        return targetPos.y == area.y and targetPos.x > area.x
    elseif dir == 3 then
        return targetPos.x == area.x and targetPos.y < area.y
    elseif dir == 4 then
        return targetPos.y == area.y and targetPos.x < area.x
    elseif dir == 5 then
        return targetPos.x < area.x and targetPos.y > area.y
    elseif dir == 6 then
        return targetPos.x < area.x and targetPos.y < area.y
    elseif dir == 7 then
        return targetPos.x > area.x and targetPos.y > area.y
    elseif dir == 8 then
        return targetPos.x > area.x and targetPos.y < area.y
    end
end

function PlaySkillPhaseBulletFlyCaster:_CalculateHitDelay(dir, startPos, worldPos, speed)
    if dir == 1 then
        return (startPos.z - worldPos.z) / speed
    elseif dir == 2 then
        return (startPos.x - worldPos.x) / speed
    elseif dir == 3 then
        return (worldPos.z - startPos.z) / speed
    elseif dir == 4 then
        return (worldPos.x - startPos.x) / speed
    else
        local dis = math.sqrt((startPos.z - worldPos.z) ^ 2 + (startPos.x - worldPos.x) ^ 2)
        return dis / speed
    end
end

---@param casterEntity Entity
---@param dir number TODO: replace it with an enum
---@param startPos Vector3
---@param speed number
---@param targets number[]
function PlaySkillPhaseBulletFlyCaster:_GetBulletScheduleByDir(casterEntity, dir, startPos, speed, targets)
    if (not targets) or (#targets == 0) then
        return {}
    end

    local casterGridPos = casterEntity:GetGridPosition()
    local bodyArea = casterEntity:BodyArea():GetArea()
    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()

    local yieldSchedule = {}

    if dir == 2 then
        Log.error()
    end

    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    for _, id in ipairs(targets) do
        local target = self._world:GetEntityByID(id)
        local defenderPos = target:GetGridPosition()
        local delay = 0
        for _, offset in ipairs(bodyArea) do
            local found = false
            local area = casterGridPos + offset
            for __, defenderOffset in ipairs(target:BodyArea():GetArea()) do
                local targetPos = defenderOffset + defenderPos
                if self:_IsTargetHitByThisBullet(dir, area, targetPos) then
                    local worldPos = boardServiceRender:GridPos2RenderPos(targetPos)
                    local curDelay = (startPos.z - worldPos.z) / speed
                    local deltaDelay = curDelay - delay
                    delay = curDelay
                    local damageInfo = skillEffectResultContainer:GetEffectResultByPos(SkillEffectType.Damage, targetPos)
                    if damageInfo == nil then
                        Log.fatal("严重错误，找到目标，但是没有伤害，位置：", targetPos)
                    end
                    --找到弹道可以打到的目标
                    yieldSchedule[#yieldSchedule + 1] = {
                        beHitDelay = deltaDelay,
                        beHitEntity = target,
                        damageInfo = damageInfo
                    }
                    found = true
                    break
                end
            end
            if found then
                break
            end
        end
    end

    return yieldSchedule
end
