--[[------------------------------------------------------------------------------------------
    GuidePreviewLinkLineSystem_Render : 主动技预览阶段的划线引导system
]]
--------------------------------------------------------------------------------------------

---@class GuidePreviewLinkLineSystem_Render:ReactiveSystem
_class("GuidePreviewLinkLineSystem_Render", ReactiveSystem)
GuidePreviewLinkLineSystem_Render = GuidePreviewLinkLineSystem_Render

function GuidePreviewLinkLineSystem_Render:Constructor(world)
    ---@type MainWorld
    self._world = world
    self._fingerTweener = nil

    self._guideLineEntityArray = {}
    self._guideDotEntityArray = {}
    self._guideGridEffectEntityArray = {}

    self._showGuideMark = false

    self._guideStepEvent = nil
end

function GuidePreviewLinkLineSystem_Render:GetTrigger(world)
    local group = world:GetGroup(world.BW_WEMatchers.GuidePreviewLinkLine)
    local c = Collector:New({ group }, { "Added" })
    return c
end

function GuidePreviewLinkLineSystem_Render:Filter(entity)
    return entity:HasGuidePreviewLinkLine()
end

function GuidePreviewLinkLineSystem_Render:TearDown()
    if self._fingerTweener ~= nil then
        self._fingerTweener:Kill()
        self._fingerTweener = nil
    end
    if self._guideStepEvent ~= nil then
        GameGlobal.Timer():CancelEvent(self._guideStepEvent)
        self._guideStepEvent = nil
    end
end

function GuidePreviewLinkLineSystem_Render:ExecuteEntities(entities)
    for i = 1, #entities do
        self:OnGuidePLLPath(entities[i])
    end
end

function GuidePreviewLinkLineSystem_Render:OnGuidePLLPath(entity)
    local reBoard = self._world:GetRenderBoardEntity()

    local fingerEntity = self:_GetFingerEntity()

    ---@type GuidePreviewLinkLineComponent
    local guidePLLCmpt = reBoard:GuidePreviewLinkLine()
    ---@type GuideRefreshType
    local refreshType = guidePLLCmpt:GetGuideRefreshType()
    --Log.fatal("RefreshType",refreshType," frame",UnityEngine.Time.frameCount)

    if refreshType == GuideRefreshType.StopGuidePath then
        if self._fingerTweener ~= nil then
            self._fingerTweener:Kill()
            self._fingerTweener = nil
        end
        if self._guideStepEvent ~= nil then
            GameGlobal.Timer():CancelEvent(self._guideStepEvent)
            self._guideStepEvent = nil
        end

        ---@type LinkageRenderService
        -- local linkageRenderService = self._world:GetService("LinkageRender")
        -- linkageRenderService:DestroyAllLinkLine()
        -- linkageRenderService:DestroyAllLinkedNum()
        -- linkageRenderService:DestroyLinkedGridEffect()
        self:_DestroyGuideLinkDot()
        self:_DestroyGuideLinkLine()

        fingerEntity:SetViewVisible(false)
    elseif refreshType == GuideRefreshType.StartGuidePath then
        fingerEntity:SetViewVisible(true)
        self._showGuideMark = true
        if self._showGuideMark == true then
            local guidePath = self:_GetGuidePreviewLinkLine()
            self:_CreateGuideMarkEntity(guidePath)
            self._showGuideMark = false
        end
        self:_GuideTargetPath()
    elseif refreshType == GuideRefreshType.ShowGuideLine then
        if self._fingerTweener ~= nil then
            self._fingerTweener:Kill()
            self._fingerTweener = nil
        end

        if self._guideStepEvent ~= nil then
            GameGlobal.Timer():CancelEvent(self._guideStepEvent)
            self._guideStepEvent = nil
        end

        ---@type LinkageRenderService
        local linkageRenderService = self._world:GetService("LinkageRender")
        --linkageRenderService:DestroyAllLinkLine()
        --linkageRenderService:DestroyAllLinkedNum()
        --linkageRenderService:DestroyLinkedGridEffect()
        local guidePath = self:_GetGuidePreviewLinkLine()
        for index, value in ipairs(guidePath) do
            linkageRenderService:ShowLinkNormal(value)
        end
        fingerEntity:SetViewVisible(false)
    elseif refreshType == GuideRefreshType.RestartGuidePath then
        fingerEntity:SetViewVisible(true)
        if self._showGuideMark == true then
            local guidePath = self:_GetGuidePreviewLinkLine()
            self:_CreateGuideMarkEntity(guidePath)
            self._showGuideMark = false
        end
        self:_GuideTargetPath()
    end
end

function GuidePreviewLinkLineSystem_Render:_GuideTargetPath()
    local reBoard = self._world:GetRenderBoardEntity()

    local fingerEntity = self:_GetFingerEntity()
    local hasView = self:_HasView(fingerEntity)
    if hasView == false then
        return
    end

    ---@type GuidePreviewLinkLineComponent
    local guidePLLCmpt = reBoard:GuidePreviewLinkLine()
    local guidePath = guidePLLCmpt:GetGuidePLLPath()

    local guidePointCount = #guidePath
    local duration = guidePointCount * BattleConst.GuidePathInternal

    self:_StartDoTweenGuide(guidePath, duration)

    ---启动一个监听event，每隔一段时间执行一次引导
    if self._guideStepEvent == nil then
        self._guideStepEvent =
            GameGlobal.Timer():AddEventTimes(
                duration * 1000 + BattleConst.GuidePathStepWaitTime,
                TimerTriggerCount.Infinite,
                function()
                    local refreshType = guidePLLCmpt:GetGuideRefreshType()
                    if refreshType == GuideRefreshType.StartGuidePath or refreshType == GuideRefreshType.RestartGuidePath then
                        self:_OnGuideComplete()
                        self:_StartDoTweenGuide(guidePath, duration)
                    end
                end
            )
    end
end

function GuidePreviewLinkLineSystem_Render:_StartDoTweenGuide(guidePath, duration)
    local fingerEntity = self:_GetFingerEntity()
    fingerEntity:SetViewVisible(true)
    ---@type ViewComponent
    local viewCmpt = fingerEntity:View()
    ---@type Transform
    local fingerTrans = viewCmpt:GetGameObject().transform
    local rectTrans = viewCmpt:GetGameObject():GetComponent("RectTransform")
    if rectTrans ~= nil then
        rectTrans:SetAsLastSibling()
    end

    local guideHudPosArray = self:_CalcGuideFingerPath(guidePath)
    fingerTrans.position = guideHudPosArray[1]
    self._fingerTweener =
        fingerTrans:DOPath(guideHudPosArray, duration):SetEase(DG.Tweening.Ease.Linear):OnWaypointChange(
            function(waypointIndex)
                local guidePathIndex = waypointIndex + 1
                self:_OnGuideWayPointChange(guidePathIndex)
            end
        )
end

function GuidePreviewLinkLineSystem_Render:_OnGuideWayPointChange(guidePosIndex)
    --Log.fatal("guidePosIndex",guidePosIndex,UnityEngine.Time.frameCount)
    if guidePosIndex <= 1 then
        return
    end

    local guidePath = self:_GetGuidePreviewLinkLine()
    local headPos = guidePath[guidePosIndex - 1]
    local endPos = guidePath[guidePosIndex]

    if endPos == nil then
        return
    end

    ---@type UtilDataServiceShare
    local utilData = self._world:GetService("UtilData")
    local pieceType = utilData:FindPieceElement(endPos)

    ---@type LinkageRenderService
    local linkageRenderService = self._world:GetService("LinkageRender")
    linkageRenderService:CreateLineRender(headPos, endPos, guidePosIndex, endPos, nil, pieceType)
    --linkageRenderService:CreateLinkDot(endPos,guidePosIndex,guidePosIndex)
    linkageRenderService:ShowLinkDot(endPos)
    --linkageRenderService:ShowSelectGridEffect(endPos)
end

function GuidePreviewLinkLineSystem_Render:_OnGuideComplete()
    Log.notice("_OnGuideComplete", UnityEngine.Time.frameCount)
    local guidePath = self:_GetGuidePreviewLinkLine()
    if self._showGuideMark == true then
        self:_CreateGuideMarkEntity(guidePath)
        self._showGuideMark = false
    end

    local fingerEntity = self:_GetFingerEntity()
    fingerEntity:SetViewVisible(false)
    fingerEntity:View():GetGameObject():SetActive(false)

    ---@type LinkageRenderService
    local linkageRenderService = self._world:GetService("LinkageRender")
    linkageRenderService:DestroyAllLinkLine()
    linkageRenderService:DestroyLinkedGridEffect()

    for i = 2, #guidePath do
        linkageRenderService:HideLinkDot(guidePath[i])
    end

    self._fingerTweener:Kill()
end

function GuidePreviewLinkLineSystem_Render:_GetGuidePreviewLinkLine()
    local reBoard = self._world:GetRenderBoardEntity()

    ---@type GuidePreviewLinkLineComponent
    local guidePLLCmpt = reBoard:GuidePreviewLinkLine()
    local guidePath = guidePLLCmpt:GetGuidePLLPath()
    return guidePath
end

function GuidePreviewLinkLineSystem_Render:_GetFingerEntity()
    local fingerGroup = self._world:GetGroup(self._world.BW_WEMatchers.GuideFinger)
    local fingerEntities = fingerGroup:GetEntities()
    local fingerEntity = fingerEntities[1]

    return fingerEntity
end

---创建引导的细线
function GuidePreviewLinkLineSystem_Render:_CreateGuideMarkEntity(guidePath)
    local guidePathMaxCount = #guidePath
    for guidePosIndex = 2, guidePathMaxCount do
        self:_CreateGuideLinkDot(guidePath[guidePosIndex])

        local headPos = guidePath[guidePosIndex - 1]
        local endPos = guidePath[guidePosIndex]
        self:_CreateGuideLineRender(headPos, endPos, endPos)
    end
end

function GuidePreviewLinkLineSystem_Render:_HasView(e)
    local viewCmpt = e:View()
    if viewCmpt == nil then
        return false
    end

    local gameObj = viewCmpt:GetGameObject()
    if gameObj == nil then
        return false
    end

    return true
end

---计算出划线的路径点的HUD坐标值
---@param guideGridPath array 要划线的格子坐标数组
function GuidePreviewLinkLineSystem_Render:_CalcGuideFingerPath(guideGridPath)
    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")

    local fingerPath = {}
    for k, v in ipairs(guideGridPath) do
        local gridRenderPos = boardServiceRender:GridPos2RenderPos(v)
        local hudPos = self:_CalcGridHUDWorldPos(gridRenderPos)
        fingerPath[#fingerPath + 1] = hudPos
    end

    return fingerPath
end

function GuidePreviewLinkLineSystem_Render:_CalcGridHUDWorldPos(gridRenderPos)
    local camera = self._world:MainCamera():Camera()
    local screenPos = camera:WorldToScreenPoint(gridRenderPos)

    local hudCamera = self._world:MainCamera():HUDCamera()
    local hudWorldPos = hudCamera:ScreenToWorldPoint(screenPos)

    return hudWorldPos
end

function GuidePreviewLinkLineSystem_Render:_CreateGuideLinkDot(pos)
end

function GuidePreviewLinkLineSystem_Render:_DestroyGuideLinkDot()
    local guideSpotGroup = self._world:GetGroup(self._world.BW_WEMatchers.GuideSpot)
    local remove_list = {}
    for _, guideSpotEntity in ipairs(guideSpotGroup:GetEntities()) do
        table.insert(remove_list, guideSpotEntity)
    end

    for _, e in ipairs(remove_list) do
        self._world:DestroyEntity(e)
    end
end

function GuidePreviewLinkLineSystem_Render:_DestroyGuideLinkLine()
    local guideLineGroup = self._world:GetGroup(self._world.BW_WEMatchers.GuideLinkLine)
    local remove_list = {}
    for _, guideSpotEntity in ipairs(guideLineGroup:GetEntities()) do
        table.insert(remove_list, guideSpotEntity)
    end

    for _, e in ipairs(remove_list) do
        self._world:DestroyEntity(e)
    end
end

function GuidePreviewLinkLineSystem_Render:_CreateGuideLineRender(headGridPos, endGridPos, gridPos)
    ---@type RenderEntityService
    local sEntity = self._world:GetService("RenderEntity")
    ---@type Entity
    local linkLineRenderEntity = sEntity:CreateRenderEntity(EntityConfigIDRender.GuideLinkLine)

    --linkLineRenderEntity:SetGridLocation(gridPos, Vector2(1, 0))
    linkLineRenderEntity:SetLocation(gridPos, Vector2(1, 0))
    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    local headRenderPos = boardServiceRender:GridPos2RenderPos(headGridPos)
    local endRenderPos = boardServiceRender:GridPos2RenderPos(endGridPos)

    local lineHeight = 0.01
    headRenderPos.y = lineHeight
    endRenderPos.y = lineHeight

    linkLineRenderEntity:ReplaceLinkLineRender(headRenderPos, endRenderPos)

    return linkLineRenderEntity
end
