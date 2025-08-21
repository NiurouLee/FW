---@class UIN14FishingGameRewardItem : UICustomWidget
_class("UIN14FishingGameRewardItem", UICustomWidget)
UIN14FishingGameRewardItem = UIN14FishingGameRewardItem
function UIN14FishingGameRewardItem:OnShow(uiParams)
    self:_GetComponents()
end
function UIN14FishingGameRewardItem:_GetComponents()
    --generated--
    ---@type UICustomWidgetPool
    self._uiItem = self:GetUIComponent("UISelectObjectPath", "uiitem")
    self._lock = self:GetGameObject("Lock")
    --generated end--
end
function UIN14FishingGameRewardItem:SetData(data, scoretype, missioninfo)
    self._item = self._uiItem:SpawnObject("UIItem")
    self._item:SetForm(UIItemForm.Base,0.6)
    self._lock.transform.localScale = Vector3.one * 0.6
    self._item:SetClickCallBack(
        function (go)
            self:ShowTips(go)
        end
    )
    self._itemid = data[1]
    self._itemCount = data[2]
    self._missionInfo = missioninfo
    self._scoreType = scoretype
    self:_OnValue()
end
function UIN14FishingGameRewardItem:_OnValue()
    local cfg = Cfg.cfg_item[self._itemid]
    if cfg == nil then
        Log.fatal("cfg_item is nil." .. self._itemid)
    end
    local icon = cfg.Icon
    local quality = cfg.Color
    local text1 = self._itemCount
    self._item:SetData({icon = icon, quality = quality, text1 = text1, itemId = self._itemid})
    self:RefreshUIInfo(self._missionInfo)
end
function UIN14FishingGameRewardItem:RefreshUIInfo(missioninfo)
    self._missionInfo = missioninfo
    local state = self._missionInfo.reward_mask & self._scoreType ~= 0 and self._missionInfo.mission_grade >= self._scoreType
    self._lock:SetActive(state)
end
function UIN14FishingGameRewardItem:ShowTips(go)
    GameGlobal.EventDispatcher():Dispatch(GameEventType.OnN14FishingGameRewardItemClicked, self._itemid, go.transform.position)
end
