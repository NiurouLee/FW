---@class UIHeartSpiritController : UIController
_class("UIHeartSpiritController", UIController)
UIHeartSpiritController = UIHeartSpiritController

function UIHeartSpiritController:Constructor()
    self._itemCountPerRow = 6
    self._listShowItemCount = 0
    --1加载中 2加载结束
    self._AsyncLoadFlagMap = {}
    self._TaskList = {}
    self._btnCount = 3
    self._firstIn = true
    self._uiHeartAtlas = self:GetAsset("UIHeartItem.spriteatlas", LoadType.SpriteAtlas)
    self._items = {}
    self._elementSortTypeOrder = 
    {
        [1] = PetSortType.WaterFirst,
        [2] = PetSortType.FireFirst,
        [3] = PetSortType.SenFirst,
        [4] = PetSortType.ElectricityFirst
    }
    self._currentElementSortTypeOrder = 0
    self._sortFilterActiveStatus = false -- 筛选界面显示状态
    self._petHeartItemList = {}

    self._isFilterRedPoint = false
end
--突破红点
function UIHeartSpiritController:FilterRedBtnOnClick(go)
    self._isFilterRedPoint = not self._isFilterRedPoint

    if self._isFilterRedPoint then
        if not self._filterParams then
            self._filterParams = {}
        end
        --增加
        local filterParam = PetFilterParam:New(PetFilterType.RedPoint_Break,PetFilterType.RedPoint_Break)
        table.insert(self._filterParams,filterParam)
    else
        if not self._filterParams then
            self._filterParams = {}
        else
            --移除
            local removeIdx = nil
            for index, value in ipairs(self._filterParams) do
                if value._filter_type == PetFilterType.RedPoint_Break then
                    removeIdx = index
                    break
                end
            end
            if removeIdx then
                table.remove(self._filterParams,removeIdx)
            end
        end
    end

    self:SetFilterImgActive()

    self:RefrenshPetList()
end
function UIHeartSpiritController:SetFilterImgActive()
    local sp 
    if self._isFilterRedPoint then
        sp = self._filterRedSp1
    else
        sp = self._filterRedSp2
    end
    self._filterRedImg.sprite = sp
end
function UIHeartSpiritController:GetComponents()
    local backBtns = self:GetUIComponent("UISelectObjectPath", "backBtns")
    self._backBtns = backBtns:SpawnObject("UICommonTopButton")
    self._backBtns:SetData(
        function()
            GameGlobal.EventDispatcher():Dispatch(GameEventType.ActivityDialogRefresh)
            self._petModule:ClearAllPetSortInfo()
            self:CloseDialog()
        end,
        nil
    )

    self._sortBtns = self:GetUIComponent("UISelectObjectPath", "sortBtns")

    self._scrollView = self:GetUIComponent("UIDynamicScrollView", "ScrollView")

    self._curSortStateIcon = self:GetUIComponent("Image", "btnFiltrate")
    self._emptyDataTip = self:GetGameObject("EmptyTip")
    self._emptyDataTip:SetActive(false)

    self._sortFilterLoader = self:GetUIComponent("UISelectObjectPath", "sortFilter")
    self._clearFilterBtn = self:GetGameObject("clearFilterBtn")
    self._clearFilterBtn:SetActive(false)
    self._clearFilterBtnTrans = self:GetUIComponent("RectTransform" , "clearFilterBtn")
    self._topRightTrans = self:GetUIComponent("RectTransform","TopRightAnchor")
    self._redPoint = self:GetGameObject("RedPoint")
    self._refineTip =  self:GetGameObject("RefineTip")
    self._refineTip:SetActive(false)
    self._topRight  = self:GetGameObject("TopRight")
    self._topRightRect = self:GetUIComponent("RectTransform","TopRight")

    self._filterRedImg = self:GetUIComponent("Image","FilterRedBtn")
    self._filterRedIGo = self:GetGameObject("FilterRedBtn")

    self._filterRedSp1 = self._uiHeartAtlas:GetSprite("spirit_jiantou_b_4_frame")
    self._filterRedSp2 = self._uiHeartAtlas:GetSprite("spirit_jiantou_b_3_frame")
end
function UIHeartSpiritController:OnValue()
    self:SetFilterImgActive()
    --Log.error("[UI profile] UIHeartSpiritController:OnValue SetFilterImgActive 完成")
    self:SetClearBtnStatus()

    self:SetFilterGoActive()

    self:InitTopBtns()
    --Log.error("[UI profile] UIHeartSpiritController:OnValue InitTopBtns 完成")
    self:CalcPetScrollViewCount()
    --Log.error("[UI profile] UIHeartSpiritController:OnValue CalcPetScrollViewCount 完成")
    self:_InitSrollView()
    self:FlushFiltRateRed()
    self:SetFilterGoActive()
end
--遍历星灵列表，如果都没有红点就不显示
function UIHeartSpiritController:SetFilterGoActive()
    local show = false
    if self._pets and table.count(self._pets)>0 then
        for key, value in pairs(self._pets) do
            local isShow = value:IsShowRedPoint() or value:IsShowSkinRedPoint()
            if not isShow then
                isShow = UIPetEquipHelper.CheckRefineRed(value)
            end
            if isShow then
                show = true
                break
            end
        end
    end
    self._filterRedIGo:SetActive(show)
end
function UIHeartSpiritController:OnShow(uiParams)
    self:GetComponents()
    --Log.error("[UI profile] UIHeartSpiritController:OnShow GetComponents 完成")
    ---@type PetModule
    self._petModule = GameGlobal.GetModule(PetModule)

    --排序筛选相关--
    local sortFilterCfg = UISortFilterCfg["UIHeartSpirit"]
    local sortCfg = {}
    for idx, value in ipairs(sortFilterCfg.Sort) do
        sortCfg[idx] = Cfg.cfg_client_pet_sort[value]
    end
    local filterCfg = {}
    for tag, filters in pairs(sortFilterCfg.Filter) do
        local cfgs = {}
        for idx, value in ipairs(filters) do
            cfgs[idx] = Cfg.cfg_client_pet_filter[value]
        end
        filterCfg[tag] = cfgs
    end
    self._sortCfg = sortCfg
    self._filterCfg = filterCfg
    
    if self._petModule.PetSortType ~= nil then
        self._sortType = self._petModule.PetSortType
    else
        self._sortType = PetSortType.Level
    end

    if self._petModule.PetSortOrder ~= nil then
        self._sortOrder = self._petModule.PetSortOrder
    else
        self._sortOrder = PetSortOrder.Descending
    end
  
    if self._petModule.PetSortFilter ~= nil then
        self._filterParams = self._petModule.PetSortFilter
    else
        self._filterParams = {}
    end
    --end--
    --Log.error("[UI profile] UIHeartSpiritController:OnShow 一系列排序完成")
    self:AttacEvents()
    --Log.error("[UI profile] UIHeartSpiritController:OnShow AttacEvents 完成")
    local sortParams = PetDefaulSort[self._sortType][self._sortOrder]
    ---@type MatchPet[]
    self._pets = self._petModule:_SortPets(self._petModule:GetPets(), self._filterParams, sortParams,self._petModule.PetSortChooseSecondAttribute)
    --Log.error("[UI profile] UIHeartSpiritController:OnShow _SortPets 完成")
    self:OnValue()
end

function UIHeartSpiritController:InitTopBtns()
    if not self._petModule:CheckHasCachePetSortInfo() then
        self._curSortStateIcon.sprite = self._uiHeartAtlas:GetSprite("spirit_jiantou_b_1_frame")
    end
    if self._petModule.PetSortElementIndex ~= 0 then
        self._currentElementSortTypeOrder = self._petModule.PetSortElementIndex
    end
    self._sortBtns:SpawnObjects("UITopSortBtnItem", self._btnCount)
    ---@type UITopSortBtnItem[]
    self._sortBtnsPool = self._sortBtns:GetAllSpawnList()
    for i = 1, self._btnCount do
        self._sortBtnsPool[i]:SetData(
            i,
            self._sortCfg[i],
            self._sortType,
            self._sortOrder,
            function(idx)
                self:ChangeSortParams(idx)
            end,
            self._currentElementSortTypeOrder
            
        )
    end

    UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self._topRightTrans)
    local topBtnsWidth = self._topRightTrans.rect.width
    local targetPos = Vector2(-topBtnsWidth - 100 , self._clearFilterBtn.transform.localPosition.y)
    self._topRightRect.anchoredPosition = targetPos
end

function UIHeartSpiritController:ChangeSortParams(idx)
    local tp = self._sortCfg[idx].Type
    GameGlobal.UAReportForceGuideEvent("UIPetViewClick", {self._sortCfg[idx].Name}, true)
    if self._sortType == tp then
        --顺序反转
        if self._sortOrder == PetSortOrder.Ascending then
            self._sortOrder = PetSortOrder.Descending
        elseif self._sortOrder == PetSortOrder.Descending then
            self._sortOrder = PetSortOrder.Ascending
        end
    else
        self._sortType = tp
    end


    --刷新顶部排序按钮状态
    self:FlushTopBtnState()

    --排序，获取，刷新列表
    self:RefrenshPetList()
end

function UIHeartSpiritController:FlushTopBtnState()
    for i = 1, self._btnCount do
        self._sortBtnsPool[i]:Flush(self._sortType, self._sortOrder , self._petModule.PetSortElementIndex)
    end
end

function UIHeartSpiritController:AttacEvents()
    self:AttachEvent(GameEventType.PetUpLevelEvent, self.RefrenshPetList)
    self:AttachEvent(GameEventType.PetUpGradeEvent, self.RefrenshPetList)
    self:AttachEvent(GameEventType.PetAwakenEvent, self.RefrenshPetList)
    self:AttachEvent(GameEventType.OnPetSkinChange, self.RefrenshPetList)
    self:AttachEvent(GameEventType.ItemCountChanged, self.OnItemCountChange)
    self:AttachEvent(GameEventType.WatchPetSkinStory, self.OnItemCountChange)
    self:AttachEvent(GameEventType.OnPetFilterTypeChange, self.OnPetFilterTypeChange)
    self:AttachEvent(GameEventType.CheckCardAwakeRedPoint, self.CheckCardAwakeRedPoint)
end

function UIHeartSpiritController:DetachEvents()
    self:DetachEvent(GameEventType.PetUpLevelEvent, self.RefrenshPetList)
    self:DetachEvent(GameEventType.PetUpGradeEvent, self.RefrenshPetList)
    self:DetachEvent(GameEventType.PetAwakenEvent, self.RefrenshPetList)
    self:DetachEvent(GameEventType.OnPetSkinChange, self.RefrenshPetList)
    self:DetachEvent(GameEventType.ItemCountChanged, self.OnItemCountChange)
    self:DetachEvent(GameEventType.WatchPetSkinStory, self.OnItemCountChange)
    self:DetachEvent(GameEventType.OnPetFilterTypeChange, self.OnPetFilterTypeChange)
    self:DetachEvent(GameEventType.CheckCardAwakeRedPoint, self.CheckCardAwakeRedPoint)
end
function UIHeartSpiritController:CheckCardAwakeRedPoint()
    self:RefrenshPetList(0,true)
end
function UIHeartSpiritController:OnHide()
    for _, v in pairs(self._TaskList) do
        if v then
            GameGlobal.TaskManager():KillTask(v)
            v = nil
        end
    end
    self:DetachEvents()
    self._petModule:ClearAllPetSortInfo()
end

function UIHeartSpiritController:_InitSrollView()
    self._scrollView:InitListView(
        self._listShowItemCount,
        function(scrollView, index)
            return self:InitSpritListInfo(scrollView, index)
        end,
        self:GetScrollViewParam()
    )
    self._firstIn = false
end

function UIHeartSpiritController:GetScrollViewParam()
    ---@type UIDynamicScrollViewInitParam
    local param = UIDynamicScrollViewInitParam:New()
    param.mItemDefaultWithPaddingSize = 333
    return param
end

function UIHeartSpiritController:GetHasItemAsyncLoading()
    for _, v in pairs(self._AsyncLoadFlagMap) do
        if v == 1 then
            return true
        end
    end
    return false
end

function UIHeartSpiritController:InitSpritListInfo(scrollView, index)
    if index < 0 then
        return nil
    end
    local item = scrollView:NewListViewItem("RowItem")
    local rowPool = self:GetUIComponentDynamic("UISelectObjectPath", item.gameObject)
    if item.IsInitHandlerCalled == false then
        if self._TaskList[item] then
            return item
        end
        self._TaskList[item] = self:StartTask(function(TT)
            if index > 0 then
                while self:GetHasItemAsyncLoading() do
                    YIELD(TT)
                end 
            end
            self._AsyncLoadFlagMap[item] = 1
            rowPool:AsyncSpawnObjects(TT, "UIHeartItem", self._itemCountPerRow)
            ---@type UIHeartItem[]
            local rowList = rowPool:GetAllSpawnList()
            self._petHeartItemList = rowList
            for i = 1, self._itemCountPerRow do
                local heartItem = rowList[i]
                heartItem:GetGameObject():SetActive(false)
            end
            for i = 1, self._itemCountPerRow do
                local heartItem = rowList[i]
                local itemIndex = index * self._itemCountPerRow + i

                if itemIndex > self._petCount then
                    heartItem:GetGameObject():SetActive(false)
                else
                    self:ShowHeartItem(TT, heartItem, itemIndex)
                    heartItem:PlayFadeInAnim()
                    self._items[itemIndex] = heartItem
                    if itemIndex % 2 == 0 then
                        YIELD(TT)
                    end
                end
            end
            self._AsyncLoadFlagMap[item] = 2
            item.IsInitHandlerCalled = true
            self._TaskList[item] = nil
        end)
    else
        local rowList = rowPool:GetAllSpawnList()
        self._petHeartItemList = rowList
        for i = 1, self._itemCountPerRow do
            local heartItem = rowList[i]
            heartItem:GetGameObject():SetActive(false)
        end
        for i = 1, self._itemCountPerRow do
            local heartItem = rowList[i]
            local itemIndex = index * self._itemCountPerRow + i

            if itemIndex > self._petCount then
                heartItem:GetGameObject():SetActive(false)
            else
                self:ShowHeartItem(TT, heartItem, itemIndex)
                heartItem:ResetInAnim()
                self._items[itemIndex] = heartItem
            end
        end
    end
    return item
end

---@param heartItem UIHeartItem
function UIHeartSpiritController:ShowHeartItem(TT, heartItem, index)
    local config = self._pets[index]
    heartItem:GetGameObject():SetActive(true)
    if (config ~= nil) then
        heartItem:SetData(
            config,
            function(id)
                local pstids = {}
                for i = 1, #self._pets do
                    table.insert(pstids, self._pets[i]:GetPstID())
                end
                self._petModule.uiModule:SetTeamPets(pstids)
                local petid = self._petModule:GetPet(id):GetTemplateID()
                GameGlobal.UAReportForceGuideEvent("UIPetViewClick", {tostring(petid)}, true)
                self:ShowDialog("UISpiritDetailGroupController", petid,nil,nil,heartItem)
            end,
            true,
            self._firstIn,
            TeamOpenerType.Main,
            PetSkinEffectPath.CARD_PET_LIST
        )
        --设置光灵红点
        self:_SetRedPoint(config,heartItem)
    end
end

--计算数量
function UIHeartSpiritController:CalcPetScrollViewCount()
    self._petCount = table.count(self._pets)
    self._listShowItemCount = math.ceil(self._petCount / self._itemCountPerRow)
    self:CheckEmptyTip()
end

--检查是否空
function UIHeartSpiritController:CheckEmptyTip()
    if self._petCount <= 0 then
        self._emptyDataTip:SetActive(true)
    else
        self._emptyDataTip:SetActive(false)
    end
end

--刷新
function UIHeartSpiritController:RefrenshPetList(pstid,stay)
    self._items = {}
    local sortParams
    if self._sortType == PetSortType.Element then
        self._currentElementSortTypeOrder = self._petModule.PetSortElementIndex
        sortParams = PetDefaulSort[self._elementSortTypeOrder[self._currentElementSortTypeOrder]][PetSortOrder.Descending]
    else
        sortParams = PetDefaulSort[self._sortType][self._sortOrder]
    end
    -- sortParams = PetDefaulSort[self._sortType][self._sortOrder]
    self._pets = self._petModule:_SortPets(self._petModule:GetPets(), self._filterParams, sortParams,self._petModule.PetSortChooseSecondAttribute)
    self._petModule:SavePetSortInfo(self._filterParams , self._sortOrder ,self._sortType )
    self:CalcPetScrollViewCount()
    self._scrollView:SetListItemCount(self._listShowItemCount)
    if not stay then
        self._scrollView:MovePanelToItemIndex(0, 0)
    else
        self._scrollView:RefreshAllShownItem()
    end
    self:SetFilterGoActive()
end

function UIHeartSpiritController:OnSortFilterChanged(sortType, sortOrder, filterParams)
    self._sortType = sortType
    self._sortOrder = sortOrder
    self._filterParams = filterParams

    self:FlushTopBtnState()
    self:RefrenshPetList()
end

--打开排序界面
function UIHeartSpiritController:btnFiltrateOnClick(go)
    GameGlobal.UAReportForceGuideEvent("UIPetViewClick", {"shaixuankai"}, true)

    self._curSortStateIcon.sprite = self._uiHeartAtlas:GetSprite("spirit_jiantou_b_2_frame")
    self._sortFilterActiveStatus = true
    if self._sortFilter == nil then
        ---@type UISortFilterItem
        self._sortFilter = self._sortFilterLoader:SpawnObject("UISortFilterItem")
    end
    self._sortFilter:SetData(
        self._sortType,
        self._sortOrder,
        self._filterParams,
        self._sortCfg,
        self._filterCfg,
        function(sortType, sortOrder, filterParams)
            self:OnSortFilterChanged(sortType, sortOrder, filterParams)
        end,
        function()
            self:CloseFiterCallBack()
        end
    )
    self._clearFilterBtn:SetActive(true)
    self._sortFilter:GetGameObject():SetActive(true)
    self._petModule:ClickPetEquipRefine()
    self:FlushFiltRateRed()
end

--注释+首字母大写
function UIHeartSpiritController:ClearFilterBtnOnClick()
    if self._sortFilterActiveStatus == false then
        self._clearFilterBtn:SetActive(false)    
        self._curSortStateIcon.sprite = self._uiHeartAtlas:GetSprite("spirit_jiantou_b_1_frame")
    end
    self._petModule:ClearPetSortFilterInfo()

    self._filterParams = {}

    self._isFilterRedPoint = false
    self:SetFilterImgActive()
  
    --刷新顶部排序按钮状态
    self:FlushTopBtnState()

    --排序，获取，刷新列表
    self:RefrenshPetList()

     --清除按钮状态
     if self._sortFilter then
        self._sortFilter:ClearFilters()    
    end
    self._refineTip:SetActive(false) 
end

function UIHeartSpiritController:CloseFiterCallBack()
    GameGlobal.UAReportForceGuideEvent("UIPetViewClick", {"shaixuanguan"}, true)
    self._sortFilterActiveStatus = false
    self:SetClearBtnStatus()
end

function UIHeartSpiritController:SetClearBtnStatus()
    if not self._petModule:CheckHasCachePetSortInfo() then
        self._curSortStateIcon.sprite = self._uiHeartAtlas:GetSprite("spirit_jiantou_b_1_frame")
        self._clearFilterBtn:SetActive(false)
    else
        self._curSortStateIcon.sprite = self._uiHeartAtlas:GetSprite("spirit_jiantou_b_2_frame")
        self._clearFilterBtn:SetActive(true)
    end
end
   

function UIHeartSpiritController:GetHeartItem(index)
    if self._items[index] then
        return self._items[index]:GetGameObject("openDetail")
    else
        --Log.error("UIHeartSpiritController cant find index", index, " uiheartitem")
        return nil
    end
end

function UIHeartSpiritController:GetGuideScroll()
    return self:GetUIComponent("ScrollRect", "ScrollView")
end

---@param config MatchPet
function UIHeartSpiritController:_SetRedPoint(config,heartItem)
    local isShow = config:IsShowRedPoint() or config:IsShowSkinRedPoint()
    if not isShow then
        isShow = UIPetEquipHelper.CheckRefineRed(config)
    end
    heartItem:ShowRedPoint(isShow)
end

function UIHeartSpiritController:OnItemCountChange()
    self:RefreshEquipRed()
end

function UIHeartSpiritController:RefreshEquipRed()
    --检查突破红点和皮肤红点
    for i,heartItem in pairs(self._items) do
        local config = self._pets[i]
        self:_SetRedPoint(config,heartItem)
    end
end

function UIHeartSpiritController:GetPetHeartItem(pettid)
    for k, v in pairs(self._items) do
        if v:GetPetTid() == pettid then
            return v
        end
    end

    return nil
end

function UIHeartSpiritController:FlushFiltRateRed()
   self._redPoint:SetActive(self._petModule:PetEquipRefineNew())
end

function UIHeartSpiritController:OnPetFilterTypeChange(type,isAdd)
    if type == PetFilterType.Refine then 
        self._refineTip:SetActive(isAdd) 
    end 
end

