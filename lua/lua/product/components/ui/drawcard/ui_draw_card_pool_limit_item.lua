---@class UIDrawcardPoolLimitItem : UICustomWidget
_class("UIDrawcardPoolLimitItem", UICustomWidget)
UIDrawcardPoolLimitItem = UIDrawcardPoolLimitItem
function UIDrawcardPoolLimitItem:OnShow(uiParams)
    self:InitWidget()
end
function UIDrawcardPoolLimitItem:InitWidget()
    --generated--
    ---@type UnityEngine.RectTransform
    self.root = self:GetUIComponent("Transform", "root")
    ---@type RawImageLoader
    self.icon = self:GetUIComponent("RawImageLoader", "icon")
    --generated end--
end
function UIDrawcardPoolLimitItem:SetData(cfg)
    if cfg then
        local icon = cfg.icon
        local pos = Vector2(cfg.pos[1], cfg.pos[2])
        local size = Vector2(cfg.size[1], cfg.size[2])
        self.icon:LoadImage(icon)
        self.root.anchoredPosition = pos
        self.root.sizeDelta = size
        self.root.gameObject:SetActive(true)
    else
        self.root.gameObject:SetActive(false)
    end
end
