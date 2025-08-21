---@class UIXH1PointInfo : UICustomWidget
_class("UIXH1PointInfo", UICustomWidget)
UIXH1PointInfo = UIXH1PointInfo
function UIXH1PointInfo:OnShow(uiParams)
    self:InitWidget()
end
function UIXH1PointInfo:InitWidget()
    --generated--
    ---@type RawImageLoader
    self.icon = self:GetUIComponent("Image", "icon")
    ---@type UILocalizationText
    self.text = self:GetUIComponent("UILocalizationText", "text")
    --generated end--
end
function UIXH1PointInfo:SetData(camCpt, needCount)
    ---@type ICampaignComponent
    self._campComponent = camCpt
    local cmpID = self._campComponent:GetComponentCfgId()
    local cfg = self._campComponent:GetActionPointConfig()
    if cfg == nil then
        Log.exception("cfg_component_action_point中找不到组件ID:", cmpID)
    end
    self._pointID = cfg.ItemID
    local module = self:GetModule(ItemModule)
    local count = module:GetItemCount(self._pointID)
    if not count then
        count = 0
    end
    local ceiling = cfg.RegainMax
    local text
    if count < needCount then
        text = "<color=#00ffea>" .. count .. "</color>" .. " /" .. ceiling
    else
        text = count .. " /" .. ceiling
    end
    self.text:SetText(text)

    local itemCfg = Cfg.cfg_top_tips[self._pointID]
    self.icon.sprite = self:GetAsset("UICommon.spriteatlas", LoadType.SpriteAtlas):GetSprite(itemCfg.Icon)
end
function UIXH1PointInfo:itemOnClick(go)
    self:ShowDialog("UIXH1PointDetail")
end
