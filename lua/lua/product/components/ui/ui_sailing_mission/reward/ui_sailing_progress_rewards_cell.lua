---@class UISailingProgressRewardsCell : UICustomWidget
_class("UISailingProgressRewardsCell", UICustomWidget)
UISailingProgressRewardsCell = UISailingProgressRewardsCell
function UISailingProgressRewardsCell:Constructor()
    self._animInfo = {
        nameSpecial = "uieff_UISailingProgressRewardsCell_lingqu_glow1",
        nameNormal = "uieff_UISailingProgressRewardsCell_lingqu_glow2",
        len = 400
    }
end
function UISailingProgressRewardsCell:OnShow(uiParams)
    self._isFirst = true
    --每行显示的列数
    self._itemCountPerRow = 1

    self:AttachEvent(GameEventType.SailingGetProgressReward, self.OnSailingGetProgressReward)
    self:AttachEvent(GameEventType.SailingOnProgressRewardCellSelect, self.OnSailingOnProgressRewardCellSelect)
    self:InitWidget()
    -- self._timeEvent =
    --     GameGlobal.RealTimer():AddEvent(
    --     1, --bug，msg25362
    --     function()
    --         if self._rootAnim then
    --             self._rootAnim:Play("uieff_Activity_Eve_LoginAward_Cell_In")
    --         end
    --     end
    -- )
end
function UISailingProgressRewardsCell:OnHide()
    if self._timeEvent then
        GameGlobal.RealTimer():CancelEvent(self._timeEvent)
        self._timeEvent = nil
    end
end
--刷新
function UISailingProgressRewardsCell:OnSailingGetProgressReward(cfgIDList)
    if cfgIDList then
        if table.icontains(cfgIDList,self._data._cfgID) then
            self._data._state = ECumulativeLoginRewardStatus.E_CUMULATIVE_LOGIN_REWARD_RECVED
            self:SetState(self._data._state)
            --anim
            self:_PlayGetAnim()
        end
    end
end
function UISailingProgressRewardsCell:OnSailingOnProgressRewardCellSelect(cfgID)
    if self._data._cfgID == cfgID then
        self:SetSelected(true)
    else
        self:SetSelected(false)
    end
end
function UISailingProgressRewardsCell:InitWidget()
    --generated--
    self._rootAnim = self:GetUIComponent("Animation","UISailingProgressRewardsCell")
    ---@type UILocalizationText
    self._progressNumText = self:GetUIComponent("UILocalizationText", "ProgressNumText")
    self._specialProgressNumText = self:GetUIComponent("UILocalizationText", "SpecialProgressNumText")
    self._selectCellBorderGo = self:GetGameObject("SelectCellBorder")
    self._selectCellBorderSpGo = self:GetGameObject("SelectCellBorderSp")
    self._bgNormalGo = self:GetGameObject("BgNormal")
    self._bgSpecialGo = self:GetGameObject("BgSpecial")
    self._progressAreaGo = self:GetGameObject("ProgressArea")
    self._specialProgressAreaGo = self:GetGameObject("SpecialProgressArea")
    self._bgNormalImg = self:GetUIComponent("RawImage", "BgNormal")
    self._bgNormalImgLoader = self:GetUIComponent("RawImageLoader", "BgNormal")
    self._bgSpecialImg = self:GetUIComponent("RawImage", "BgSpecial")
    self._bgSpecialImgLoader = self:GetUIComponent("RawImageLoader", "BgSpecial")
    self._setAlphaArea = self:GetUIComponent("CanvasGroup", "SetAlphaArea")

    ---@type UnityEngine.UI.Image
    self._selectStateAreaGo = self:GetGameObject("SelectStateArea")
    self._eff = self:GetGameObject("eff")
    self._effSub1 = self:GetGameObject("effSub1")
    self._effSub2 = self:GetGameObject("effSub2")

    ---@type UnityEngine.GameObject
    self._stateArea = self:GetGameObject("StateArea")
    self._stateGot = self:GetGameObject("StateGot")
    self._stateCanGet = self:GetGameObject("StateCanGet")
    self._stateLocked = self:GetGameObject("StateLocked")
    self._cellState = 1
    self._stateAreaGroup = {
        [ECumulativeLoginRewardStatus.E_CUMULATIVE_LOGIN_REWARD_RECVED] = self._stateGot,
        [ECumulativeLoginRewardStatus.E_CUMULATIVE_LOGIN_REWARD_CAN_RECV] = self._stateCanGet,
        [ECumulativeLoginRewardStatus.E_CUMULATIVE_LOGIN_REWARD_LOCK] = self._stateLocked
    }

    -- ---@type UICustomWidgetPool
    -- self._item1 = self:GetUIComponent("UISelectObjectPath", "Item1")
    -- ---@type UICustomWidgetPool
    -- self._item2 = self:GetUIComponent("UISelectObjectPath", "item2")
    -- self._items = {self._item1, self._item2}

    -- self._itemGo1 = self:GetGameObject("Item1")
    -- self._itemGo2 = self:GetGameObject("item2")
    -- self._itemGos = {self._itemGo1, self._itemGo2}

    --self._itemWidgetTb = {}
    -- ---@type UILocalizationText
    -- self._stateGotText = self:GetUIComponent("UILocalizationText", "StateGotText")
    -- local gotStr = StringTable.Get("str_temp_sign_in_got")
    -- self._stateGotText:SetText(gotStr)
    -- self._stateCanGetText = self:GetUIComponent("UILocalizationText", "StateCanGetText")
    -- local canGetStr = StringTable.Get("str_temp_sign_in_get")
    -- self._stateCanGetText:SetText(canGetStr)

    self._eff_front = self:GetGameObject("eff_front")
    self._eff_back = self:GetGameObject("eff_back")

    self._rewardList = self:GetUIComponent("UIDynamicScrollView", "RewardList")
    self._rewardListGo = self:GetGameObject("RewardList")
    self._itemAreaGo = self:GetGameObject("ItemArea")

    --
    self._rewardListGo:SetActive(true)
    self._itemAreaGo:SetActive(false)

    self:SetSelected(false)
    --generated end--
end
function UISailingProgressRewardsCell:SetData()
end
function UISailingProgressRewardsCell:_PlayGetAnim()
    -- if not self._data._isSpecial then
    --     return
    -- end
    if self._rootAnim then
        self:Lock("UISailingProgressRewardsCell:_PlayGetAnim")
        local animName = self._animInfo.nameNormal
        if self._data._isSpecial then
            animName = self._animInfo.nameSpecial
        end
        if self._eff then
            self._eff:SetActive(true)
            if self._effSub1 and self._effSub2 then
                self._effSub1:SetActive(self._data._isSpecial)
                self._effSub2:SetActive(not self._data._isSpecial)
            end
        end
        if self._rootAnim then
            self._rootAnim:Play(animName)
        end
        self:StartTask(
            function(TT)
                YIELD(TT, self._animInfo.len)
                if self._eff then
                    self._eff:SetActive(false)
                end
                self:UnLock("UISailingProgressRewardsCell:_PlayGetAnim")
            end,
            self
        )
    end
end
function UISailingProgressRewardsCell:_SetAlpha(alpha)
    self._setAlphaArea.alpha = alpha
end
function UISailingProgressRewardsCell:SetSelected(isSelected)
    self._selectStateAreaGo:SetActive(isSelected)
end

function UISailingProgressRewardsCell:_CellOnClick()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.SailingOnProgressRewardCellSelect, self._data._cfgID)
end

function UISailingProgressRewardsCell:StateCanGetBgOnClick(go)
    if self._data:CanReceive() then
        if self._getRewardCallback then
            local cfgIDList = {self._data._cfgID}
            self._getRewardCallback(cfgIDList)
        end
    end
    GameGlobal.EventDispatcher():Dispatch(GameEventType.SailingOnProgressRewardCellSelect, self._data._cfgID)
end
function UISailingProgressRewardsCell:BgAreaOnClick(go)
    self:_CellOnClick()
end
function UISailingProgressRewardsCell:BgNormalOnClick(go)
    self:_CellOnClick()
end
function UISailingProgressRewardsCell:BgSpecialOnClick(go)
    self:_CellOnClick()
end
function UISailingProgressRewardsCell:SetState(state)
    self._cellState = state
    if
        self._cellState == ECumulativeLoginRewardStatus.E_CUMULATIVE_LOGIN_REWARD_Expired or
            self._cellState == ECumulativeLoginRewardStatus.E_CUMULATIVE_LOGIN_REWARD_UNKNOW
     then
        self._cellState = ECumulativeLoginRewardStatus.E_CUMULATIVE_LOGIN_REWARD_LOCK
    end
    for index, value in ipairs(self._stateAreaGroup) do
        value:SetActive(index == self._cellState)
    end
    -- if self._cellState == ECumulativeLoginRewardStatus.E_CUMULATIVE_LOGIN_REWARD_RECVED then
    --     self:_SetAlpha(0.5)
    -- else
    --     self:_SetAlpha(1)
    -- end
    self._rewardList:RefreshAllShownItem()
    -- if self._itemWidgetTb then
    --     for _,widget in ipairs(self._itemWidgetTb) do
    --         widget:SetState(state)
    --     end
    -- end
    self:_CheckEff()
    --大奖底板特效 在SetState之后
end

function UISailingProgressRewardsCell:_SetBg(isSpecial)
    self._bgNormalGo:SetActive((isSpecial == false))
    self._bgSpecialGo:SetActive((isSpecial == true))
    self._progressAreaGo:SetActive((isSpecial == false))
    self._specialProgressAreaGo:SetActive((isSpecial == true))
    self._selectCellBorderGo:SetActive((isSpecial == false))
    self._selectCellBorderSpGo:SetActive((isSpecial == true))
end
function UISailingProgressRewardsCell:_FillUi()
    self:_SetBg(self._data._isSpecial)
    self:SetState(self._data._state)
    self._progressNumText:SetText(self._data._progressNum)
    self._specialProgressNumText:SetText(self._data._progressNum)
    -- for index, value in ipairs(self._items) do
    --     if self._data._items[index] then
    --         value:SpawnObject("UISailingProgressRewardItem")
    --         local widgets = value:GetAllSpawnList()
    --         for indexWidget, valueWidget in ipairs(widgets) do
    --             valueWidget:SetData(self._data._items[index], self._itemInfoCallback)
    --             table.insert(self._itemWidgetTb, valueWidget)
    --         end
    --         self._itemGos[index]:SetActive(true)
    --     else
    --         self._itemGos[index]:SetActive(false)
    --     end
    -- end
end
---@param data DSailingProgressRewardsCell
function UISailingProgressRewardsCell:InitData(data, cfg_data, itemInfoCallback, getRewardCallback)
    self._data = data
    self._cfg_data = cfg_data
    self._itemInfoCallback = itemInfoCallback
    self._getRewardCallback = getRewardCallback

    self._rewardCount = table.count(self._data._items)
    if self._isFirst then
        self._isFirst = false
        -- ScrollViewList
        self._rewardList:InitListView(
            self._rewardCount,
            function(scrollView, index)
                return self:_InitScrollViewList(scrollView, index)
            end
        )
    else
        self:_RefreshRewardList(self._data._items, self._rewardList)
    end
    self:_FillUi()
end
function UISailingProgressRewardsCell:_CheckEff()
    local canShowEff = true
    if self._cellState == ECumulativeLoginRewardStatus.E_CUMULATIVE_LOGIN_REWARD_RECVED then
        canShowEff = false
    end
    self._eff_front:SetActive(self._data._isSpecial and canShowEff)
    self._eff_back:SetActive(self._data._isSpecial and canShowEff)
end
function UISailingProgressRewardsCell:_InitScrollViewList(scrollView, index)
    if index < 0 then
        return nil
    end

    local item = scrollView:NewListViewItem("RowItem")
    local rowPool = self:GetUIComponentDynamic("UISelectObjectPath", item.gameObject)
    if item.IsInitHandlerCalled == false then
        item.IsInitHandlerCalled = true
        rowPool:SpawnObjects("UISailingProgressRewardItem", self._itemCountPerRow)
    end

    local rewardList = self._data._items
    local rewardCount = #rewardList
    ---@type UISailingProgressRewardItem[]
    local rowList = rowPool:GetAllSpawnList()
    for i = 1, self._itemCountPerRow do
        local itemIndex = index * self._itemCountPerRow + i
        if itemIndex > rewardCount then
            rowList[i]:GetGameObject():SetActive(false)
        else
            rowList[i]:GetGameObject():SetActive(true)
            rowList[i]:SetData(rewardList[itemIndex], self._itemInfoCallback,self._data._state)
        end
    end
    return item
end
function UISailingProgressRewardsCell:_RefreshRewardList(info, list)
    local count = table.count(info)
    --local contentPos = list.ScrollRect.content.localPosition
    list:SetListItemCount(count)
    list:MovePanelToItemIndex(0, 0)
    list:RefreshAllShownItem()
    --list.ScrollRect.content.localPosition = contentPos
end