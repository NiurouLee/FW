require "ui_common_message_box"
require "ui_get_item_controller"

---@class UIN25IdolMessageBox:UICommonMessageBox
_class("UIN25IdolMessageBox", UICommonMessageBox)
UIN25IdolMessageBox = UIN25IdolMessageBox

---@class UIN25IdolGetItem:UIGetItemController
_class("UIN25IdolGetItem", UIGetItemController)
UIN25IdolGetItem = UIN25IdolGetItem

function UIN25IdolMessageBox:Constructor()

end

function UIN25IdolMessageBox:ButtonCancelOnClick(go)
    self._animation = self.gameobject:GetComponent("Animation")
    if self._animation == nil then
        UICommonMessageBox.ButtonCancelOnClick(self, go)
        return
    end

    local cancelCallback = self.cancelCallback
    self.cancelCallback = nil

    UICommonMessageBox.ButtonCancelOnClick(self, go)

    local lockName = "UIN25IdolMessageBox:_backAnim"
    self:StartTask(function(TT)
        self:Lock(lockName)
        self._animation:Play("uieff_UIN25IdolMessageBox_out")
        YIELD(TT, 400)
        self:UnLock(lockName)

        if cancelCallback then
            cancelCallback()
        end
    end)
end

function UIN25IdolMessageBox:StartTask(func, ...)
    -- 协程开始
    if type(func) ~= "function" then
        return
    end

    return GameGlobal.TaskManager():StartTask(func, ...)
end

---加锁
---@param name string
function UIN25IdolMessageBox:Lock(name)
    GameGlobal.UIStateManager():Lock(name)
end

---解锁
---@param name string
function UIN25IdolMessageBox:UnLock(name)
    GameGlobal.UIStateManager():UnLock(name)
end

function UIN25IdolGetItem:Constructor()

end

function UIN25IdolGetItem:_InitListView(scrollView, index)
    local fnBase = UIGetItemController._InitListView
    local item = fnBase(self, scrollView, index)
    return item
end

---@private
---@param index number
---@param giftItem UIGetItemControllerItem
function UIN25IdolGetItem:_ShowItem(giftItem, index, tweenIdx)
    local beforeTime = 0
    if not self._inited then
        beforeTime = self._beforeTime
    end
    local item_data = self:_GetItemDataByIndex(index)
    if item_data then
        giftItem:SetData(
                item_data,
                index,
                function(id, pos)
                    self:OnItemSelect(id, pos)
                end,
                Color(109 / 255, 80 / 255, 195 / 255, 1),
                tweenIdx,
                beforeTime
        )
        giftItem:GetGameObject():SetActive(true)
    else
        giftItem:GetGameObject():SetActive(false)
    end
end


