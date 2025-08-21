---@class UIN18LineMissionController:UIController
_class("UIN18LineMissionController", UIController)
UIN18LineMissionController = UIN18LineMissionController

--region Helper
function UIN18LineMissionController:_SpawnObject(widgetName, className)
    ---@type UICustomWidgetPool
    local pool = self:GetUIComponent("UISelectObjectPath", widgetName)
    local obj = pool:SpawnObject(className)
    return obj
end
-- 设置剩余时间
function UIN18LineMissionController:_SetRemainingTime(widgetName, descId, endTime,endCallBack)
    ---@type UIActivityCommonRemainingTime
    local obj = self:_SpawnObject(widgetName, "UIActivityCommonRemainingTime")
 
    obj:SetCustomTimeStr_Common_1()
    obj:SetAdvanceText("str_n18_activity_lasttime")
    obj:SetData(endTime, nil, endCallBack)

end

function UIN18LineMissionController:_SetIcon(widgetName, icon)
    widgetName = widgetName or "icon"
    ---@type UnityEngine.UI.RawImageLoader
    local obj = self:GetUIComponent("RawImageLoader", widgetName)
    obj:LoadImage(icon)
end

function UIN18LineMissionController:_SetText(widgetName, str)
    widgetName = widgetName or "text"
    ---@type UILocalizationText
    local obj = self:GetUIComponent("UILocalizationText", widgetName)
    obj:SetText(str)
end
--endregion

function UIN18LineMissionController:Constructor()

end

function UIN18LineMissionController:InitWidget()
    local backBtns = self:GetUIComponent("UISelectObjectPath", "_backBtns")
    ---@type UICommonTopButton
    self._backBtns = backBtns:SpawnObject("UICommonTopButton")
    self._backBtns:SetData(
        function()
            ---@type CampaignModule
            local campaignModule = GameGlobal.GetModule(CampaignModule)
            campaignModule:CampaignSwitchState(
                true,
                UIStateType.UIN18Main,
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

    ---@type UICustomWidgetPool
    self._linesPool = self:GetUIComponent("UISelectObjectPath", "Lines")
    self._nodesPool = self:GetUIComponent("UISelectObjectPath", "Nodes")

    ---@type H3DUIBlurHelper
    self._shot = self:GetUIComponent("H3DUIBlurHelper", "screenShot")

    --安全区宽度,没有找到框架的接口,直接从RectTransform上取
    self._safeAreaSize = self:GetUIComponent("RectTransform", "SafeArea").rect.size
    self._shot.width = self._safeAreaSize.x
    self._shot.height = self._safeAreaSize.y
end

--- @param TT 协程函数标识
--- @param res AsyncRequestRes 异步请求结果
function UIN18LineMissionController:LoadDataOnEnter(TT, res, uiParams)
    self._campaignType = ECampaignType.CAMPAIGN_TYPE_N18
    self._componentId_LineMission = ECampaignN18ComponentID.ECAMPAIGN_N18_LEVEL_COMMON
    self._componentId_LineMissionFixteam = ECampaignN18ComponentID.ECAMPAIGN_N18_LEVEL_FIXTEAM

    self._missionModule = self:GetModule(MissionModule)
    if not self.data then
        self.data = N18Data:New()
    end
        ---@type CampaignModule
    self._campModule = self.data:GetCampaignModule()
    ---@type UIActivityCampaign
    self._campaign = self.data:GetActivityCampaign()
    self._campaign:LoadCampaignInfo(
        TT,
        res,
        self._campaignType,
        self._componentId_LineMission,
        self._componentId_LineMissionFixteam
    )

    --强制请求
    --请求完了再获取就一定是最新的了
    self._campaign:ReLoadCampaignInfo_Force(TT, res)

    if res and res:GetSucc() then
        ---@type LineMissionComponent
        self._line_component = self._campaign:GetComponent(self._componentId_LineMission)
        --- @type LineMissionComponentInfo
        self._line_info = self._line_component:GetComponentInfo()

        if not self._campaign:CheckComponentOpen(self._componentId_LineMission) then
            res.m_result = self._campaign:CheckComponentOpenClientError(self._componentId_LineMission)
            local campaignModule = GameGlobal.GetModule(CampaignModule)
            campaignModule:ShowErrorToast(res.m_result, true)
            return
        end
    end

    -- 错误处理
    if res and not res:GetSucc() then
        self._campModule:CheckErrorCode(res.m_result, self._campaign._id, nil, nil)
    end
end

function UIN18LineMissionController:OnShow(uiParams)
    self._isOpen = true
    self._timerHolder = UITimerHolder:New()

    self.NodeCfg = {
        [DiscoveryStageType.FightNormal] = {
            [1] = {
                normal = "n18_xxg_btn01",
                press = "n18_xxg_btn01",
                lock = "",
                textColor = Color(240 / 255, 240 / 255, 240 / 255), -- 不使用
                normalStar = "",
                passStar = "n18_xxg_coffee01"
            }, 
            [2] = {
                normal = "n18_xxg_btn03",
                press = "n18_xxg_btn03",
                lock = "",
                textColor = Color(240 / 255, 240 / 255, 240 / 255), -- 不使用
                normalStar = "",
                passStar = "n18_xxg_coffee01"
            } 
        },
        [DiscoveryStageType.FightBoss] = {
            [1] = {
                normal = "n18_xxg_btn04",
                press = "n18_xxg_btn04",
                lock = "",
                textColor = Color(240 / 255, 240 / 255, 240 / 255), -- 不使用
                normalStar = "",
                passStar = "n18_xxg_coffee01"
            }, 
            [2] = {
                normal = "n18_xxg_btn04",
                press = "n18_xxg_btn04",
                lock = "",
                textColor = Color(240 / 255, 240 / 255, 240 / 255), -- 不使用
                normalStar = "",
                passStar = "n18_xxg_coffee01"
            } 
        },
        [DiscoveryStageType.Plot] = {
            [1] = {
                normal = "n18_xxg_btn02",
                press = "n18_xxg_btn02",
                lock = "",
                textColor = Color(240 / 255, 240 / 255, 240 / 255), -- 不使用
                normalStar = "",
                passStar = "n18_xxg_coffee01"
            }, 
            [2] = {
                normal = "n18_xxg_btn02",
                press = "n18_xxg_btn02",
                lock = "",
                textColor = Color(240 / 255, 240 / 255, 240 / 255), -- 不使用
                normalStar = "",
                passStar = "n18_xxg_coffee01"
            } 
        },
        [DiscoveryStageType.Node] = {
            [1] = {
                normal = "n18_xxg_btn01",
                press = "n18_xxg_btn01",
                lock = "",
                textColor = Color(240 / 255, 240 / 255, 240 / 255), 
                textShadow = Color(86 / 255, 66 / 255, 23 / 255, 128/255), -- 不使用
                normalStar = "",
                passStar = "n18_xxg_coffee01"
            }, 
            [2] = {
                normal = "n18_xxg_btn01",
                press = "n18_xxg_btn01",
                lock = "",
                textColor = Color(240 / 255, 240 / 255, 240 / 255), 
                textShadow = Color(86 / 255, 66 / 255, 23 / 255, 128/255), -- 不使用
                normalStar = "",
                passStar = "n18_xxg_coffee01"
            } 
        },
    }

    self:AttachEvents()
    self:InitWidget()

    self:_Refresh()

    -- 进场锁定
    local lockName = "UIActivityN18_LineMissionController_Enter"
    self:Lock(lockName)
    self._timerHolder:StartTimer(
        lockName,
        500,
        function()
            self:UnLock(lockName)
        end
    )
end

function UIN18LineMissionController:OnHide()
    self.SLeval = nil
    self.NodeCfg = nil
    self._isOpen = false
    self._timerHolder:Dispose()
    if self._shot then
        self._shot:CleanRenderTexture()
        self._shot = nil
    end
    UIN18LineMissionController.super:Dispose()
    self._scroller:Dispose()
    self:DetachEvents()
end

function UIN18LineMissionController:_Refresh()
    self:FlushNodes()

    self:_SetTimeInfo()
    self:_SetTryoutBtn()
    self:_SetExchangeBtn()
end

function UIN18LineMissionController:_SetTimeInfo()
    local endTime = self._line_component:GetComponentInfo().m_close_time
    self:_SetRemainingTime("_remainingTimePool", nil, endTime)
end

function UIN18LineMissionController:_SetTryoutBtn()
    local componentId = self._componentId_LineMissionFixteam

    local obj = self:_SpawnObject("_tryoutBtn", "UIActivityCommonComponentEnterLock")

    obj:SetRed(
        "red",
        function()
            return self._campaign:CheckComponentOpen(componentId) and self._campaign:CheckComponentRed(componentId)
        end
    )

    local component = self._campaign:GetComponent(componentId)
    obj:SetData(
        self._campaign,
        componentId,
        function()

            self:ShowDialog(
                "UIActivityPetTryController",
                self._campaignType,
                componentId,
                function(mid)
                    return component:IsPassCamMissionID(mid)
                end,
                function(missionid)
                    ---@type TeamsContext
                    local ctx = self._missionModule:TeamCtx()
                    local missionComponent = self._campaign:GetComponent(componentId)
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
    )
end

function UIN18LineMissionController:_SetExchangeBtn()
    local componentId = ECampaignN18ComponentID.ECAMPAIGN_N18_SHOP
    local economics = self:GetUIComponent("UISelectObjectPath", "_exchangeBtn")
    ---@type UIN18CampaignEconomic
    local UIN18CampaignEconomic = economics:SpawnObject("UIN18CampaignEconomic")
    UIN18CampaignEconomic:Flush("")

end

function UIN18LineMissionController:FlushNodes()
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

    self._nodesPool:SpawnObjects("UIN18LineMissionMapNode", levelCount)
    local nodes = self._nodesPool:GetAllSpawnList()
    self._linesPool:SpawnObjects("UIN18LineMissionMapLine", lineCount)
    ---@type table<number,UIN18LineMissionMapLine>
    local lines = self._linesPool:GetAllSpawnList()

    local nodeIdx, lineIdx = 1, 1
    for missionID, cfg in pairs(showMission) do
        ---@type UIN18LineMissionMapNode
        local uiNode = nodes[nodeIdx]
        uiNode:SetData(
            cfg,
            self._line_info.m_pass_mission_info[missionID],
            function(stageId, isStory, worldPos)
                self:_onNodeClick(stageId, isStory, worldPos)
            end,
            1,
            self.NodeCfg,
            true
        )
        nodeIdx = nodeIdx + 1

        if cfg.WayPointType ~= 4 and cfg.NeedMissionId ~= 0 then
            local n1 = showMission[cfg.NeedMissionId]
            local n2 = cfg
            ---@type UIN18LineMissionMapLine
            local line = lines[lineIdx]
            line:Flush(Vector2(n2.MapPosX, n2.MapPosY), Vector2(n1.MapPosX, n1.MapPosY))
            lineIdx = lineIdx + 1
        end
    end

    local right = -1111111111111111
    for _, cfg in pairs(showMission) do
        right = math.max(right, cfg.MapPosX)
    end
    --滚动列表总宽度=最右边路点+右边距
    local width = math.abs(right + extra_width)
    width = math.max(self._safeAreaSize.x, width)
    self._contentRect.sizeDelta = Vector2(width, self._contentRect.sizeDelta.y)
    self._contentRect.anchoredPosition = Vector2(self._safeAreaSize.x - width, 0)

    --背景滚动
    local posx = {}
    for _, cfg in pairs(missionCfgs) do
        posx[#posx + 1] = cfg.MapPosX
    end
    table.sort(posx) --所有路点横坐标从左到右排序
    local sp1, sp2 = 12, 12
    local bgLoader1 = self:GetUIComponent("RawImageLoader", "bg1")
    local bgLoader2 = self:GetUIComponent("RawImageLoader", "bg2")
    --28个路点分成3段,有两个分割点,可能会经常改动
    ---@type UILevelScroller
    self._scroller =
        UILevelScroller:New(
        self._contentRect,
        bgLoader1,
        bgLoader2,
        {
            "n18_xxg_bg01",
            "n18_xxg_bg01",
            "n18_xxg_bg01"
        },
        {
            posx[sp1],
            posx[sp1 + 1],
            posx[sp2],
            posx[sp2 + 1]
        }
    )
    self._scrollRect.onValueChanged:AddListener(
        function()
            self._scroller:OnChange()
        end
    )
    self._allMissionCfgs = missionCfgs
end

function UIN18LineMissionController:_onNodeClick(stageId, isStory, worldPos)
    if isStory then
        --剧情关
        local missionCfg = Cfg.cfg_campaign_mission[stageId]
        local titleId = StringTable.Get(missionCfg.Title)
        local titleName = StringTable.Get(missionCfg.Name)
        local storyId = self._missionModule:GetStoryByStageIdStoryType(stageId, StoryTriggerType.Node)
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
        return
    end

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
        local _moveTime = 0.5
        self._tweener = self._contentRect:DOAnchorPosX(targetPos, _moveTime)
        -- 移动关卡锁定
        local moveLockName = "UILineMissionControllerMoveToStage"
        self:Lock(moveLockName)
        self._timerHolder:StartTimer(
            moveLockName,
            _moveTime * 1000,
            function()
                self:UnLock(moveLockName)
                self:_EnterStage(stageId, worldPos) -- 移动后，进入关卡
            end
        )
    else
        self:_EnterStage(stageId, worldPos) -- 直接进入关卡
    end
end

function UIN18LineMissionController:_EnterStage(stageId, worldPos)
    local missionCfg = Cfg.cfg_campaign_mission[stageId]
    local autoFightShow = self:_CheckSerialAutoFightShow(missionCfg.Type, stageId)
    self:ShowDialog(
        "UIActivityLevelStageNew",
        stageId,
        self._line_info.m_pass_mission_info[stageId],
        self._line_component,        
        autoFightShow,
        nil --行动点组件
    )
end

function UIN18LineMissionController:PlotEndCallback(stageId)
    local isActive = self._line_component:IsPassCamMissionID(stageId)
    if isActive then --已激活的就不再发激活消息
        -- self:SwitchState(UIStateType.UIN18LineMissionController)
        return
    end

    self:StartTask(
        function(TT)
            self._line_component:SetMissionStoryActive(TT, stageId, ActiveStoryType.ActiveStoryType_BeforeBattle)

            local res = AsyncRequestRes:New()
            local award = self._line_component:HandleCompleteStoryMission(TT, res, stageId)
            if not res:GetSucc() then
                self._campModule:CheckErrorCode(res.m_result, self._campaign._id, nil, nil)
            else
                if table.count(award) ~= 0 then
                    self:ShowDialog(
                        "UIGetItemController",
                        award,
                        function()
                            self:SwitchState(UIStateType.UIN18LineMissionController)
                        end
                    )
                else
                    self:SwitchState(UIStateType.UIN18LineMissionController)
                end
            end
        end,
        self
    )
end

function UIN18LineMissionController:_CheckSerialAutoFightShow(stageType, stageId)
    local autoFightShow = false
    if stageType == DiscoveryStageType.Plot then
        autoFightShow = false
    else
        local missionCfg = Cfg.cfg_campaign_mission[stageId]
        if missionCfg then
            local enableParam = missionCfg.EnableSerialAutoFight
            if enableParam == CampainMissionCanSerialAutoFightType.E_CAMPAIGN_MISSION_CAN_SERIAL_AUTO_FIGHT_DISABLE then
                autoFightShow = false
            elseif
                enableParam == CampainMissionCanSerialAutoFightType.E_CAMPAIGN_MISSION_CAN_SERIAL_AUTO_FIGHT_ENABLE or
                    enableParam ==
                        CampainMissionCanSerialAutoFightType.E_CAMPAIGN_MISSION_CAN_SERIAL_AUTO_FIGHT_NEED_UNLOCK
             then
                autoFightShow = true
            end
        end
    end
    return autoFightShow
end

function UIN18LineMissionController:ShowSerialRewards()
    self:ShowDialog("UISerialAutoFightInfo", OpenUISerialFightInfoState.Finished)
end

--region AttachEvent
function UIN18LineMissionController:AttachEvents()
    self:AttachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
    self:AttachEvent(GameEventType.OnUIGetItemCloseInQuest, self.OnUIGetItemCloseInQuest)
end

function UIN18LineMissionController:DetachEvents()
    self:DetachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
    self:DetachEvent(GameEventType.OnUIGetItemCloseInQuest, self.OnUIGetItemCloseInQuest)
end

function UIN18LineMissionController:_CheckActivityClose(id)
    if self._campaign and self._campaign._id == id then
        self:SwitchState(UIStateType.UIMain)
    end
end
-- 刷新回调
function UIN18LineMissionController:OnUIGetItemCloseInQuest(type)
    if self._isOpen then
        local res = AsyncRequestRes:New()
        self:StartTask(
            function(TT)
                self._campaign:ReLoadCampaignInfo_Force(TT, res)
            end,
            self
        )
    end
end

function UIN18LineMissionController:btnShopOnClick(go)
    local cType, cId = self.data:GetCampaignTypeId()
    ClientCampaignShop.OpenCampaignShop(
        cType,
        cId,
        function()
            local campaignModule = GameGlobal.GetModule(CampaignModule)
            campaignModule:CampaignSwitchState(
                true,
                UIStateType.UIN18LineMissionController,
                UIStateType.UIMain,
                nil,
                cId,
                ECampaignN18ComponentID.ECAMPAIGN_N18_LEVEL_COMMON
            )
        end
    )
end

function UIN18LineMissionController:SetFontMat(lable,resname) 
    local res = ResourceManager:GetInstance():SyncLoadAsset(resname, LoadType.Mat)
    if not res  then return end 
    local obj  = res.Obj
    local mat = lable.fontMaterial
    lable.fontMaterial = obj
    lable.fontMaterial:SetTexture("_MainTex", mat:GetTexture("_MainTex"))
end

--endregion
