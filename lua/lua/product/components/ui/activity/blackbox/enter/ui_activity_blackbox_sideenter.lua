--
---@class UIActivityBlackBoxSideEnter : UICustomWidget
_class("UIActivityBlackBoxSideEnter", UICustomWidget)
UIActivityBlackBoxSideEnter = UIActivityBlackBoxSideEnter

function UIActivityBlackBoxSideEnter:Constructor()
end

--初始化
function UIActivityBlackBoxSideEnter:OnShow(uiParams)
    self:_GetComponents()
end

function UIActivityBlackBoxSideEnter:OnHide()
    self._activityData = nil

    if self._timer then
        GameGlobal.Timer():CancelEvent(self._timer)
        self._timer = nil
    end
end

--获取ui组件
function UIActivityBlackBoxSideEnter:_GetComponents()
    self._txtTitle = self:GetUIComponent("UILocalizationText", "txtTitle")
    self._bg = self:GetUIComponent("RawImageLoader", "bg")
    self._red = self:GetGameObject("red")
    self._new = self:GetGameObject("new")
end

--设置数据
function UIActivityBlackBoxSideEnter:SetData()
    
end

--按钮点击
function UIActivityBlackBoxSideEnter:BtnOnClick(go)
    local isOver = self._activityData:CheckTaskIsOver()
    
    if isOver then
        ToastManager.ShowToast(StringTable.Get("str_n27_valentine_y_offline"))
        return
    end
    
    self:ShowDialog("UIActivityBlackBoxMain")
end

function UIActivityBlackBoxSideEnter:OnSideEnterLoad(TT, setShowCallback, setNewRedCallback)
    self._setShowCallback = setShowCallback
    self._setNewRedCallback = setNewRedCallback
    self:Lock("UIActivityBlackBoxSideEnter")

    local res = AsyncRequestRes:New()
    ---@type ActivityBlackBoxData
    self._activityData = ActivityBlackBoxData:New()
    self._activityData:LoadData(TT, res)

    self:UnLock("UIActivityBlackBoxSideEnter")
    self._campain = self._activityData:GetCampaign()
    local isOpen = self._campain:CheckCampaignOpen()
    if not isOpen then
        self._setShowCallback(false)
        return
    end
    self._setShowCallback(true)

    if self._timer then
        GameGlobal.Timer():CancelEvent(self._timer)
        self._timer = nil
    end

    local showNew =  self._activityData:GetEntryNew()
    local showRed = self._activityData:GetEntryRed()

    self._setNewRedCallback(showNew, showRed)
end

-- 需要提供入口图片
---@return string
function UIActivityBlackBoxSideEnter:GetSideEnterRawImage()
    local campainId = self._activityData:GetCampaignID()
    local cfg = Cfg.cfg_campaign[campainId]
    return cfg and cfg.SideEnterIcon
end