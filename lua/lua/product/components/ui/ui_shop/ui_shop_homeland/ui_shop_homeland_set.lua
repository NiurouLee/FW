--
---@class UIShopHomelandSet : UIController
_class("UIShopHomelandSet", UIController)
UIShopHomelandSet = UIShopHomelandSet

function UIShopHomelandSet:Constructor()
    self._shopModule = self:GetModule(ShopModule)
    self._clientShop = self._shopModule:GetClientShop()
    self._shopData = self._clientShop:GetHomelandShopData()
    ---@type UIHomelandModule
    self._homeLandModule = GameGlobal.GetUIModule(HomelandModule)
    self._atlas = self:GetAsset("UIShop.spriteatlas", LoadType.SpriteAtlas)
end

---@param res AsyncRequestRes
function UIShopHomelandSet:LoadDataOnEnter(TT, res)
    res:SetSucc(true)
end
--初始化
function UIShopHomelandSet:OnShow(uiParams)
    ---@type HomelandShopItemSet
    self._data = uiParams[1]
    self:_GetComponents()
    self:_OnValue()
    self:AttachEvent(GameEventType.ShopBuySuccess, self._OnBuySuccess)
    self:AttachEvent(GameEventType.OpenShop, self.OpenShop)
end
--获取ui组件
function UIShopHomelandSet:_GetComponents()
    self._backBtn = self:GetUIComponent("UISelectObjectPath", "BackBtn")
    self._commonTopBtn = self._backBtn:SpawnObject("UICommonTopButton")
    local hideHomeBtn = self._homeLandModule:IsRunning()
    self._commonTopBtn:SetData(
        function()
            self:CloseDialog()
        end,
        nil,
        nil,
        hideHomeBtn
    )
    ---@type UILocalizationText
    self._setNameOutLineTextBg = self:GetUIComponent("UILocalizationText", "SetNameOutLineTextBg")
    ---@type UILocalizationText
    self._setNameOutLineText = self:GetUIComponent("UILocalizationText", "SetNameOutLineText")
    ---@type UILocalizedTMP
    self._setName = self:GetUIComponent("UILocalizedTMP", "SetName")
    ---@type UILocalizedTMP
    self._setNameN23 = self:GetUIComponent("UILocalizedTMP", "SetNameN23")
    ---@type UILocalizedTMP
    self._setNameN25 = self:GetUIComponent("UILocalizedTMP", "SetNameN25")
    ---@type UILocalizedTMP
    self._setNameN27 = self:GetUIComponent("UILocalizedTMP", "SetNameN27")
    ---@type UILocalizedTMP
    self._setNameN29 = self:GetUIComponent("UILocalizedTMP", "SetNameN29")
    ---@type UILocalizedTMP
    self._setNameN31 = self:GetUIComponent("UILocalizedTMP", "SetNameN31")
    ---@type RawImageLoader
    self._awardIcon = self:GetUIComponent("RawImageLoader", "AwardIcon")
    ---@type UILocalizationText
    self._name = self:GetUIComponent("UILocalizationText", "Name")
    ---@type UILocalizationText
    self._awardText = self:GetUIComponent("UILocalizationText", "AwardText")
    ---@type UILocalizationText
    self._collectProgress = self:GetUIComponent("UILocalizationText", "CollectProgress")
    ---@type UICustomWidgetPool
    self._content = self:GetUIComponent("UISelectObjectPath", "Content")
    local menu = self:GetUIComponent("UISelectObjectPath", "CurrencyMenu")
    ---@type UICurrencyMenu
    self._currencyMenu = menu:SpawnObject("UICurrencyMenu")
    ---@type RawImageLoader
    self._showImage = self:GetUIComponent("RawImageLoader", "ShowImage")
    ---@type UnityEngine.RectTransform
    self._showImageRect = self:GetUIComponent("RectTransform", "ShowImage")
    ---@type UnityEngine.UI.ScrollRect
    self._scrollRect = self:GetUIComponent("ScrollRect", "ScrollView")
    ---@type UnityEngine.RectTransform
    self._scrollRectTransform = self:GetUIComponent("RectTransform", "ScrollView")
    self._awardLock = self:GetGameObject("AwardLock")
    self._redpoint = self:GetGameObject("Redpoint")
    ---@type RawImageLoader
    self._background = self:GetUIComponent("RawImageLoader", "Background")
    self._gotBackground = self:GetUIComponent("Image", "GotBackground")
    ---@type CircleOutline
    self._lockTextCircleOutline = self:GetUIComponent("H3D.UGUI.CircleOutline", "LockText")
    self._showBtn = self:GetUIComponent("Image", "ShowBtn")
    self._bigAwardTitleBg = self:GetUIComponent("Image", "BigAwardTitleBg")
end

function UIShopHomelandSet:_OnValue()
    local name = StringTable.Get(self._data.cfg.Name)
    self._setNameOutLineTextBg:SetText(name)
    self._setNameOutLineText:SetText(name)
    if self._data.cfg.ShopId == UIShopHomelandThemeKey.N31 then --n31
        self._setNameN31:SetText(name)
    elseif self._data.cfg.ShopId == UIShopHomelandThemeKey.N29 then --n29
        self._setNameN29:SetText(name)
    elseif self._data.cfg.ShopId == UIShopHomelandThemeKey.N27 then --n27
        self._setNameN27:SetText(name)
    elseif self._data.cfg.ShopId == UIShopHomelandThemeKey.N25 then --n25
        self._setNameN25:SetText(name)
    elseif self._data.cfg.ShopId == UIShopHomelandThemeKey.N23 then --n23
        self._setNameN23:SetText(name)
    else
        self._setName:SetText(name)
    end
    local theme = UIShopHomelandTheme[self._data.cfg.ShopId]
    if theme then
        self._showBtn.sprite = self._atlas:GetSprite(theme.ShowBtn)
        self._bigAwardTitleBg.sprite = self._atlas:GetSprite(theme.BigAwardTitleBg)
        self._gotBackground.sprite = self._atlas:GetSprite(theme.GotBackground)
        self._lockTextCircleOutline.effectColor = theme.LockTextOutLine
    end
    if self._data.cfg then
        if self._data.cfg.ShowImage then
            local imageInfo = self._data.cfg.ShowImage[1]
            self._showImage:LoadImage(imageInfo.image)
            self._showImageRect.sizeDelta = Vector2(imageInfo.width, imageInfo.height)
            self._showImageRect.anchoredPosition = Vector2(imageInfo.x, imageInfo.y)
        end
        if self._data.cfg.Background then
            self._background:LoadImage(self._data.cfg.Background)
        end
    end
    self._currencyMenu:SetData({RoleAssetID.RoleAssetFurnitureCoin, RoleAssetID.RoleAssetGlow})
    self._specialGoods, self._normalGoods = self:_ClassifyGoods()
    --套组奖励
    if self._specialGoods[1] then
        self._awardIcon:LoadImage(self._specialGoods[1].cfg.Icon)
        self._name:SetText(StringTable.Get(self._specialGoods[1].cfg.Name))
        local sellOut = self._specialGoods[1]:IsSellOut()
        if sellOut then
            self._awardText:SetText(StringTable.Get("str_shop_homeland_got_award"))
        else
            self._awardText:SetText(StringTable.Get("str_shop_homeland_set_desc"))
        end
        self._awardLock:SetActive(sellOut)
        local selledCount, totalCount = self:_GetCollectedProgress(self._normalGoods)
        self._collectProgress:SetText(StringTable.Get("str_shop_homeland_collect_progress", selledCount, totalCount))
        self._redpoint:SetActive(selledCount >= totalCount and not sellOut)
    end
    --普通商品
    self._content:SpawnObjects("UIShopHomelandGoodsItem", #self._normalGoods)
    ---@type UIShopHomelandGoodsItem[]
    self._goodsWidgets = self._content:GetAllSpawnList()
    for key, widget in pairs(self._goodsWidgets) do
        widget:SetData(key, self._normalGoods[key], MarketType.Shop_Furniture, self._data.cfg.ShopId)
    end
    local count = math.floor(self._scrollRectTransform.sizeDelta.x / 430) * 2
    self._scrollRect.horizontal = #self._normalGoods >= count
end

function UIShopHomelandSet:_ClassifyGoods()
    local specialGoods = {}
    local normalGoods = {}
    for _, goods in pairs(self._data.goods) do
        if goods:IsSelling() then
            if goods.isSpecial then
                table.insert(specialGoods, goods)
            else
                table.insert(normalGoods, goods)
            end
        end
    end
    return specialGoods, normalGoods
end

---@param goods HomelandShopItem[]
function UIShopHomelandSet:_GetCollectedProgress(goods)
    local totalCount = 0
    local selledCount = 0
    for _, goods in pairs(goods) do
        if goods:IsSelling() then
            totalCount = totalCount + goods.goodsCount
            selledCount = selledCount + goods.selledCount
        end
    end
    return selledCount, totalCount
end

---@param goods HomelandShopItem
function UIShopHomelandSet:_UpdateGoods(goods)
    for key, value in pairs(self._normalGoods) do
        if value.goodsID == goods.goodsID then
            self._normalGoods[key] = goods
            break
        end
    end
    if self._specialGoods[1] then
        if self._specialGoods[1].goodsID == goods.goodsID then
            self._specialGoods[1] = goods
        end
    end
end

function UIShopHomelandSet:_OnBuySuccess(goodsID)
    self:Lock("UIShopHomelandSet_OnBuySuccess")
    self._refreshTaskID = self:StartTask(
        function(TT)
            if self._clientShop:SendProtocal(TT, ShopMainTabType.Homeland) then
                local goods = self._shopData:GetGoodsByGoodsId(goodsID)
                self._data:UpdateGoods(goods)
                self:_UpdateGoods(goods)
                self._data:Sort(self._normalGoods)
                for key, widget in pairs(self._goodsWidgets) do
                    widget:SetData(key, self._normalGoods[key], MarketType.Shop_Furniture, self._data.cfg.ShopId)
                end
                if self._specialGoods[1] then
                    local sellOut = self._specialGoods[1]:IsSellOut()
                    self._awardLock:SetActive(sellOut)
                    local selledCount, totalCount = self:_GetCollectedProgress(self._normalGoods)
                    self._collectProgress:SetText(StringTable.Get("str_shop_homeland_collect_progress", selledCount, totalCount))
                    self._redpoint:SetActive(selledCount >= totalCount and not sellOut)
                end
            end
            self:UnLock("UIShopHomelandSet_OnBuySuccess")
        end,
        self
    )
end

function UIShopHomelandSet:AwardIconOnClick(go)
    local selledCount, totalCount = self:_GetCollectedProgress(self._normalGoods)
    if selledCount < totalCount then
        ToastManager.ShowToast(StringTable.Get("str_shop_homeland_set_desc"))
        return
    end
    if self._specialGoods[1]:IsSellOut() then
        ToastManager.ShowToast(StringTable.Get("str_shop_homeland_got_award"))
        return
    end
    self:StartTask(
        function(TT)
            local shopModule = self:GetModule(ShopModule)
            self:Lock("UIShopHomelandSetGetAward")
            local result = shopModule:BuyItem(
                TT,
                MarketType.Shop_Furniture,
                self._specialGoods[1].goodsID,
                1,
                self._specialGoods[1]:GetSaleType(),
                self._specialGoods[1]:GetSalePrice()
            )
            self:UnLock("UIShopHomelandSetGetAward")
            if result then
                if ClientShop.CheckShopCode(result) then
                    local roleAsset = RoleAsset:New()
                    roleAsset.assetid = self._specialGoods[1]:GetItemId()
                    roleAsset.count = self._specialGoods[1]:GetItemCount()
                    local assetList = {roleAsset}
                    self:ShowDialog("UIGetItemController",
                        assetList,
                        function()
                            self:_OnBuySuccess(self._specialGoods[1].goodsID)
                            self._awardText:SetText(StringTable.Get("str_shop_homeland_got_award"))
                        end
                    )
                end
            end
        end,
        self
    )
end

function UIShopHomelandSet:ShowBtnOnClick()
    self:ShowDialog("UIShopHomelandPreview", self._data.cfg.PreviewPictures)
end

---@param mainTabType ShopMainTabType
function UIShopHomelandSet:OpenShop(mainTabType)
    if mainTabType == ShopMainTabType.Recharge then
        self:CloseDialog()
    end
end