_class("GuidePopup", Object)
GuidePopup = GuidePopup

---@class GuideMessageBoxMng:Singleton
---@field GetInstance GuideMessageBoxMng
_class("GuideMessageBoxMng", Singleton)
GuideMessageBoxMng = GuideMessageBoxMng
local PrefabSuffix = ".prefab"
--region 初始化/销毁
function GuideMessageBoxMng:Constructor()
    self._uiMsgBox = nil
    self.name2MsgBox = {}
    self._guidePopup = nil
end

function GuideMessageBoxMng:Dispose()
end
--end

--region 对外接口

---弹出Popup，
---@param uiMsgBoxName string
---@param priority PopupPriority
---@param ... 不定参由具体的UIMessageBox.Alert解析
function GuideMessageBoxMng:OpenGuideBox(uiMsgBoxName, ...)
    GameGlobal.UIStateManager():Lock("OpenGuideBox")
    self.params = {...}
    self._guidePopup = GuidePopup:New()
    GameGlobal.TaskManager():StartTask(self._OpenPopup, self, uiMsgBoxName, ...)
    return self._guidePopup
end

---引导弹窗是否处于激活状态
---@return boolean
function GuideMessageBoxMng:IsGuideBoxShowing()
    return self._uiMsgBox ~= nil
end

---@private
---@param popup Popup
function GuideMessageBoxMng:_OpenPopup(TT, uiMsgBoxName, ...)
    local isCache, uiMsgBox, uiView, resRequest = self:GetUIMessageBox(TT, uiMsgBoxName)
    if not isCache then
        GameGlobal.UIStateManager():SetGuideMessageBoxParent(uiView, uiMsgBoxName)
        self:SetUIMessageBox(uiMsgBoxName, uiMsgBox, uiView, resRequest)
    end
    GameGlobal.UIStateManager():CheckMessageBoxCameraStatus(true)
    GameGlobal.UIStateManager():CheckMessageBoxCameraStatus(true)
    self._uiMsgBox = uiMsgBox
    self._uiMsgBox:Alert(self, self.params)
    self._uiMsgBox:SetShow(true)
    GameGlobal.UIStateManager():UnLock("OpenGuideBox")
end

---@private
---主动关闭popup（通常是当前正在显示的popup；强引导也是popup，所以会可能主动关闭popup，并且可能不在显示）
---@param popup Popup
function GuideMessageBoxMng:ClosePopup(popup)
    Log.debug("[guide] GuideMessageBoxMng:ClosePopup")
    if (self._uiMsgBox ~= nil) then
        self._uiMsgBox:ClearCallback()
        self._uiMsgBox = nil
        self._guidePopup = nil
        GameGlobal.UIStateManager():CheckMessageBoxCameraStatus(false)
    end
end

---@private
---@param uiMsgBoxName string
---@return UIMessageBox
function GuideMessageBoxMng:GetUIMessageBox(TT, uiMsgBoxName)
    local uiMsgBox = self.name2MsgBox[uiMsgBoxName]
    if uiMsgBox then
        return true, uiMsgBox
    else
        -- 创建脚本
        local uiMsgBox = self:CreateUIMessageBox(uiMsgBoxName)
        if not uiMsgBox then
            return
        end
        uiMsgBox:SetName(uiMsgBoxName)

        -- 加载资源
        local uiView, resRequest = UIResourceManager.GetViewAsync(TT, uiMsgBoxName, uiMsgBoxName .. PrefabSuffix)
        if not uiView then
            Log.fatal("[UI] PopupManager:GetUIMessageBox Error, View is Null, ", uiMsgBoxName)
            return
        end

        return false, uiMsgBox, uiView, resRequest
    end
end
---@private
---@param uiMsgBox UIMessageBox
function GuideMessageBoxMng:SetUIMessageBox(uiMsgBoxName, uiMsgBox, uiView, resRequest)
    if uiMsgBox == nil or uiView == nil then
        return
    end
    -- 设置Load Show
    uiMsgBox:Load(uiView, resRequest)
    self.name2MsgBox[uiMsgBoxName] = uiMsgBox
end

---@private
function GuideMessageBoxMng:CreateUIMessageBox(uiMsgBoxName)
    -- 然后创建实例
    local uiMsgBox = _createInstance(uiMsgBoxName)
    if not uiMsgBox then
        Log.fatal("[UI] PopupManager:CreateUIMessageBox Error, No UIMessageBox of name = ", uiMsgBoxName)
    end
    if not uiMsgBox:IsChildOf("UIMessageBox") then
        Log.fatal("[UI] PopupManager:CreateUIMessageBox Fail, ", uiMsgBoxName, " is not inherited from UIMessageBox!")
        return
    end
    return uiMsgBox
end
--endregion
