---@class UIExtraMissionAwardControllerItem : UICustomWidget
_class("UIExtraMissionAwardControllerItem", UICustomWidget)
UIExtraMissionAwardControllerItem = UIExtraMissionAwardControllerItem

--最大可现实的数字位数
local maxNumCount = 5
function UIExtraMissionAwardControllerItem:OnShow(uiParams)
    self._rect = self:GetUIComponent("RectTransform", "rect")
    --图集
    self._index = -1
    self._pstid = -1
    self._itemCount = 0
    --- uiitem
    local sop = self:GetUIComponent("UISelectObjectPath", "uiitem")
    ---@type UIItem
    self.uiItem = sop:SpawnObject("UIItem")
    self.uiItem:SetForm(UIItemForm.Base)
    self.uiItem:SetClickCallBack(
        function(go)
            self:itemOnClick(go)
        end
    )
end

---@param itemInfo table 物品信息
---@param index number 下标
---@param clickCallback function 回调
---@param nameColor Color 文本颜色ss
function UIExtraMissionAwardControllerItem:SetData(itemInfo, index, clickCallback, nameColor)
    self._index = index
    self._templateData = itemInfo
    self._item_id = self._templateData.item_id

    local text2Color = nameColor
    local text2 = StringTable.Get(self._templateData.item_name)
    local quality = self._templateData.color
    self._itemCount = self._templateData.item_count
    local icon = self._templateData.icon
    local tex = self:FormatItemCount(self._itemCount)
    local text1 = tex
    local itemId = self._templateData.id
    self._clickCallback = clickCallback
    self.uiItem:SetData(
        {
            icon = icon,
            quality = quality,
            text1 = text1,
            text2 = text2,
            text2Color = text2Color,
            itemId = itemId
        }
    )
end

function UIExtraMissionAwardControllerItem:itemOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.SoundDefaultClick)
    if not self._templateData then
        return
    end

    if self._clickCallback then
        self._rect:DOPunchScale(Vector3(0.1, 0.1, 0.1), 0.2)
        self._clickCallback(self._item_id, go.transform.position)
    end
end
---@return number
function UIExtraMissionAwardControllerItem:GetIndex()
    return self._index
end

---@param count number 数量
function UIExtraMissionAwardControllerItem:FormatItemCount(count)
    local tex = HelperProxy:GetInstance():FormatItemCount(count)
    return tex
end
