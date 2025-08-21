--
---@class UIShopHomelandItem : UICustomWidget
_class("UIShopHomelandItem", UICustomWidget)
UIShopHomelandItem = UIShopHomelandItem
--初始化
function UIShopHomelandItem:OnShow(uiParams)
    self:_GetComponents()
    self:AttachEvent(GameEventType.AfterUILayerChanged, self._AfterUILayerChanged)
end
--获取ui组件
function UIShopHomelandItem:_GetComponents()
    ---@type RawImageLoader
    self._imgIcon = self:GetUIComponent("RawImageLoader", "ImgIcon")
    ---@type UnityEngine.GameObject
    self._salesPromotionBg = self:GetGameObject("SalesPromotionBg")
    ---@type UILocalizationText
    self._salesPromotion = self:GetUIComponent("UILocalizationText", "SalesPromotion")
    ---@type UILocalizationText
    self._name = self:GetUIComponent("UILocalizationText", "Name")
    ---@type UnityEngine.RectTransform
    self._nameRect = self:GetUIComponent("RectTransform", "Name")
    ---@type UnityEngine.GameObject
    self._countObj = self:GetGameObject("Count")
    ---@type UILocalizationText
    self._countValue = self:GetUIComponent("UILocalizationText", "CountValue")
    ---@type UILocalizationText
    self._gotoText = self:GetUIComponent("UILocalizationText", "GotoText")
    ---@type UnityEngine.GameObject
    self._newObj = self:GetGameObject("New")
end

---@param data HomelandShopItemSet
function UIShopHomelandItem:SetData(data)
    ---@type HomelandShopItemSet
    self._data = data
    self:_RefreshUIInfo()
end

function UIShopHomelandItem:_RefreshUIInfo()
    self._salesPromotionBg:SetActive(self._data.cfg.IsPromotion == true)
    self._name:SetText(StringTable.Get(self._data.cfg.Name))
    if self._data.shopType == FurnitureShopType.FRN_Set then
        local totalCount = self._data:GetAllGoodsCount()
        local selledCount = self._data:GetSelledCount()
        self._countValue:SetText(StringTable.Get("str_shop_homeland_gotcount", selledCount, totalCount))
        self._gotoText:SetText(StringTable.Get("str_shop_homeland_goto_buy"))
        local show = self:GetModule(ShopModule):GetHomelandShopLocalRecord(self._data.shopID, 0)
        self._newObj:SetActive(show <= 0)
        if self._data:IsDiscount() then
            self._imgIcon:LoadImage(self._data.cfg.GroupBigIcon)
        else
            self._imgIcon:LoadImage(self._data.cfg.GroupIcon)
        end
    else
        self._imgIcon:LoadImage(self._data.cfg.GroupIcon)
        self._gotoText:SetText(StringTable.Get("str_shop_homeland_goto_exchange"))
        self._newObj:SetActive(false)
    end
    self._countObj:SetActive(self._data.shopType == FurnitureShopType.FRN_Set)
end

function UIShopHomelandItem:GotoBtnOnClick(go)
    self:OpenDetailUI()
end

function UIShopHomelandItem:ImgIconOnClick(go)
    self:OpenDetailUI()
end


function UIShopHomelandItem:OpenDetailUI()
    if self._data.shopType == FurnitureShopType.FRN_Set then
        self:ShowDialog("UIShopHomelandSet", self._data)
        self:GetModule(ShopModule):SetHomelandShopLocalRecord(self._data.shopID, 1)
        GameGlobal.EventDispatcher():Dispatch(GameEventType.ShopNew)
    elseif self._data.shopType == FurnitureShopType.FRN_Components then
        self:ShowDialog("UIShopHomelandParts", self._data)
    elseif self._data.shopType == FurnitureShopType.FRN_Precious then
        self:ShowDialog("UIShopHomelandPrecious", self._data)
    end
end

function UIShopHomelandItem:_AfterUILayerChanged()
    self:_RefreshUIInfo()
end