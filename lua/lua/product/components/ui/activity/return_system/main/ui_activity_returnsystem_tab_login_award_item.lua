---@class UIActivityReturnSystemTabLoginAwardItem : UICustomWidget
_class("UIActivityReturnSystemTabLoginAwardItem", UICustomWidget)
UIActivityReturnSystemTabLoginAwardItem = UIActivityReturnSystemTabLoginAwardItem

function UIActivityReturnSystemTabLoginAwardItem:OnShow()
    ---@type RawImageLoader
    self.imgIcon = self:GetUIComponent("RawImageLoader", "imgIcon")
    ---@type UILocalizationText
    self.txtCount = self:GetUIComponent("UILocalizationText", "txtCount")
end

function UIActivityReturnSystemTabLoginAwardItem:OnHide()
    if self.imgIcon then
        self.imgIcon:DestoryLastImage()
        self.imgIcon = nil
    end
end

---@param award RoleAsset
function UIActivityReturnSystemTabLoginAwardItem:Flush(award, tipsCallback)
    self.award = award
    self._tipsCallback = tipsCallback

    local cfgv = Cfg.cfg_item[award.assetid]
    self.imgIcon:DestoryLastImage()
    self.imgIcon:LoadImage(cfgv.Icon)
    self.txtCount:SetText(award.count)
end

function UIActivityReturnSystemTabLoginAwardItem:imgIconOnClick(go)
    if self._tipsCallback then
        self._tipsCallback(self.award.assetid, go.transform.position)
    end
end
