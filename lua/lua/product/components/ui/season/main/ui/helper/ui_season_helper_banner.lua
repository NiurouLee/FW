---@class UISeasonHelperBanner:UICustomWidget
_class("UISeasonHelperBanner", UICustomWidget)
UISeasonHelperBanner = UISeasonHelperBanner

function UISeasonHelperBanner:OnShow()
    self:InitWidget()
    --self:InitScrollView()
end
function UISeasonHelperBanner:OnHide()
    if self._scrollEvent then
        GameGlobal.Timer():CancelEvent(self._scrollEvent)
        self._scrollEvent = nil
    end
    self._matRes = {}
    if self._scrollPlayer then
        if self._scrollPlayer:IsPlaying() then
            self._scrollPlayer:Stop()
        end
    end
    self._scrollPlayer = nil
end
function UISeasonHelperBanner:SetData(tabIndex)
    if tabIndex then
        self._tabIndex = tabIndex
    else
        self._tabIndex = 1
    end
    self:InitScrollView()
end
function UISeasonHelperBanner:InitWidget()
    self._cellArea1Go = self:GetGameObject("CellArea1")
    self._cellArea2Go = self:GetGameObject("CellArea2")
    local cellGen1 = self:GetUIComponent("UISelectObjectPath","CellArea1")
    self._cellWidget1 = cellGen1:SpawnObject("UISeasonHelperBannerItem")
    local cellGen2 = self:GetUIComponent("UISelectObjectPath","CellArea2")
    self._cellWidget2 = cellGen2:SpawnObject("UISeasonHelperBannerItem")
    self._cellCanvas1 = self:GetUIComponent("CanvasGroup","CellArea1")
    self._cellCanvas2 = self:GetUIComponent("CanvasGroup","CellArea2")
    self._cellRect1 = self:GetUIComponent("RectTransform","CellArea1")
    self._cellRect2 = self:GetUIComponent("RectTransform","CellArea2")
    --self._anim = self:GetUIComponent("Animation","UISeasonHelperBanner")
    self._imageLeftGo = self:GetGameObject("ImageLeft")
    self._imageRightGo = self:GetGameObject("ImageRight")

    --
    self._rollInterval = 5000
    if not self._tabIndex then
        self._tabIndex = 1
    end
end
function UISeasonHelperBanner:ScrollToIndex(tarIdx)
    if self._count <= 1 then
        return
    end
    if self._scrollIng then
        return
    end
    local oldIndex = self._currIdx

    local tmpIdx = tarIdx
    if tmpIdx > self._count then
        self._currIdx = tmpIdx % self._count
    elseif tmpIdx <= 0 then
        self._currIdx = self._count
    else
        self._currIdx = tmpIdx
    end

    for i = 1, #self._idxItems do
        self._idxItems[i]:Flush(self._currIdx)
    end

    --设置内容，播动画
    self:_SetCellForAnim()
    self:_SetScrollCellData(self._cellWidget1,oldIndex)
    self:_SetScrollCellData(self._cellWidget2,self._currIdx)
    self:_PlayScrollAnim(self._currIdx > oldIndex)
    self:_CreateScrollEvent()
    self:_RefreshArrowBtn()
end
function UISeasonHelperBanner:ImageLeftOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.SoundDefaultClick)
    if self._count <= 1 then
        return
    end
    local tmpIdx = self._currIdx - 1
    self:ScrollToIndex(tmpIdx)
end
function UISeasonHelperBanner:ImageRightOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.SoundDefaultClick)
    if self._count <= 1 then
        return
    end
    local tmpIdx = self._currIdx + 1
    self:ScrollToIndex(tmpIdx)
end
--轮播
function UISeasonHelperBanner:InitScrollView()
    self:_SetCellForNormal()
    self._isDarging = false

    self._isScrollReady = false

    self:_CreateScrollData()
    self._currIdx = 1
    self:_CreateScrollItem()
    self:_CreateScrollEvent()
    self:_RefreshArrowBtn()
    self._isScrollReady = true
end
function UISeasonHelperBanner:_RefreshArrowBtn()
    local showLeft = true
    if self._currIdx == 1 then
        showLeft = false
    end
    local showRight = true
    if self._currIdx == self._count then
        showRight = false
    end
    self._imageLeftGo:SetActive(showLeft)
    self._imageRightGo:SetActive(showRight)
end
function UISeasonHelperBanner:_CreateScrollData()
    self._carouselTab = {}
    self._cfgTab = Cfg.cfg_season_helper {Tab = self._tabIndex}
    local count = table.count(self._cfgTab)
    count = table.count(self._cfgTab)
    self._count = count

    for i = 1, self._count do
        local cfg_item_middle = {}
        --cfg_item_middle.idx = i
        cfg_item_middle.data = self._cfgTab[i]

        table.insert(self._carouselTab, cfg_item_middle)
    end
    table.sort(self._carouselTab,function(a,b)
        if a.data.OrderInTab == b.data.OrderInTab then
            return a.data.ID < b.data.ID
        else
            return a.data.OrderInTab < b.data.OrderInTab
        end
    end)
end
function UISeasonHelperBanner:_CreateScrollItem()
    --idxUI----------------
    self._grid = self:GetUIComponent("UISelectObjectPath", "grid")
    self._grid:SpawnObjects("UISeasonHelperBannerIdxItem", self._count)
    ---@type UIIdxItem[]
    self._idxItems = self._grid:GetAllSpawnList()
    for i = 1, #self._idxItems do
        self._idxItems[i]:SetData(i, self._currIdx)
    end
    ------------------------------------------------------------------------------------------

    self._content = self:GetUIComponent("RectTransform", "Content")
    self._scroll = self:GetGameObject("scroll")
    self._height = 745--579 --593
    self._width = 1235--579 --593

    ---------------------------------------------------
    local dataCount = #self._carouselTab
    if dataCount == 0 then
        self._scroll:SetActive(false)
        return
    end
    --self:_SetScrollCellData(self._cellWidget1,1)
    --self:_SetCellForNormal()

    --
    self:_SetCellForAnim()
    self:_SetScrollCellData(self._cellWidget2,1)
    self:_PlayScrollAnim()
end
function UISeasonHelperBanner:_SetScrollCellData(cellWidget,dataIndex)
    cellWidget:SetData(
            self._carouselTab[dataIndex],
            function(cfgID)
            end,
            function(eventData)
                if self._count <= 1 then
                    return
                end
                if self._scrollIng then
                    return
                end
                self._bDragPosY = eventData.position.y
                self._bDragPosX = eventData.position.x
                self._isDarging = true
                if self._scrollEvent then
                    --拖拽中不计时
                    GameGlobal.Timer():CancelEvent(self._scrollEvent)
                    self._scrollEvent = nil
                end
            end,
            function(eventData)
                if self._count <= 1 then
                    return
                end
            end,
            function(eventData)
                if self._count <= 1 then
                    return
                end
                if not self._isDarging then
                    return
                end
                
                local triggerRange = self._width * 0.1

                local tmpIdx = self._currIdx
                local idChanged = false
                self._eDragPosY = eventData.position.y
                self._eDragPosX = eventData.position.x
                --local delta = math.abs(self._eDragPosY - self._bDragPosY)
                local delta = math.abs(self._eDragPosX - self._bDragPosX)
                if self._eDragPosX < self._bDragPosX then
                    --左滑超过1/5
                    if delta > triggerRange then
                        if tmpIdx < self._count then
                            tmpIdx = tmpIdx + 1
                            idChanged = true
                        end
                    else
                        tmpIdx = tmpIdx
                    end
                else
                    --下滑超过1/5
                    if delta > triggerRange then
                        if tmpIdx > 1 then
                            tmpIdx = tmpIdx - 1
                            idChanged = true
                        end
                    else
                        tmpIdx = tmpIdx
                    end
                end
                local newIdx = tmpIdx
                if tmpIdx > self._count then
                    newIdx = tmpIdx % self._count
                elseif tmpIdx <= 0 then
                    newIdx = self._count
                else
                    newIdx = tmpIdx
                end
                self._isDarging = false
                if idChanged then
                    self:ScrollToIndex(newIdx)
                else
                    self:_CreateScrollEvent()
                end
            end
        )
end
-- function UISeasonHelperBanner:_SetScrollCellData(cellWidget,dataIndex)
--     cellWidget:SetData(
--             self._carouselTab[dataIndex],
--             function(cfgID)
--             end,
--             function(eventData)
--                 if self._count <= 1 then
--                     return
--                 end
--                 if self._scrollIng then
--                     return
--                 end
--                 self._bDragPosY = eventData.position.y
--                 self._isDarging = true
--                 if self._scrollEvent then
--                     --拖拽中不计时
--                     GameGlobal.Timer():CancelEvent(self._scrollEvent)
--                     self._scrollEvent = nil
--                 end
--             end,
--             function(eventData)
--                 if self._count <= 1 then
--                     return
--                 end
--             end,
--             function(eventData)
--                 if self._count <= 1 then
--                     return
--                 end
--                 if not self._isDarging then
--                     return
--                 end
                
--                 local triggerRange = self._height * 0.1

--                 local tmpIdx = self._currIdx
--                 local idChanged = false
--                 self._eDragPosY = eventData.position.y
--                 local delta = math.abs(self._eDragPosY - self._bDragPosY)
--                 if self._eDragPosY > self._bDragPosY then
--                     --上滑超过1/5
--                     if delta > triggerRange then
--                         tmpIdx = tmpIdx + 1
--                         idChanged = true
--                     else
--                         tmpIdx = tmpIdx
--                     end
--                 else
--                     --下滑超过1/5
--                     if delta > triggerRange then
--                         tmpIdx = tmpIdx - 1
--                         idChanged = true
--                     else
--                         tmpIdx = tmpIdx
--                     end
--                 end
--                 local newIdx = tmpIdx
--                 if tmpIdx > self._count then
--                     newIdx = tmpIdx % self._count
--                 elseif tmpIdx <= 0 then
--                     newIdx = self._count
--                 else
--                     newIdx = tmpIdx
--                 end
--                 self._isDarging = false
--                 if idChanged then
--                     self:ScrollToIndex(newIdx)
--                 else
--                     self:_CreateScrollEvent()
--                 end
--             end
--         )
-- end

function UISeasonHelperBanner:_CreateScrollEvent()
    do return end
    local deltaTime = self._rollInterval
    local dir = 1

    if self._scrollEvent then
        GameGlobal.Timer():CancelEvent(self._scrollEvent)
        self._scrollEvent = nil
    end

    if self._count > 1 then
        self._scrollEvent =
            GameGlobal.Timer():AddEventTimes(
            deltaTime,
            TimerTriggerCount.Infinite,
            function()
                if not self._isDarging then
                    local idx = self._currIdx
                    if dir == 1 then
                        idx = self._currIdx + 1
                    else
                        idx = self._currIdx - 1
                    end
                    if idx < 1 then
                        idx = self._count
                    elseif idx > self._count then
                        idx = 1
                    end
                    --self._currIdx = idx
                    for i = 1, #self._idxItems do
                        self._idxItems[i]:Flush(idx)
                    end
                    self:ScrollToIndex(idx)
                end
            end
        )
    end
end
function UISeasonHelperBanner:_SetCellForNormal()
    self._cellArea1Go:SetActive(true)
    self._cellArea2Go:SetActive(false)
    self._cellCanvas1.alpha = 1
    self._cellRect1.anchoredPosition = Vector2(0,0)
    self._cellRect2.anchoredPosition = Vector2(0,0)
end
function UISeasonHelperBanner:_SetCellForAnim()
    self._cellArea1Go:SetActive(true)
    self._cellArea2Go:SetActive(true)
    self._cellRect1.anchoredPosition = Vector2(0,0)
    self._cellRect2.anchoredPosition = Vector2(0,0)
end
function UISeasonHelperBanner:OnUpdate(deltaTimeMS)
    if self._isScrollReady then
        if self._count <= 1 then
            return
        end
    end
end
function UISeasonHelperBanner:_PlayScrollAnim(bDown)
    -- local anim = self._anim
    -- local animName = "uieff_UISeasonHelperBanner_cellarea1_upout"
    -- if not bDown then
    --     animName = "uieff_UISeasonHelperBanner_cellarea1_downout"
    -- end
    -- if self._scrollPlayer then
    --     if self._scrollPlayer:IsPlaying() then
    --         self._scrollPlayer:Stop()
    --     end
    --     self._scrollPlayer = nil
    -- end
    -- self._scrollIng = true
    -- local player = EZTL_Player:New()
    -- local tl =
    --     EZTL_Sequence:New(
    --     {
    --         EZTL_PlayAnimation:New(anim, animName),
    --         EZTL_Callback:New(
    --             function()
    --                 self:_SetCellForNormal()
    --                 self:_SetScrollCellData(self._cellWidget1,self._currIdx)
    --                 self._scrollIng = false
    --             end
    --         ),
    --     },
    --     "动效"
    -- )
    -- player:Play(tl)
    -- self._scrollPlayer = player

    --tmp
    self._cellCanvas1.alpha = 1
    self._cellCanvas2.alpha = 0
    self._scrollIng = true
    self._cellCanvas1:DOFade(0,0.3)
    self._cellCanvas2:DOFade(1,0.3):OnComplete(
        function()
            self:_SetCellForNormal()
            self:_SetScrollCellData(self._cellWidget1,self._currIdx)
            self._scrollIng = false
        end
    )
    
end