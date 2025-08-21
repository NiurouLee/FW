---@class UIHomeMovieStoryChooseItem:UICustomWidget
_class("UIHomeMovieStoryChooseItem", UICustomWidget)
UIHomeMovieStoryChooseItem = UIHomeMovieStoryChooseItem

function UIHomeMovieStoryChooseItem:OnShow(uiParams)
    ---@type UILocalizationText
    self._text = self:GetUIComponent("UILocalizationText","text")
    self._anim = self:GetUIComponent("Animation","anim")
    --self._contentSizeFitter = self:GetUIComponent("ContentSizeFitter","layout")
    --self._layoutRt = self:GetUIComponent("RectTransform","layout")
    self._go = self:GetGameObject()
    --self._new = self:GetGameObject("New")
    --self._layoutHorz = self:GetUIComponent("HorizontalLayoutGroup","layout")
    --self._chatIcon = self:GetUIComponent("RawImageLoader", "chatIcon")
    --self._chatIconImg = self:GetUIComponent("RawImage", "chatIcon")
    --适配度
    self._badFit = self:GetGameObject("badFit")
    self._goodFit = self:GetGameObject("goodFit")
    self._excellentFit = self:GetGameObject("excellentFit")

    -- default layout
    --self:ShowChatIcon(false, nil)
end
function UIHomeMovieStoryChooseItem:Active(active)
    self._go:SetActive(active)
end
function UIHomeMovieStoryChooseItem:SetData(idx,txt,fit,callback,type,leftCount,rightCount,PetFishClue)
    self._idx = idx
    self._leftCount = leftCount
    self._rightCount = rightCount
    self._PetFishClue=PetFishClue
    self._fit = fit

    self._callback = callback
    self._text:SetText(txt)

    local showType = false
    if type then
        showType = true
    end

    -- if self._text.preferredWidth > 322 then
    --     self._contentSizeFitter.enabled = false
    --     self._layoutRt.sizeDelta = Vector2(322,100)
    --     self._text.resizeTextForBestFit = true
    --     self._text.verticalOverflow = UnityEngine.VerticalWrapMode.Truncate
    -- else
    --     self._contentSizeFitter.enabled = true
    --     self._text.resizeTextForBestFit = false
    --     self._text.verticalOverflow = UnityEngine.VerticalWrapMode.Overflow
    -- end

    self._badFit:SetActive(false)
    self._goodFit:SetActive(false)
    self._excellentFit:SetActive(false)

    if self._fit == 0 then
        self._badFit:SetActive(true)
    elseif self._fit == 1 then
        self._goodFit:SetActive(true)
    elseif self._fit == 2 then
        self._excellentFit:SetActive(true)
    end
end

function UIHomeMovieStoryChooseItem:SetNewStatus(status)
    self._new:SetActive(status)
end

function UIHomeMovieStoryChooseItem:bgOnClick(go)
    self._anim:Play("UIHomeMovieStoryDialog_xuanzhong")
    if self._callback then
        self._callback(self._idx,self._leftCount,self._rightCount,self._PetFishClue)
    end
end

function UIHomeMovieStoryChooseItem:ShowChatIcon(inShow, iconName)
    local paddingLeft = 0
    if inShow then
        paddingLeft = self._chatIconImg.rectTransform.rect.width
        self._chatIcon:LoadImage(iconName)
    else
        paddingLeft = 0
    end

    local padding = self._layoutHorz.padding
    padding.left = paddingLeft
    self._layoutHorz.padding = padding
    self._chatIconImg.gameObject:SetActive(inShow)
end

