---@class UIHomelandBackpack:UIController
_class("UIHomelandBackpack", UIController)
UIHomelandBackpack = UIHomelandBackpack

---物品详情背景模板
local ItemDetailBgTemplate = 
{
    Default = 1,
    Lv = 2,
    Architecture = 3
}

function UIHomelandBackpack:Constructor()
    self.mHomeland = GameGlobal.GetModule(HomelandModule)
    self.data = self.mHomeland:GetHomelandBackpackData()
    self.mItem = GameGlobal.GetModule(ItemModule)

    self.minShowItemCount = 20 --最少显示多少item
    self.countPerRow = 4 --每行数量

    self.tabMaterial = 1 --道具类型-材料
    self.tabTool = 2 --道具类型-工具
    self.tabArchitecture = 3 --道具类型-建筑
    self.tabTree = 4 --道具类型-奇异树
    self.tabFish = 5 --道具类型-观赏鱼
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.HomelandAudioOpenBackpack)
    self._atlas = self:GetAsset("UIHomelandBackpack.spriteatlas", LoadType.SpriteAtlas)

    self.keyLockAnim = "UIHomelandBackpackonGetItemByIndex"
end

function UIHomelandBackpack:OnShow(uiParams)
    ---@type RawImageLoader
    self.imgIcon = self:GetUIComponent("RawImageLoader", "imgIcon")
    ---@type UILocalizationText
    self.txtName = self:GetUIComponent("UILocalizationText", "txtName")
    ---@type UICustomWidgetPool
    self.tabs = self:GetUIComponent("UISelectObjectPath", "tabs")
    ---@type UIDynamicScrollView
    self.sv = self:GetUIComponent("UIDynamicScrollView", "sv")
    self.default = self:GetGameObject("default")
    self.lv = self:GetGameObject("lv")
    self.architecture = self:GetGameObject("architecture")
    self.bgImg = self:GetUIComponent("Image", "bgImg")
    ---@type UILocalizationText
    self.txtCount = self:GetUIComponent("UILocalizationText", "txtCount")
    ---@type UILocalizationText
    self.txtCurLv = self:GetUIComponent("UILocalizationText", "txtCurLv")
    ---@type UILocalizationText
    self.txtLv = self:GetUIComponent("UILocalizationText", "txtLv")
    self.btnLvUp = self:GetGameObject("btnLvUp")
    self.lvUpRed = self:GetGameObject("lvUpRed")
    ---@type UILocalizationText
    self.txtSize = self:GetUIComponent("UILocalizationText", "txtSize")
    ---@type UILocalizationText
    self.txtPlace = self:GetUIComponent("UILocalizationText", "txtPlace")
    ---@type UILocalizationText
    self.txtDesc = self:GetUIComponent("UILocalizationText", "txtDesc")
    self.goUse = self:GetGameObject("btnUse")
    ---@type UILocalizationText
    self._btnUseText = self:GetUIComponent("UILocalizationText", "btnUseText")
    self.itemInfo = self:GetGameObject("itemInfo")
    self.empty = self:GetGameObject("empty")
    self.presentMask = self:GetGameObject("PresentTipMask")
    self.presentBtnImage = self:GetUIComponent("Image", "PresentBtn")
    self.presentTip = self:GetGameObject("PresentTip")
    self.presentTipText = self:GetUIComponent("UILocalizationText", "PresentTipText")
    ---@type UnityEngine.Animation
    self._safaAreaAnim = self:GetUIComponent("Animation", "SafeArea")
    self.useSv = self:GetGameObject("useSv")
    ---@type UILocalizationText
    self.txtUseDesc = self:GetUIComponent("UILocalizationText","txtUseDesc")

    self:AttachEvent(GameEventType.ItemCountChanged, self.ItemCountChanged)
    self:AttachEvent(GameEventType.HomelandBackpackFoldFilter, self.FoldFilter)
    self:AttachEvent(GameEventType.HomelandBackpackSelectItem, self.HomelandBackpackSelectItem)
    self:AttachEvent(GameEventType.OnItemUpgrade, self.OnItemUpgrade)

    self.filterId = uiParams[1]
    self.subFilter = uiParams[2]
    self.callback = uiParams[3]
    self.curId = 0 --当前选中的item的pstId

    self:Init()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandBackpackFoldFilter, self.filterId or 1)
end
function UIHomelandBackpack:OnHide()
    self.imgIcon:DestoryLastImage()
    self:DetachEvent(GameEventType.ItemCountChanged, self.ItemCountChanged)
    self:DetachEvent(GameEventType.HomelandBackpackFoldFilter, self.FoldFilter)
    self:DetachEvent(GameEventType.HomelandBackpackSelectItem, self.HomelandBackpackSelectItem)
    self:DetachEvent(GameEventType.OnItemUpgrade, self.OnItemUpgrade)
    if GameGlobal.UIStateManager():IsLocked() then
        self:CancelExpirationLock(self.keyLockAnim)
    end
end

--region Init
function UIHomelandBackpack:Init()
    self:InitSrollView()
    self:InitFilter()
end
function UIHomelandBackpack:InitFilter()
    local len = table.count(self.data.filters)
    if self.filterId then
        len = 1
    end
    self.tabs:SpawnObjects("UIHomelandBackpackTab", len)
    ---@type UIHomelandBackpackTab[]
    local uis = self.tabs:GetAllSpawnList()
    local i = 1
    for _, filter in pairs(self.data.filters) do
        if self.filterId then
            if self.filterId == filter.id then
                uis[len]:Init(filter.id)
                break
            end
        else
            uis[i]:Init(filter.id)
            i = i + 1
        end
    end
end
function UIHomelandBackpack:InitSrollView()
    self:CalcList()
    ---@type UIDynamicScrollViewInitParam
    local param = UIDynamicScrollViewInitParam:New()
    param.mItemDefaultWithPaddingSize = 180
    self.sv:InitListView(
        self.countRC,
        function(scrollView, index)
            return self:onGetItemByIndex(scrollView, index)
        end,
        param
    )
end
function UIHomelandBackpack:onGetItemByIndex(scrollView, index)
    if index < 0 then
        return nil
    end
    local countPerRC = self.countPerRow
    local rowItem = scrollView:NewListViewItem("RowItem")
    local pool = self:GetUIComponentDynamic("UISelectObjectPath", rowItem.gameObject)
    if rowItem.IsInitHandlerCalled == false then
        rowItem.IsInitHandlerCalled = true
        pool:SpawnObjects("UIHomelandBackpackItem", countPerRC)
    end

    --region 播放动画期间不允许操作
    local animCount = 0
    local msStep = 75
    --endregion

    ---@type UIHomelandBackpackItem[]
    local uis = pool:GetAllSpawnList()
    for i, ui in ipairs(uis) do
        local idxItem = index * countPerRC + i
        local item = self.list[idxItem]
        local go = ui:GetGameObject()
        if item then
            go:SetActive(true)
            ui:Flush(self.filterId, self:GetItemID(item))
            ui:FlushSelect(self.curId)
            if self._flushingList then
                ui:PlayShowAnim(index, msStep)
                animCount = animCount + 1
            end
        else
            go:SetActive(false)
        end
    end

    --region 播放动画期间不允许操作
    if self._flushingList then
        if animCount > 0 then
            self:ExpirationLock(self.keyLockAnim, animCount * msStep + 333) --item隐藏到显示的时长ms
        end
    end
    --endregion

    return rowItem
end
--endregion

---@param item Item
---获取item的pstId
function UIHomelandBackpack:GetItemID(item)
    if item and item.GetID then
        return item:GetID()
    end
end
---@param item Item
---获取item的tplId
function UIHomelandBackpack:GetItemTplID(item)
    if item and item.GetTemplateID then
        return item:GetTemplateID()
    end
end

function UIHomelandBackpack:FlushList()
    self._flushingList = true
    self:CalcList()
    self.sv:SetListItemCount(self.countRC)
    self.sv:MovePanelToItemIndex(0, 0)
    self:FlushTabRed()
    self._flushingList = false
end
function UIHomelandBackpack:FlushCurItem()
    local item = self:GetCurSelectItem()
    if item then
        self.itemInfo:SetActive(true)
        self.empty:SetActive(false)
        local tpl = item:GetTemplate()
        self.txtName:SetText(StringTable.Get(tpl.Name))
        self.imgIcon:LoadImage(tpl.Icon)
        self.txtDesc:SetText(StringTable.Get(tpl.Intro))
        local useDesc = StringTable.Get(tpl.UseDesc)--道具使用途径描述

        if tpl.UseType == ItemUseType.ItemUseType_ManualUse or tpl.IsDecompose then
            local show = true
            if
                tpl.ItemSubType == ItemSubType.ItemSubType_Seed or
                    tpl.ItemSubType == ItemSubType.ItemSubType_CultivationItem
             then
                show = self.callback ~= nil
            end
            self.goUse:SetActive(show)
        else
            self.goUse:SetActive(false)
        end
        local useBtnStr = "str_common_use"
        if tpl.IsDecompose then
            if not self.callback then --目前只有奇异树有分解
                useBtnStr = "str_homeland_decompose"
            end
        end
        self._btnUseText:SetText(StringTable.Get(useBtnStr))

        if self.filterId == self.tabMaterial then
            self:FlushCurItemDefault()
            self:FlushUseDesc(ItemDetailBgTemplate.Default, useDesc)
        elseif self.filterId == self.tabTool then
            self:FlushCurItemTool()
            self:FlushUseDesc(ItemDetailBgTemplate.Lv, useDesc)
        elseif self.filterId == self.tabFish then
            self:FlushCurItemFish()
            self:FlushUseDesc(ItemDetailBgTemplate.Architecture, useDesc)
        else --建筑和奇异树走这个
            local tplId = item:GetTemplateID()
            if Cfg.cfg_item_architecture[tplId] then
                self:FlushCurItemArchitecture()
                self:FlushUseDesc(ItemDetailBgTemplate.Architecture, useDesc)
            else
                self:FlushCurItemDefault()
                self:FlushUseDesc(ItemDetailBgTemplate.Default, useDesc)
            end
        end
        self._showPresentTip = false
        self.presentTip:SetActive(false)
        self.presentMask:SetActive(false)
        if self:_CanPresent(item) then
            self.presentBtnImage.sprite = self._atlas:GetSprite("n17_pack_icon07")
        else
            self.presentBtnImage.sprite = self._atlas:GetSprite("n17_pack_icon08")
        end
    else
        self.itemInfo:SetActive(false)
        self.empty:SetActive(true)
    end
end
---@return string
function UIHomelandBackpack:FormatCount(count)
    if count > 999999 then
        local c = math.floor(count * 0.001) * 0.1
        return StringTable.Get("str_homeland_backpack_n_w", c)
    end
    return tostring(count)
end
---当前显示的Item-默认
function UIHomelandBackpack:FlushCurItemDefault()
    self.default:SetActive(true)
    self.lv:SetActive(false)
    self.architecture:SetActive(false)

    local item = self:GetCurSelectItem()
    local tplId = item:GetTemplateID()
    local curCount = self.mItem:GetItemCount(tplId)
    self.txtCount:SetText(self:FormatCount(curCount))
end
---当前显示的Item-工具
function UIHomelandBackpack:FlushCurItemTool()
    self.default:SetActive(false)
    self.lv:SetActive(true)
    self.architecture:SetActive(false)

    local item = self:GetCurSelectItem()
    local tplId = item:GetTemplateID()
    local toolItem = self.data:GetHomelandBackpackToolItemByTplId(tplId)
    if toolItem then
        local strCurLv = StringTable.Get("str_homeland_backpack_tool_cur_lv")
        if toolItem:IsLevelMax() then
            self.btnLvUp:SetActive(false)
            self.lvUpRed:SetActive(false)
            strCurLv = strCurLv .. "<color=#E8B429>" .. StringTable.Get("str_homeland_backpack_max_lv") .. "</color>"
        else
            self.btnLvUp:SetActive(true)
            local pstId = item:GetID()
            self.lvUpRed:SetActive(self.data:IsItemLvSatisfy(pstId))
        end
        self.txtCurLv:SetText(strCurLv)
        self.txtLv:SetText(toolItem.lv)
    end
end
---当前显示的Item-建筑
function UIHomelandBackpack:FlushCurItemArchitecture()
    self.default:SetActive(false)
    self.lv:SetActive(false)
    self.architecture:SetActive(true)

    local item = self:GetCurSelectItem()
    local tplId = item:GetTemplateID()
    local cfg_item_architecture = Cfg.cfg_item_architecture[tplId]
    if cfg_item_architecture then
        local x = cfg_item_architecture.Size[1]
        local y = cfg_item_architecture.Size[2]
        self.txtSize:SetText(x .. "*" .. y)
    else
        self.txtSize:SetText("--")
        Log.error("### no data in cfg_item_architecture. id =", tplId)
    end

    local curCount, placedCount = 0, 0
    curCount, placedCount = UIForgeData.GetOwnPlaceCount(tplId)
    self.txtPlace:SetText(self:FormatCount(placedCount) .. "/" .. self:FormatCount(curCount))
end
---当前显示的Item-观赏鱼
function UIHomelandBackpack:FlushCurItemFish()
    self.default:SetActive(false)
    self.lv:SetActive(false)
    self.architecture:SetActive(true)

    self.txtSize:SetText("--")

    local item = self:GetCurSelectItem()
    local tplId = item:GetTemplateID()
    local curCount, placedCount = 0, 0
    curCount = GameGlobal.GetModule(ItemModule):GetItemCount(tplId)
    -- local dict = self.mHomeland:GetFishsInWishingBuilding()
    -- placedCount = dict[tplId] or 0
    placedCount = self.mHomeland:GetFishsInBuilding(tplId)
    self.txtPlace:SetText(self:FormatCount(placedCount) .. "/" .. self:FormatCount(curCount))
end

---当前显示的Item-使用途径描述
---@param template 详情背景框模板 ItemDetailBgTemplate
---@param useDesc 道具使用途径描述内容
function UIHomelandBackpack:FlushUseDesc(template, useDesc)
    self.useSv:SetActive(useDesc ~= nil)
    if useDesc then
        self.txtUseDesc:SetText(useDesc)
    end

    --bg for item detail
    if template == ItemDetailBgTemplate.Default then
        self.bgImg.sprite = self._atlas:GetSprite(useDesc == nil and "n17_shop_di07" or "n17_pack_di08")
    elseif template == ItemDetailBgTemplate.Lv then
        self.bgImg.sprite = self._atlas:GetSprite(useDesc == nil and "n17_pack_di02" or "n17_pack_di07")
    elseif template ==ItemDetailBgTemplate.Architecture  then
        self.bgImg.sprite = self._atlas:GetSprite(useDesc == nil and "n17_shop_di10" or "n17_pack_di09")
    end
    self.bgImg:SetNativeSize()
end

function UIHomelandBackpack:CalcList()
    ---@type Item[]
    self.list = {}
    for _, item in ipairs(self.data.list) do
        if item:GetTemplate().TabType == self.filterId and (not self.subFilter or self.subFilter(item)) then
            table.insert(self.list, item)
        end
    end
    local len = table.count(self.list)
    if len < self.minShowItemCount then
        for i = len + 1, self.minShowItemCount do
            table.insert(self.list, {})
        end
    end
    self.count = table.count(self.list)
    self.countRC = math.ceil(self.count / self.countPerRow) --行/列数
end

function UIHomelandBackpack:FoldFilter(id)
    self._safaAreaAnim.enabled = true
    self._safaAreaAnim:Play("UIHomelandBackpack_ui_Switching")
    self._safaAreaAnim:Rewind("UIHomelandBackpack_ui_Switching")
    self.filterId = id
    self:FlushList()
    local pstId = self:GetItemID(self.list[1])
    if pstId then
        GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandBackpackSelectItem, pstId)
    else
        GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandBackpackSelectItem, 0)
    end
end

function UIHomelandBackpack:FlushTabRed()
    ---@type UIHomelandBackpackTab[]
    local uis = self.tabs:GetAllSpawnList()
    if not uis then
        return
    end
    if #uis <= 1 then
        local ui = uis[1]
        local isShow = self.data:IsFilterNew(self.filterId)
        ui:FlushRed(isShow)
    else
        local i = 1
        for _, filter in pairs(self.data.filters) do
            local ui = uis[i]
            local isShow = self.data:IsFilterNew(filter.id)
            ui:FlushRed(isShow)
            i = i + 1
        end
    end
end

---@param id number Item的pstId
---@param byClick boolean
---@param item UIHomelandBackpackItem
function UIHomelandBackpack:HomelandBackpackSelectItem(id, byClick, item)
    self.curId = id
    self:FlushCurItem()
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.SoundSwitch)
    -- 如果是点击物品 同时还需要消除红点
    if byClick then
        local dataItem = self:GetCurSelectItem()
        if dataItem then
            local tplId = dataItem:GetTemplateID()
            local pstId = dataItem:GetID()
            if dataItem:IsHomelandNew() then
            --MSG56100	（QA_孟伟）背包QA_自选箱消除红点规则_20230113	5	QA-开发制作中	李学森, 1958	01/13/2023	
            --if dataItem:IsHomelandNew() and not self.mItem:IsChoosePetGift(tplId) then
                self:StartTask(
                    function(TT)
                        self:Lock("UIHomelandBackpack:HomelandBackpackSelectItem")
                        self.ignoreItemCountChangeEvent = true
                        self.mItem:SetItemUnnew(TT, pstId)
                        self.data:UnnewItem(self.filterId, pstId)
                        self:FlushTabRed()
                        item:FlushRed()
                        self.ignoreItemCountChangeEvent = false
                        self:UnLock("UIHomelandBackpack:HomelandBackpackSelectItem")
                    end
                )
            end
        end
    end
end

function UIHomelandBackpack:OnItemUpgrade(tplId)
    if self.list and table.count(self.list) > 0 then
        for _, item in ipairs(self.list) do
            local pstId = self:GetItemID(item)
            local tplId = self:GetItemTplID(item)
            if tplId == tplId then
                GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandBackpackSelectItem, pstId) --每种工具只能有1个，所以只需要去查tplId就能拿到升级的工具
                break
            end
        end
    end
end

---@return Item
function UIHomelandBackpack:GetCurSelectItem()
    local item = self.data:GetItemById(self.curId)
    return item
end

function UIHomelandBackpack:ItemCountChanged()
    if self.ignoreItemCountChangeEvent then
        return
    end
    self.data:Init()
    local dataItem = self.data:GetItemById(self.curId)
    if not dataItem then
        if self.list[1].GetID then
            self.curId = self.list[1]:GetID()
        end
    end
    self:FlushList()
    self:FlushCurItem()
end

function UIHomelandBackpack:btnBackOnClick(go)
    self:CloseDialog()
end

function UIHomelandBackpack:btnGetFromOnClick(go)
    local item = self:GetCurSelectItem()
    if item then
        self:ShowDialog("UIHomelandGetPath", item:GetTemplateID())
    end
end

--region Use
function UIHomelandBackpack:btnUseOnClick(go)
    local item = self:GetCurSelectItem()
    local tpl = item:GetTemplate()
    if tpl.UseType ~= ItemUseType.ItemUseType_ManualUse and not tpl.IsDecompose then
        return
    end
    if not self:CheckLessTime(tpl.ID) then
        ToastManager.ShowHomeToast(StringTable.Get("str_item_public_time_out"))
        return
    end
    local UseItem = function(isGift)
        if item:GetCount() == 1 then
            self:StartTaskUseItem(item, 1, isGift)
        else
            self:ShowDialog(
                "UIHomelandSaleAndUseWithCount",
                item,
                EnumItemSaleAndUseState.Use,
                function(item_data, count)
                    self:StartTaskUseItem(item_data, count, isGift)
                end
            )
        end
    end
    if tpl.ItemSubType == ItemSubType.ItemSubType_Base then
        if item:IsAwakeDirectlyItem() then --觉醒直升道具打开特殊的界面
            self:ShowDialog(
                "UIAwakeDirectly",
                item,
                function(data, petID)
                    self:StartTaskUseItem(data, 1, false, petID)
                end
            )
        else
            UseItem(false)
        end
    elseif
        tpl.ItemSubType == ItemSubType.ItemSubType_Seed or tpl.ItemSubType == ItemSubType.ItemSubType_CultivationItem or
            tpl.ItemSubType == ItemSubType.ItemSubType_Architecture
     then
        if self.callback then
            local result = self.callback(item)
            if result then
                self:CloseDialog()
            end
        else
            if tpl.IsDecompose then
                self:ShowDialog("UIHomelandDecompose", item)
            end
        end
    else
        local giftType = self.mItem:GetItemGiftType(item:GetTemplateID())
        if giftType ~= ItemGiftType.ItemGiftType_Choose then
            UseItem(true)
        else
            if self.mItem:IsChoosePetGift(item:GetTemplateID()) then
                self:ShowDialog("UIPetBackPackBox", item)
            else
                if item:GetCount() == 1 then
                    self:ShowDialog("UIHomelandBackpackBox", item, 1)
                else
                    self:ShowDialog(
                        "UIHomelandSaleAndUseWithCount",
                        item,
                        EnumItemSaleAndUseState.Use,
                        function(item_data, count)
                            self:ShowDialog("UIHomelandBackpackBox", item_data, count)
                        end
                    )
                end
            end
        end
    end
end
---@param id number Item Template Id
function UIHomelandBackpack:CheckLessTime(id)
    local cfg_item = Cfg.cfg_item[id]
    if not cfg_item then
        Log.error("###[UIBackPackItem] cfg is nil ! id --> ", id)
    end
    if not string.isnullorempty(cfg_item.DeadTime) then
        local timeType = Enum_DateTimeZoneType.E_ZoneType_ServerTimeZone
        if cfg_item.TimeTransform and cfg_item.TimeTransform == 0 then
            timeType = Enum_DateTimeZoneType.E_ZoneType_GMT
        end
        local lessTime = math.floor(self._loginModule:GetTimeStampByTimeStr(cfg_item.DeadTime, timeType))
        local nowTime = math.floor(self._svrTimeModule:GetServerTime() * 0.001)
        local gapTime = lessTime - nowTime
        if gapTime <= 0 then
            return false
        end
    end
    return true
end
--使用和出售的回调
---@param item Item
---@param count number
---@param isGift boolean
function UIHomelandBackpack:StartTaskUseItem(item, count, isGift, param1, param2, param3)
    GameGlobal.GetModule(PetModule):GetAllPetsSnapshoot()
    self._lastIndex = self._selectItemIndex
    self:StartTask(self.UseItem, self, item, count, isGift, param1, param2, param3)
end
---@param item Item
---@param count number
---@param isGift boolean
function UIHomelandBackpack:UseItem(TT, item, count, isGift, param1, param2, param3)
    local key = "UIHomelandBackpack_UseItem"
    self:Lock(key)
    local tpl = item:GetTemplate()
    GameGlobal.UAReportForceGuideEvent("UIBackPackControllerUseItem", {tpl.ID or 0}, true)
    local tplId = self:GetItemID(item)
    local res, msg = self.mItem:RequestUseItemByPstID(TT, tplId, count, param1, param2, param3)
    self:UnLock(key)
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
                    self:CloseDialog("UIPetObtain")
                    self:ShowDialog("UIHomeShowAwards", msg.m_reward_list, nil, false)
                end
            )
        else --列表为空就不弹窗
            if msg.m_reward_list and next(msg.m_reward_list) then
                self:ShowDialog("UIHomeShowAwards", msg.m_reward_list, nil, false)
            end
        end
    else
        if item.m_template_data.UseEffect == "PhyGift" then
            local stMsg = StringTable.Get("str_physicalpower_error_phy_add_full")
            ToastManager.ShowHomeToast(stMsg)
        else
            Log.fatal("[item] ### UseItem failed :" .. res.m_result)
        end
    end
end
--endregion

--region Level
function UIHomelandBackpack:btnLvUpOnClick(go)
    local item = self:GetCurSelectItem()
    local id = self:GetItemID(item)
    self:ShowDialog("UIHomelandToolLevelUp", id)
end
--endregion

function UIHomelandBackpack:PresentBtnOnClick()
    self._showPresentTip = true
    self.presentTip:SetActive(true)
    self.presentMask:SetActive(true)
    local item = self:GetCurSelectItem()
    if self:_CanPresent(item) then
        self.presentTipText:SetText(StringTable.Get("str_homeland_backpack_gift_can_present"))
    else
        self.presentTipText:SetText(StringTable.Get("str_homeland_backpack_gift_cant_present"))
    end
end

---@param item Item
function UIHomelandBackpack:_CanPresent(item)
    local id = item:GetTemplateID()
    local cfg = Cfg.cfg_homeland_gift_item[id]
    return cfg and cfg.PutMaxNum > 0
end

function UIHomelandBackpack:PresentTipMaskOnClick()
    self._showPresentTip = false
    self.presentTip:SetActive(false)
    self.presentMask:SetActive(false)
end

function UIHomelandBackpack:imgIconOnClick(go)
    local item = self:GetCurSelectItem()
    local str = "del_asset h " .. item:GetTemplateID() .. " " .. item:GetCount()
    HelperProxy:GetInstance():CopyString(str)
    Log.fatal(str)
end