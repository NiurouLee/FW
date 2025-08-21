---@class UIBackPackBoxUseItem : UICustomWidget
_class("UIBackPackBoxUseItem", UICustomWidget)
UIBackPackBoxUseItem = UIBackPackBoxUseItem

function UIBackPackBoxUseItem:OnShow(uiParams)
    ---@type UICustomWidgetPool
    local sop = self:GetUIComponent("UISelectObjectPath", "uiitem")
    ---@type UIItem
    self.uiItem = sop:SpawnObject("UIItem")
    self.uiItem:SetForm(UIItemForm.BackPack)
    self.uiItem:SetClickCallBack(
        function()
            self:ItemOnClick()
        end
    )
end

function UIBackPackBoxUseItem:OnHide()
end

---@param itemInfo BackPackBoxItem 物品信息
---@param index number 下标
---@param clickCallback function 事件
function UIBackPackBoxUseItem:Flush(itemInfo, index, count,toggleGroup, clickCallback,selectedId)
    self._index = index
    self._toggleGroup = toggleGroup
    self._selectedId = selectedId
    self._itemInfo = itemInfo
    if not itemInfo then
        return
    end
    self._clickCallback = clickCallback
    self.uiItem:SetData(
        {
            icon = itemInfo:GetIcon(),
            quality = itemInfo:GetColor(),
            text1 = HelperProxy:GetInstance():FormatItemCount(itemInfo:GetCount() * count),
            itemId = itemInfo:GetTplId(),
            showNew = false
        }
    )
    self.uiItem:SetBtnImage(true)

    self.uiItem:SetToggleGroup(self._toggleGroup)

    self.uiItem:SetToggleValue(self._selectedId == self._itemInfo:GetTplId())

    self.OnValueChangedCallBack = function(isOn) 
        GameGlobal.EventDispatcher():Dispatch(GameEventType.SwitchUseBoxItem,isOn,self._index,self._itemInfo)
    end 
    self.uiItem:SetToggleOnValueChangedCallBack(self.OnValueChangedCallBack)
end

function UIBackPackBoxUseItem:FlushEmpty()
    self.uiItem:SetData({text1 = "", icon = "", quality = 0, showNew = false})
    self.uiItem:SetBtnImage(false)
    self._clickCallback = nil
end

--点击
function UIBackPackBoxUseItem:ItemOnClick()
    if self._clickCallback then
        self._clickCallback(self._itemInfo:GetTplId(),self.uiItem.gameobject.transform.position)
    end
end
