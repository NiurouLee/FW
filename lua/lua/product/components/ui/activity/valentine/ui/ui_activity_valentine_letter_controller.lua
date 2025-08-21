---@class UIActivityValentineLetterController:UIController
_class("UIActivityValentineLetterController", UIController)
UIActivityValentineLetterController = UIActivityValentineLetterController

function UIActivityValentineLetterController:Constructor()
end

function UIActivityValentineLetterController:OnShow(uiParams)
    self._cfg = uiParams[1]
    self:_GetComponent()
    self:_InitLetterInfo()
end

function UIActivityValentineLetterController:OnHide()
end

function UIActivityValentineLetterController:_GetComponent()
    self._letterBg = self:GetUIComponent("RawImageLoader","letterBg")
    self._letterInfo = self:GetUIComponent("UILocalizationText","letterInfo")
    self._letterSign = self:GetUIComponent("UILocalizationText","letterSign")
    self._anim = self:GetUIComponent("Animation","anim")
end

function UIActivityValentineLetterController:_InitLetterInfo()
    self._letterInfo:SetText(self:_SetName(StringTable.Get(self._cfg.LetterInfo)))
    self._letterSign:SetText(StringTable.Get(self._cfg.LetterWriter))
    self._letterBg:LoadImage(self._cfg.Paper)

    local isDark = self._cfg.IsDark
    if not isDark then
        self._letterInfo.color = Color(83/255,82/255,80/255)
        self._letterSign.color = Color(83/255,82/255,80/255)
    else
        self._letterInfo.color = Color(251/255,248/255,240/255)
        self._letterSign.color = Color(251/255,248/255,240/255)
    end
end

function UIActivityValentineLetterController:_SetName(strContent)
    local roleName = GameGlobal.GetModule(RoleModule):GetName()
    local strRes = string.gsub(strContent, "PlayerName", roleName)
    return strRes
end

function UIActivityValentineLetterController:LetterBtnOnClick()
    local spineStr = self._cfg.CloseSpine
    self:StartTask(self._Close,self)
end

function UIActivityValentineLetterController:_Close(TT)
    self:Lock("UIActivityValentineLetterController_close")
    self._anim:Play("uieff_UIActivityValentineLetterController_SafeArea_out")
    YIELD(TT,500)
    self:UnLock("UIActivityValentineLetterController_close")
    self:CloseDialog()
end

