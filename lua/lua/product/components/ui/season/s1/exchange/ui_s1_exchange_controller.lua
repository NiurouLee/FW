--- @class UIS1ExchangeController:UIController
_class("UIS1ExchangeController", UIController)
UIS1ExchangeController = UIS1ExchangeController

--region help

function UIS1ExchangeController:_SetRemainingTime(widgetName, descId, endTime)
    ---@type UIActivityCommonRemainingTime
    local obj = UIWidgetHelper.SpawnObject(self, widgetName, "UIActivityCommonRemainingTime")
    obj:GetGameObject():SetActive(endTime ~= nil)

    -- obj:SetExtraRollingText()
    obj:SetAdvanceText(descId)

    obj:SetData(endTime, nil, function()
        self:_Refresh()
    end)
end

--endregion

--region resident func [ver_20220506]

function UIS1ExchangeController:_SetCommonTopButton()
    ---@type UICommonTopButton
    local obj = UIWidgetHelper.SpawnObject(self, "_backBtns", "UICommonTopButton")
    obj:SetData(
        function()
            self:_Back()
        end,
        function()
            UISeasonHelper.ShowSeasonHelperBook(UISeasonHelperTabIndex.S1Exchange)
        end,
        nil,
        false,
        nil
    )
end

function UIS1ExchangeController:_Back()
    self:_PlayAnim(2, function()
        self:CloseDialog()
    end)
end

function UIS1ExchangeController:_HideUI()
    self:GetGameObject("_backBtns"):SetActive(false)
    self:GetGameObject("_showBtn"):SetActive(true)

    -- self:GetGameObject("_uiElements"):SetActive(false)
    -- self:_PlayAnim("_ani", "uieff_n13_build_main_hide", 333, nil)
end

function UIS1ExchangeController:_ShowUI()
    self:GetGameObject("_backBtns"):SetActive(true)
    self:GetGameObject("_showBtn"):SetActive(false)

    -- self:GetGameObject("_uiElements"):SetActive(true)
    -- self:_PlayAnim("_ani", "uieff_n13_build_main_show", 333, nil)
end

function UIS1ExchangeController:_SetSpine()
    local obj = self:GetUIComponent("SpineLoader", "_spine")
    obj:LoadSpine("1601054_spine_idle")
end

function UIS1ExchangeController:_SetImgRT(imgRT)
    if imgRT ~= nil then
        ---@type UnityEngine.UI.RawImage
        local rt = self:GetUIComponent("RawImage", "rt")
        rt.texture = imgRT

        return true
    end
    return false
end

function UIS1ExchangeController:_PlayAnim(type, callback)
    local tb = {
        { animName = "uieff_UIS1ExchangeController", duration = 600 },
        { animName = "uieff_UIS1ExchangeController_out", duration = 333 }
    }
    UIWidgetHelper.PlayAnimation(self, "_anim", tb[type].animName, tb[type].duration, callback)
end

function UIS1ExchangeController:_CheckGuide()
    -- GameGlobal.EventDispatcher():Dispatch(GameEventType.GuideOpenUI, GuideOpenUI.UIS1ExchangeController)
end

--endregion

-----------------------------------------------------------------

--- @param TT 协程函数标识
--- @param res AsyncRequestRes 异步请求结果
function UIS1ExchangeController:LoadDataOnEnter(TT, res, uiParams)
    ---@type SeasonModule
    self._seasonModule = GameGlobal.GetModule(SeasonModule)
    local reqRes = self._seasonModule:ForceRequestCurSeasonData(TT)

    self._seasonId = self._seasonModule:GetCurSeasonID()

    --- @type ExchangeItemComponent
    self._component = self._seasonModule:GetCurSeasonExchangeComponent()

    -- -- 错误处理
    if reqRes and not reqRes:GetSucc() then
        self._seasonModule:CheckErrorCode(reqRes.m_result, nil, nil)
        res:SetSucc(false)
        return
    end

    -- -- 清除 new
    -- self._campaign:ClearCampaignNew(TT)
end

function UIS1ExchangeController:OnShow(uiParams)
    self._tipsCallback = function(matid, pos)
        UIWidgetHelper.SetAwardItemTips(self, "_tipsPool", matid, pos)
    end

    if self._component == nil then
        return
    end

    local time = self._component:GetComponentInfo().m_close_time
    self:_SetRemainingTime("_remainingTime", "str_season_s1_main_time_exchange", time)

    self:_SetCommonTopButton()
    self:_SetSpine()

    self:_PlayAnim(1)
    self:_Refresh(true)

    self:_AttachEvents()
end

function UIS1ExchangeController:OnHide()
    self:_DetachEvents()
end

function UIS1ExchangeController:_Refresh(isFirst)
    self:_SetTaken()
    self:_SetTopTips()
    self:_SetDynamicList()
    self:_DynamicListPlayAnimation(isFirst)
end

function UIS1ExchangeController:_SetTaken()
    local itemInfo = self._component:GetExchangeItemSpecial()
    local show = self._component:IsExchangeItemSoldout(itemInfo)
    self:GetGameObject("_taken"):SetActive(show)
end

function UIS1ExchangeController:_SetTopTips()
    local id1, id2 = self._component:GetCostItemId(true), self._component:GetCostItemId(false)
    local tb = { id1, id2 }
    local objs = UIWidgetHelper.SpawnObjects(self, "_topTips", "UIS1TopTips", #tb)
    for i, v in ipairs(objs) do
        v:SetData(tb[i])
    end
end

--region DynamicList

function UIS1ExchangeController:_SetDynamicListData()
    self._infos = UISeasonExchangeHelper.GetExchangeItemList_Sort(self._component)

    self._itemCountPerRow = 1
    self._dynamicListSize = math.floor((table.count(self._infos) - 1) / self._itemCountPerRow + 1)
end

function UIS1ExchangeController:_SetDynamicList()
    self:_SetDynamicListData()

    if not self._isDynamicInited then
        self._isDynamicInited = true

        ---@type UIDynamicScrollView
        self._dynamicList = self:GetUIComponent("UIDynamicScrollView", "DynamicList")

        self._dynamicList:InitListView(
            self._dynamicListSize,
            function(scrollView, index)
                return self:_SpawnListItem(scrollView, index)
            end
        )
    else
        self:_RefreshList(self._dynamicListSize, self._dynamicList)
    end
end

function UIS1ExchangeController:_RefreshList(count, list)
    local contentPos = list.ScrollRect.content.localPosition
    list:SetListItemCount(count)
    list:MovePanelToItemIndex(0, 0)
    list.ScrollRect.content.localPosition = contentPos
end

function UIS1ExchangeController:_SpawnListItem(scrollView, index)
    if index < 0 then
        return nil
    end

    local idx = index * self._itemCountPerRow + 1
    local isLarge = self._infos[idx].m_is_special
    local prefabName = isLarge and "CellLarge" or "CellSmall"
    local className = "UIS1ExchangeCell"

    local item = scrollView:NewListViewItem(prefabName)
    local rowPool = self:GetUIComponentDynamic("UISelectObjectPath", item.gameObject)
    if item.IsInitHandlerCalled == false then
        item.IsInitHandlerCalled = true
        rowPool:SpawnObjects(className, self._itemCountPerRow)
    end

    local rowList = rowPool:GetAllSpawnList()
    for i = 1, self._itemCountPerRow do
        local listItem = rowList[i]
        local itemIndex = index * self._itemCountPerRow + i
        if itemIndex > self._dynamicListSize then
            listItem:GetGameObject():SetActive(false)
        else
            listItem:GetGameObject():SetActive(true)
            self:_SetListItemData(listItem, itemIndex)
        end
    end

    if isLarge then
        -- self:_ReCalcSize()
    end
    return item
end

function UIS1ExchangeController:_SetListItemData(item, index)
    local info = self._infos[index]
    item:SetData(index, info, self._seasonId, self._component, self._tipsCallback)
end

-- 为动态列表中可以变化的元素重新计算大小
function UIS1ExchangeController:_ReCalcSize(rect)
    UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
    self._dynamicList:OnItemSizeChanged(0)
end


function UIS1ExchangeController:_DynamicListPlayAnimation(isPlay)
    if isPlay ~= true then
        return
    end

    local showTabIds = self._dynamicList:GetVisibleItemIDsInScrollView()
    for index = 0, showTabIds.Count - 1 do
        local id = math.floor(showTabIds[index])
        local item = self._dynamicList:GetShownItemByItemIndex(id)
        local rowPool = self:GetUIComponentDynamic("UISelectObjectPath", item.gameObject)
        local rowList = rowPool:GetAllSpawnList()
        for i = 1, self._itemCountPerRow do
            local listItem = rowList[i]
            local itemIndex = index * self._itemCountPerRow + i
            listItem:PlayAnimationInSequence(itemIndex)
        end
    end
end

--endregion

--region Event Callback

function UIS1ExchangeController:SkinBtnOnClick(go)
    local item = self._component:GetExchangeItemSpecial()
    local itemId = item.m_reward.assetid
    self._tipsCallback(itemId)
end

function UIS1ExchangeController:ShowBtnOnClick(go)
    self:_ShowUI()
end

--endregion

--region AttachEvent

function UIS1ExchangeController:_AttachEvents()
    self:AttachEvent(GameEventType.OnUIGetItemCloseInQuest, self._Refresh)
    self:AttachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
end

function UIS1ExchangeController:_DetachEvents()
    self:DetachEvent(GameEventType.OnUIGetItemCloseInQuest, self._Refresh)
    self:DetachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
end

function UIS1ExchangeController:_CheckActivityClose(id)
    if self._seasonId == id then
        self:CloseDialog()
    end
end

--endregion
