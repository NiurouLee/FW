--日常关
---@class SeasonMapDaily:Object
_class("SeasonMapDaily", Object)
SeasonMapDaily = SeasonMapDaily

function SeasonMapDaily:Constructor(manager, compoentID, loader)
    ---@type SeasonMapManager
    self._seasonMapManager = manager
    local cfgs = Cfg.cfg_component_season_daily { ComponentID = compoentID }
    if cfgs then
       self._dailyComponentCfg = cfgs[1]
    else
        Log.error("SeasonMapDaily cfg_component_season_daily error.")
    end
    ---@type SeasonDailyState
    self._state = SeasonDailyState.Lock
    self._isUnLock = true
    ---@type SeasonMapEventPointLoader
    self._loader = loader
    ---@type SeasonMapEventPoint[] 
    self._eventPoints = {} --日常关所有事件点
    ---@type SeasonDailyResetPhase
    self._resetPhase = SeasonDailyResetPhase.None
    self._checkTime = 0
    self._serverInfoEmpty = false
    self._autoBinder = AutoEventBinder:New(GameGlobal.EventDispatcher())
    self._autoBinder:BindEvent(GameEventType.OnSeasonDailyReset, self, self._OnSeasonDailyReset)
end

function SeasonMapDaily:Update(deltaTime)
    for id, eventPoint in pairs(self._eventPoints) do
        eventPoint:Update(deltaTime)
    end
    self:_CheckReset(deltaTime)
end

function SeasonMapDaily:Dispose()
    for _, eventPoint in pairs(self._eventPoints) do
        eventPoint:Dispose()
    end
    table.clear(self._eventPoints)
    self._resetPhase = SeasonDailyResetPhase.None
    self._autoBinder:UnBindAllEvents()
end

---添加一个zone的事件点
---@param cfgMission cfg_season_mission
function SeasonMapDaily:AddEventPoint(cfgMission)
    if not cfgMission then
        return
    end
    local missionID = cfgMission.ID
    if self._eventPoints[missionID] then
        return
    end
    local cfgEventPoint = Cfg.cfg_season_map_eventpoint[missionID]
    if cfgEventPoint then
        ---@type SeasonMapEventPoint
        local eventPoint = SeasonMapEventPoint:New(self, cfgMission, cfgEventPoint)
        if eventPoint:GetResName() then
            self._loader:LoadResource(eventPoint)
        else
            eventPoint:CreateVirtualPoint()
        end
        self._eventPoints[missionID] = eventPoint
    end
end

---@return SeasonMapEventPoint
function SeasonMapDaily:GetEventPoint(id)
    return self._eventPoints[id]
end

function SeasonMapDaily:GetEventPoints()
    return self._eventPoints
end

---@return cfg_component_season_daily
function SeasonMapDaily:ComponentCfg()
    return self._dailyComponentCfg
end

---@param state SeasonDailyState
function SeasonMapDaily:SetState(state)
    self._state = state
    self:SetUnLock(self._state == SeasonDailyState.Unlock)
end

---@return SeasonDailyState
function SeasonMapDaily:GetState()
    return self._state
end

function SeasonMapDaily:IsUnLock()
    return self._isUnLock
end

function SeasonMapDaily:SetUnLock(unlock)
    self._isUnLock = unlock
end

---服务器记录的坐标信息是否为空(每次重置之后会清空)
function SeasonMapDaily:GetServerInfoEmpty()
    return self._serverInfoEmpty
end

function SeasonMapDaily:CheckEventPointCondition(map)
    if self._isUnLock then
        for id, eventPoint in pairs(self._eventPoints) do
            local result, progress = eventPoint:CheckCondition(map)
            if result then
                eventPoint:PlayExpress(progress, SeasonExpressTriggerType.Passive)
            end
        end
    end
end

---@param eventPointType SeasonEventPointType
function SeasonMapDaily:GetEventPointsByType(eventPointType, force)
    local result = nil
    for _, eventPoint in pairs(self._eventPoints) do
        if eventPoint:EventPointType() == eventPointType and (eventPoint:DiffAble() or force) then
            if not result then
                result = {}
            end
            table.insert(result, eventPoint)
        end
    end
    return result
end

function SeasonMapDaily:EventPointPlaying()
    for _, eventPoint in pairs(self._eventPoints) do
        local isPlaying, id = eventPoint:IsPlaying()
        if isPlaying then
            return isPlaying, id
        end
    end
    return false, nil
end

function SeasonMapDaily:GetAllPRIDs()
    local ids = {}
    for _, eventPoint in pairs(self._eventPoints) do
        table.insert(ids, eventPoint:PRID())
    end
    return ids
end

--同步当前所有日常关坐标池ID
function SeasonMapDaily:TrySyncPRIDs(SuccCallBack)
    ---@type SeasonModule
    local seasonModule = GameGlobal.GetModule(SeasonModule)
    ---@type SeasonMissionComponentInfo
    local componentInfo = seasonModule:GetCurSeasonObj():GetComponentInfo(ECCampaignSeasonComponentID.SEASON_MISSION)
    local serverInfo = componentInfo.m_daily_info.m_save_info
    local change = false
    local ids = {}
    if table.count(serverInfo) <= 0 then
        self._serverInfoEmpty = true
    end
    for _, eventPoint in pairs(self._eventPoints) do
        change = change or serverInfo[eventPoint:GetID()] ~= eventPoint:PRID()
        ids[eventPoint:GetID()] = eventPoint:PRID()
    end
    if change then
        Log.info("SeasonMapDaily TrySyncRPIDs.")
        GameGlobal.UIStateManager():Lock("SeasonMapDailyTrySyncRPIDs")
        TaskManager:GetInstance():StartTask(
            function(TT)
                local res = GameGlobal.GetModule(SeasonModule):HandleSeasonPointClientData(TT, ids)
                if res:GetSucc() then
                    if SuccCallBack then
                        SuccCallBack()
                    end
                end
                GameGlobal.UIStateManager():UnLock("SeasonMapDailyTrySyncRPIDs")
            end,
            self
        )
    else
        Log.info("SeasonMapDaily no change.")
    end
end

---自动移动到最近的日常关
function SeasonMapDaily:MoveToEventPoint()
    if self._state == SeasonDailyState.Unlock then
        ---@type UISeasonModule
        local uiSeasonModule = GameGlobal.GetUIModule(SeasonModule)
        local player = uiSeasonModule:SeasonManager():SeasonPlayerManager():GetPlayer()
        local position = player:RealPosition()
        local minDistance = 0
        ---@type SeasonMapEventPoint
        local targetEventPoint = nil
        for _, eventPoint in pairs(self._eventPoints) do
            local distance = Vector3.Distance(position, eventPoint:Position())
            if not targetEventPoint then
                minDistance = distance
                targetEventPoint = eventPoint
            else
                if distance < minDistance then
                    minDistance = distance
                    targetEventPoint = eventPoint
                end
            end
        end
        if targetEventPoint then
            uiSeasonModule:SeasonManager():AutoMoveToEventPoint(targetEventPoint:GetID())
        end
    end
end

function SeasonMapDaily:_OnSeasonDailyReset()
    if self._seasonMapManager:EventPointPlaying() then
        self._resetPhase = SeasonDailyResetPhase.Waiting
    else
        self._checkTime = 0
        self:Reset()
    end
end

function SeasonMapDaily:Reset()
    self._resetPhase = SeasonDailyResetPhase.Reseting
    for _, eventPoint in pairs(self._eventPoints) do
        local cfg = eventPoint:GetEventPointCfg()
        eventPoint:RandomPR(cfg.PRP)
    end
    self:TrySyncPRIDs(function ()
        for _, eventPoint in pairs(self._eventPoints) do
            eventPoint:ResetPR()
        end
        self._resetPhase = SeasonDailyResetPhase.Success
        self._seasonMapManager:CalcDailyState()
        GameGlobal.EventDispatcher():Dispatch(GameEventType.OnSeasonDailyResetSucc)
        ToastManager.ShowToast(StringTable.Get(self._dailyComponentCfg.RefreshText))
        Log.info("SeasonMapDaily Reset success.")
    end)
end

function SeasonMapDaily:_CheckReset(deltaTime)
    self._checkTime = self._checkTime + deltaTime
    if self._checkTime >= 5000 then
        self._checkTime = 0
        if self._resetPhase == SeasonDailyResetPhase.Waiting then
            if not self._seasonMapManager:EventPointPlaying() then
                self:Reset()
            end
        end
    end
end