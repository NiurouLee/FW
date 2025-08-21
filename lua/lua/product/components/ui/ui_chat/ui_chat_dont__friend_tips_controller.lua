---@class UIChatDontFriendTipsController:UIController
_class("UIChatDontFriendTipsController", UIController)
UIChatDontFriendTipsController = UIChatDontFriendTipsController

function UIChatDontFriendTipsController:OnShow(uiParams)
    ---@type ChatFriendData
    self._friendData = uiParams[1]
    ---@type ChatFriendManager
    self._chatFriendManager = uiParams[2]
    self:_GetComponents()
    self:_Init()
end

--获取组件
function UIChatDontFriendTipsController:_GetComponents()
    self._tipsLabel = self:GetUIComponent("UILocalizationText", "Tips")
    self._sednAddFriendBtnOnGo = self:GetGameObject("SendAddFriendBtnOn")
end

---初始化
function UIChatDontFriendTipsController:_Init()
    self._tipsLabel.text = StringTable.Get("str_chat_is_not_your_friend_tips")
    self._sendAddFriendMessage = false
    self._sednAddFriendBtnOnGo:SetActive(self._sendAddFriendMessage)
end

-- =========================================== 按钮点击事件 =======================================

function UIChatDontFriendTipsController:SendAddFriendBtnOnClick(go)
    if self._sendAddFriendMessage then
        self._sendAddFriendMessage = false
    else
        self._sendAddFriendMessage = true
    end
    self._sednAddFriendBtnOnGo:SetActive(self._sendAddFriendMessage)
end

function UIChatDontFriendTipsController:ConfirmBtnOnClick(go)
    if not self._sendAddFriendMessage then
        self:CloseDialog()
        return
    end
    self:Lock("ConfirmBtnOnClick")
    GameGlobal.TaskManager():StartTask(self._SendAddFriendMsg, self)
end

function UIChatDontFriendTipsController:_SendAddFriendMsg(TT)
    ---@type SocialModule
    local socialModule = GameGlobal.GetModule(SocialModule)
    ---@type AsyncRequestRes
    local res = socialModule:InvitationFriend(TT, self._friendData:GetFriendId())
    if not res:GetSucc() then
        local retCode = res:GetResult()
        if retCode == SocialErrorCode.SOCIAL_INVITATION_MUTUAL_SUCCESS then
            ToastManager.ShowToast(StringTable.Get("str_chat_is_your_friend"))
        else
            self._chatFriendManager:HandleErrorMsgCode(retCode)
        end
    else
        ToastManager.ShowToast(StringTable.Get("str_chat_send_request_add_friend_success"))
    end
    self:UnLock("ConfirmBtnOnClick")
    self:CloseDialog()
end

function UIChatDontFriendTipsController:CancelBtnOnClick(go)
    self:CloseDialog()
end

-- ================================================================================================
