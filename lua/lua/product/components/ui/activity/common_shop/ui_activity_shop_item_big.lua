---@class UIActivityShopItemBig : UICustomWidget
---@field _data DCampaignShopItemBase
_class("UIActivityShopItemBig", UICustomWidget)
UIActivityShopItemBig = UIActivityShopItemBig
function UIActivityShopItemBig:OnShow(uiParams)
    self:InitWidget()
end
function UIActivityShopItemBig:InitWidget()
    --generated--
    self._infoCanvasGroup = self:GetUIComponent("CanvasGroup", "InfoArea")
    self._selledAreaGO = self:GetGameObject("SelledArea")
    self._itemRestAreaGO = self:GetGameObject("ItemRestArea")
    self._itemCountAreaGO = self:GetGameObject("ItemCountArea")
    self._bgAreaGO = self:GetGameObject("InfoBg")

    ---@type UnityEngine.UI.Image
    self._infoBg = self:GetUIComponent("Image", "InfoBg")
    self._disabledInfoBg = self:GetUIComponent("Image", "DisabledInfoBg")
    ---@type UILocalizationText
    self._itemNameText = self:GetUIComponent("UILocalizationText", "ItemNameText")
    ---@type RawImageLoader
    self._itemIcon = self:GetUIComponent("RawImageLoader", "ItemIcon")
    self._itemIconGO = self:GetGameObject("ItemIcon")
    self._itemIconPet = self:GetUIComponent("RawImageLoader", "ItemIconPet")
    self._itemIconPetGO = self:GetGameObject("ItemIconPet")
    self._itemIconPetRect = self:GetUIComponent("RectTransform", "ItemIconPet")
    ---@type UILocalizationText
    self._itemCountText = self:GetUIComponent("UILocalizationText", "ItemCountText")
    ---@type UILocalizationText
    self._itemRestText = self:GetUIComponent("UILocalizationText", "ItemRestText")
    ---@type UnityEngine.UI.Image
    self._moneyIcon = self:GetUIComponent("RawImageLoader", "MoneyIcon")
    ---@type UILocalizationText
    self._priceText = self:GetUIComponent("UILocalizationText", "PriceText")
    ---@type UnityEngine.UI.Image
    self.trans = self:GetGameObject().transform
    self._itemRestUnLimitGo = self:GetGameObject("ItemRestUnLimit")
    self._data = {}
    self._itemClickLock = "UIActivityShopSelectItemLock"
    self:AttachEvent(GameEventType.ActivityShopBuySuccess, self._ActivityShopBuySuccess)

    --generated end--
end

function UIActivityShopItemBig:OnHide()
    self:DetachEvent(GameEventType.ActivityShopBuySuccess, self._ActivityShopBuySuccess)
end
function UIActivityShopItemBig:SetData()
end
function UIActivityShopItemBig:InfoAreaOnClick(go)
    local useNormalDlg = false
    if not self._data:IsUnLimit() then
        local remainCount = self._data:GetRemainCount()
        if remainCount <= 0 then
            return
        end
        if remainCount == 1 then
            useNormalDlg = true
        end
    end

    self:StartTask(
        function(TT)
            self:Lock(self._itemClickLock)
            -- self.trans:DOScale(Vector3(0.95, 0.95, 1), 0.1):SetEase(DG.Tweening.Ease.Linear):OnComplete(
            --     function()
            --         self.trans:DOScale(Vector3.one, 0.1):SetEase(DG.Tweening.Ease.Linear)
            --     end
            -- )
            -- YIELD(TT, 300)
            if useNormalDlg then
                self:ShowDialog("UICampaignShopConfirmNormalController", self._data, self.subTabType)
            else
                self:ShowDialog("UICampaignShopConfirmDetailController", self._data, self.subTabType)
            end
            self:UnLock(self._itemClickLock)
        end
    )
end

function UIActivityShopItemBig:InitData(data)
    self._data = data
    self:_fillPriceArea()
    self:_fillItemBaseArea()
    self:_fillItemCountArea()
    self:_FillRemainArea()
end
function UIActivityShopItemBig:_fillPriceArea()
    --self.moneyIcon.sprite = self.uiCommonAtlas:GetSprite(ClientShop.GetCurrencyImageName(self.goodData:GetCostItemId()))
    local currencyId = self._data:GetSaleType()
    self._moneyIcon:LoadImage(ClientCampaignShop.GetCurrencyImageName(currencyId))
    self._priceText:SetText(self._data:GetSalePrice())
end
function UIActivityShopItemBig:_fillItemBaseArea()
    local icon = ""
    local cfgItem = Cfg.cfg_item[self._data:GetItemId()]
    if not cfgItem then
        return
    end
    self._itemNameText:SetText(StringTable.Get(cfgItem.Name))
    local specialIconCfg = Cfg.cfg_activity_shop_special_item_icon_client[self._data:GetItemId()]
    if specialIconCfg and specialIconCfg.UseInBigCell then
        icon = specialIconCfg.SpecialIcon
        self._itemIconPet:LoadImage(icon)
        self._itemIconGO:SetActive(false)
        self._itemIconPetGO:SetActive(true)
        if specialIconCfg.PosInBigCell then
            local b = string.split(specialIconCfg.PosInBigCell, "|")
            local posX = tonumber(b[1])
            local posY = tonumber(b[2])
            self._itemIconPetRect.anchoredPosition = Vector2(posX, posY)
        end
        if specialIconCfg.SizeInBigCell then
            local b = string.split(specialIconCfg.SizeInBigCell, "|")
            local w = tonumber(b[1])
            local h = tonumber(b[2])
            self._itemIconPetRect.sizeDelta = Vector2(w, h)
        end
    else
        icon = cfgItem.Icon
        self._itemIcon:LoadImage(icon)
        self._itemIconGO:SetActive(true)
        self._itemIconPetGO:SetActive(false)
    end
end
function UIActivityShopItemBig:_fillItemCountArea()
    local count = self._data:GetItemCount()
    local text1 = count <= 1 and "" or StringTable.Get("str_shop_good_count") .. count
    if count <= 1 then
        self._itemCountAreaGO:SetActive(false)
    else
        self._itemCountAreaGO:SetActive(true)
        local text1 = StringTable.Get("str_shop_good_count") .. count
        self._itemCountText:SetText(text1)
    end
end
function UIActivityShopItemBig:_FillRemainArea()
    local showRemain = self._data:ShowRemain()
    local remainCount = self._data:GetRemainCount()
    if showRemain == false then
        self._itemRestAreaGO:SetActive(false)
    else
        if self._data:IsUnLimit() then
            self._itemRestAreaGO:SetActive(false)
        else
            if remainCount <= 0 then
                self._itemRestAreaGO:SetActive(false)
            else
                self._itemRestAreaGO:SetActive(true)
                -- 限购10
                --StringTable.Get("str_activity_common_shop_remain",remainCount)
                self._itemRestText:SetText(remainCount)
            end
        end
    end
    if self._data:IsUnLimit() then
        self._selledAreaGO:SetActive(false)
        self._bgAreaGO:SetActive(true)
        self._infoCanvasGroup.blocksRaycasts = true
    else
        if remainCount <= 0 then
            self._selledAreaGO:SetActive(true)
            self._bgAreaGO:SetActive(false)
            --self._disabledInfoBg:SetActive(true)
            --self._infoCanvasGroup.alpha = 0.5
            self._infoCanvasGroup.blocksRaycasts = false
        else
            self._selledAreaGO:SetActive(false)
            self._bgAreaGO:SetActive(true)
            --self._disabledInfoBg:SetActive(false)
            --self._infoCanvasGroup.alpha = 1
            self._infoCanvasGroup.blocksRaycasts = true
        end
    end
    if self._itemRestUnLimitGo then
        self._itemRestUnLimitGo:SetActive(self._data:IsUnLimit())
    end
end
function UIActivityShopItemBig:_ActivityShopBuySuccess(goodsId)
    if self._data and self._data:GetGoodsId() == goodsId then
        local remainCount = self._data:GetRemainCount()
        if remainCount <= 0 then
        -- self.anim:SetTrigger("in")
        end
    end
end
