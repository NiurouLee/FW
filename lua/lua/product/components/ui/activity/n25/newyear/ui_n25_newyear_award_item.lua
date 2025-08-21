---@class UIN25NewYearAwardItem : UICustomWidget
_class("UIN25NewYearAwardItem", UICustomWidget)
UIN25NewYearAwardItem = UIN25NewYearAwardItem

--初始化
function UIN25NewYearAwardItem:OnShow(uiParams)
    self._atlas = self:GetAsset("UIN25NewYear.spriteatlas", LoadType.SpriteAtlas)
    self:_GetComponents()
end

--获取ui组件
function UIN25NewYearAwardItem:_GetComponents()
    self._background = self:GetUIComponent("Image", "Background")
    self._icon = self:GetUIComponent("RawImageLoader", "Icon")
    self._count = self:GetUIComponent("UILocalizationText", "Count")
end

--设置数据
function UIN25NewYearAwardItem:SetData(data, callBack, bigAwardItem)
    self._data = data
    self._callback = callBack
    if bigAwardItem then
        self._background.sprite = self._atlas:GetSprite("N25_knhd_kuang02")
    else
        self._background.sprite = self._atlas:GetSprite("N25_knhd_kuang01")
    end
    local cfg = Cfg.cfg_item[self._data.assetid]
    if cfg == nil then
        Log.fatal("cfg_item is nil." .. self._data.assetid)
        return
    end
    self._icon:LoadImage(cfg.Icon)
    self._count:SetText(self._data.count)
end

function UIN25NewYearAwardItem:IconOnClick(go)
    self._callback(self._data.assetid, go.transform.position)
end