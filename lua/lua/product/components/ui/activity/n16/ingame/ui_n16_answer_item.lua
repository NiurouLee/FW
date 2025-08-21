---@class UIN16AnswerItem : UICustomWidget
_class("UIN16AnswerItem", UICustomWidget)
UIN16AnswerItem = UIN16AnswerItem
function UIN16AnswerItem:OnShow(uiParams)
    self:InitWidget()
    self:AttachEvent(GameEventType.OnN16SelectClick, self._ShowOnError)
end

function UIN16AnswerItem:OnHide() 
    self:DetachEvent(GameEventType.OnN16SelectClick, self._ShowOnError)
end 
function UIN16AnswerItem:InitWidget()
    --generated--
    ---@type UnityEngine.UI.Image
    self.selet = self:GetUIComponent("Image", "Selet")
    ---@type UILocalizationText
    self.option = self:GetUIComponent("UILocalizationText", "Option")
    ---@type UILocalizationText
    self.content = self:GetUIComponent("UILocalizationText", "Content")
    ---@type UnityEngine.GameObject
    self.isRight = self:GetGameObject("IsRight")
    ---@type UnityEngine.GameObject
    self.isError = self:GetGameObject("IsError")
    ---@type UnityEngine.GameObject
    self.noContentMask = self:GetGameObject("NoContentMask")
    ---@type UnityEngine.GameObject
    self.mask = self:GetGameObject("Mask")
    self.isRight = self:GetGameObject("IsRight")

    ---@type UnityEngine.GameObject
    self.aniObj = self:GetGameObject("kuang1")
    ---@type UnityEngine.GameObject
    self.aniObj1 = self:GetGameObject("kuang2")
    self.anim = self:GetUIComponent("Animation","go")
    --generated end--
end

function UIN16AnswerItem:Refresh(data) 
    self.option:SetText(self:GetOption())
    self.content:SetText(data)
    self.noContentMask:SetActive(not data)
    self.isRight:SetActive(false)
    self.isError:SetActive(false)
    self.mask:SetActive(false)
    self:SetColorDefault() 
    self.selet.gameObject:SetActive(false)
    if data == "" or not data then 
       -- self.anim:Play("uieff_AnswerItem_NotSelect")
       -- self.selet.color = Color(0.66, 0.66, 0.66, 1)
    end 
end 
function UIN16AnswerItem:SetData(nIndex,callback)
    self._onClickCallback = callback
    self._index = nIndex
end
function UIN16AnswerItem:SeletOnClick(go)
    if self._onClickCallback then 
        self._onClickCallback(self._index)
    end 
end

function UIN16AnswerItem:_ShowOnError(rightIndex,seletIndex)
    self.isRight:SetActive(rightIndex == self._index)
    self.isError:SetActive((seletIndex == self._index) and not(rightIndex == self._index))
    self.selet.gameObject:SetActive((seletIndex == self._index) and not(rightIndex == self._index)) 
   -- self.mask:SetActive((seletIndex == self._index) and not(rightIndex == self._index))
    -- self.aniObj:SetActive(seletIndex == self._index)
    -- self.aniObj1:SetActive(seletIndex == self._index)
    if  (seletIndex == self._index) and not(rightIndex == self._index)  then     
        self.anim:Play("uieff_AnswerItem_SelectWrong")
    end 

    if  rightIndex == self._index then 
        self.anim:Play("uieff_AnswerItem_SelectRight")
    end

    if seletIndex ~= self._index and rightIndex ~= self._index then 
        self.selet.color = Color(0.66, 0.66, 0.66, 1)
    end 

    if self._index == seletIndex then
        if seletIndex == rightIndex then
            AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1GameSuccess)
        else
            AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1GameFail)
        end
    end
end

function UIN16AnswerItem:GetOption()
    local op = ""
        if  self._index == 1 then 
            op =  "A"
        elseif self._index == 2 then 
            op =  "B"
        elseif self._index == 3 then 
            op =  "C"
        elseif self._index == 4 then 
            op =  "D"
        end 
   return op
end 

function UIN16AnswerItem:SetColorDefault() 
  --  self.selet.color = Color(1, 1, 1, 1)
end 


