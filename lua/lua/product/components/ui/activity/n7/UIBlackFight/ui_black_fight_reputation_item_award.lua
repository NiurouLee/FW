---@class UIBlackFightReputationItemAward : UICustomWidget
_class("UIBlackFightReputationItemAward", UICustomWidget)
UIBlackFightReputationItemAward = UIBlackFightReputationItemAward

function UIBlackFightReputationItemAward:OnShow()
    ---@type RawImageLoader
    self.icon = self:GetUIComponent("RawImageLoader", "icon")
    ---@type UnityEngine.UI.RawImage
    self.iconRaw = self:GetUIComponent("RawImage", "icon")
    ---@type UILocalizationText
    self.txtCount = self:GetUIComponent("UILocalizationText", "txtCount")
end

function UIBlackFightReputationItemAward:OnHide()
    if self.icon then
        self.icon:DestoryLastImage()
    end
end

---@param award RoleAsset
function UIBlackFightReputationItemAward:Flush(award)
    ---@type RoleAsset
    self.award = award
    local cfgItem = Cfg.cfg_item[award.assetid]
    if cfgItem then
        self.icon:LoadImage(cfgItem.Icon)
        self.txtCount:SetText(award.count)
    else
        Log.warn("### no data in cfg_item. assetid=", award.assetid)
    end
end

function UIBlackFightReputationItemAward:FlushGray(gray)
    if not self._EMIMat then
        self._EMIMat = UnityEngine.Material:New(self.iconRaw.material)
    end
    if gray then
        local texture = self.iconRaw.material.mainTexture
        self.iconRaw.material = self._EMIMat
        self.iconRaw.material.mainTexture = texture
        self.iconRaw.material:SetFloat("_LuminosityAmount", 1)
    else
        self.iconRaw.material:SetFloat("_LuminosityAmount", 0)
    end
end

function UIBlackFightReputationItemAward:iconOnClick()
    GameGlobal.EventDispatcher():Dispatch(
        GameEventType.AircraftInteractiveEventRewardShowItemTips,
        self.award.assetid,
        self:GetGameObject().transform.position
    )
end
