---@class UIN12MapGetRewardsItem : UICustomWidget
_class("UIN12MapGetRewardsItem", UICustomWidget)
UIN12MapGetRewardsItem = UIN12MapGetRewardsItem
function UIN12MapGetRewardsItem:OnShow(uiParams)
    self:GetComponents()
end
function UIN12MapGetRewardsItem:GetComponents()
    self._go = self:GetGameObject("uiitem")
    local sop = self:GetUIComponent("UISelectObjectPath", "uiitem")
    ---@type UIItem
    self.uiItem = sop:SpawnObject("UIItem")
    self.uiItem:SetForm(UIItemForm.Base, UIItemScale.Level2)
    self.uiItem:SetClickCallBack(
        function()
            self:bgOnClick()
        end
    )
end
---@param v Award
function UIN12MapGetRewardsItem:SetData(v,callback)
    if not v then
        return
    end
    self._v = v
    self._callback = callback
    local icon = v.icon
    local quality = v.color
    local text1 = v.count
    local strKey = ""
    local activityText = ""
    local awardType = v.type
    local itemId = v.id
    if awardType == StageAwardType.First then
        strKey = "str_discovery_first_award"
    elseif awardType == StageAwardType.Star then
        strKey = "str_discovery_3star_award"
    elseif awardType == StageAwardType.Activity then
        strKey = "str_discovery_activity_award"
        activityText = "str_item_xianshi" 
    elseif awardType == StageAwardType.HasGen then
        strKey = "str_discovery_already_collect"
    else
        strKey = "str_discovery_normal_award"
    end
    self.uiItem:SetData(
        {
            icon = icon,
            quality = quality,
            text1 = text1,
            awardText = StringTable.Get(strKey),
            itemId = itemId,
            topText = UIEnum.ItemRandomStr(v.randomType),
            activityText = StringTable.Get(activityText)
        }
    )
end
function UIN12MapGetRewardsItem:bgOnClick()
    if self._callback then
        self._callback(self._v.id,self._go.transform.position)
    end
end