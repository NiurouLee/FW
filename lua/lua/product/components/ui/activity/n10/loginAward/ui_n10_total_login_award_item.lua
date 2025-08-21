---@class UIN10TotalLoginAwardItem : UICustomWidget
_class("UIN10TotalLoginAwardItem", UICustomWidget)
UIN10TotalLoginAwardItem = UIN10TotalLoginAwardItem
function UIN10TotalLoginAwardItem:OnShow(uiParams)
    self:InitWidget()
end
function UIN10TotalLoginAwardItem:InitWidget()
    --generated--
    ---@type RawImageLoader
    self._icon = self:GetUIComponent("RawImageLoader", "Icon")
    self._iconRect = self:GetUIComponent("RectTransform", "Icon")
    self._iconRectDefaultSize = Vector2(self._iconRect.sizeDelta.x,self._iconRect.sizeDelta.y)

    self._iconImg = self:GetUIComponent("RawImage", "Icon")
    self._countArea = self:GetUIComponent("Image", "CountArea")
    ---@type UILocalizationText
    self._countText = self:GetUIComponent("UILocalizationText", "CountText")

    --generated end--
end
---@param data RoleAsset
function UIN10TotalLoginAwardItem:SetData(data,itemInfoCallback,ShowLastAward)
    self._itemId = data.assetid
    self._itemCount = data.count
    self._itemInfoCallback = itemInfoCallback
    local cfg_item = Cfg.cfg_item[self._itemId]--[3203032]
    if not cfg_item then
        return
    end
    local icon = cfg_item.Icon
    self._icon:LoadImage(icon)
    self._countText:SetText(self._itemCount)
    if ShowLastAward then
        local atlas = self:GetAsset("UIN10.spriteatlas", LoadType.SpriteAtlas)
        self._countArea.sprite = atlas:GetSprite("n10_signin_bg_shuliang1")
    end
    local isHead = false
    if self._itemId >= 3750000 and self._itemId <= 3759999 then
        isHead = true
    end
    if isHead then
        local whRate = 1
        --没有资源接口临时处理
        if self._itemId >= 3751000 and self._itemId <= 3751999 then
            whRate = 160 / 190
        elseif self._itemId >= 3752000 and self._itemId <= 3752999 then
            whRate = 138 / 216
        elseif self._itemId >= 3753000 and self._itemId <= 3753999 then
            whRate = 138 / 216
        end

        self._iconRect.sizeDelta = Vector2(self._iconRect.sizeDelta.x, self._iconRect.sizeDelta.x * whRate)
    else
        self._iconRect.sizeDelta = self._iconRectDefaultSize
    end
end

function UIN10TotalLoginAwardItem:_SetAlpha(alpha)
    self._iconImg.color = Color(self._iconImg.color.r,self._iconImg.color.g,self._iconImg.color.b,alpha)
    self._countArea.color = Color(self._countArea.color.r,self._countArea.color.g,self._countArea.color.b,alpha)
    self._countText.color = Color(self._countText.color.r,self._countText.color.g,self._countText.color.b,alpha)

end
function UIN10TotalLoginAwardItem:IconOnClick(go)
    if self._itemInfoCallback then
        local tr = go.transform
        local pos = tr.position
        self._itemInfoCallback(self._itemId, pos)
    end
end