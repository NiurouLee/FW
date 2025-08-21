---@class UISummerActivityTwoPlotDetailAwardItem:UICustomWidget
_class("UISummerActivityTwoPlotDetailAwardItem", UICustomWidget)
UISummerActivityTwoPlotDetailAwardItem = UISummerActivityTwoPlotDetailAwardItem

function UISummerActivityTwoPlotDetailAwardItem:OnShow(uiParams)
end

function UISummerActivityTwoPlotDetailAwardItem:SetData(index, cfg, callback, scale)
    self._scale = scale or UIItemScale.Level3
    self:_GetComponents()

    self._index = index
    self._cfg = cfg
    self._callback = callback
    local cfg_item = Cfg.cfg_item[self._cfg.assetid]
    if cfg_item == nil then
        Log.fatal("[quest] error --> cfg_item is nil ! id --> " .. self._cfg.assetid)
        return
    end

    self._cg = cfg_item.Icon
    self._colorEnum = cfg_item.Color

    self:_OnValue()
end

function UISummerActivityTwoPlotDetailAwardItem:OnHide()
    self._cg = nil
    self._index = nil
    self._callback = nil
end

function UISummerActivityTwoPlotDetailAwardItem:_GetComponents()
    local sop = self:GetUIComponent("UISelectObjectPath", "uiitem")
    ---@type UIItem
    self.uiItem = sop:SpawnObject("UIItem")
    self.uiItem:SetForm(UIItemForm.Base, self._scale)
    self.uiItem:SetClickCallBack(
        function(go)
            self:bgOnClick(go)
        end
    )
end

function UISummerActivityTwoPlotDetailAwardItem:_OnValue()
    local icon = self._cg
    local quality = self._colorEnum
    local text1 = self._cfg.count
    self.uiItem:SetData({icon = icon, quality = quality, text1 = text1, itemId = self._cfg.assetid})
end

function UISummerActivityTwoPlotDetailAwardItem:bgOnClick(go)
    if self._callback then
        self._callback(self._cfg.assetid, go.transform.position)
    end
end
