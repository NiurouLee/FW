---@class UISummer1:UIController
_class("UISummer1", UIController)
UISummer1 = UISummer1

function UISummer1:LoadDataOnEnter(TT, res, uiParams)
    self.shopCoinId = 3000211 --商店代币id

    self.mCampaign = self:GetModule(CampaignModule)
    self.summer1Data = self.mCampaign:GetSummer1Data()
    self.summer1Data:RequestCampaign(TT)

    self.isShow = true

    self._loginModule = self:GetModule(LoginModule)
    self._svrTimeModule = self:GetModule(SvrTimeModule)

    self:LoadDataOnEnter_BattlePass(TT)
end

function UISummer1:LoadDataOnEnter_BattlePass(TT)
    local res = AsyncRequestRes:New()
    res:SetSucc(true)

    ---@type UIActivityCampaign
    self._battlepassCampaign = UIActivityCampaign:New()
    self._battlepassCampaign:LoadCampaignInfo(TT, res, ECampaignType.CAMPAIGN_TYPE_BATTLEPASS)
end

function UISummer1:OnShow(uiParams)
    Summer1Data.SetPrefsMain()
    self.imgRT = uiParams[1]
    ---@type UnityEngine.UI.RawImage
    self.rt = self:GetUIComponent("RawImage", "rt")
    ---@type UnityEngine.Animation
    self.anim = self:GetGameObject():GetComponent("Animation")
    ---@type UICustomWidgetPool
    local btns = self:GetUIComponent("UISelectObjectPath", "btns")
    ---@type UICommonTopButton
    self._backBtns = btns:SpawnObject("UICommonTopButton")
    self._backBtns:SetData(
        function()
            self:PlayAnimOut(
                function()
                    self:SwitchState(UIStateType.UIMain)
                end
            )
        end,
        nil,
        nil,
        false,
        function()
            if self.isShow then
                self.isShow = false
                self:ShowHideUI()
            end
        end
    )
    self.animTopBtns = self._backBtns:GetGameObject():GetComponent(typeof(UnityEngine.Animation))
    ---@type UILocalizationText
    self.txtStageLeftTime = self:GetUIComponent("UILocalizationText", "txtStageLeftTime")
    self.txtStageLeftTimeRollingText = self:GetUIComponent("RollingText", "txtStageLeftTime")
    ---@type UILocalizationText
    self.txtShopCount = self:GetUIComponent("UILocalizationText", "txtShopCount")
    ---@type UnityEngine.UI.Button
    self.btnStageNormal = self:GetUIComponent("Button", "btnStageNormal")
    ---@type UnityEngine.UI.Button
    self.btnStageHard = self:GetUIComponent("Button", "btnStageHard")
    self.cdStageHard = self:GetGameObject("cdStageHard")
    ---@type UILocalizationText
    self.txtStageHardOpenTime = self:GetUIComponent("RollingText", "txtStageHardOpenTime")
    ---@type UnityEngine.UI.Button
    self.btnGame = self:GetUIComponent("Button", "btnGame")
    self.cdGame = self:GetGameObject("cdGame")
    ---@type UILocalizationText
    self.txtGameOpenTime = self:GetUIComponent("RollingText", "txtGameOpenTime")
    ---@type RawImageLoader
    self.imgStageNormal = self:GetUIComponent("RawImageLoader", "imgStageNormal")
    self.imgStageHard = self:GetGameObject("imgStageHard")
    self.imgStageHardGray = self:GetGameObject("imgStageHardGray")
    self.imgGame = self:GetGameObject("imgGame")
    self.imgGameGray = self:GetGameObject("imgGameGray")
    self.btnGame = self:GetUIComponent("Button", "btnGame")
    self.redBattlePass = self:GetGameObject("redBattlePass")
    self.redAward = self:GetGameObject("redAward")
    self.redStageNormal = self:GetGameObject("redStageNormal")
    self.newStageHard = self:GetGameObject("newStageHard")
    self.redGame = self:GetGameObject("redGame")
    self.newGame = self:GetGameObject("newGame")
    self:AttachEvent(GameEventType.SummerTwoLoginRed, self.FlushRedPointAward)
    self:AttachEvent(GameEventType.CampaignComponentStepChange, self._OnComponentStepChange)
    self:AttachEvent(GameEventType.ItemCountChanged, self.FlushShopCount)
    self:AttachEvent(GameEventType.ActivityShopBuySuccess, self.FlushShopCount)
    self:AttachEvent(GameEventType.ActivityDialogRefresh, self._OnActivityDialogRefresh)

    self.btnStageNormalState = 0

    self:Flush()

    if uiParams[2] then
        self:PlayAnimIn()
    end

    self.teActivity =
        UIActivityHelper.StartTimerEvent(
        self.teActivity,
        function()
            self:FlushCDActivity(true)
        end
    )
end

function UISummer1:OnHide()
    if self.imgRT then
        self.imgRT:Release()
        self.imgRT = nil
    end
    self:DetachEvent(GameEventType.SummerTwoLoginRed, self.FlushRedPointAward)
    self:DetachEvent(GameEventType.CampaignComponentStepChange, self._OnComponentStepChange)
    self:DetachEvent(GameEventType.ItemCountChanged, self.FlushShopCount)

    self.teActivity = UIActivityHelper.CancelTimerEvent(self.teActivity)
    self:CancelTimerEventNormal()
    self:CancelTimerEventHard()
    self:CancelTimerEventGame()

    self.summer1Data = nil
    self.btnStageNormal = nil
    self.btnStageHard = nil
    self.btnGame = nil
end

function UISummer1:CancelTimerEventNormal()
    if self.teNormal then
        GameGlobal.Timer():CancelEvent(self.teNormal)
    end
end
function UISummer1:CancelTimerEventHard()
    if self.teHard then
        GameGlobal.Timer():CancelEvent(self.teHard)
    end
end
function UISummer1:CancelTimerEventGame()
    if self.teGame then
        GameGlobal.Timer():CancelEvent(self.teGame)
    end
end

function UISummer1:_OnComponentStepChange(campaign_id, component_id, component_step)
    if self.summer1Data then
        if self.summer1Data:GetCampaignId() == campaign_id then
            self:Flush()
        end
    end

    self:FlushRedPointBattlePass() -- 活动id 与夏活不一致
end

function UISummer1:_OnActivityDialogRefresh()
    self:FlushNewGame()
end

function UISummer1:Flush()
    self.rt.texture = self.imgRT
    self:FlushShopCount()

    self:FlushRedPointBattlePass()
    self:FlushRedPointAward()

    self:FlushCDActivity(false)
    self:FlushNormalStage()
    self:FlushCDHard()
    self:FlushCDGame()
end

--海滩商店点数
function UISummer1:FlushShopCount()
    local count = self:GetModule(ItemModule):GetItemCount(self.shopCoinId) or 0
    self.txtShopCount:SetText(count)
end

--region 红点
function UISummer1:FlushRedPointBattlePass() --特别事件簿
    local bShow = UIActivityHelper.CheckCampaignSampleRedPoint(self._battlepassCampaign)
    self.redBattlePass:SetActive(bShow)
end
function UISummer1:FlushRedPointAward() --累计奖励
    local red = self.summer1Data:CheckRedAward()
    self.redAward:SetActive(red)
end
function UISummer1:FlushRedPointStageNormal() --夏之旅红点
    if not self.summer1Data then
        return
    end
    local red = self.summer1Data:CheckRedNormal()
    self.redStageNormal:SetActive(red)
end
function UISummer1:FlushNewStageHard() --幻之境new
    if not self.summer1Data then
        return
    end
    if Summer1Data.HasPrefsHard() then --已进入过高难关
        self.newStageHard:SetActive(false)
    else
        local isOpen = self.summer1Data:GetStateHard() == UISummerOneEnterBtnState.Normal
        self.newStageHard:SetActive(isOpen)
    end
end
function UISummer1:FlushRedPointGame() --小游戏红点
    if not self.summer1Data then
        return
    end
    local red = self.summer1Data:CheckRedGame()
    self.redGame:SetActive(red)
end
function UISummer1:FlushNewGame() --小游戏new
    if not self.summer1Data then
        return
    end
    if self.summer1Data:GetStateGame() == UISummerOneEnterBtnState.Normal then
        local notEnter = not Summer1Data.HasPrefsGame() --未进入过小游戏
        local hasNewStage = self.summer1Data:CheckMiniGameNewStage()
        self.newGame:SetActive(notEnter or hasNewStage)
    else
        self.newGame:SetActive(false)
    end
end
--endregion

--活动倒计时
function UISummer1:FlushCDActivity(fromtimer)
    local nowTimestamp = UICommonHelper.GetNowTimestamp()
    local cHardInfo = self.summer1Data:GetComponentHard()
    if nowTimestamp < cHardInfo.m_close_time then --作战剩余时间
        local leftSeconds = UICommonHelper.CalcLeftSeconds(cHardInfo.m_close_time)
        local d, h, m, s = UICommonHelper.S2DHMS(leftSeconds)
        if d >= 1 then
            self.txtStageLeftTime:SetText(
                StringTable.Get("str_activity_summer_i_stage_left_time_d_h", math.floor(d), math.floor(h))
            )
        else
            if h >= 1 then
                self.txtStageLeftTime:SetText(
                    StringTable.Get("str_activity_summer_i_stage_left_time_h_m", math.floor(h), math.floor(m))
                )
            else
                if m >= 1 then
                    self.txtStageLeftTime:SetText(
                        StringTable.Get("str_activity_summer_i_stage_left_time_m", math.floor(m))
                    )
                else
                    self.txtStageLeftTime:SetText(StringTable.Get("str_activity_summer_i_stage_left_time_lt_m"))
                end
            end
        end
    else
        local cCameInfo = self.summer1Data:GetComponentGame()
        if nowTimestamp < cCameInfo.m_close_time then --刨冰挑战剩余时间
            local leftSeconds = UICommonHelper.CalcLeftSeconds(cCameInfo.m_close_time)
            local d, h, m, s = UICommonHelper.S2DHMS(leftSeconds)
            if d >= 1 then
                self.txtStageLeftTime:SetText(
                    StringTable.Get("str_activity_summer_i_stage_left_time2_d_h", math.floor(d), math.floor(h))
                )
            else
                if h >= 1 then
                    self.txtStageLeftTime:SetText(
                        StringTable.Get("str_activity_summer_i_stage_left_time2_h_m", math.floor(h), math.floor(m))
                    )
                else
                    if m >= 1 then
                        self.txtStageLeftTime:SetText(
                            StringTable.Get("str_activity_summer_i_stage_left_time2_m", math.floor(m))
                        )
                    else
                        self.txtStageLeftTime:SetText(StringTable.Get("str_activity_summer_i_stage_left_time2_lt_m"))
                    end
                end
            end
        else
            self.txtStageLeftTime:SetText(StringTable.Get("str_activity_finished"))
            UIActivityHelper.CancelTimerEvent(self.teActivity)
        end
    end
    if not fromtimer then
        self.txtStageLeftTimeRollingText:RefreshText(self.txtStageLeftTime.text)
    end
end

function UISummer1:RegisterTimeEvent(seconds, componentId)
    if componentId == ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_COMMON then --普通
        self:CancelTimerEventNormal()
    elseif componentId == ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_HARD then --高难
        self:CancelTimerEventHard()
    elseif componentId == ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_SHAVING_ICE then --小游戏
        self:CancelTimerEventGame()
    else
        Log.warn("### RegisterTimeEvent componentId=", componentId)
        return
    end
    if seconds < 60 then
        seconds = 60
    end
    local ms = seconds * 1000
    local te =
        GameGlobal.Timer():AddEvent(
        ms,
        function()
            self:StartTask(
                function(TT)
                    if self.summer1Data then
                        self.summer1Data:RequestCampaign(TT)
                        if componentId == ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_COMMON then --普通
                            self:FlushNormalStage()
                        elseif componentId == ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_HARD then --高难
                            self:FlushCDHard()
                        elseif componentId == ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_SHAVING_ICE then --小游戏
                            self:FlushCDGame()
                        end
                    end
                end,
                self
            )
        end
    )
    if componentId == ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_COMMON then --普通
        self.teNormal = te
    elseif componentId == ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_HARD then --高难
        self.teHard = te
    elseif componentId == ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_SHAVING_ICE then --小游戏
        self.teGame = te
    end
end
--region 普通关
function UISummer1:FlushNormalStage()
    self.btnStageNormal.interactable = false
    self.imgStageNormal:LoadImage("summer_home_xiazhilv_close")
    local cNormalInfo = self.summer1Data:GetComponentNormal()
    if not cNormalInfo then
        Log.fatal("### no ECAMPAIGN_SUMMER_I_LEVEL_COMMON data.")
        return
    end
    local nowTimestamp = UICommonHelper.GetNowTimestamp()
    if nowTimestamp < cNormalInfo.m_unlock_time then --未开启
        local leftSeconds = UICommonHelper.CalcLeftSeconds(cNormalInfo.m_unlock_time)
        self:RegisterTimeEvent(leftSeconds, ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_COMMON)
        self.btnStageNormalState = UISummerOneEnterBtnState.NotOpen
    elseif nowTimestamp > cNormalInfo.m_close_time then --已关闭
        self:CancelTimerEventNormal()
        self.btnStageNormalState = UISummerOneEnterBtnState.Closed
    else --进行中
        self.btnStageNormal.interactable = true
        self.imgStageNormal:LoadImage("summer_home_xiazhilv_open")
        local leftSeconds = UICommonHelper.CalcLeftSeconds(cNormalInfo.m_close_time)
        self:RegisterTimeEvent(leftSeconds, ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_COMMON)
        self.btnStageNormalState = UISummerOneEnterBtnState.Normal
    end
    self:FlushRedPointStageNormal()
end
--endregion

---@param uiText UILocalizationText
---@param time number 时间戳
function UISummer1:FlushCDText(uiText, time)
    local strs = {
        "str_activity_summer_i_will_open_after_d_h",
        "str_activity_summer_i_will_open_after_h_m",
        "str_activity_summer_i_will_open_after_m",
        "str_activity_summer_i_will_open_after_lt_m"
    }
    local leftSeconds = UICommonHelper.CalcLeftSeconds(time)
    --[[
        用例：1小时59分30秒；1小时0分30秒；59分30秒；59秒；
    ]]
    local d, h, m, s = UICommonHelper.S2DHMS(leftSeconds)
    if d >= 1 then
        uiText:RefreshText(StringTable.Get(strs[1], math.floor(d), math.floor(h)))
    else
        if h >= 1 then
            uiText:RefreshText(StringTable.Get(strs[2], math.floor(h), math.floor(m)))
        else
            if m >= 1 then
                uiText:RefreshText(StringTable.Get(strs[3], math.floor(m)))
            else
                uiText:RefreshText(StringTable.Get(strs[4], math.ceil(m)))
            end
        end
    end
end

--region 高难关
function UISummer1:FlushCDHard()
    self.btnStageHard.interactable = false
    self.imgStageHard:SetActive(false)
    self.imgStageHardGray:SetActive(true)
    self.cdStageHard:SetActive(false)
    local stateHard = self.summer1Data:GetStateHard()
    local cHardInfo = self.summer1Data:GetComponentHard()
    if not cHardInfo then
        Log.fatal("### no ECAMPAIGN_SUMMER_I_LEVEL_HARD data.")
        return
    end
    if stateHard == UISummerOneEnterBtnState.NotOpen then
        self.cdStageHard:SetActive(true)
        self:FlushCDText(self.txtStageHardOpenTime, cHardInfo.m_unlock_time)
        --
        local leftSeconds = UICommonHelper.CalcLeftSeconds(cHardInfo.m_unlock_time)
        local secondsLeft = leftSeconds % 60 --还有几秒到达下一分钟的0秒
        self:RegisterTimeEvent(secondsLeft, ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_HARD)
    elseif stateHard == UISummerOneEnterBtnState.Locked then
        self.cdStageHard:SetActive(true)
        local cfgv = Cfg.cfg_campaign_mission[cHardInfo.m_need_mission_id]
        local lvName = StringTable.Get(cfgv.Name)
        self.txtStageHardOpenTime:RefreshText(
            StringTable.Get("str_activity_summer_i_will_open_after_clearance", lvName)
        ) --通关{1}关后开启
    elseif stateHard == UISummerOneEnterBtnState.Closed then
        self:CancelTimerEventHard()
    else
        self.btnStageHard.interactable = true
        self.imgStageHard:SetActive(true)
        self.imgStageHardGray:SetActive(false)
        --
        local leftSeconds = UICommonHelper.CalcLeftSeconds(cHardInfo.m_close_time)
        self:RegisterTimeEvent(leftSeconds, ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_LEVEL_HARD)
    end
    self:FlushNewStageHard()
end
--endregion

--region 小游戏
function UISummer1:FlushCDGame()
    self.btnGame.interactable = false
    self.imgGame:SetActive(false)
    self.imgGameGray:SetActive(true)
    self.cdGame:SetActive(false)
    local stateGame = self.summer1Data:GetStateGame()
    local cCameInfo = self.summer1Data:GetComponentGame()
    if not cCameInfo then
        Log.fatal("### no ECAMPAIGN_SUMMER_I_SHAVING_ICE data.")
        return
    end
    if stateGame == UISummerOneEnterBtnState.NotOpen then
        self.cdGame:SetActive(true)
        self:FlushCDText(self.txtGameOpenTime, cCameInfo.m_unlock_time)
        --
        local leftSeconds = UICommonHelper.CalcLeftSeconds(cCameInfo.m_unlock_time)
        local secondsLeft = leftSeconds % 60 --还有几秒到达下一分钟的0秒
        self:RegisterTimeEvent(secondsLeft, ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_SHAVING_ICE)
    elseif stateGame == UISummerOneEnterBtnState.Locked then
        self.cdGame:SetActive(true)
        local cfgv = Cfg.cfg_campaign_mission[cCameInfo.m_need_mission_id]
        local lvName = StringTable.Get(cfgv.Name)
        self.txtGameOpenTime:RefreshText(StringTable.Get("str_activity_summer_i_will_open_after_clearance", lvName)) --通关{1}关后开启
    elseif stateGame == UISummerOneEnterBtnState.Closed then
        self:CancelTimerEventGame()
    else
        self.btnGame.interactable = true
        self.imgGame:SetActive(true)
        self.imgGameGray:SetActive(false)
        --
        local leftSeconds = UICommonHelper.CalcLeftSeconds(cCameInfo.m_close_time)
        self:RegisterTimeEvent(leftSeconds, ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_SHAVING_ICE)
    end
    self:FlushNewGame()
    self:FlushRedPointGame()
end
--endregion

--region OnClick
function UISummer1:bgOnClick(go)
    if not self.isShow then
        self.isShow = true
        self:ShowHideUI()
    end
end

function UISummer1:btnIntroOnClick(go)
    self:ShowDialog("UISummer1Intro")
end

function UISummer1:btnBattlePassOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1Click)
    UIActivityBattlePassHelper.ShowBattlePassDialog(self._battlepassCampaign)
end

function UISummer1:btnLoginAwardOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1Click)
    self:ShowDialog(
        "UIActivityTotalLoginAwardController",
        false,
        ECampaignType.CAMPAIGN_TYPE_SUMMER_I,
        ECampaignSummerIComponentID.ECAMPAIGN_SUMMER_I_CUMULATIVE_LOGIN
    )
end

function UISummer1:btnBeachShopOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1Click)
    self:ShowDialog("UIXH1Shop")
end

function UISummer1:btnStageNormalOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1Click)
    if self.btnStageNormalState == UISummerOneEnterBtnState.Normal then
        self.mCampaign:CampaignSwitchState(
            true,
            UIStateType.UIXH1SimpleLevel,
            UIStateType.UIMain,
            nil,
            self.summer1Data:GetCampaignId()
        )
    else
        self:_ShowBtnErrorMsg(self.btnStageNormalState)
    end
end

function UISummer1:btnStageHardOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1Click)
    local stateHard = self.summer1Data:GetStateHard()
    if stateHard == UISummerOneEnterBtnState.Locked then
        --提示通关xxx后解锁
        local cHardInfo = self.summer1Data:GetComponentHard()
        if cHardInfo then
            local cfgv = Cfg.cfg_campaign_mission[cHardInfo.m_need_mission_id]
            if cfgv then
                local lvName = StringTable.Get(cfgv.Name)
                local msg = StringTable.Get("str_activity_summer_i_will_open_after_clearance", lvName) --通关{1}关后开启
                ToastManager.ShowToast(msg)
            end
        end
    elseif stateHard == UISummerOneEnterBtnState.Normal then
        if not Summer1Data.HasPrefsHard() then
            Summer1Data.SetPrefsHard()
        end
        ---@type H3DUIBlurHelper
        local blur = self:GetUIComponent("H3DUIBlurHelper", "screenShot")
        local size = self:GetUIComponent("RectTransform", "screenShot").rect.size
        blur.OwnerCamera = GameGlobal.UIStateManager():GetControllerCamera(self:GetName())
        local rt = blur:BlurTexture(size.x, size.y, 0)
        local cache_rt = UnityEngine.RenderTexture:New(size.x, size.y, 16)
        self:StartTask(
            function(TT)
                YIELD(TT)
                UnityEngine.Graphics.Blit(rt, cache_rt)
                self.mCampaign:CampaignSwitchState(
                    true,
                    UIStateType.UIXH1HardLevel,
                    UIStateType.UIMain,
                    {{false, false, cache_rt}},
                    self.summer1Data:GetCampaignId()
                )
            end
        )
    else
        self:_ShowBtnErrorMsg(stateHard)
    end
end

function UISummer1:btnGameOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1Click)
    local state = self.summer1Data:GetStateGame()
    if state == UISummerOneEnterBtnState.Normal then
        if not Summer1Data.HasPrefsGame() then
            Summer1Data.SetPrefsGame()
        end
        self:ShowDialog("UIMiniGameStageController")
    else
        self:_ShowBtnErrorMsg(state)
    end
end
function UISummer1:_ShowBtnErrorMsg(btnState)
    local errType = 0
    if btnState == UISummerOneEnterBtnState.NotOpen then
        errType = CampaignErrorType.E_CAMPAIGN_ERROR_TYPE_CAMPAIGN_NO_OPEN
        self.mCampaign:ShowErrorToast(errType, true)
    elseif btnState == UISummerOneEnterBtnState.Closed then
        errType = CampaignErrorType.E_CAMPAIGN_ERROR_TYPE_CAMPAIGN_FINISHED
        self.mCampaign:ShowErrorToast(errType, true)
    end
end
--endregion

function UISummer1:PlayAnimIn()
    self:StartTask(
        function(TT)
            self:Lock("UISummer1PlayAnimOut")
            AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1SeaWave)
            self.anim:Play("uieff_Activity_Summer1_In")
            YIELD(TT, 1100)
            GameGlobal.EventDispatcher():Dispatch(GameEventType.GuideOpenUI, GuideOpenUI.UISummer1)
            self:UnLock("UISummer1PlayAnimOut")
        end,
        self
    )
end
function UISummer1:PlayAnimOut(callback)
    self:StartTask(
        function(TT)
            self:Lock("UISummer1PlayAnimOut")
            AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1SeaWave)
            local go = self.rt.gameObject
            if go.activeInHierarchy then
                go:SetActive(false)
            end
            self.anim:Play("uieff_Activity_Summer1_Out")
            YIELD(TT, 1000)
            self:UnLock("UISummer1PlayAnimOut")
            if callback then
                callback()
            end
        end,
        self
    )
end

function UISummer1:ShowHideUI()
    self:StartTask(
        function(TT)
            self:Lock("UISummer1ShowHideUI")
            local animName = "uieff_Activity_Summer1_enjoy"
            local animNameTB = "uieff_CommonTopBtn_In1"
            ---@type UnityEngine.AnimationState
            local state = self.anim:get_Item(animName)
            ---@type UnityEngine.AnimationState
            local stateTB = self.animTopBtns:get_Item(animNameTB)
            if self.isShow then
                state.speed = -1
                stateTB.speed = 1
                self._backBtns:GetGameObject():SetActive(true)
                state.time = state.clip.length
                stateTB.time = 0
            else
                state.speed = 1
                stateTB.speed = -1
                state.time = 0
                stateTB.time = state.clip.length
            end
            self.anim:Play(animName)
            self.animTopBtns:Play()
            YIELD(TT, 633)
            if self.isShow then
            else
                self._backBtns:GetGameObject():SetActive(false)
            end
            self:UnLock("UISummer1ShowHideUI")
        end,
        self
    )
end
