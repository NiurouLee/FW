---@class UIN21LineMissionController:UIController
_class("UIN21LineMissionController", UIController)
UIN21LineMissionController = UIN21LineMissionController

--region Helper

function UIN21LineMissionController:_SetRemainingTime(widgetName, descId, endTime)
    local obj = UIWidgetHelper.SpawnObject(self, widgetName, "UIActivityCommonRemainingTime")

    obj:SetCustomTimeStr_Common_1()
    obj:SetExtraRollingText()
    obj:SetAdvanceText(descId)

    obj:SetData(endTime, nil, nil)
end

--endregion

function UIN21LineMissionController:InitWidget()
    local backBtns = self:GetUIComponent("UISelectObjectPath", "_backBtns")
    ---@type UICommonTopButton
    self._backBtns = backBtns:SpawnObject("UICommonTopButton")
    self._backBtns:SetData(
        function()
            ---@type CampaignModule
            local campaignModule = GameGlobal.GetModule(CampaignModule)
            campaignModule:CampaignSwitchState(
                true,
                UIStateType.UIN21Controller,
                UIStateType.UIMain,
                nil,
                self._campaign._id
            )
        end
    )
    ---@type UnityEngine.UI.ScrollRect
    self._scrollRect = self:GetUIComponent("ScrollRect", "MapContent")
    self._mapContentRect = self:GetUIComponent("RectTransform", "MapContent")
    self._contentRect = self:GetUIComponent("RectTransform", "Content")

    --安全区宽度,没有找到框架的接口,直接从RectTransform上取
    self._safeAreaSize = self:GetUIComponent("RectTransform", "SafeArea").rect.size

    self.PetTryRed = self:GetGameObject("PetTryRed")

    self.timeStr = self:GetUIComponent("UILocalizationText","timeStr")
end
function UIN21LineMissionController:PetTryBtnOnClick(go)
    local component = self._campaign:GetComponentInfo(ECampaignN21ComponentID.ECAMPAIGN_N21_LEVEL_FIXTEAM)
    local endTime = component.m_close_time
    local nowTime = self._svrTimeModule:GetServerTime() * 0.001
    self._petTryLock = endTime < nowTime

    if self._petTryLock then
        local tips = StringTable.Get("str_activity_common_notice_content")
        ToastManager.ShowToast(tips)
        return
    end

    self:ShowDialog(
        "UIActivityPetTryController",
        ECampaignType.CAMPAIGN_TYPE_N21,
        ECampaignN21ComponentID.ECAMPAIGN_N21_LEVEL_FIXTEAM,
        function(mid)
            local component = self._campaign:GetComponent(ECampaignN21ComponentID.ECAMPAIGN_N21_LEVEL_FIXTEAM)
            return component:IsPassCamMissionID(mid)
        end,
        function(missionid)
            ---@type TeamsContext
            local ctx = self._missionModule:TeamCtx()
            local missionComponent = self._campaign:GetComponent(ECampaignN21ComponentID.ECAMPAIGN_N21_LEVEL_FIXTEAM)
            local param = {
                missionid,
                missionComponent:GetCampaignMissionComponentId(),
                missionComponent:GetCampaignMissionParamKeyMap()
            }
            ctx:Init(TeamOpenerType.Campaign, param)
            ctx:ShowDialogUITeams(false)
        end
    )
end
--- @param TT 协程函数标识
--- @param res AsyncRequestRes 异步请求结果
function UIN21LineMissionController:LoadDataOnEnter(TT, res, uiParams)
    self._campaignType = ECampaignType.CAMPAIGN_TYPE_N21
    self._componentId_LineMission = ECampaignN21ComponentID.ECAMPAIGN_N21_LEVEL_COMMON
    -- self._componentId_LineMissionFixteam = ECampaignN8ComponentID.ECAMPAIGN_N8_LINE_MISSION_FIXTEAM -- todo

    -- 获取活动 以及本窗口需要的组件
    ---@type UIActivityCampaign
    self._campaign = UIActivityCampaign:New()
    self._campaign:LoadCampaignInfo(
        TT,
        res,
        self._campaignType,
        self._componentId_LineMission
        -- self._componentId_LineMissionFixteam
    )

    --强制请求
    --请求完了再获取就一定是最新的了
    self._campaign:ReLoadCampaignInfo_Force(TT, res)

    self._campaignID = self._campaign._id

    if res and res:GetSucc() then
        ---@type LineMissionComponent
        self._line_component = self._campaign:GetComponent(self._componentId_LineMission)
        --- @type LineMissionComponentInfo
        self._line_info = self._line_component:GetComponentInfo()

        if not self._campaign:CheckComponentOpen(self._componentId_LineMission) then
            res.m_result = self._campaign:CheckComponentOpenClientError(self._componentId_LineMission) or res.m_result
            self._campaign:ShowErrorToast(res.m_result, true)
            return
        end
    end

    -- 错误处理
    if res and not res:GetSucc() then
        self._campaign._campaign_module:CheckErrorCode(res.m_result, self._campaign._id, nil, nil)
    end
    self._svrTimeModule = GameGlobal.GetModule(SvrTimeModule)
end

function UIN21LineMissionController:OnShow(uiParams)
    self._missionModule = GameGlobal.GetModule(MissionModule)
    self._isOpen = true
    self._timerHolder = UITimerHolder:New()

    self:AttachEvents()
    self:InitWidget()

    self:_Refresh()

    -- 进场锁定
    local lockName = "UIN21LineMissionController_OnShow"
    self:Lock(lockName)
    self._timerHolder:StartTimer(
        lockName,
        500,
        function()
            self:UnLock(lockName)
        end
    )
end

function UIN21LineMissionController:OnHide()
    self._isOpen = false
    self._timerHolder:Dispose()

    UIN21LineMissionController.super:Dispose()
    if self._scroller then
        self._scroller:Dispose()
    end

    if self._timer then
        GameGlobal.Timer():CancelEvent(self._timer)
        self._timer = nil
    end
end

function UIN21LineMissionController:_Refresh()
    self:FlushNodes()

    self:TimeStr()

    local redTry = self:_CheckRedPoint(self.PetTryRed, ECampaignN21ComponentID.ECAMPAIGN_N21_LEVEL_FIXTEAM)
    self.PetTryRed:SetActive(redTry)
end
function UIN21LineMissionController:_CheckRedPoint(obj, ...)
    local bShow = self._campaign:CheckComponentRed(...)
    return bShow
end
function UIN21LineMissionController:TimeStr()
    self.svrTimeModule = GameGlobal.GetModule(SvrTimeModule)
    if self._timer then
        GameGlobal.Timer():CancelEvent(self._timer)
    end
    self._timer = GameGlobal.Timer():AddEventTimes(1000,TimerTriggerCount.Infinite,function()
        self:ShowLessTime()
    end)
    
    self:ShowLessTime()
end
function UIN21LineMissionController:Time2Tex(sec)
    local timeStr = ""
    local minAll = sec // 60
    local min = minAll % 60
    local hourAll = minAll // 60
    local hour = hourAll % 24
    local day = hourAll // 24
    if day and day > 0 then
        --如果有小时
        if hour and hour > 0 then
            timeStr = StringTable.Get("str_n21_reset_time_day_and_hour", day, hour)
        else
            timeStr = StringTable.Get("str_n21_reset_time_day", day)
        end
        return timeStr
    end
    if hour and hour > 0 then
        if min and min > 0 then
            timeStr = StringTable.Get("str_n21_reset_time_hour_and_min", hour, min)
        else
            timeStr = StringTable.Get("str_n21_reset_time_hour", hour)
        end
        return timeStr
    end
    if min and min > 0 then
        timeStr = StringTable.Get("str_n21_reset_time_only_min", min)
        return timeStr
    end
    timeStr = StringTable.Get("str_n21_reset_time_only_sec")
    return timeStr
end
function UIN21LineMissionController:ShowLessTime()
    local endTime = self._line_component:GetComponentInfo().m_close_time
    local nowTime = self.svrTimeModule:GetServerTime()*0.001
    if nowTime<endTime then
        local sec = math.modf(endTime-nowTime)
        local timeStr = self:Time2Tex(sec)
        self.timeStr:SetText(StringTable.Get("str_n19_main_remaining_time",timeStr))
    else
        if self._timer then
            GameGlobal.Timer():CancelEvent(self._timer)
            self._timer = nil
        end
    end
end
function UIN21LineMissionController:FlushNodes()
    local cmpID = self._line_component:GetComponentCfgId()
    local extra_cfg = Cfg.cfg_component_line_mission_extra {ComponentID = cmpID}
    local extra_width = extra_cfg[1].MarginRight
    local missionCfgs_temp = Cfg.cfg_component_line_mission {ComponentID = cmpID}
    --所有配置,以id为索引
    local missionCfgs = {}
    for _, cfg in pairs(missionCfgs_temp) do
        missionCfgs[cfg.CampaignMissionId] = cfg
    end
    --所有关卡的解锁关系
    local unlockInfo = {}
    local firstMissionID = nil
    for _, cfg in pairs(missionCfgs) do
        if unlockInfo[cfg.NeedMissionId] == nil then
            unlockInfo[cfg.NeedMissionId] = {}
        end
        unlockInfo[cfg.NeedMissionId][cfg.CampaignMissionId] = cfg
        if cfg.NeedMissionId == 0 then
            firstMissionID = cfg.CampaignMissionId
        end
    end
    local showMission = {}
    local levelCount, lineCount = 0, 0
    if next(self._line_info.m_pass_mission_info) then
        for missionID, passInfo in pairs(self._line_info.m_pass_mission_info) do
            if not showMission[missionID] then
                showMission[missionID] = missionCfgs[missionID]
                levelCount = levelCount + 1
            end
            if unlockInfo[missionID] then
                for id, cfg in pairs(unlockInfo[missionID]) do
                    if not showMission[id] then
                        showMission[id] = missionCfgs[id]
                        levelCount = levelCount + 1
                    end
                    --S关和第1关不需要连线
                    if cfg.WayPointType ~= 4 and cfg.NeedMissionId ~= 0 then
                        lineCount = lineCount + 1
                    end
                end
            end
        end
    else
        --没有通关信息则显示第一关
        showMission[firstMissionID] = missionCfgs[firstMissionID]
        levelCount = 1
    end

    -- 设置节点和线
    self:_SetNodeAndLine(levelCount, lineCount, showMission)

    local right = -99999999
    for _, cfg in pairs(showMission) do
        right = math.max(right, cfg.MapPosX)
    end
    --滚动列表总宽度=最右边路点+右边距
    local width = math.abs(right + extra_width)
    width = math.max(self._safeAreaSize.x, width)
    self._contentRect.sizeDelta = Vector2(width, self._contentRect.sizeDelta.y)
    self._contentRect.anchoredPosition = Vector2(self._safeAreaSize.x - width, 0)

    --背景滚动
    --self:_SetLevelScroller(missionCfgs)

    self._allMissionCfgs = missionCfgs
end

function UIN21LineMissionController:_SetNodeAndLine(levelCount, lineCount, showMission)
    local nodes = UIWidgetHelper.SpawnObjects(self, "Nodes", "UIN21LineMissionMapNode", levelCount)
    local lines = UIWidgetHelper.SpawnObjects(self, "Lines", "UIN21LineMissionMapLine", lineCount)

    local nodeIdx, lineIdx = 1, 1
    for missionID, cfg in pairs(showMission) do
        ---@type UIN21LineMissionMapNode
        local uiNode = nodes[nodeIdx]
        uiNode:SetData(
            cfg,
            self._line_info.m_pass_mission_info[missionID],
            function(stageId, isStory, worldPos)
                self:_OnNodeClick(stageId, isStory, worldPos)
            end
        )
        nodeIdx = nodeIdx + 1

        if cfg.WayPointType ~= 4 and cfg.NeedMissionId ~= 0 then
            local n1 = showMission[cfg.NeedMissionId]
            local n2 = cfg
            ---@type UIN21LineMissionMapLine
            local line = lines[lineIdx]
            line:Flush(Vector2(n2.MapPosX, n2.MapPosY), Vector2(n1.MapPosX, n1.MapPosY))
            lineIdx = lineIdx + 1
        end
    end
end

function UIN21LineMissionController:_SetLevelScroller(missionCfgs)
    local posx = {}
    for _, cfg in pairs(missionCfgs) do
        posx[#posx + 1] = cfg.MapPosX
    end
    table.sort(posx) --所有路点横坐标从左到右排序

    local sp1, sp2 = 6, 12

    -- 28个路点分成 3 段,有两个分割点,可能会经常改动
    ---@type UILevelScroller
    self._scroller =
        UILevelScroller:New(
        self._contentRect,
        self:GetUIComponent("RawImageLoader", "bg1"),
        self:GetUIComponent("RawImageLoader", "bg2"),
        {
            "n19_xxg_bg1",
            "n19_xxg_bg2"
        },
        {
            posx[sp1],
            posx[sp1 + 1]
        }
    )
    self._scrollRect.onValueChanged:AddListener(
        function()
            self._scroller:OnChange()
        end
    )
end

function UIN21LineMissionController:_OnNodeClick(stageId, isStory, worldPos)
    if isStory then
        self:_OnNodeClick_Story(stageId, worldPos)
    else
        self:_OnNodeClick_Battle(stageId, worldPos)
    end
end

function UIN21LineMissionController:_OnNodeClick_Story(stageId, worldPos)
    --剧情关
    local missionCfg = Cfg.cfg_campaign_mission[stageId]
    local titleId = StringTable.Get(missionCfg.Title)
    local titleName = StringTable.Get(missionCfg.Name)
    ---@type MissionModule
    local missionModule = self:GetModule(MissionModule)
    local storyId = missionModule:GetStoryByStageIdStoryType(stageId, StoryTriggerType.Node)
    if not storyId then
        Log.exception("配置错误,找不到剧情,关卡id:", stageId)
        return
    end

    self:ShowDialog(
        "UIActivityPlotEnter",
        titleId,
        titleName,
        storyId,
        function()
            self:PlotEndCallback(stageId)
        end
    )
end

function UIN21LineMissionController:_OnNodeClick_Battle(stageId, worldPos)
    --战斗关
    local pos = self._allMissionCfgs[stageId].MapPosX
    local curPos = self._contentRect.anchoredPosition.x
    local areaWidth = 408
    local halfScreen = self._safeAreaSize.x / 2
    local targetPos = nil
    local left, right = -curPos + areaWidth, -curPos + self._safeAreaSize.x - areaWidth
    if pos < left then
        targetPos = curPos + left - pos
    elseif pos > right then
        targetPos = curPos + right - pos
    end
    self._scrollRect:StopMovement()
    if self._tweener then
        self._tweener:Kill()
        self._tweener = nil
    end
    if targetPos then
        local move_time = 0.5
        self._tweener = self._contentRect:DOAnchorPosX(targetPos, move_time)
        -- 移动关卡锁定
        local moveLockName = "UIActivityLineMissionController_MoveToStage"
        self:Lock(moveLockName)
        self._timerHolder:StartTimer(
            moveLockName,
            move_time * 1000,
            function()
                self:UnLock(moveLockName)
                self:_EnterStage(stageId, worldPos) -- 移动后，进入关卡
            end
        )
    else
        self:_EnterStage(stageId, worldPos) -- 直接进入关卡
    end
end

function UIN21LineMissionController:_EnterStage(stageId, worldPos)
    local missionCfg = Cfg.cfg_campaign_mission[stageId]
    local autoFightShow = self:_CheckSerialAutoFightShow(missionCfg.Type, stageId)
    local pointComponent = self._campaign:GetComponentByType(CampaignComType.E_CAMPAIGN_COM_ACTION_POINT, 1)
    self:ShowDialog(
        "UIActivityLevelStageNew",
        stageId,
        self._line_info.m_pass_mission_info[stageId],
        self._line_component,
        autoFightShow,
        pointComponent
        --行动点组件
    )
end

function UIN21LineMissionController:_CheckSerialAutoFightShow(stageType, stageId)
    local autoFightShow = false
    if stageType == DiscoveryStageType.Plot then
        autoFightShow = false
    else
        local missionCfg = Cfg.cfg_campaign_mission[stageId]
        if missionCfg then
            local enableParam = missionCfg.EnableSerialAutoFight
            local tb = {
                [CampainMissionCanSerialAutoFightType.E_CAMPAIGN_MISSION_CAN_SERIAL_AUTO_FIGHT_DISABLE] = false,
                [CampainMissionCanSerialAutoFightType.E_CAMPAIGN_MISSION_CAN_SERIAL_AUTO_FIGHT_ENABLE] = true,
                [CampainMissionCanSerialAutoFightType.E_CAMPAIGN_MISSION_CAN_SERIAL_AUTO_FIGHT_NEED_UNLOCK] = true
            }
            autoFightShow = tb[enableParam]
        end
    end
    return autoFightShow
end

function UIN21LineMissionController:ShowSerialRewards()
    self:ShowDialog("UISerialAutoFightInfo", OpenUISerialFightInfoState.Finished)
end

function UIN21LineMissionController:PlotEndCallback(stageId)
    local isActive = self._line_component:IsPassCamMissionID(stageId)
    if isActive then --已激活的就不再发激活消息
        -- self:SwitchState(UIStateType.UIN21LineMissionController)
        return
    end

    self:StartTask(
        function(TT)
            self._line_component:SetMissionStoryActive(TT, stageId, ActiveStoryType.ActiveStoryType_BeforeBattle)

            local res = AsyncRequestRes:New()
            local award = self._line_component:HandleCompleteStoryMission(TT, res, stageId)
            if not res:GetSucc() then
                self._campaign._campaign_module:CheckErrorCode(res.m_result, self._campaign._id, nil, nil)
            else
                if table.count(award) ~= 0 then
                    self:ShowDialog(
                        "UIGetItemController",
                        award,
                        function()
                            self:SwitchState(UIStateType.UIN21LineMissionController)
                        end
                    )
                else
                    self:SwitchState(UIStateType.UIN21LineMissionController)
                end
            end
        end,
        self
    )
end

function UIN21LineMissionController:AttachEvents()
    self:AttachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
    self:AttachEvent(GameEventType.OnUIGetItemCloseInQuest, self.OnUIGetItemCloseInQuest)
end

function UIN21LineMissionController:_CheckActivityClose(id)
    if self._campaign and self._campaign._id == id then
        self:SwitchState(UIStateType.UIMain)
    end
end

function UIN21LineMissionController:OnUIGetItemCloseInQuest(type)
    if self._isOpen then
        self:_Refresh()
    end
end

--endregion
