_class("UIChatSetNoteNameController", UIController)
---@class UIChatSetNoteNameController:UIController
UIChatSetNoteNameController = UIChatSetNoteNameController

function UIChatSetNoteNameController:OnShow(uiParams)
    ---@type ChatFriendData
    self._friendData = uiParams[1]
    ---@type ChatFriendManager
    self._chatFriendManager = uiParams[2]
    if not self._friendData then
        return
    end
    self._nameInput = self:GetUIComponent("EmojiFilteredInputField", "NameInput")
    self._patcherLabel = self:GetUIComponent("UILocalizationText", "Patcher")
    self._noteName = self._friendData:GetName()

    if string.isnullorempty(self._friendData:GetRemarkName()) then
        self._patcherLabel.text = self._friendData:GetName()
        self._nameInput.text = ""
    else
        self._patcherLabel.text = ""
        self._nameInput.text = self._friendData:GetName()
    end


    self._nameMaxLength = 14
    self.OnIptValueChanged = function()
        local s = self._nameInput.text
        if string.isnullorempty(s) then
            self._noteName = ""
            self._patcherLabel.text = self._friendData:GetOriginalName()
            return
        end

        local showStr = HelperProxy:GetInstance():GetSubStringByWordsNum(s,self._nameMaxLength)

        self._nameInput.text = showStr
        self._noteName = self._nameInput.text
    end
    self._nameInput.onValueChanged:AddListener(self.OnIptValueChanged)
end

function UIChatSetNoteNameController:GetCharSize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- =========================================== 按钮点击事件 =======================================

function UIChatSetNoteNameController:ConfirmBtnOnClick(go)
    if not self._friendData then
        self:CloseDialog()
        return
    end
    if self._noteName == self._friendData:GetName() then
        self:CloseDialog()
        return
    end
    local newName = self._noteName
    if HelperProxy:GetInstance():GetCharLength(newName) > self._nameMaxLength then
        ToastManager.ShowToast(StringTable.Get("str_chat_set_name_tolong"))
        return
    end
    self:Lock("ConfirmBtnOnClick")
    GameGlobal.TaskManager():StartTask(self._ChangeName, self, newName)
end

function UIChatSetNoteNameController:_ChangeName(TT, newName)
    if not self._friendData then
        self:UnLock("ConfirmBtnOnClick")
        self:CloseDialog()
        return
    end
    ---@type SocialModule
    local socialModule = GameGlobal.GetModule(SocialModule)
    ---@type AsyncRequestRes
    local res = socialModule:HandleRemark(TT, self._friendData:GetFriendId(), newName)
    if not res:GetSucc() then
        self._chatFriendManager:HandleErrorMsgCode(res:GetResult())
        self:UnLock("ConfirmBtnOnClick")
        -- self:CloseDialog()
        return
    end
    ToastManager.ShowToast(StringTable.Get("str_chat_set_name_success"))
    self:UnLock("ConfirmBtnOnClick")
    self:CloseDialog()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.ChangeFriendInfoSuccess)
end

function UIChatSetNoteNameController:CancelBtnOnClick(go)
    self:CloseDialog()
end

-- ================================================================================================
