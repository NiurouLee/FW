---@class UIActivityN26ShopItem:UICustomWidget
_class("UIActivityN26ShopItem", UICustomWidget)
UIActivityN26ShopItem = UIActivityN26ShopItem

function UIActivityN26ShopItem:OnShow()
    self._petIcon = self:GetGameObject("PetIcon")
    self._petIconLoader = self:GetUIComponent("RawImageLoader", "PetIcon")
    self._petIconRect = self:GetUIComponent("RectTransform", "PetIcon")
    self._icon = self:GetGameObject("Icon")
    self._iconLoader = self:GetUIComponent("RawImageLoader", "Icon")
    self._nameLabel = self:GetUIComponent("UILocalizationText", "Name")
    self._reamainCountLabel = self:GetUIComponent("UILocalizationText", "ReamainCount")
    self._counttLabel = self:GetUIComponent("UILocalizationText", "Count")
    self._costLabel = self:GetUIComponent("UILocalizationText", "Cost")
    self._costIconLoader = self:GetUIComponent("RawImageLoader", "CostIcon")
    self._empty = self:GetGameObject("Empty")
    self._go = self:GetGameObject()
    self._anim = self:GetUIComponent("Animation", "Anim")
end

function UIActivityN26ShopItem:SetVisible(status)
    self._go:SetActive(status)
end

---@param itemInfo ExchangeItemComponentItemInfo
---@param comp ExchangeItemComponent
function UIActivityN26ShopItem:Refresh(itemInfo, comp, callback)
    if itemInfo == nil then
        self._go:SetActive(false)
        return
    end
    self._go:SetActive(true)
    ---@type ExchangeItemComponentItemInfo
    self._itemInfo = itemInfo
    self._callback = callback

    if self._itemInfo.m_exchange_limit_count == -1 then
        self._empty:SetActive(false)
        self._reamainCountLabel:SetText(StringTable.Get("str_n26_item_unlimit_count"))
    else
        self._reamainCountLabel:SetText("x" .. self._itemInfo.m_can_exchange_count)
        if self._itemInfo.m_can_exchange_count == 0 then
            self._empty:SetActive(true)
        else
            self._empty:SetActive(false)
        end
    end
    
    local itemId = self._itemInfo.m_reward.assetid
    local count = self._itemInfo.m_reward.count
    self._counttLabel:SetText("x" .. count)
    local cfgItem = Cfg.cfg_item[itemId]
    if not cfgItem then
        return
    end
    self._nameLabel:SetText(StringTable.Get(cfgItem.Name))
    local specialIconCfg = Cfg.cfg_activity_shop_special_item_icon_client[itemId]

    if specialIconCfg and specialIconCfg.UseInBigCell then
        self._petIconLoader:LoadImage(specialIconCfg.SpecialIcon)
        self._icon:SetActive(false)
        self._petIcon:SetActive(true)
        if specialIconCfg.PosInBigCell then
            local b = string.split(specialIconCfg.PosInBigCell, "|")
            local posX = tonumber(b[1])
            local posY = tonumber(b[2])
            self._petIconRect.anchoredPosition = Vector2(posX,posY)
        end
        if specialIconCfg.SizeInBigCell then
            local b = string.split(specialIconCfg.SizeInBigCell, "|")
            local w = tonumber(b[1])
            local h = tonumber(b[2])
            self._petIconRect.sizeDelta = Vector2(w,h)
        end
    else
        self._icon:SetActive(true)
        self._petIcon:SetActive(false)
        self._iconLoader:LoadImage(cfgItem.Icon)
    end
    
    local icon1, realCount = comp:GetCostItemIconText()
    self._costIconLoader:LoadImage(icon1)
    if self._itemInfo.m_cost_count <= realCount then
        self._costLabel:SetText(UIActivityN26Helper.GetItemCountStr(6, self._itemInfo.m_cost_count, "#45312c", "#45312c"))
    else
        self._costLabel:SetText(UIActivityN26Helper.GetItemCountStr(6, self._itemInfo.m_cost_count, "#45312c", "#ca5c38"))
    end
end

function UIActivityN26ShopItem:BGOnClick()
    if self._itemInfo.m_exchange_limit_count ~= -1 and self._itemInfo.m_can_exchange_count == 0 then
        ToastManager.ShowToast(StringTable.Get("str_n26_item_has_empty_tips"))
        return
    end
    if self._callback then
        self._callback(self._itemInfo)
    end
end
