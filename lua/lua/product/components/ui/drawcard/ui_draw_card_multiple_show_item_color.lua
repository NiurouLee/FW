---@class UIDrawCardMultipleShowItemColor : Object
_class("UIDrawCardMultipleShowItemColor", Object)
UIDrawCardMultipleShowItemColor = UIDrawCardMultipleShowItemColor

function UIDrawCardMultipleShowItemColor:InitWidget()
    self.color = self:GetUIComponent("Transform", "root")
end

function UIDrawCardMultipleShowItemColor:GetUIComponent(component, name)
    return self._view:GetUIComponent(component, name)
end
function UIDrawCardMultipleShowItemColor:GetAsset(name, loadType)
    return UIResourceManager.GetAsset(name, loadType, self.name2Assets)
end

function UIDrawCardMultipleShowItemColor:SetData(tmpID, view)
    self.name2Assets = {}

    self._view = view
    self:InitWidget()

    local cfg = Cfg.cfg_pet[tmpID]
    local star = cfg.Star

    if star > 3 then
        --[[

            self.color.sprite =
            self:GetAsset("UIDrawCard.spriteatlas", LoadType.SpriteAtlas):GetSprite(
                "obtain_donghua_beiguang" .. (star - 3)
                )
                ]]
        self.color.gameObject:SetActive(true)
    else
        self.color.gameObject:SetActive(false)
    end
end

function UIDrawCardMultipleShowItemColor:OnHide()
    UIResourceManager.DisposeAllAssets(self.name2Assets)
    self.name2Assets = nil
end
