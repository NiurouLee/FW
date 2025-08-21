---@class UIN19P5SignInItemAwardBase:UICustomWidget
_class("UIN19P5SignInItemAwardBase", UICustomWidget)
UIN19P5SignInItemAwardBase = UIN19P5SignInItemAwardBase

function UIN19P5SignInItemAwardBase:OnShow()
    self.pos = self:GetUIComponent("RectTransform","pos")
    self.countPos = self:GetUIComponent("RectTransform","countPos")
    self.count = self:GetUIComponent("UILocalizationText","count")
    self.icon = self:GetUIComponent("RawImageLoader","icon")
    self._iconRect = self:GetUIComponent("RectTransform","icon")
    self._iconRectDefaultSize = self._iconRect.sizeDelta
    self._iconRawImg = self:GetUIComponent("RawImage","icon")
end
function UIN19P5SignInItemAwardBase:SetData(idx,roleAsset,callback,gray,pos,countPos)
    self.pos.anchoredPosition = pos
    self.countPos.anchoredPosition = countPos

    self.id = roleAsset.assetid
    local count = roleAsset.count

    local cfg = Cfg.cfg_item[self.id]
    if not cfg then
        Log.fatal("###[UIN19P5SignInItemAwardBase] cfg is nil ! id --> ",self.id)
    end
    local icon = cfg.Icon
    self.icon:LoadImage(icon)
    self:SetIcon()

    if not self._EMIMat then
        self._EMIMat = UnityEngine.Material:New(self._iconRawImg.material)
    end
    local texture = self._iconRawImg.material.mainTexture
    self._iconRawImg.material = self._EMIMat
    self._iconRawImg.material.mainTexture = texture

    if gray then
        self._iconRawImg.material:SetFloat("_LuminosityAmount",1)
    else
        self._iconRawImg.material:SetFloat("_LuminosityAmount",0)
    end
    self._iconRawImg.gameObject:SetActive(false)
    self._iconRawImg.gameObject:SetActive(true)

    self.count:SetText(count)
end
function UIN19P5SignInItemAwardBase:SetIcon()
    local isHead = false
    if self.id >= 3750000 and self.id <= 3759999 then
        isHead = true
    end
    if isHead then
        local whRate = 1
        --MSG23427	【必现】（测试_朱文科）累计签到查看头像和邮件发送头像时会有变形，附截图	4	新缺陷	李学森, 1958	05/22/2021
        --没有资源接口临时处理
        if self.id >= 3751000 and self.id <= 3751999 then
            whRate = 160 / 190
        elseif self.id >= 3752000 and self.id <= 3752999 then
            whRate = 138 / 216
        elseif self.id >= 3753000 and self.id <= 3753999 then
            whRate = 138 / 216
        end

        self._iconRect.sizeDelta = Vector2(self._iconRect.sizeDelta.x, self._iconRect.sizeDelta.x * whRate)
    else
        self._iconRect.sizeDelta = self._iconRectDefaultSize
    end
end
---@class UIN19P5SignInItemAwardBig:UIN19P5SignInItemAwardBase
_class("UIN19P5SignInItemAwardBig", UIN19P5SignInItemAwardBase)
UIN19P5SignInItemAwardBig = UIN19P5SignInItemAwardBig
function UIN19P5SignInItemAwardBig:IconOnClick(go)
    local awardInfo = AwardInfo:New()
    awardInfo.m_item_id = self.id
    self:ShowDialog("UIN19P5Tip",awardInfo,true)
    --ToastManager.ShowToast("icon btn on click ! id --> "..self.id)
end
---@class UIN19P5SignInItemAwardSmall:UIN19P5SignInItemAwardBase
_class("UIN19P5SignInItemAwardSmall", UIN19P5SignInItemAwardBase)
UIN19P5SignInItemAwardSmall = UIN19P5SignInItemAwardSmall