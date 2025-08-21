require "play_skill_phase_base_r"
_class("PlaySkillFlashKnifeAndLinePhase", PlaySkillPhaseBase)
PlaySkillFlashKnifeAndLinePhase = PlaySkillFlashKnifeAndLinePhase

function PlaySkillFlashKnifeAndLinePhase:PlayFlight(TT, casterEntity, phaseParam)
    ---@type SkillPhaseFlashKnifeAndLineParam
    local param = phaseParam
    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()
    --提取施法位置
    ---@type  UnityEngine.Vector2
    --local castPos = casterEntity:Location().Position
    local castPos = casterEntity:GridLocation().Position
    ---@param worldPos UnityEngine.Vector3
    local worldPos = boardServiceRender:GridPos2RenderPos(castPos)
    ---@type SkillScopeResult
    local scope = skillEffectResultContainer:GetScopeResult()
    ---攻击范围
    local gridRange = scope:GetAttackRange()
    ---攻击点对应的伤害数字
    local gridData = skillEffectResultContainer:GetAttackRange()
    ---type Entity[]
    self._LineEffect = {}
    ---@type EffectService
    local effectService = self._world:GetService("Effect")
    casterEntity:SetAnimatorControllerTriggers({param:GetAnimationName()})
    local targetList, maxLength = self:_GetFlyTargetPos(gridRange, castPos)
    self._targetList = targetList
    YIELD(TT)
    self:_CreateFlashKnife(targetList, castPos, param)
    local knifeFylTaskID =
        GameGlobal.TaskManager():CoreGameStartTask(
        self._StartKnifeFly,
        self,
        casterEntity,
        castPos,
        targetList,
        maxLength,
        param,
        castPos
    )
    local flashLineTaskID = GameGlobal.TaskManager():CoreGameStartTask(self._StartFlashLine, self, param, castPos)
end
---@param phaseParam SkillPhaseFlashKnifeAndLineParam
function PlaySkillFlashKnifeAndLinePhase:_CreateFlashKnife(targets, worldPos, phaseParam)
    local effectID = phaseParam:GetFlashKnifeEffect()
    for k, v in pairs(targets) do
        if v.gridpos ~= nil then
            local effectEntity =
                self._world:GetService("Effect"):CreateWorldPositionDirectionEffect(effectID, worldPos, v.direction)
            v.entity = effectEntity
        end
    end
end

---@param phaseParam SkillPhaseFlashKnifeAndLineParam
function PlaySkillFlashKnifeAndLinePhase:_StartKnifeFly(
    TT,
    castEntity,
    worldPos,
    targets,
    maxLength,
    phaseParam,
    castPos)
    local flyOneGridMs = phaseParam:GetFlyOneGridMs()
    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    YIELD(TT)
    local atklist = ArrayList:New()
    for k, v in pairs(targets) do
        local effectEntity = v.entity
        if effectEntity ~= nil then
            local gridpos = v.gridpos
            local go = effectEntity:View():GetGameObject()
            local tran = go.transform
            v.tran = go.transform

            ---@type Vector3
            local gridWorldpos = boardServiceRender:GridPos2RenderPos(gridpos)
            local disx = math.abs(gridpos.x - castPos.x)
            local disy = math.abs(gridpos.y - castPos.y)
            local dis = math.max(disx, disy)

            Log.notice(
                "[skill] PlaySkillService:_StartKnifeFly from ",
                castPos.x,
                castPos.y,
                " to ",
                gridpos.x,
                gridpos.y
            )
            self:_KnifeMove(go, tran, gridWorldpos, dis, flyOneGridMs)
        end
    end
    self:_CheckFlyAttack(TT, targets, maxLength, boardServiceRender, castEntity, phaseParam, atklist)
end
---@param phaseParam SkillPhaseFlashKnifeAndLineParam
---@param boardServiceRender BoardServiceRender
function PlaySkillFlashKnifeAndLinePhase:_CheckFlyAttack(
    TT,
    targets,
    maxLength,
    boardServiceRender,
    casterEntity,
    phaseParam,
    atklist)
    local flyOneGridMs = phaseParam:GetFlyOneGridMs()
    local hitAnimName = phaseParam:GetHitAnimationName()
    local hitEffectID = phaseParam:GetHitEffect()
    local totaltime = self:_GetFlyTime(maxLength, flyOneGridMs)
    local endtime = GameGlobal:GetInstance():GetCurrentTime() + totaltime

    while GameGlobal:GetInstance():GetCurrentTime() < endtime do
        for k, v in pairs(targets) do
            local effectEntity = v.entity
            if effectEntity ~= nil then
                local tran = v.tran
                local flypos = boardServiceRender:BoardRenderPos2GridPos(tran.position)
                if v.flypos ~= flypos then
                    self:_HandlePlayFlyAttack(TT, casterEntity, flypos, hitAnimName, hitEffectID, atklist)
                    v.flypos = flypos
                end
            end
        end
        YIELD(TT)
    end
end
---@param phaseParam SkillPhaseFlashKnifeAndLineParam
function PlaySkillFlashKnifeAndLinePhase:_StartFlashLine(TT, phaseParam, worldPos)
    local effectFlashLine = phaseParam:GetFlashLineEffect()
    for k, v in pairs(self._targetList) do
        if v.gridpos ~= nil then
            local effectEntity = self._world:GetService("Effect"):CreateWorldPositionEffect(effectFlashLine, worldPos)
            v.flashLineEntity = effectEntity
        end
    end
    YIELD(TT)
    local drawLineTaskList = {}
    for k, v in pairs(self._targetList) do
        if v.gridpos ~= nil then
            local taskID =
                GameGlobal.TaskManager():CoreGameStartTask(
                self._LineMove,
                self,
                v,
                phaseParam:GetLineFlyOneGridMs(),
                phaseParam:GetFlashOneGridLinePoint(),
                phaseParam:GetFlashLineWidth(),
                phaseParam:GetFlashLineHeight()
            )
            table.insert(drawLineTaskList, taskID)
        end
    end
end

function PlaySkillFlashKnifeAndLinePhase:_GetFlyTime(maxLength, flyOneGridMs)
    return flyOneGridMs * maxLength
end

function PlaySkillFlashKnifeAndLinePhase:_GetFlyTargetPos(chainGrid, castPos)
    local leftup = nil
    local leftbottom = nil
    local rightbottom = nil
    local rightup = nil
    local up = nil
    local bottom = nil
    local right = nil
    local left = nil
    local maxLength = 0
    local leftUpList = {}
    local leftBottomList = {}
    local rightBottomList = {}
    local rightUpList = {}
    local upList = {}
    local bottomList = {}
    local rightList = {}
    local leftList = {}
    for i, pos in pairs(chainGrid) do
        local dis = pos - castPos
        if (math.abs(dis.x) > maxLength) then
            maxLength = math.abs(dis.x)
        end
        if (math.abs(dis.y) > maxLength) then
            maxLength = math.abs(dis.y)
        end
        if dis.x > 0 and dis.y < 0 then
            table.insert(rightBottomList, pos)
            if rightbottom == nil or rightbottom.x < pos.x then
                rightbottom = pos
            end
        elseif dis.x < 0 and dis.y < 0 then
            table.insert(leftBottomList, pos)
            if leftbottom == nil or leftbottom.x > pos.x then
                leftbottom = pos
            end
        elseif dis.x < 0 and dis.y > 0 then
            table.insert(leftUpList, pos)
            if leftup == nil or leftup.x > pos.x then
                leftup = pos
            end
        elseif dis.x > 0 and dis.y > 0 then
            table.insert(rightUpList, pos)
            if rightup == nil or rightup.x < pos.x then
                rightup = pos
            end
        elseif dis.x > 0 and dis.y == 0 then
            table.insert(rightList, pos)
            if right == nil or right.x < pos.x then
                right = pos
            end
        elseif dis.x < 0 and dis.y == 0 then
            table.insert(leftList, pos)
            if left == nil or left.x > pos.x then
                left = pos
            end
        elseif dis.x == 0 and dis.y < 0 then
            table.insert(bottomList, pos)
            if bottom == nil or bottom.y > pos.y then
                bottom = pos
            end
        elseif dis.x == 0 and dis.y > 0 then
            table.insert(upList, pos)
            if up == nil or up.y < pos.y then
                up = pos
            end
        end
    end

    table.sort(
        upList,
        function(pos1, pos2)
            return pos1.y < pos2.y
        end
    )
    table.sort(
        bottomList,
        function(pos1, pos2)
            return pos1.y > pos2.y
        end
    )
    table.sort(
        rightList,
        function(pos1, pos2)
            return pos1.x < pos2.x
        end
    )
    table.sort(
        leftList,
        function(pos1, pos2)
            return pos1.x > pos2.x
        end
    )
    table.sort(
        leftUpList,
        function(pos1, pos2)
            return pos1.y < pos2.y
        end
    )
    table.sort(
        rightUpList,
        function(pos1, pos2)
            return pos1.y < pos2.y
        end
    )
    table.sort(
        leftBottomList,
        function(pos1, pos2)
            return pos1.y > pos2.y
        end
    )
    table.sort(
        rightBottomList,
        function(pos1, pos2)
            return pos1.y > pos2.y
        end
    )

    local targets = {
        --{gridpos = leftup,direction=Vector2(-1,1)},
        --{gridpos = leftbottom,direction=Vector2(-1,-1)},
        --{gridpos = rightbottom,direction=Vector2(1,-1)},
        --{gridpos = rightup,direction=Vector2(1,1)},
        --{gridpos = up,direction=Vector2(0,1)},
        --{gridpos = bottom,direction=Vector2(0,-1)},
        --{gridpos = right,direction=Vector2(1,0)},
        --{gridpos = left,direction=Vector2(-1,0)}
        --特效默认朝下整体旋转一下
        {gridpos = leftup, direction = Vector2(1, -1), gridList = leftUpList, strDirection = "LeftUp"},
        {gridpos = leftbottom, direction = Vector2(1, 1), gridList = leftBottomList, strDirection = "LeftBottom"},
        {gridpos = rightbottom, direction = Vector2(-1, 1), gridList = rightBottomList, strDirection = "RightBottom"},
        {gridpos = rightup, direction = Vector2(-1, -1), gridList = rightUpList, strDirection = "RightUp"},
        {gridpos = up, direction = Vector2(0, -1), gridList = upList, strDirection = "Up"},
        {gridpos = bottom, direction = Vector2(0, 1), gridList = bottomList, strDirection = "Bottom"},
        {gridpos = right, direction = Vector2(-1, 0), gridList = rightList, strDirection = "Right"},
        {gridpos = left, direction = Vector2(1, 0), gridList = leftList, strDirection = "Left"}
    }
    return targets, maxLength
end

function PlaySkillFlashKnifeAndLinePhase:_KnifeMove(go, tran, gridWorldPos, disx, flyOneGridMs)
    tran:DOMove(gridWorldPos, (disx * flyOneGridMs) / 1000.0):SetEase(DG.Tweening.Ease.InOutSine):OnComplete(
        function()
            go:SetActive(false)
        end
    )
end

function PlaySkillFlashKnifeAndLinePhase:_LineMove(TT, v, lineFlyOneGridMs, OneGridPoint, lineWidth, lineHeight)
    if v.flashLineEntity then
        local go = v.flashLineEntity:View():GetGameObject()
        local transform = go.transform
        local gameObject = GameObjectHelper.FindChild(transform, "GameObject")
        ---@type UnityEngine.LineRenderer
        local lineRender = gameObject:GetComponent("LineRenderer")
        lineRender.positionCount = (#v.gridList) * OneGridPoint
        lineRender.startWidth = lineWidth
        lineRender.endWidth = lineWidth
        local onePointTime = lineFlyOneGridMs / OneGridPoint
        local lineRenderIndex = 0
        for _, gridPos in ipairs(v.gridList) do
            local finish = false
            local pointList = self:_CalcGridLinePoint(v.strDirection, gridPos, OneGridPoint, lineHeight)
            local pointIndex = 1
            local LastTime = GameGlobal:GetInstance():GetCurrentTime()
            while not finish do
                if (GameGlobal:GetInstance():GetCurrentTime() - LastTime) >= onePointTime then
                    lineRender:SetPosition(lineRenderIndex, pointList[pointIndex])
                    lineRenderIndex = lineRenderIndex + 1
                    pointIndex = pointIndex + 1
                    LastTime = GameGlobal:GetInstance():GetCurrentTime()
                    if pointIndex > #pointList then
                        finish = true
                    end
                end
                YIELD(TT)
            end
        end
        go:SetActive(false)
    ---TODO 效果EffectEntity
    end
end

function PlaySkillFlashKnifeAndLinePhase:_HandlePlayFlyAttack(
    TT,
    casterEntity,
    flypos,
    hitAnimName,
    hitEffectID,
    atklist)
    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()
    local results = skillEffectResultContainer:GetEffectResultsAsPosDic(SkillEffectType.Damage)

    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    ---@type PlayDamageService
    local playDamageService = self._world:GetService("PlayDamage")

    for posIdx, res in pairs(results) do
        local pos = Vector2.Index2Pos(posIdx)
        if pos.x == flypos.x and pos.y == flypos.y then
            if boardServiceRender:IsInPlayerArea(pos) then
                local targetEntityID = res:GetTargetID()
                local targetEntity = self._world:GetEntityByID(targetEntityID)
                if targetEntity ~= nil then
                    local targetDamageInfo = res:GetDamageInfo(1)
                    Log.debug("[skill] PlaySkillService:_HandlePlayFlyAttack ", targetEntityID, hitAnimName)

                    local isFinalAttack = skillEffectResultContainer:IsFinalAttack()
                    if isFinalAttack == true then
                        if self._bBack ~= nil and not self._bBack then
                            isFinalAttack = false
                        end
                    end

                    ---@type ArrayList
                    if (atklist:Contains(targetEntityID) == false) then
                        --启动被击者受击动画
                        targetEntity:SetAnimatorControllerTriggers({hitAnimName})
                        atklist:PushBack(targetEntityID)
                    end

                    --启动被击者受击特效
                    self._world:GetService("Effect"):CreateEffect(hitEffectID, targetEntity)

                    --伤害飘字
                    playDamageService:AsyncUpdateHPAndDisplayDamage(targetEntity, targetDamageInfo)
                end
            end
        end
    end
end
---@param direction string
---@return number
function PlaySkillFlashKnifeAndLinePhase:_GetAngle(direction)
    local angle = 0
    if direction == "Right" then
        angle = 270
    elseif direction == "RightUp" then
        angle = 45
    elseif direction == "Up" then
        angle = 180
    elseif direction == "LeftUp" then
        angle = 135
    elseif direction == "Left" then
        angle = 90
    elseif direction == "LeftBottom" then
        angle = 225
    elseif direction == "Bottom" then
        angle = 0
    elseif direction == "RightBottom" then
        angle = 315
    end
    return angle
end

---@param direction string
---@param gridPos  Vector2
function PlaySkillFlashKnifeAndLinePhase:_CalcGridLinePoint(direction, gridPos, pointCount, lineHeight)
    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    --线比格子表面高的高度
    local angle = self:_GetAngle(direction)
    local e = self._world:GetService("Piece"):FindPieceEntity(gridPos)
    local gridLoc = e:GridLocation()
    local real_pos = boardServiceRender:GridPos2RenderPos(gridPos) + Vector3(0, gridLoc.Height + lineHeight, 0)
    local radiusStep = pointCount / 2 * 0.5
    local pointResult = {}
    for i = 1, pointCount / 2 do
        local x = Mathf.Sin(angle * Mathf.Deg2Rad) * radiusStep * i
        local y = Mathf.Cos(angle * Mathf.Deg2Rad) * radiusStep * i
        local p1 = Vector3(real_pos.x + x, real_pos.y, real_pos.z + y)
        table.insert(pointResult, p1)
        x = Mathf.Sin((angle + 180) * Mathf.Deg2Rad) * radiusStep * i
        y = Mathf.Cos((angle + 180) * Mathf.Deg2Rad) * radiusStep * i
        p1 = Vector3(real_pos.x + x, real_pos.y, real_pos.z + y)
        table.insert(pointResult, p1)
    end

    table.sort(
        pointResult,
        function(p1, p2)
            if direction == "Bottom" or direction == "RightBottom" or direction == "LeftBottom" then
                return p1.z > p2.z
            elseif direction == "Up" or direction == "LeftUp" or direction == "RightUp" then
                return p1.z < p2.z
            elseif direction == "Right" then
                return p1.x < p2.x
            elseif direction == "Left" then
                return p1.x > p2.x
            end
        end
    )
    return pointResult
end
