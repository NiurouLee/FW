_class("UIBackPackController", UIController)
---@class UIBackPackController : UIController
UIBackPackController = UIBackPackController

function UIBackPackController:OnShow(uiParams)
    self._AsyncLoadFlagMap = {}
    self._TaskList = {}
    --CutsceneManager.ExcuteCutsceneOut()
    self._backCallback = uiParams[1]
    local backBtns = self:GetUIComponent("UISelectObjectPath", "backBtns")
    self._backBtns = backBtns:SpawnObject("UICommonTopButton")
    self._backBtns:SetData(
        function()
            if self._backCallback then
                self._backCallback()
            else
                self:CloseDialog()
            end
        end,
        nil
    )

    --标签按钮
    self._allStateOn = self:GetGameObject("allStateOn")
    self._allStateOff = self:GetGameObject("allStateOff")
    self._clStateOn = self:GetGameObject("clStateOn")
    self._clStateOff = self:GetGameObject("clStateOff")
    self._xhStateOn = self:GetGameObject("xhStateOn")
    self._xhStateOff = self:GetGameObject("xhStateOff")
    self._currentType = ItemType.ItemType_None
    self:ChangeState(self._currentType)

    --TODO 接数据
    ---@type ItemModule
    self._itemModule = GameGlobal.GetModule(ItemModule)
    self._loginModule = GameGlobal.GetModule(LoginModule)
    self._svrTimeModule = GameGlobal.GetModule(SvrTimeModule)
    --一行多少个
    self._itemCountPerRow = 4
    --得到物品
    ---@type Item[]
    self._itemList = self:GetNotHomelandItems(ItemType.ItemType_None)

    --qa 进入清除所有物品的红点
    self.pst2red = {}
    self.clearRed = false
    self:ClearItemsRedPoint()

    --物品数量
    self._listItemTotalCount = table.count(self._itemList)
    self._countClone = self._listItemTotalCount

    --使用的物品index
    self._lastIndex = 1

    --显示多少行
    self._showRow = 8
    --生成多少行
    self._listItemTotalRow = 0

    --所有Item
    ---@type UIBackPackItem[]
    self._itemTable = {}
    self._selectItemIndex = -1

    self._itemDetail = self:GetGameObject("item")
    self._itemDetailEmpty = self:GetGameObject("itemEmpty")

    self._txtItemName = self:GetUIComponent("UILocalizationText", "txt_itemname")
    self._imageItemIcon = self:GetUIComponent("RawImageLoader", "image_itemicon")
    self._txtItemNum = self:GetUIComponent("UILocalizationText", "txt_itemnum")
    self._txtDetailDesc = self:GetUIComponent("UILocalizationText", "txt_detail_desc")
    self._use = self:GetGameObject("use")

    self._lessTimeGo = self:GetGameObject("lessTimeGo")
    self._timeDownGo = self:GetGameObject("timeDownGo")
    self._timeTexRoot = self:GetGameObject("timeTexRoot")
    self._timeTex = self:GetUIComponent("UILocalizationText", "timeTex")

    ---@type UIDynamicScrollView
    self._scrollView = self:GetUIComponent("UIDynamicScrollView", "ItemList")
    self._content = self:GetUIComponent("RectTransform", "Content")

    self.btn_item_from = self:GetGameObject("btn_item_from")
    self._alphaImg = self:GetGameObject("alphaImg")
    self._alphaImg:SetActive(false)
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self.btn_item_from),
        UIEvent.Press,
        function(go)
            self._alphaImg:SetActive(true)
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self.btn_item_from),
        UIEvent.Release,
        function(go)
            self._alphaImg:SetActive(false)
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self.btn_item_from),
        UIEvent.Click,
        function(go)
            self:btnItemFromClick()
        end
    )

    self:AttachEvent(GameEventType.ItemCountChanged, self.OnItemCountChange)
    self:AttachEvent(GameEventType.OpenGiftReward, self.OnOpenGift)

    self:_InitBackPack()
end
function UIBackPackController:GetSaveItemRed(pstid)
    return self.pst2red[pstid] or false
end
function UIBackPackController:RemoveSaveItemRed(pstid)
    if self.pst2red[pstid] then
        self.pst2red[pstid] = nil
    end
end
function UIBackPackController:ClearItemsRedPoint()
    if self._itemList and #self._itemList>0 then
        local sendList = {}
        for key, item_data in pairs(self._itemList) do
            if item_data:IsNew() then
                self.clearRed = true
                local pstid = item_data:GetID()
                table.insert(sendList,pstid)
                self.pst2red[pstid] = true
            end
        end
        GameGlobal.TaskManager():StartTask(self.ClearItemsRedPointReq,self,sendList)
    end
end
function UIBackPackController:ClearItemsRedPointReq(TT,sendList)
    self._itemModule:SetItemListUnnew(TT,sendList)
end
function UIBackPackController:allOnClick()
    self:_PlaySwitchSound()
    local type = ItemType.ItemType_None
    if self._currentType == type then
        return
    end
    GameGlobal.UAReportForceGuideEvent("UIBackPackControllerClick", {"qb"}, true)
    self._currentType = type
    self:ChangeState(type)
    self:OnChangeCurrentType(type)
end
function UIBackPackController:xhOnClick()
    self:_PlaySwitchSound()
    local type = ItemType.ItemType_Use
    if self._currentType == type then
        return
    end
    GameGlobal.UAReportForceGuideEvent("UIBackPackControllerClick", {"xh"}, true)
    self._currentType = type
    self:ChangeState(type)

    self:OnChangeCurrentType(type)
end
function UIBackPackController:clOnClick()
    self:_PlaySwitchSound()
    local type = ItemType.ItemType_Material
    if self._currentType == type then
        return
    end
    GameGlobal.UAReportForceGuideEvent("UIBackPackControllerClick", {"cl"}, true)
    self._currentType = type
    self:ChangeState(type)

    self:OnChangeCurrentType(type)
end

---播放切换音效
function UIBackPackController:_PlaySwitchSound()
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.SoundSwitch)
end

--切换标签状态
function UIBackPackController:ChangeState(type)
    if type == ItemType.ItemType_None then
        self:ChangeAllType(true)
        self:ChangeCLType(false)
        self:ChangeXHType(false)
    elseif type == ItemType.ItemType_Use then
        self:ChangeAllType(false)
        self:ChangeCLType(false)
        self:ChangeXHType(true)
    elseif type == ItemType.ItemType_Material then
        self:ChangeAllType(false)
        self:ChangeCLType(true)
        self:ChangeXHType(false)
    end
end
--切换全部状态
function UIBackPackController:ChangeAllType(isOn)
    if isOn then
        self._allStateOn:SetActive(true)
        self._allStateOff:SetActive(false)
    else
        self._allStateOn:SetActive(false)
        self._allStateOff:SetActive(true)
    end
end
--切换材料状态
function UIBackPackController:ChangeCLType(isOn)
    if isOn then
        self._clStateOn:SetActive(true)
        self._clStateOff:SetActive(false)
    else
        self._clStateOn:SetActive(false)
        self._clStateOff:SetActive(true)
    end
end
--切换消耗状态
function UIBackPackController:ChangeXHType(isOn)
    if isOn then
        self._xhStateOn:SetActive(true)
        self._xhStateOff:SetActive(false)
    else
        self._xhStateOn:SetActive(false)
        self._xhStateOff:SetActive(true)
    end
end

---@private
function UIBackPackController:_InitBackPack()
    self:_InitSrollView()
end

function UIBackPackController:ShowFirstItem()
    self:OnItemSelect(1)
end

---@private
function UIBackPackController:_InitSrollView()
    self:CalcCount()

    if self._scrollView then
        self._scrollView:InitListView(
            self:_CalcTotalRow(self._listItemTotalCount),
            function(scrollView, index)
                return self:_InitListView(scrollView, index)
            end,
            self:GetParamItem()
        )
    end
    --显示第一个
    self:ShowFirstItem()
end

function UIBackPackController:GetParamItem()
    ---@type UIDynamicScrollViewInitParam
    local param = UIDynamicScrollViewInitParam:New()
    param.mItemDefaultWithPaddingSize = 180
    return param
end

function UIBackPackController:CalcCount()
    if self._listItemTotalCount < self._itemCountPerRow * self._listItemTotalRow then
        self._baseCount = self._itemCountPerRow * self._listItemTotalRow
    else
        self._baseCount = self._listItemTotalCount
    end
end

function UIBackPackController:GetHasItemAsyncLoading()
    for _, v in pairs(self._AsyncLoadFlagMap) do
        if v == 1 then
            return true
        end
    end
    return false
end

function UIBackPackController:GetHasLowIndexItemAsyncLoading(index)
    for idx, v in pairs(self._AsyncLoadFlagMap) do
        if v == 1 and idx < index and index < 8 then
            return true
        end
    end
    return false
end

---@private
---@param scrollView UIDynamicScrollView
---@param index number
---@return UIDynamicScrollViewItem
function UIBackPackController:_InitListView(scrollView, index)
    if index < 0 then
        return nil
    end
    local item = scrollView:NewListViewItem("RowItem")
    local rowPool = self:GetUIComponentDynamic("UISelectObjectPath", item.gameObject)
    
    if item.IsInitHandlerCalled == false then
        item.IsInitHandlerCalled = true
        self:Lock("UIBackPackController_InitListView" .. index)
        self._TaskList[item] = self:StartTask(function(TT)
            if index > 0 then
                while self:GetHasItemAsyncLoading() do
                    YIELD(TT)
                end 
            end
            self._AsyncLoadFlagMap[item] = 1
            rowPool:AsyncSpawnObjects(TT, "UIBackPackItem", self._itemCountPerRow)
            self:SpawnRawItem(index, rowPool, true)
            YIELD(TT)
            self._AsyncLoadFlagMap[item] = 2
            self:UnLock("UIBackPackController_InitListView" .. index)
            self._TaskList[item] = nil
        end)
    else
        if self._TaskList[item] then
            self:StartTask(function()
                while self._TaskList[item] do
                    YIELD(TT)
                end 
                self:SpawnRawItem(index, rowPool, true) 
            end)
        else
            self:SpawnRawItem(index, rowPool, false) 
        end
    end
    return item
end

function UIBackPackController:SpawnRawItem(index, rowPool, anim)
    local rowList = rowPool:GetAllSpawnList()
        for i = 1, self._itemCountPerRow do
            ---@type UIBackPackItem
            local backPackItem = rowList[i]
            local itemIndex = index * self._itemCountPerRow + i

            self._itemTable[itemIndex] = backPackItem

            --[[
                不能删，不然复用时会激活选中框
            ]]
            if self._selectItemIndex == itemIndex then
                if self._selectItemIndex <= self._listItemTotalCount then
                    backPackItem:SelectImg(true, true)
                else
                    backPackItem:SelectImg(false)
                end
            else
                backPackItem:SelectImg(false)
            end

            if itemIndex > self._baseCount then
                self:_ShowBackPackItem(backPackItem, itemIndex, anim)
            else
                self:_ShowBackPackItem(backPackItem, itemIndex, anim)
            end
        end
end

---@private
---@param index number
---@param backPackItem UIBackPackItem
function UIBackPackController:_ShowBackPackItem(backPackItem, index, anim)
    local item_data = self:_GetItemData(index)
    if anim then
        backPackItem:PlayFadeInAnim()
    else
        backPackItem:ResetInAnim()
    end
    if item_data then
        backPackItem:SetData(
            item_data,
            index,
            function(index)
                AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.SoundDefaultClick)
                self:OnItemSelect(index)
            end,
            function(pstid)
                return self:GetSaveItemRed(pstid)
            end,
            function(pstid)
                self:RemoveSaveItemRed(pstid)
            end
        )
        backPackItem:GetGameObject():SetActive(true)
    else
        backPackItem:ResetData()
        backPackItem:HideCount()
    end
end

local random = math.random

---@private
---@param index number
---@return Item
function UIBackPackController:_GetItemData(index)
    if index <= table.count(self._itemList) then
        return self._itemList[index]
    end
    return nil
end

function UIBackPackController:OnHide()
    for _, v in pairs(self._TaskList) do
        if v then
            GameGlobal.TaskManager():KillTask(v)
            v = nil
        end
    end
    self._backBtns = nil
    GameGlobal.EventDispatcher():Dispatch(GameEventType.NoticeBackPackRed)
    if self._timer then
        GameGlobal.Timer():CancelEvent(self._timer)
        self._timer = nil
    end
end

function UIBackPackController:Dispose()
    self:DetachEvent(GameEventType.OpenGiftReward, self.OnOpenGift)
    self:DetachEvent(GameEventType.ItemCountChanged, self.OnItemCountChange)
end

function UIBackPackController:Constructor()
end

function UIBackPackController:btnItemFromClick()
    self:ShowDialog("UIItemGetPathController", self:_GetSelectItemData():GetTemplateID())
end

function UIBackPackController:CheckLessTime(id)
    local cfg_item = Cfg.cfg_item[id]
    if not cfg_item then
        Log.error("###[UIBackPackItem] cfg is nil ! id --> ", id)
    end

    local deadTime1 = math.maxinteger
    if not string.isnullorempty(cfg_item.CompulsiveDeadTime) then
        deadTime1 =
            math.floor(
            self._loginModule:GetTimeStampByTimeStr(cfg_item.CompulsiveDeadTime, Enum_DateTimeZoneType.E_ZoneType_GMT)
        )
    end

    local deadTime2 = math.maxinteger
    if not string.isnullorempty(cfg_item.DeadTime) then
        local timeType = Enum_DateTimeZoneType.E_ZoneType_ServerTimeZone
        if cfg_item.TimeTransform and cfg_item.TimeTransform == 0 then
            timeType = Enum_DateTimeZoneType.E_ZoneType_GMT
        end
        deadTime2 = math.floor(self._loginModule:GetTimeStampByTimeStr(cfg_item.DeadTime, timeType))
    end
    local lessTime = math.min(deadTime1, deadTime2)
    if lessTime == math.maxinteger then
        return true
    end
    local nowTime = math.floor(self._svrTimeModule:GetServerTime() * 0.001)
    local gapTime = lessTime - nowTime
    if gapTime <= 0 then
        return false
    end
    return true
end
function UIBackPackController:btnuseOnClick(go)
    local item_data = self:_GetSelectItemData()
    local templateData = item_data:GetTemplate()

    local _itemid = templateData.ID
    if not self:CheckLessTime(_itemid) then
        ToastManager.ShowToast(StringTable.Get("str_item_public_time_out"))
        return
    end

    if templateData.UseType == ItemUseType.ItemUseType_ManualUse then
        --普通物品
        if templateData.ItemSubType == ItemSubType.ItemSubType_Base then
            if item_data:IsAwakeDirectlyItem() then
                --觉醒直升道具打开特殊的界面
                self:ShowDialog(
                    "UIAwakeDirectly",
                    item_data,
                    function(data, petID)
                        self:StartTaskUseItem(data, 1, false, petID)
                    end
                )
            else
                if item_data:GetCount() == 1 then
                    self:StartTaskUseItem(item_data, 1, false)
                else
                    self:ShowDialog(
                        "UIItemSaleAndUseWithCountController",
                        item_data,
                        EnumItemSaleAndUseState.Use,
                        function(item_data, count)
                            self:StartTaskUseItem(item_data, count, false)
                        end
                    )
                end
            end
        else
            local giftType = self._itemModule:GetItemGiftType(item_data:GetTemplateID())
            if giftType ~= ItemGiftType.ItemGiftType_Choose then
                if item_data:GetCount() == 1 then
                    self:StartTaskUseItem(item_data, 1, true)
                else
                    self:ShowDialog(
                        "UIItemSaleAndUseWithCountController",
                        item_data,
                        EnumItemSaleAndUseState.Use,
                        function(item_data, count)
                            self:StartTaskUseItem(item_data, count, true)
                        end
                    )
                end
            else
                if self._itemModule:IsChoosePetGift(item_data:GetTemplateID()) then
                    self:ShowDialog("UIPetBackPackBox", item_data)
                else
                    local cfgItemGift = Cfg.cfg_item_gift[item_data:GetTemplateID()]
                    if cfgItemGift and cfgItemGift.SpecialOpenType ~= nil then
                        self:ShowDialog(
                            "UIBackPackUseBox",
                            item_data
                        )
                    else
                        if item_data:GetCount() == 1 then
                            self:ShowDialog("UIBackPackBox", item_data, 1)
                        else
                            self:ShowDialog(
                                "UIItemSaleAndUseWithCountController",
                                item_data,
                                EnumItemSaleAndUseState.Use,
                                function(item_data, count)
                                    self:ShowDialog("UIBackPackBox", item_data, count)
                                end
                            )
                        end
                    end 
                end
            end
        end
    end
end

--使用和出售的回调
---@param itemData Item
---@param count number
---@param isGift boolean
function UIBackPackController:StartTaskUseItem(item_Data, count, isGift, param1, param2, param3)
    GameGlobal.GetModule(PetModule):GetAllPetsSnapshoot()
    self._lastIndex = self._selectItemIndex
    self:Lock("UIBackPackController:StartTaskUseItem")
    local templateData = item_Data:GetTemplate()
    GameGlobal.UAReportForceGuideEvent("UIBackPackControllerUseItem", {templateData.ID or 0}, true)
    GameGlobal.TaskManager():StartTask(self.UseItem, self, item_Data, count, isGift, param1, param2, param3)
end

---@param itemData Item
---@param count number
---@param isGift boolean
function UIBackPackController:UseItem(TT, itemData, count, isGift, param1, param2, param3)
    local res, msg = self._itemModule:RequestUseItemByPstID(TT, itemData:GetID(), count, param1, param2, param3)
    self:UnLock("UIBackPackController:StartTaskUseItem")
    if res:GetSucc() then
        local tempPets = {}
        local pets = msg.m_reward_list
        if #pets > 0 then
            for i = 1, #pets do
                local ispet = GameGlobal.GetModule(PetModule):IsPetID(pets[i].assetid)
                if ispet then
                    table.insert(tempPets, pets[i])
                end
            end
        end
        if #tempPets > 0 then
            self:ShowDialog(
                "UIPetObtain",
                tempPets,
                function()
                    GameGlobal.UIStateManager():CloseDialog("UIPetObtain")
                    self:ShowDialog("UIGetItemController", msg.m_reward_list)
                end
            )
        else
            --列表为空就不弹窗
            if msg.m_reward_list and next(msg.m_reward_list) then
                self:ShowDialog("UIGetItemController", msg.m_reward_list)
            end
        end
    else
        if itemData.m_template_data.UseEffect == "PhyGift" then
            local stMsg
            if res:GetResult() == ITEM_RESULT_CODE.ITEM_NOT_EXIST then
                stMsg = self._itemModule:GetErrorMsg(res:GetResult())
            else
                stMsg = StringTable.Get("str_physicalpower_error_phy_add_full")
            end
            ToastManager.ShowToast(stMsg)
        end
        Log.fatal("[item] ### UseItem failed :" .. res.m_result)
    end
end

--点击背包界面的标签按钮会触发
---@param curItemIndex number
function UIBackPackController:OnChangeCurrentType()
    self._selectItemIndex = -1
    self:_RefreshItemInfo()
    self:ShowFirstItem()
end

--数量改变
function UIBackPackController:OnItemCountChange()
    if self._content == nil then
        Log.error("when ItemCountChange self._content == nil")
        return
    end
    local contentPos = self._content.anchoredPosition
    self:_RefreshItemInfo()

    local itemID = self._itemData:GetID()
    local itemdata = self._itemModule:FindItem(itemID)

    if itemdata then
        -- self:OnItemSelect(self._selectItemIndex)
        self:_SetSelectItem(itemdata)

        local idx = self:GetIndexFromList(itemdata)

        if idx == -1 then
            Log.debug("[item] ### 有這個物品，但是沒找到下標")
        end

        if self._selectItemIndex ~= -1 then
            if self._itemTable[self._selectItemIndex] then
                self._itemTable[self._selectItemIndex]:SelectImg(false)
            end
        end

        self._selectItemIndex = idx

        if self._itemTable[self._selectItemIndex] then
            self._itemTable[self._selectItemIndex]:SelectImg(true, true)
        end

        self._content.anchoredPosition = contentPos
    else
        if self._lastIndex <= self._listItemTotalCount then
            self:OnItemSelect(self._lastIndex)

            self._content.anchoredPosition = contentPos
        else
            self._selectItemIndex = -1
            self:ShowFirstItem()
        end
    end

    self._countClone = self._listItemTotalCount
end

--獲取物品下標
function UIBackPackController:GetIndexFromList(itemdata)
    for i = 1, #self._itemList do
        if itemdata == self._itemList[i] then
            return i
        end
    end
    return -1
end

--按照当前选择的类型更新ItemList
---@private
function UIBackPackController:_RefreshItemInfo()
    if self.clearRed then
        self.clearRed = false
        return
    end
    if self._itemTable[self._selectItemIndex] then
        self._itemTable[self._selectItemIndex]:SelectImg(false)
    end

    self._itemTable = {}

    self._itemList = self:GetNotHomelandItems(self._currentType)

    self._listItemTotalCount = table.count(self._itemList)

    self:CalcCount()

    self._scrollView:SetListItemCount(self:_CalcTotalRow(self._listItemTotalCount))

    self._scrollView:MovePanelToItemIndex(0, 0)
    --[[

        if self._listItemTotalCountClone ~= self._listItemTotalCount then
            --移动到最上方,使用或者出售如果没用完该物品不移动
            self._scrollView:MovePanelToItemIndex(0, 0)
            self._selectItemIndex = -1
            self:ShowFirstItem()
            self._listItemTotalCountClone = self._listItemTotalCount
        else
            self:OnItemSelect(self._selectItemIndex)
        end
        ]]
end

---@private
---@param itemData Item
function UIBackPackController:_SetSelectItem(itemData)
    --显示物品详情
    self._itemData = itemData
    self._itemDetailIsOpen = true
    self._itemDetail:SetActive(true)

    local templteItemData = self._itemData:GetTemplate()
    self._txtItemName:SetText(StringTable.Get(templteItemData.Name))

    self._imageItemIcon:LoadImage(templteItemData.Icon)

    local c = self._itemData:GetCount()
    --[[
    local roleModule = GameGlobal.GetModule(RoleModule)
    local c = roleModule:GetAssetCount(self._itemData:GetTemplateID())
    ]]
    self._txtItemNum:SetText(StringTable.Get("str_item_public_owned") .. c)
    if string.len(templteItemData.RpIntro) ~= 0 then
        self._txtDetailDesc:SetText(StringTable.Get(templteItemData.RpIntro))
    else
        self._txtDetailDesc:SetText("")
    end
    if templteItemData.UseType == ItemUseType.ItemUseType_ManualUse then
        self._use:SetActive(true)
    else
        self._use:SetActive(false)
    end

    self:InitTimeLess()
end

--期限道具
function UIBackPackController:InitTimeLess()
    local itemId = self._itemData:GetTemplate().ID
    local cfg_item = Cfg.cfg_item[itemId]
    if not cfg_item then
        Log.error("###[UIBackPackItem] cfg is nil ! id --> ", itemId)
    end
    self._lessTimeStr = cfg_item.DeadTime
    if string.isnullorempty(self._lessTimeStr) then
        self._lessTimeStr = cfg_item.CompulsiveDeadTime
    end
    self._isTimeItem = true
    if string.isnullorempty(self._lessTimeStr) then
        self._isTimeItem = false
    end
    self._lessTimeGo:SetActive(self._isTimeItem)
    self._timeDownGo:SetActive(false)
    self._timeTexRoot:SetActive(false)

    self._timeDown = false
    if self._isTimeItem then
        self._timeType = Enum_DateTimeZoneType.E_ZoneType_ServerTimeZone
        if cfg_item.TimeTransform and cfg_item.TimeTransform == 0 then
            self._timeType = Enum_DateTimeZoneType.E_ZoneType_GMT
        end
        local lessTime = math.floor(self._loginModule:GetTimeStampByTimeStr(self._lessTimeStr, self._timeType))
        local nowTime = math.floor(self._svrTimeModule:GetServerTime() * 0.001)
        local gapTime = lessTime - nowTime
        if gapTime <= 0 then
            --过期
            if self._timer then
                GameGlobal.Timer():CancelEvent(self._timer)
                self._timer = nil
            end
            self._timeDownGo:SetActive(true)
            self._timeDown = true
        else
            self:ShowTimeLess()
            self._timeTexRoot:SetActive(true)
            if self._timer then
                GameGlobal.Timer():CancelEvent(self._timer)
                self._timer = nil
            end
            self._timer =
                GameGlobal.Timer():AddEventTimes(
                1000,
                TimerTriggerCount.Infinite,
                function()
                    self:ShowTimeLess()
                end
            )
        end
    else
        if self._timer then
            GameGlobal.Timer():CancelEvent(self._timer)
            self._timer = nil
        end
    end
end
function UIBackPackController:ShowTimeLess()
    local lessTime = math.floor(self._loginModule:GetTimeStampByTimeStr(self._lessTimeStr, self._timeType))
    local nowTime = math.floor(self._svrTimeModule:GetServerTime() * 0.001)
    local gapTime = lessTime - nowTime

    if gapTime > 0 then
        --time2str
        local timeTex = HelperProxy:GetInstance():Time2Tex(gapTime)
        self._timeTex:SetText(StringTable.Get("str_item_public_time_out_str", timeTex))
    else
        --过期
        if self._timer then
            GameGlobal.Timer():CancelEvent(self._timer)
            self._timer = nil
        end
        self._timeDownGo:SetActive(true)
        self._timeDown = true
        self._timeTexRoot:SetActive(false)
    end
end

---@public
function UIBackPackController:OnItemSelect(index)
    local itemdata = self:_GetItemData(index)

    if not itemdata then
        self._itemDetailEmpty:SetActive(true)
        self._itemDetail:SetActive(false)
        return
    else
        self._itemDetailEmpty:SetActive(false)
        self._itemDetail:SetActive(true)
    end
    self:_SetSelectItem(itemdata)
    local templateData = itemdata:GetTemplate()
    GameGlobal.UAReportForceGuideEvent("UIBackPackControllerClickItem", {templateData.ID or 0}, true)

    if self._selectItemIndex ~= -1 then
        if self._itemTable[self._selectItemIndex] then
            self._itemTable[self._selectItemIndex]:SelectImg(false)
        end
    end

    self._selectItemIndex = index

    if self._itemTable[self._selectItemIndex] then
        self._itemTable[self._selectItemIndex]:SelectImg(true)
    end
end

local modf = math.modf

---@private
--计算行数
---@type itemTotalCount number
function UIBackPackController:_CalcTotalRow(itemTotalCount)
    --不能整除的就多一行
    local row, mod = modf(itemTotalCount / self._itemCountPerRow)
    if mod ~= 0 then
        row = row + 1
    end

    self._listItemTotalRow = row

    if self._listItemTotalRow < self._showRow then
        self._listItemTotalRow = self._showRow
    end
    return self._listItemTotalRow
end

--获取当前标签页第一个物品的index
---@return number
function UIBackPackController:GetFirstItemIndex()
    return 1
end

---@private
---@param itemCount number
---@return string
--	qa10366
function UIBackPackController:_FormatItemCount(itemCount)
    return HelperProxy:GetInstance():FormatItemCount(itemCount)
end

---@private
---@return Item
function UIBackPackController:_GetSelectItemData()
    return self:_GetItemData(self._selectItemIndex)
end

--使用普通礼包的回调，module派发
---@param rewadrd_list table 获得的信息
function UIBackPackController:OnOpenGift(giftID, rewadrd_list)
    self:ShowDialog("UIGetItemController", rewadrd_list)
end
---@param itemType ItemType
function UIBackPackController:GetNotHomelandItems(itemType)
    local items = {}
    local allItems = self._itemModule:GetInBagItemInfosByType(itemType)
    for _, item in ipairs(allItems) do
        local tpl = item:GetTemplate()
        local showType = tpl.ShowType or 1
        if showType & 0x01 == 0x01 then
            table.insert(items, item)
        end
    end
    return items
end
