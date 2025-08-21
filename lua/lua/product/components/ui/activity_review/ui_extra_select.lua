--
---@class UIExtraSelect : UIController
_class("UIExtraSelect", UIController)
UIExtraSelect = UIExtraSelect

function UIExtraSelect:LoadDataOnEnter(TT, res)
    local module = GameGlobal.GetModule(RoleModule)
    self._isPetExtraLock = not module:CheckModuleUnlock(GameModuleID.MD_ExtMission)
    self._isReviewLock = not module:CheckModuleUnlock(GameModuleID.MD_CAMPAIGNREVIEW) --关卡解锁条件
end

--初始化
function UIExtraSelect:OnShow(uiParams)
    self:InitWidget()
    ---@type UICommonTopButton
    local topWidget = self.topBtn:SpawnObject("UICommonTopButton")
    topWidget:SetData(
        function()
            self:SwitchState(UIStateType.UIDiscovery)
        end
    )

    self.extraLock:SetActive(self._isPetExtraLock)
    local openTime =
        GameGlobal.GetModule(LoginModule):GetTimeStampByTimeStr(
        Cfg.cfg_global["ActiveReviewStartTime"].StrValue,
        Enum_DateTimeZoneType.E_ZoneType_GMT
    )
    local delta = openTime - GetSvrTimeNow()
    self._isReviewClose = delta > 0
    self.reviewLock:SetActive(self._isReviewLock or self._isReviewClose)
    if delta > 0 then
        self._timeStr = HelperProxy:GetInstance():FormatTime_3(delta)
        self.countdown:SetText(self._timeStr)

        self._timerHolder = UITimerHolder:New()
        self._timerHolder:StartTimerInfinite(
            "ReviewOpenCountdown",
            1000,
            function()
                local delta = openTime - GetSvrTimeNow()
                if delta > 0 then
                    local timeStr = HelperProxy:GetInstance():FormatTime_3(delta)
                    if self._timeStr ~= timeStr then
                        self.countdown:SetText(timeStr)
                        self._timeStr = timeStr
                    end
                    self._isReviewClose = true
                else
                    self.countdown.gameObject:SetActive(false)
                    self._isReviewClose = false
                    self.reviewLock:SetActive(self._isReviewLock or self._isReviewClose)
                end
            end
        )
    else
        self.countdown.gameObject:SetActive(false)
    end

    ---@type UICampaignModule
    local uiModule = GameGlobal.GetUIModule(CampaignModule)
    local data = uiModule:GetReviewData()
    self.reviewRed:SetActive(not data:IsLocked() and (data:HasCollectableItem() or data:HasUnlockableItem()))

    local petStoryModule = self:GetModule(ExtMissionModule)
    local awardRed = petStoryModule:UI_IsExtAwardRed()
    local newChapter = petStoryModule:UI_IsExtNewChapter()
    local isRedPetStory = (newChapter or awardRed)
    self.extraRed:SetActive(isRedPetStory)
end
function UIExtraSelect:OnHide()
    if self._timerHolder then
        self._timerHolder:Dispose()
        self._timerHolder = nil
    end
end
--获取ui组件
function UIExtraSelect:InitWidget()
    --generated--
    ---@type UICustomWidgetPool
    self.topBtn = self:GetUIComponent("UISelectObjectPath", "topBtn")
    ---@type UnityEngine.GameObject
    self.extraLock = self:GetGameObject("ExtraLock")
    ---@type UnityEngine.GameObject
    self.reviewLock = self:GetGameObject("ReviewLock")
    ---@type UILocalizationText
    self.countdown = self:GetUIComponent("UILocalizationText", "countdown")
    --generated end--
    self.reviewRed = self:GetGameObject("reviewRed")
    self.extraRed = self:GetGameObject("extraRed")
end
--按钮点击
function UIExtraSelect:PetExtraOnClick(go)
    -- GameGlobal.UAReportForceGuideEvent("UIDiscoveryClick", {"PetStory"}, true)
    if self._isPetExtraLock then
        ToastManager.ShowToast(StringTable.Get("str_function_lock_fanwaijuben_tips"))
        return
    end
    self:StartTask(self._reqPetExtraData, self)
end
--按钮点击
function UIExtraSelect:ActivityReviewOnClick(go)
    if self._isReviewClose then
        ToastManager.ShowToast(StringTable.Get("str_function_lock_review_tips"))
        return
    end
    if self._isReviewLock then
        local functionLockCfg = Cfg.cfg_module_unlock[GameModuleID.MD_CAMPAIGNREVIEW]
        ToastManager.ShowToast(StringTable.Get(functionLockCfg.Tips))
        return
    end
    self:SwitchState(UIStateType.UIActivityReview)
end

function UIExtraSelect:_reqPetExtraData(TT)
    ---@type ExtMissionModule
    local extModule = GameGlobal.GetModule(ExtMissionModule)
    if not extModule then
        Log.fatal("[error] extModule is nil !")
    end
    self:Lock("extModule:Request_GetSummary_All")
    local res = extModule:Request_GetSummary_All(TT)
    self:UnLock("extModule:Request_GetSummary_All")
    if res:GetSucc() then
        self:SwitchState(UIStateType.UIExtraMission)
    else
        Log.fatal("请求番外数据失败:", res:GetResult())
    end
end
