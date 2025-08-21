---@class UIAircraftTactic : UIController
_class("UIAircraftTactic", UIController)
UIAircraftTactic = UIAircraftTactic

---@param res UIStateSwitchReq
function UIAircraftTactic:LoadDataOnEnter(TT, res, uiParams)
    self._airModule = self:GetModule(AircraftModule)
    ---@type AircraftTacticRoom
    self._tacticRoom = self._airModule:GetRoomByRoomType(AirRoomType.TacticRoom)
    if not self._tacticRoom then
        Log.exception("获取不到战术室数据")
        res:SetResult(false)
        return
    end
    local ack = self._airModule:RequestRefreshTacticRoom(TT)
    if not ack or not ack:GetSucc() then
        self._airModule:GetErrorMsg(ack:GetResult())
        res:SetResult(false)
        return
    end
    res:SetSucc(true)
end
function UIAircraftTactic:OnShow(uiParams)
    self:InitWidget()
    self._timeModule = self:GetModule(SvrTimeModule)

    ---@type UICurrencyMenu
    self._topTips = self.firefly:SpawnObject("UICurrencyMenu")
    self._topTips:SetData({RoleAssetID.RoleAssetFirefly})
    ---@type UICurrencyItem
    local firefly = self._topTips:GetItemByTypeId(RoleAssetID.RoleAssetFirefly)
    if firefly then
        firefly:CloseAddBtn()
        self:OnFireflyChanged()
    end
    ---@type UICommonTopButton
    local topWidget = self.topBtn:SpawnObject("UICommonTopButton")
    topWidget:SetData(
        function()
            self:CloseDialog()
        end,
        function()
            self:ShowDialog("UIHelpController", self:GetName())
        end,
        function()
            --Loading回主界面
            GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftLeaveAircraft)
            GameGlobal.LoadingManager():StartLoading(LoadingHandlerName.Aircraft_Exit, "UI")
        end
    )

    ---@type UIAircraftTacticTapeTime
    self._tapeTime = self.time:SpawnObject("UIAircraftTacticTapeTime")

    self._timerHolder = UITimerHolder:New()
    self._timerHolder:StartTimerInfinite(
        "CallPerSecond",
        1000,
        function()
            self:CallPerSecond()
        end
    )

    ---@type UIAircraftTacticTapeList
    self._tapePool = self.tapes:SpawnObject("UIAircraftTacticTapeList")

    self:Refresh()

    self:AttachEvent(GameEventType.AircraftOnFireFlyChanged, self.OnFireflyChanged)
    self:AttachEvent(GameEventType.AircraftTacticRefreshTapeList, self.RefreshTapeList)
    self:AttachEvent(GameEventType.OnTopRankGetAward, self.RankRed)
    self:AttachEvent(GameEventType.OnDataBaseInfoUnLock, self.DataBaseRed)
    self:AttachEvent(GameEventType.OnDataBaseInfoGetAward, self.DataBaseRed)

    self:RankRed()
    self:DataBaseRed()
    self:TopRankEffect()
    self:TriggerGuide()

    self:Lock("WaitForAnim")
    self._timerHolder:StartTimer(
        "WaitForAnim",
        1500,
        function()
            self:UnLock("WaitForAnim")
        end
    )
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N8EnterTatic)
end

function UIAircraftTactic:TriggerGuide()
    self:StartTask(
        function(TT)
            YIELD(TT, 1667)
            GameGlobal.EventDispatcher():Dispatch(GameEventType.GuideOpenUI, GuideOpenUI.UIAircraftTactic)
        end
    )
end

function UIAircraftTactic:OnHide()
    self._timerHolder:Dispose()
end

function UIAircraftTactic:Refresh(afterReq)
    ---@type table<number,UIAircraftTacticAwardItem>
    -- local awardItems = {}
    -- self.weeklyAward:SpawnObjects("UIAircraftTacticAwardItem", 3, awardItems)
    -- local weeklyAward = Cfg.cfg_aircraft_values[34].StringValue
    -- local a = string.split(weeklyAward, "|")
    -- for i = 1, 3 do
    --     local b = string.split(a[i], ";")
    --     local c = string.split(b[2], ",")
    --     awardItems[i]:SetData(i, tonumber(b[1]), tonumber(c[1]), tonumber(c[2]))
    -- end

    self:RefreshTapeList()

    --立刻刷新一次倒计时
    self:CallPerSecond(afterReq)
end

function UIAircraftTactic:RefreshTapeList()
    ---@type table<number, Item> 卡带列表
    self._tapeList = self._tacticRoom:GetCartridgeList()
    table.sort(
        self._tapeList,
        function(a, b)
            local cfga = Cfg.cfg_item_cartridge[a:GetTemplateID()]
            local cfgb = Cfg.cfg_item_cartridge[b:GetTemplateID()]
            --排序字段小的在前
            if cfga.SortID ~= cfgb.SortID then
                return cfga.SortID < cfgb.SortID
            end
            --新获得在前
            if a:IsNewOverlay() ~= b:IsNewOverlay() then
                return a:IsNewOverlay()
            end
            --获得时间晚的在前
            return a:GetGainTime() > b:GetGainTime()
        end
    )
    self._curTapeCount = #self._tapeList
    self._packCount = self._tacticRoom:GetCartridgeGiftCount() --礼包数量
    --卡带是否已满
    self._tapeIsFull = self._curTapeCount + self._packCount >= self._tacticRoom:GetCartridgeLimit()
    self._tapePool:SetData(self._tapeList, self._packCount)

    self._tapeTime:SetData(self._curTapeCount + self._packCount)
    self.speedupBtn.interactable = not self._tapeIsFull
    self._empty:SetActive(self._curTapeCount + self._packCount == 0)
end

function UIAircraftTactic:OnFireflyChanged()
    ---@type UICurrencyItem
    local firefly = self._topTips:GetItemByTypeId(RoleAssetID.RoleAssetFirefly)
    if firefly then
        firefly:SetText(self._airModule:GetFirefly() .. "/" .. math.floor(self._airModule:GetMaxFirefly()))
    end
end

--每秒会调用的方法,处理倒计时
function UIAircraftTactic:CallPerSecond(afterReq)
    local now = math.floor(self._timeModule:GetServerTime() / 1000)
    --周刷新
    local weekTime = self._tacticRoom:GetNextResetTime() - now
    local weekRefresh = weekTime < 0
    local weekStr = HelperProxy:GetInstance():FormatTime_3(weekTime)
    if self._weeklyStr ~= weekStr then
        self._weeklyStr = weekStr
        self.weekCountdown:SetText(StringTable.Get("str_aircraft_tactic_weekly_refresh_time", weekStr))
    end

    local tapeCeiling = self._tacticRoom:GetCartridgeLimit()
    local tapeCount = self._tacticRoom:GetCartridgeGiftCount() + self._curTapeCount
    local tapeRefresh = false
    if tapeCount < tapeCeiling then
        local time = self._tacticRoom:GetCartridgeCountDown() - now
        self._tapeTime:Tick(time)
        if time <= 0 then
            tapeRefresh = true
        end
    end

    if weekRefresh or tapeRefresh then
        if afterReq then
            Log.error(
                "战术室时间错误",
                "，周刷新:",
                weekRefresh,
                "，卡带刷新:",
                tapeRefresh,
                "，当前时间:",
                now,
                "，卡带刷新时间:",
                self._tacticRoom:GetCartridgeCountDown(),
                "，卡带总数量:",
                tapeCount,
                "，卡带上限:",
                tapeCeiling,
                "，礼包数量:",
                self._tacticRoom:GetCartridgeGiftCount()
            )
            --到时间后请求,请求完后依然需要请求会引发死循环
            Log.exception("战术室时间错误,引发死循环,详情查看日志")
            self._timerHolder:StopTimer("CallPerSecond")
            return
        end
        AirLog("倒计时到0，请求更新战术室。周刷新:", weekRefresh, "，卡带刷新:", tapeRefresh)
        self:StartTask(self.reqRefresh, self, tapeRefresh)
    end
end

function UIAircraftTactic:reqRefresh(TT, isTapeChanged)
    self:Lock(self:GetName())
    local res = self._airModule:RequestRefreshTacticRoom(TT)
    self:UnLock(self:GetName())
    if not res or not res:GetSucc() then
        self._airModule:GetErrorMsg(res:GetResult())
        return
    end
    if isTapeChanged then
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftTacticOnTapeChanged)
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftRefreshRoomUI, self._tacticRoom:SpaceId())
    end
    self:Refresh(true)
end

function UIAircraftTactic:InitWidget()
    --generated--
    ---@type UICustomWidgetPool
    self.firefly = self:GetUIComponent("UISelectObjectPath", "firefly")
    ---@type UICustomWidgetPool
    self.topBtn = self:GetUIComponent("UISelectObjectPath", "TopBtn")
    ---@type UILocalizationText
    self.weekCountdown = self:GetUIComponent("UILocalizationText", "weekCountdown")

    ---@type UnityEngine.UI.Button
    self.speedupBtn = self:GetUIComponent("Button", "SpeedupBtn")
    ---@type UILocalizationText
    self.topRankLevel = self:GetUIComponent("UILocalizationText", "TopRankLevel")
    ---@type UICustomWidgetPool
    self.dbRed = self:GetUIComponent("UISelectObjectPath", "dbRed")
    self.dbRedGo = self:GetGameObject("dbRed")

    ---@type UICustomWidgetPool
    self.rankRed = self:GetUIComponent("UISelectObjectPath", "rankRed")
    self.rankRedGo = self:GetGameObject("rankRed")

    ---@type UICustomWidgetPool
    self.time = self:GetUIComponent("UISelectObjectPath", "time")
    ---@type UICustomWidgetPool
    self.tapes = self:GetUIComponent("UISelectObjectPath", "tapes")
    --generated end--
    self._empty = self:GetGameObject("empty")
    self._rankEff = self:GetUIComponent("Animation", "UIAircraftTactic")
end
function UIAircraftTactic:TopRankEffect()
    local expID = Cfg.cfg_aircraft_values[36].IntValue
    local count = 0
    if expID then
        count = GameGlobal.GetModule(RoleModule):GetAssetCount(expID)
    end
    local currentLv = GameGlobal.GetModule(AircraftModule):GetLvByExp(count)

    local open_id = GameGlobal.GameLogic():GetOpenId()
    local key = "rank_save_lv_enter_" .. open_id
    --上次的等级
    local saveLv = LocalDB.GetInt(key, 0)
    LocalDB.SetInt(key, currentLv)
    self.topRankLevel:SetText(saveLv)
    if saveLv < currentLv then
        AirLog("播放巅峰升级动效:", saveLv, "->", currentLv)
        --播动效
        self._rankEff:Play("uieff_AircraftTactic_LevelUp_Main")
        self:Lock("UIAircraftTactic:TopRankEffect")
        GameGlobal.Timer():AddEvent(
            792,
            function()
                self:UnLock("UIAircraftTactic:TopRankEffect")
                self.topRankLevel:SetText(self._airModule:UI_TopRankCurrentLv())
            end
        )
    end
end
function UIAircraftTactic:TopRankBtnOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N8DefaultClick)
    self:ShowDialog("UITopRankController")
end
function UIAircraftTactic:DatabaseBtnOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N8DefaultClick)
    self:ShowDialog("UIDataBaseMapController")
end
function UIAircraftTactic:SpeedupBtnOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N8DefaultClick)
    if self._tapeIsFull then
        return
    end
    if self._tacticRoom:GetWeeklyFreeMakeCount() > 0 then
        self:ShowDialog("UITacticTapeProduceFree")
    else
        self:ShowDialog("UITacticTapeProduceSpeedup")
    end
end

function UIAircraftTactic:RankRed()
    local red = self._airModule:UI_TopRankRed()
    self.rankRedGo:SetActive(red)
end
function UIAircraftTactic:DataBaseRed()
    local red = self._airModule:UI_DB_all_node_red()
    self.dbRedGo:SetActive(red)
end
