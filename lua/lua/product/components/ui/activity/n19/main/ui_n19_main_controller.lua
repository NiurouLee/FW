--- @class UIN19MainController:UIController
_class("UIN19MainController", UIController)
UIN19MainController = UIN19MainController

--region help
--
function UIN19MainController:_SetRemainingTime(widgetName, extraId, descId, endTime, customTimeStr)
    ---@type UIActivityCommonRemainingTime
    local obj = UIWidgetHelper.SpawnObject(self, widgetName, "UIActivityCommonRemainingTime")

    if customTimeStr then
        obj:SetCustomTimeStr_Common_1()
    end
    -- obj:SetExtraRollingText()
    obj:SetExtraText("txtDesc", nil, extraId)
    obj:SetAdvanceText(descId)

    obj:SetData(
        endTime,
        nil,
        function()
            self:_UpdateTime()
        end
    )
end

--endregion

--region resident func [ver_20220506]
function UIN19MainController:_SetCommonTopButton()
    ---@type UICommonTopButton
    local obj = UIWidgetHelper.SpawnObject(self, "_backBtns", "UICommonTopButton")
    obj:SetData(
        function()
            self:_Back()
        end,
        nil,
        nil,
        false,
        function()
            self:_HideUI()
        end
    )
end

--
function UIN19MainController:_Back()
    self:SwitchState(UIStateType.UIMain)
end

--
function UIN19MainController:_HideUI()
    self:GetGameObject("_backBtns"):SetActive(false)
    self:GetGameObject("_showBtn"):SetActive(true)

    -- self:GetGameObject("_uiElements"):SetActive(false)
    UIWidgetHelper.PlayAnimation(self, "_anim", "eff_UIN19MainController_out", 500, nil)
    if self._lineLevelBtn then
        UIWidgetHelper.PlayAnimation(self._lineLevelBtn, "_anim", "eff_UIN19LineLevelBtn_out", 500, nil)
    end
    if self._miniGameBtn then
        UIWidgetHelper.PlayAnimation(self._miniGameBtn, "_anim", "eff_UIN19MiniGameBtn_out", 500, nil)
    end
end

--
function UIN19MainController:_ShowUI()
    self:GetGameObject("_backBtns"):SetActive(true)
    self:GetGameObject("_showBtn"):SetActive(false)

    -- self:GetGameObject("_uiElements"):SetActive(true)
    UIWidgetHelper.PlayAnimation(self, "_anim", "eff_UIN19MainController_in2", 667, nil)
    if self._lineLevelBtn then
        UIWidgetHelper.PlayAnimation(self._lineLevelBtn, "_anim", "eff_UIN19LineLevelBtn_in", 667, nil)
    end
    if self._miniGameBtn then
        UIWidgetHelper.PlayAnimation(self._miniGameBtn, "_anim", "eff_UIN19MiniGameBtn_in", 667, nil)
    end
end

--
function UIN19MainController:_SetBg()
    local url = UIActivityHelper.GetCampaignMainBg(self._campaign, 1)
    if url then
        UIWidgetHelper.SetRawImage(self, "_mainBg", url)
    end
end

--
function UIN19MainController:_SetSpine()
    local obj = self:GetUIComponent("SpineLoader", "_spine")
    obj:LoadSpine("n19_kv_2_spine_idle")
end

--
function UIN19MainController:_SetImgRT(imgRT)
    if imgRT ~= nil then
        ---@type UnityEngine.UI.RawImage
        local rt = self:GetUIComponent("RawImage", "rt")
        rt.texture = imgRT

        return true
    end
    return false
end

--
function UIN19MainController:_CheckGuide()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.GuideOpenUI, GuideOpenUI.UIN19MainController)
end

--endregion

--
--- @param TT 协程函数标识
--- @param res AsyncRequestRes 异步请求结果
function UIN19MainController:LoadDataOnEnter(TT, res, uiParams)
    self._campaignType = ECampaignType.CAMPAIGN_TYPE_N19_COMMON

    -- 获取活动 以及本窗口需要的组件
    ---@type UIActivityCampaign
    self._campaign = UIActivityCampaign:New()
    self._campaign:LoadCampaignInfo(
        TT,
        res,
        self._campaignType,
        ECampaignN19CommonComponentID.HARD_LEVEL,
        ECampaignN19CommonComponentID.COMMON_LEVEL,
        ECampaignN19CommonComponentID.PANGOLIN
    )

    -- 错误处理
    if res and not res:GetSucc() then
        self._campaign:CheckErrorCode(res.m_result, nil, nil)
        return
    end

    -- 清除 new
    self._campaign:ClearCampaignNew(TT)

    -- region 战斗通行证
    ---@type UIActivityCampaign
    self._bp_campaign = UIActivityCampaign:New()
    local bp_res = AsyncRequestRes:New()
    self._bp_campaign:LoadCampaignInfo(TT, bp_res, ECampaignType.CAMPAIGN_TYPE_BATTLEPASS)
    --endregion
end

--
function UIN19MainController:OnShow(uiParams)
    self:_AttachEvents()
    self._isOpen = true

    self:_SetBg()
    self:_SetCommonTopButton()

    self:_SetSpine()

    self:_UpdateTime()

    self:_Refresh()

    --------------------------------------------------------------------------------
    -- 传入底图，并决定是否播放动效
    -- if self:_SetImgRT(uiParams[1]) then
    UIWidgetHelper.PlayAnimation(
        self,
        "_anim",
        "eff_UIN19MainController_in",
        1000,
        function()
            self:_CheckGuide()
        end
    )
    -- else
    --     self:_CheckGuide()
    -- end
end

--
function UIN19MainController:OnHide()
    self:_DetachEvents()
    self._isOpen = false
end

function UIN19MainController:Destroy()
    self._bpMatReq = UIWidgetHelper.DisposeLocalizedTMPMaterial(self._bpMatReq)
end

--
function UIN19MainController:_Refresh()
    self:_SetBattlePassBtn(self._bp_campaign)
    self:_SetLineLevelBtn()
    self:_SetMiniGameBtn()
end

function UIN19MainController:_UpdateTime()
    --- @type SvrTimeModule
    local svrTimeModule = GameGlobal.GetModule(SvrTimeModule)
    local curTime = math.floor(svrTimeModule:GetServerTime() * 0.001)

    local stop = self._campaign:GetSample().end_time

    if curTime < stop then
        self:_SetRemainingTime("_remainingTimePool", "", "str_n19_main_remaining_time", stop, true)
    end
end

--region EnterBtn

---@param campaign UIActivityCampaign
function UIN19MainController:_SetBattlePassBtn(bp_campaign)
    local useStateUI = false

    -- 检查活动是否开启，决定是否显示
    local open_sample = bp_campaign:CheckCampaignOpen()
    if open_sample then
        local obj = UIWidgetHelper.SpawnObject(self, "_battlePassBtn", "UIActivityCommonCampaignEnter")
        obj:SetData(bp_campaign, useStateUI)

        self._bpMatReq = UIWidgetHelper.SetLocalizedTMPMaterial(obj, "_txtTitle", "uieff_uin19_main_battlepass.mat",
            self._bpMatReq)
    end

    local obj = self:GetGameObject(widgetName)
    obj:SetActive(open_sample)
end

function UIN19MainController:_SetLineLevelBtn()
    local componentId = ECampaignN19CommonComponentID.COMMON_LEVEL
    local component = self._campaign:GetComponent(componentId)

    local obj = UIWidgetHelper.SpawnObject(self, "_lineLevelBtn", "UIActivityCommonComponentEnterLock")

    -- obj:SetNew("_new",
    --     function()
    --         return false
    --     end
    -- )

    obj:SetRed(
        "_red",
        function()
            return component:HaveRedPoint()
        end
    )

    -- remaining time
    -- local unlockTime = component and component:ComponentUnLockTime() or 0
    -- obj:SetActivityCommonRemainingTime("_timePool_lock", "str_n19_line_level_remaining_time", unlockTime, true)

    local tb = {
        { "state_lock", "time_lock" },
        { "state_lock" },
        { "state_unlock" },
        { "state_close" }
    }
    obj:SetWidgetNameGroup(tb)

    obj:SetData(
        self._campaign,
        componentId,
        function()
            self._campaign._campaign_module:CampaignSwitchState(
                true,
                UIStateType.UIN19LineMissionController,
                UIStateType.UIMain,
                nil,
                self._campaign._id
            )
        end
    )

    self._lineLevelBtn = obj
end

function UIN19MainController:_SetMiniGameBtn()
    local componentId = ECampaignN19CommonComponentID.PANGOLIN
    local component = self._campaign:GetComponent(componentId)

    local obj = UIWidgetHelper.SpawnObject(self, "_miniGameBtn", "UIActivityCommonComponentEnterLock")

    obj:SetNew("_new",
        function()
            -- 任务新开启
            local new = component:NewTaskRed("N19TaskComp", "red")
            -- 组件开起
            local comNew = component:GetPrefsComponentNew("N19TaskComp")
            return (new ~= nil and new > 0) or comNew < 1
        end
    )

    obj:SetRed(
        "_red",
        function()
            return component:HaveRedPoint()
        end
    )

    -- remaining time
    local unlockTime = component and component:ComponentUnLockTime() or 0
    obj:SetActivityCommonRemainingTime("_timePool_lock", "str_n19_minigame_remaining_time", unlockTime, true)

    local tb = {
        { "state_lock", "time_lock" },
        { "state_lock" },
        { "state_unlock" },
        { "state_close" }
    }
    obj:SetWidgetNameGroup(tb)

    obj:SetData(
        self._campaign,
        componentId,
        function()
            -- self:ShowDialog("UICampainEnterController", 1)
            self:ShowDialog("UIHomelandStoryTaskSimpleController", 1, self._campaignType, componentId)
        end
    )

    self._miniGameBtn = obj
end

--endregion

--region Event Callback

--
function UIN19MainController:ShowBtnOnClick(go)
    self:_ShowUI()
end

--endregion

--region AttachEvent

function UIN19MainController:_AttachEvents()
    self:AttachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
    self:AttachEvent(GameEventType.AfterUILayerChanged, self._Refresh)
end

function UIN19MainController:_DetachEvents()
    self:DetachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
    self:DetachEvent(GameEventType.AfterUILayerChanged, self._Refresh)
end

function UIN19MainController:_CheckActivityClose(id)
    if self._campaign and self._campaign._id == id then
        self:SwitchState(UIStateType.UIMain)
    end
end

--endregion
