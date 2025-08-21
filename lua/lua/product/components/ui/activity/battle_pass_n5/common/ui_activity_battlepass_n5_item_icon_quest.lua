---@class UIActivityBattlePassN5ItemIconQuest:UICustomWidget
_class("UIActivityBattlePassN5ItemIconQuest", UICustomWidget)
UIActivityBattlePassN5ItemIconQuest = UIActivityBattlePassN5ItemIconQuest

function UIActivityBattlePassN5ItemIconQuest:_GetComponents()
    self._iconImg = self:GetUIComponent("RawImageLoader", "icon")
    self._iconRect = self:GetUIComponent("RectTransform", "icon")
    self._iconObj = self:GetGameObject("icon")
    self._countBgObj = self:GetGameObject("countBg")
    self._countText = self:GetUIComponent("UILocalizationText", "countText")
    self._countTextObj = self:GetGameObject("countText")
end

function UIActivityBattlePassN5ItemIconQuest:SetData(index, roleAsset, callback)
    self:_GetComponents()

    self._index = index
    self._roleAsset = roleAsset
    self._callback = callback
    self._cfg_item = Cfg.cfg_item[self._roleAsset.assetid]
    if self._cfg_item == nil then
        Log.fatal("[quest] error --> cfg_item is nil ! id --> " .. self._roleAsset.assetid)
        return
    end

    self:_OnValue()
end

function UIActivityBattlePassN5ItemIconQuest:OnShow(uiParams)
end

function UIActivityBattlePassN5ItemIconQuest:OnHide()
    self._callback = nil
end

function UIActivityBattlePassN5ItemIconQuest:_OnValue()
    local icon = self._cfg_item.Icon
    local count = self._roleAsset.count
    local itemId = self._roleAsset.assetid

    self:SetIcon(icon, itemId)
    self:SetCount(count, true)
end

function UIActivityBattlePassN5ItemIconQuest:iconOnClick(go)
    if self._callback then
        self._callback(self._roleAsset.assetid, go.transform.position)
    end
end

--region Icon
function UIActivityBattlePassN5ItemIconQuest:SetIcon(name, itemId)
    if not string.isnullorempty(name) then
        self:ShowIcon(true, itemId)
        self._iconImg:LoadImage(name)
    else
        self:ShowIcon(false)
    end
end

function UIActivityBattlePassN5ItemIconQuest:ShowIcon(show, itemId)
    self._iconObj:SetActive(show)
    self:SetIconOffset(itemId)
end

function UIActivityBattlePassN5ItemIconQuest:SetIconOffset(itemId)
    -- if self:_IsPet(itemId) then
    --     self._iconRect.anchoredPosition = Vector2(0, 0)
    -- else
    --     self._iconRect.anchoredPosition = Vector2(0, 5)
    -- end
end

function UIActivityBattlePassN5ItemIconQuest:_IsPet(id)
    local cfg = Cfg.cfg_pet {ID = id}
    return cfg and true or false
end
--endregion

--region Count
function UIActivityBattlePassN5ItemIconQuest:SetCount(text, showZeroFlag)
    if text ~= nil then
        local show = false
        if type(text) == "number" then
            local num = text
            show = num > 0 or showZeroFlag
            self._countText:SetText(HelperProxy:GetInstance():FormatItemCount(num))
        elseif type(text) == "string" then
            show = not string.isnullorempty(text)
            self._countText:SetText(text)
        end
        self:ShowCountGroup(show)
    else
        self:ShowCountGroup(false)
    end
end

function UIActivityBattlePassN5ItemIconQuest:ShowCountGroup(show)
    self._countTextObj:SetActive(show)
    self._countBgObj:SetActive(show)
end
--endregion
