---@class UIS1ExchangeCell:UICustomWidget
_class("UIS1ExchangeCell", UICustomWidget)
UIS1ExchangeCell = UIS1ExchangeCell

function UIS1ExchangeCell:SetData(index, info, seasonId, component, tipsCallback)
    self._index = index
    ---@type ExchangeItemComponentItemInfo
    self._info = info
    self._seasonId = seasonId
    --- @type ExchangeItemComponent
    self._component = component
    self._tipsCallback = tipsCallback

    local type = self:_GetType()

    self:_SetBg(type)
    self:_SetRemain()
    self:_SetDiscount()
    self:_SetItem(type)
    self:_SetCoin()
    self:_SetSoldout()
end

function UIS1ExchangeCell:PlayAnimationInSequence(index)
    local tb = {
        { animName = "uieff_UIS1Exchange_Cell_Large", duration = 600 },
        { animName = "uieff_UIS1Exchange_Cell_Small", duration = 600 },
        { animName = "uieff_UIS1Exchange_Cell_Small", duration = 600 }
    }
    local type = self:_GetType()
    local animName, duration = tb[type].animName, tb[type].duration
    local delay = index * 60
    UIWidgetHelper.PlayAnimationInSequence(self, "_anim", "_anim", animName, delay, duration)
end

function UIS1ExchangeCell:_GetType()
    local special = self._info.m_is_special
    local bold = UISeasonExchangeHelper.GetBold(self._component, self._info.m_id)

    local type = special and 1 or (bold and 2 or 3)
    return type
end

function UIS1ExchangeCell:_SetBg(type)
    local tb = {
        [1] = "exp_s1_shop_shizhuangtu1",
        [2] = "exp_s1_shop_tuchudaoju1",
        [3] = "exp_s1_shop_putongdaoju1"
    }

    local atlasName = "UIS1Exchange.spriteatlas"
    local spriteName = tb[type]
    UIWidgetHelper.SetImageSprite(self, "_bg", atlasName, spriteName)
end

function UIS1ExchangeCell:_SetRemain()
    local constHide = 0
    local remain = self._component:GetCanExchangeCount(self._info, constHide)
    local str = StringTable.Get("str_season_s1_exchange_remain", remain)
    UIWidgetHelper.SetLocalizationText(self, "_remainText", str)
    self:GetGameObject("_remainBg"):SetActive(remain ~= 0)
end

function UIS1ExchangeCell:_SetDiscount()
    local discount = UISeasonExchangeHelper.GetDiscount(self._component, self._info.m_id)
    local str = "-" .. discount .. "%"
    UIWidgetHelper.SetLocalizationText(self, "_discountText", str)
    self:GetGameObject("_discountBg"):SetActive(discount ~= 0)
end

function UIS1ExchangeCell:_SetItem(type)
    local roleAsset = self._info.m_reward
    UIWidgetHelper.SetItemIcon(self, roleAsset.assetid , "_icon")
    UIWidgetHelper.SetLocalizationText(self, "_count", roleAsset.count)

    UIWidgetHelper.SetItemText(self, roleAsset.assetid , "_title")

    local tb = {
        [1] = "#FFFFFF",
        [2] = "#865737",
        [3] = "#4e2929"
    }
    UIStyleHelper.FitStyle_Widget({ color = tb[type] }, self, "_title")
end

function UIS1ExchangeCell:_SetCoin()
    local itemId = self._component:GetCostItemId(self._info.m_is_special)
    local atlasName = "UICommon.spriteatlas"
    local spriteName = "toptoon_" .. itemId
    UIWidgetHelper.SetImageSprite(self, "_coin", atlasName, spriteName)

    local price1 = UISeasonExchangeHelper.GetPrice(self._component, self._info.m_id)
    UIWidgetHelper.SetLocalizationText(self, "_price1", price1)
    self:GetGameObject("_price1"):SetActive(price1 ~= 0)

    local price2 = self._info.m_cost_count
    UIWidgetHelper.SetLocalizationText(self, "_price2", price2)
end

function UIS1ExchangeCell:_SetSoldout()
    local isSoldout = self._component:IsExchangeItemSoldout(self._info)
    self:GetGameObject("_soldout"):SetActive(isSoldout)
end

--region Event

function UIS1ExchangeCell:BtnOnClick()
    Log.info("UIS1ExchangeCell:BtnOnClick index = ", self._index)
    local isSoldout = self._component:IsExchangeItemSoldout(self._info)
    if isSoldout then
        ToastManager.ShowToast(StringTable.Get("str_activity_common_shop_sold_out_msg"))
    else
        self:ShowDialog("UIS1ExchangeConfirm", self._seasonId, self._component, self._info)
    end
end

--endregion
