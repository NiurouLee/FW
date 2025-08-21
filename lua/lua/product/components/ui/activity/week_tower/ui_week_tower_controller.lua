---@class UIWeekTowerController : UIController
_class("UIWeekTowerController", UIController)
UIWeekTowerController = UIWeekTowerController

--------------------------难度
---@class WeekTowerDiffEnum
local WeekTowerDiffEnum = {
    Easy = 1,--简单
    Normal = 2,--正常
    Diff = 3 --困难
}
_enum("WeekTowerDiffEnum", WeekTowerDiffEnum)

function UIWeekTowerController:Constructor()
    --面板的移动动画位置
    self._infoTweenPos = {[1]=0,[2]=900}
    self._moveContentTime = 0.2

    --anim
    self._infoAnim = {["open"] = "uieff_WeekTower_Info_In",["close"] = "uieff_WeekTower_Info_Out"}

    --面板是否开着(波动话)
    self._infoIsOpen = false
    ---@type WeekTowerMissionData
    self._currentMissionData = nil
    self._missionid2activityrewards = {}

    ---@type SvrTimeModule
    self._svrTimeModule = GameGlobal.GetModule(SvrTimeModule)
    ---@type CampaignModule
    self._module = GameGlobal.GetModule(CampaignModule)
end

--创建关卡数据
function UIWeekTowerController:CreateMisisonList()
    self._component = self._localProcess:GetComponent(ECampaignWeekTowerComponentID.ECAMPAIGN_WEEK_TOWER_MISSION)
    local componentid = self._component:GetComponentCfgId()
    local missionInfo = self._localProcess:GetComponentInfo(ECampaignWeekTowerComponentID.ECAMPAIGN_WEEK_TOWER_MISSION)
    ---@type table<number,cam_mission_info>
    local passMissionMap = missionInfo.m_pass_mission_info
    local currentMissionID = missionInfo.m_cur_mission
    
    --这一期的关卡列表,读配置
    ---@type number[]
    local missionCfgList = Cfg.cfg_component_line_mission{ComponentID=componentid}
    if not missionCfgList or table.count(missionCfgList)<=0 then
        Log.error("###[UIWeekTowerController] missionIdList is nil or count <= 0 !")
    end
    table.sort(missionCfgList,function(a,b)
        return a.SortId < b.SortId
    end)

    ---@type WeekTowerMissionData[]
    local easyMissionList = {}
    ---@type WeekTowerMissionData[]
    local normalMissionList = {}
    ---@type WeekTowerMissionData[]
    local diffMissionList = {}

    local curIdx = 1
    for i = 1, #missionCfgList do
        local missionCfg = missionCfgList[i]
        local id = missionCfg.CampaignMissionId
        local pass = false
        if passMissionMap[id] ~= nil then
            pass = true
        end
        local missionData = WeekTowerMissionData:New(missionCfg,pass)

        if missionData:GetDiff() == WeekTowerDiffEnum.Easy then
            table.insert(easyMissionList,missionData)
        elseif missionData:GetDiff() == WeekTowerDiffEnum.Normal then
            table.insert(normalMissionList,missionData)
        elseif missionData:GetDiff() == WeekTowerDiffEnum.Diff then
            table.insert(diffMissionList,missionData)
        end        
    end

    self._currentMissionData = nil
    local currentDiff = nil
    local index = nil
    if currentDiff == nil then
        for i = 1, #easyMissionList do
            local mission = easyMissionList[i]
            if mission:GetID() == currentMissionID then
                if i == #easyMissionList then
                    currentDiff = WeekTowerDiffEnum.Normal
                    self._currentMissionData = normalMissionList[1]
                    index = 1
                else
                    currentDiff = WeekTowerDiffEnum.Easy
                    self._currentMissionData = easyMissionList[i+1]
                    index = i + 1
                end
                break
            end
        end
    end
    if currentDiff == nil then
        for i = 1, #normalMissionList do
            local mission = normalMissionList[i]
            if mission:GetID() == currentMissionID then
                if i == #normalMissionList then
                    currentDiff = WeekTowerDiffEnum.Diff
                    self._currentMissionData = diffMissionList[1]
                    index = 1
                else
                    currentDiff = WeekTowerDiffEnum.Normal
                    self._currentMissionData = normalMissionList[i+1]
                    index = i + 1
                end
                break
            end
        end
    end
    if currentDiff == nil then
        for i = 1, #diffMissionList do
            local mission = diffMissionList[i]
            if mission:GetID() == currentMissionID then
                currentDiff = WeekTowerDiffEnum.Diff
                if i == #diffMissionList then
                    self._currentMissionData = diffMissionList[i]
                    index = i
                else
                    self._currentMissionData = diffMissionList[i+1]
                    index = i + 1
                end
                break
            end
        end
    end
    --如果等于空，表示刚进来，第一个就是当前可打的
    if currentDiff == nil then
        Log.debug("###[UIWeekTowerController] self._currentDiff == nil !")
        currentDiff = WeekTowerDiffEnum.Easy
        index = 1
        self._currentMissionData = easyMissionList[1]
    end
    if self._currentMissionData:GetPassTime() == WeekTowerMissionBattleStatus.Lock then
        self._currentMissionData:SetPassState(WeekTowerMissionBattleStatus.Battle)
    end

    ---@type WeekTowerDiffData[]
    self._diffList = {}
    local easyLock = true
    if currentDiff >= WeekTowerDiffEnum.Easy then
        easyLock = false
    end
    local easy = WeekTowerDiffData:New(easyLock,easyMissionList,WeekTowerDiffEnum.Easy)
    table.insert(self._diffList,easy)

    local normalLock = true
    if currentDiff >= WeekTowerDiffEnum.Normal then
        normalLock = false
    end
    local normal = WeekTowerDiffData:New(normalLock,normalMissionList,WeekTowerDiffEnum.Normal)
    table.insert(self._diffList,normal)

    local diffLock = true
    if currentDiff >= WeekTowerDiffEnum.Diff then
        diffLock = false
    end
    local diff = WeekTowerDiffData:New(diffLock,diffMissionList,WeekTowerDiffEnum.Diff)
    table.insert(self._diffList,diff)

    self._selectDiffIdx = currentDiff
    self._selectIndex = index
end

function UIWeekTowerController:LoadDataOnEnter(TT,res,uiParams)
    --当前的哪一期的ID
    self._weekTowerID = self._module:GetCampaignInfo(TT,res,ECampaignType.CAMPAIGN_TYPE_WEEK_TOWER)

    -- 获取活动 以及本窗口需要的组件
    ---@type UIActivityCampaign
    self._campaign = UIActivityCampaign:New()
    self._campaign:LoadCampaignInfo(TT,res,ECampaignType.CAMPAIGN_TYPE_WEEK_TOWER)

    local isOpen = self._campaign:CheckCampaignOpen()
    if not isOpen then
        res:SetSucc(false)
        ToastManager.ShowToast(StringTable.Get("str_week_tower_reset_activity_close_tips"))
        return 
    end
    
    ---@type campaign_sample
    self._campaign_sample = self._campaign:GetSample()
    --活动结束时间
     self._activeEndTime = self._campaign_sample.end_time
    ---@type CCampaignWeekTower
    self._localProcess = self._campaign:GetLocalProcess()
    
    self:CreateMisisonList()

    res:SetSucc(true)

    self._campaign:ClearCampaignNew(TT)
end

function UIWeekTowerController:OnShow(uiParams)
    self:GetComponents()
    self:OnValue()
end

function UIWeekTowerController:GetComponents()
    local itemTips = self:GetUIComponent("UISelectObjectPath", "MatTip")
    self._selectInfo = itemTips:SpawnObject("UISelectInfo")

    ---@type UISelectObjectPath
    local ltBtns = self:GetUIComponent("UISelectObjectPath", "TopButtons")
    ---@type UICommonTopButton
    self._backBtn = ltBtns:SpawnObject("UICommonTopButton")
    self._backBtn:SetData(
        function()
            self:CloseController()
        end
    )

    self._name = self:GetUIComponent("UILocalizationText", "name")
    self._titleName = self:GetUIComponent("UILocalizationText", "titleName")

    self._timer = self:GetUIComponent("UILocalizationText", "timer")
    self._word = self:GetUIComponent("UILocalizationText", "word")
    self._wordParent = self:GetGameObject("wordParent")
    self._enemyMsg = self:GetUIComponent("UISelectObjectPath", "enemyMsg")
    self._recommendLV = self:GetUIComponent("UILocalizationText", "recommendLV")
    self._recommendLV2 = self:GetUIComponent("UILocalizationText", "recommendLV2")
    

    self._awardContent = self:GetUIComponent("UISelectObjectPath", "AwardContent")

    self._awardGot = self:GetGameObject("awardGot")

    ---@type UnityEngine.UI.GridLayoutGroup
    local grid = self:GetUIComponent("GridLayoutGroup","stagePools")
    self._itemWidth = grid.cellSize.x
    self._stagePools = self:GetUIComponent("UISelectObjectPath","stagePools")
    ---@type UnityEngine.RectTransform
    self._contentRect = self:GetUIComponent("RectTransform","stagePools")
    ---@type UnityEngine.UI.ScrollRect
    self._scrollRect = self:GetUIComponent("ScrollRect","stagePool")

    self._infoBg = self:GetUIComponent("RawImageLoader","infoBg")
    self._battleBtn = self:GetUIComponent("RawImageLoader","BattleButton")
    self._btnPress = self:GetGameObject("btnPress")
    self._infoRect = self:GetUIComponent("RectTransform","rightFull")
    self._infoRectAnim = self:GetUIComponent("Animation","rightFull")
    self._infoRectCanvasGroup = self:GetUIComponent("CanvasGroup","rightFull")

    self._btnPool1 = self:GetUIComponent("UISelectObjectPath","btnPool1")
    self._btnPool2 = self:GetUIComponent("UISelectObjectPath","btnPool2")
    self._btnPool3 = self:GetUIComponent("UISelectObjectPath","btnPool3")

    self._bgLoader1 = self:GetUIComponent("RawImageLoader", "bg1")
    self._bgLoader2 = self:GetUIComponent("RawImageLoader", "bg2")
    self._bgLoader3 = self:GetUIComponent("RawImageLoader", "bg3")

    self._titleGo = self:GetUIComponent("RectTransform","title")
    self._enemyGo = self:GetUIComponent("RectTransform","enemyInfo")
    self._awardGo = self:GetUIComponent("RectTransform","awardParent")
    self._infoBg2 = self:GetUIComponent("RawImageLoader","infoBg2")
    self._infoBg2Go = self:GetGameObject("infoBg2")

    self._bgGo = self:GetGameObject("bg")
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self._bgGo),
        UIEvent.BeginDrag,
        function(eventData)
            self._scrollRect:OnBeginDrag(eventData)
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self._bgGo),
        UIEvent.EndDrag,
        function(eventData)
            self._scrollRect:OnEndDrag(eventData)
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self._bgGo),
        UIEvent.Drag,
        function(eventData)
            self._scrollRect:OnDrag(eventData)
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self._bgGo),
        UIEvent.Click,
        function(go)
            self:bgOnClick(go)
        end
    )
    

    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self._battleBtn.gameObject),
        UIEvent.Press,
        function(go)
            self._btnPress:SetActive(true)
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self._battleBtn.gameObject),
        UIEvent.Release,
        function(go)
            self._btnPress:SetActive(false)
        end
    )

    self._maskClick = self:GetUIComponent("Image","maskClick")
    self._maskClick.alphaHitTestMinimumThreshold = 0.1
end

function UIWeekTowerController:CloseController()
    self:SwitchState(UIStateType.UIMain)
end

function UIWeekTowerController:OnValue()
    self:InitBtns()
    self:InitTimer()
    
    self:InitStagePool()
    self:InitBgScroll()
    self:ClickSucc()
    self:MoveInfoRect(true)
    self:MoveContentPosX()
end
function UIWeekTowerController:MoveContentPosX()
    self._scrollRect.enabled = false
    --:StopMovement()
    local movePosX = (self._selectIndex-1)*-1*self._itemWidth
    if self._tweener then
        self._tweener:Kill()
        self._tweener = nil
    end
    self._tweener = self._contentRect:DOAnchorPosX(movePosX,self._moveContentTime):OnComplete(function()
        self._contentRect.anchoredPosition = Vector2(movePosX,self._contentRect.anchoredPosition.y)
        self._tweener = nil
        self._scrollRect.enabled = true
    end)
end
function UIWeekTowerController:InitBtns()
    local btn1 = self._btnPool1:SpawnObject("UIWeekTowerDiffBtn")
    btn1:SetData(1,self._diffList[1],self._selectDiffIdx,function(idx)
        self:BtnItemClick(idx)
    end)
    local btn2 = self._btnPool2:SpawnObject("UIWeekTowerDiffBtn")
    btn2:SetData(2,self._diffList[2],self._selectDiffIdx,function(idx)
        self:BtnItemClick(idx)
    end)
    local btn3 = self._btnPool3:SpawnObject("UIWeekTowerDiffBtn")
    btn3:SetData(3,self._diffList[3],self._selectDiffIdx,function(idx)
        self:BtnItemClick(idx)
    end)
end
--点击难度切花关卡列表，会选中当前难度可打的那一关，如果当前难度通关了就选中最后一关
--切换难度后，会默认选中关卡，并且打开关卡信息
function UIWeekTowerController:BtnItemClick(idx)
    if idx == self._selectDiffIdx then
        return
    end
    local diffData = self._diffList[idx]  
    if diffData:Lock() then
        Log.debug("###[UIWeekTowerController] click diff is lock ! idx --> ",idx)
    else
        self._selectDiffIdx = idx
        
        local _idx = 0
        local missionList = self._diffList[self._selectDiffIdx]:MissionList()
        for i = 1, #missionList do
            ---@type WeekTowerMissionData
            local data = missionList[i]
            _idx = _idx + 1
            if data:GetPassTime() == WeekTowerMissionBattleStatus.Battle then
                break
            end
        end
        if _idx < 1 then
            _idx = 1
        end
        self._selectIndex = _idx

        self._currentMissionData = missionList[self._selectIndex]
        self:InitStagePool()
        self:InitBgScroll()
        self:ClickSucc()
        self:MoveInfoRect(true)
        self:MoveContentPosX()
        GameGlobal.EventDispatcher():Dispatch(GameEventType.OnUIWeekTowerDiffItemClick,self._selectDiffIdx)
    end  
end
function UIWeekTowerController:OnHide()
    if self._timerEvent then
        GameGlobal.Timer():CancelEvent(self._timerEvent)
        self._timerEvent = nil
    end
    if self._scroller then
        self._scroller:Dispose()
        self._scroller = nil
    end
    if self._tweener then
        self._tweener:Kill()
        self._tweener = nil
    end
end
--endregion

--背景图的切换
function UIWeekTowerController:InitBgScroll()
    --三张背景图的获取
    local cfg_week_tower_view = Cfg.cfg_week_tower_view[self._weekTowerID]
    if not cfg_week_tower_view then
        Log.error("###[UIWeekTowerController] cfg is nil ! id --> ",self._weekTowerID)
    end

    local title = cfg_week_tower_view.Title[self._selectDiffIdx]
    self._titleName:SetText(StringTable.Get(title))

    local bgs = cfg_week_tower_view.BGS[self._selectDiffIdx]
    if not bgs then
        Log.error("###[UIWeekTowerController] cfg bgs is nil ! id --> ",self._weekTowerID)
    end
    if #bgs > 1 then
        self._bgLoader1.gameObject:SetActive(true)
        self._bgLoader2.gameObject:SetActive(true)
        self._bgLoader3.gameObject:SetActive(false)

        --背景滚动
        local posx = {}
        
        local scrollIdx1 = cfg_week_tower_view.ScrollIndex[self._selectDiffIdx][1]
        local scrollIdx2 = cfg_week_tower_view.ScrollIndex[self._selectDiffIdx][2]
        ---@type UnityEngine.UI.GridLayoutGroup
        local gridLayout = self:GetUIComponent("GridLayoutGroup","stagePools")
        local sizeX = gridLayout.cellSize.x
        local pos1 = sizeX*(scrollIdx1-1)+sizeX*0.5
        local pos2 = sizeX*(scrollIdx1+1-1)+sizeX*0.5
        local pos3 = sizeX*(scrollIdx2-1)+sizeX*0.5
        local pos4 = sizeX*(scrollIdx2+1-1)+sizeX*0.5

       
        --28个路点分成3段,有两个分割点,可能会经常改动
        ---@type UILevelScroller
        self._scroller =
            UILevelScroller:New(
            self._contentRect,
            self._bgLoader1,
            self._bgLoader2,
            {
                bgs[1],
                bgs[2],
                bgs[3]
            },
            {pos1,pos2,pos3,pos4}
        )
        self._scrollRect.onValueChanged:AddListener(
            function()
                self._scroller:OnChange()
            end
        )
    else
        self._bgLoader1.gameObject:SetActive(false)
        self._bgLoader2.gameObject:SetActive(false)
        self._bgLoader3.gameObject:SetActive(true)

        self._bgLoader3:LoadImage(bgs[1])
    end
end

--region 倒计时
function UIWeekTowerController:InitTimer()
    if self._timerEvent then
        GameGlobal.Timer():CancelEvent(self._timerEvent)
        self._timerEvent = nil
    end
    self._timerEvent =
        GameGlobal.Timer():AddEventTimes(
        1000,
        TimerTriggerCount.Infinite,
        function()
            self:SetTimerTex()
        end
    )
    self:SetTimerTex()
end
function UIWeekTowerController:SetTimerTex()
    local svrTime = math.floor(self._svrTimeModule:GetServerTime() * 0.001)
    local sec = self._activeEndTime - svrTime
    if sec < -1 then
        self:TimeReset()
    else
        local timeTex = HelperProxy:GetInstance():Time2Tex(sec)
        self._timer:SetText(StringTable.Get("str_week_tower_reset_time_tips", timeTex))
    end
end
function UIWeekTowerController:TimeReset()
    if self._timerEvent then
        GameGlobal.Timer():CancelEvent(self._timerEvent)
        self._timerEvent = nil
    end
    ToastManager.ShowToast(StringTable.Get("str_week_tower_reset_time_reset_tips"))
    self:CloseController()
end
--endregion
--region 敌方情报
function UIWeekTowerController:InitEnemyInfo()
    if self._enemies == nil then
        ---@type UIEnemyMsg
        self._enemies = self._enemyMsg:SpawnObject("UIEnemyMsg")
    end
    self._enemies:SetData(self._currentMissionData:GetLevelID())
end
--endregion

--region 关卡列表
function UIWeekTowerController:InitStagePool()
    local missionList = self._diffList[self._selectDiffIdx]:MissionList()
    local count = #missionList
    self._stagePools:SpawnObjects("UIWeekTowerNodeLoader", count)
    ---@type UIWeekTowerNodeLoader[]
    local pools = self._stagePools:GetAllSpawnList()
    for i = 1, #pools do
        local item = pools[i]
        if i <= count then
            item:Active(true)
            local missionCount = #missionList
            local missionData = missionList[i]
            item:SetData(i,missionCount,missionData,function(index)
                self:OnStageItemClick(index)
            end,self._itemWidth)
        else
            item:Active(false)
        end
    end
    self._contentRect.sizeDelta = Vector2(self._itemWidth*count)
end
function UIWeekTowerController:OnStageItemClick(index)
    self._scrollRect:StopMovement()
    local movePosX = (index-1)*-1*self._itemWidth
    self._contentRect:DOAnchorPosX(movePosX,self._moveContentTime)
    if not self._infoIsOpen then
        self:MoveInfoRect(true)
    end

    if self._selectIndex == index then
        return
    end

    self._selectIndex = index
    self._currentMissionData = self._diffList[self._selectDiffIdx]:MissionList()[self._selectIndex]

    self:ClickSucc()
end
function UIWeekTowerController:ClickSucc()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.OnUIWeekTowerNodeItemClick, self._selectIndex)
    self:InitStageInfo()
end
--endregion
--region 关卡信息
function UIWeekTowerController:InitStageInfo()
    self:InitEnemyInfo()
    self:InitRecommendLv()
    self:InitStageAwardTT()
    self:InitWord()
    self:InitInfoBg()
    self:InitName()
end
function UIWeekTowerController:InitName()
    local missionName = self._currentMissionData:GetMissionName()
    self._name:SetText(missionName)
end
function UIWeekTowerController:InitInfoBg()
    local cfg = Cfg.cfg_week_tower_view[self._weekTowerID]
    local idx1 = cfg.ScrollIndex[self._selectDiffIdx][1]
    local infoBg
    local infoBg2
    local battleBtn
    local oneChoose = false
    if idx1 == 0 then
        oneChoose = true
    end
    if oneChoose then
        infoBg = cfg.InfoBg[self._selectDiffIdx][1]
        battleBtn = cfg.BattleBtn[self._selectDiffIdx][1]
        infoBg2 = cfg.LayoutIcon[self._selectDiffIdx][1]
    else
        local idx2 = cfg.ScrollIndex[self._selectDiffIdx][2]

        if idx1 > self._selectIndex then
            infoBg = cfg.InfoBg[self._selectDiffIdx][1]
            battleBtn = cfg.BattleBtn[self._selectDiffIdx][1]
            infoBg2 = cfg.LayoutIcon[self._selectDiffIdx][1]
        elseif idx2 > self._selectIndex then
            infoBg = cfg.InfoBg[self._selectDiffIdx][2]
            battleBtn = cfg.BattleBtn[self._selectDiffIdx][2]
            infoBg2 = cfg.LayoutIcon[self._selectDiffIdx][3]
        else
            infoBg = cfg.InfoBg[self._selectDiffIdx][3]
            battleBtn = cfg.BattleBtn[self._selectDiffIdx][3]
            infoBg2 = cfg.LayoutIcon[self._selectDiffIdx][3]
        end
    end
    self._infoBg:LoadImage(infoBg)
    self._infoBg2:LoadImage(infoBg2)
    self._battleBtn:LoadImage(battleBtn)
end
function UIWeekTowerController:InitRecommendLv()
    local recommendGrade = self._currentMissionData:GetRecommendGrade()
    local recommendLv = self._currentMissionData:GetRecommendLv()

    if recommendGrade and recommendGrade > 0 then
        self._recommendLV.gameObject:SetActive(true)
        self._recommendLV:SetText(
            StringTable.Get("str_pet_config_common_advance") .. "<size=29>" .. recommendGrade .. "</size>"
        )
    else
        self._recommendLV.gameObject:SetActive(false)
    end
    if recommendLv and recommendLv > 0 then
        self._recommendLV2.gameObject:SetActive(true)
        self._recommendLV2:SetText("LV." .. recommendLv)
    else
        self._recommendLV2.gameObject:SetActive(false)
    end
end
function UIWeekTowerController:InitStageAwardTT()
    local battleStatus = self._currentMissionData:GetPassTime()
    if battleStatus == WeekTowerMissionBattleStatus.Pass then
        self._awardGot:SetActive(true)
    else
        self._awardGot:SetActive(false)
    end

    local missionid = self._currentMissionData:GetID()
    if self._missionid2activityrewards[missionid] then
        self._activity_rewards = {}
        for i = 1, #self._missionid2activityrewards[missionid] do
            local _data = self._missionid2activityrewards[missionid][i]
            table.insert(self._activity_rewards, _data)
        end
        self:InitStageAward()
    else
        self:Lock("UIWeekTowerController:InitStageAwardTT")
        GameGlobal.TaskManager():StartTask(self._OnInitStageAwardTT, self)
    end
end
function UIWeekTowerController:_OnInitStageAwardTT(TT)
    local campaignModule = GameGlobal.GetModule(CampaignModule)
    local missionid = self._currentMissionData:GetID()
    local res, rewards =
        campaignModule:HandleCampaignGetMatchMissionExReward(TT, MatchType.MT_WeekTower, missionid)
    self:UnLock("UIWeekTowerController:InitStageAwardTT")
    local items = {}
    if res:GetSucc() then
        for i = 1, table.count(rewards) do
            local _data = {}
            _data.item = rewards[i]
            _data.type = StageAwardType.Activity
            table.insert(items, _data)
        end
    else
        Log.error("###[UIWeekTowerController] HandleCampaignGetMatchMissionExReward fail ! mission id --> ", missionid)
    end
    if not self._missionid2activityrewards then
        self._missionid2activityrewards = {}
    end
    if not self._missionid2activityrewards[missionid] then
        self._missionid2activityrewards[missionid] = items
    end
    self._activity_rewards = {}
    for i = 1, #items do
        local _data = items[i]
        table.insert(self._activity_rewards, _data)
    end
    self:InitStageAward()
end
function UIWeekTowerController:InitStageAward()
    --奖励
    ---@type Award[]
    local dropItems = self._currentMissionData:GetAward()
    local items = {}
    for i = 1, #dropItems do
        local _data = {}
        _data.type = StageAwardType.First
        _data.item = dropItems[i]
        table.insert(items, _data)
    end
    table.appendArray(self._activity_rewards, items)

    self._awardContent:SpawnObjects("UIItem", #self._activity_rewards)
    ---@type UIItem[]
    local items = self._awardContent:GetAllSpawnList()
    for i, data in ipairs(self._activity_rewards) do
        local item = data.item
        items[i]:SetForm(UIItemForm.Tower, UIItemScale.Level3)
        local cfgItem = Cfg.cfg_item[item.id]
        if not cfgItem then
            Log.error("###[UIWeekTowerController] cfgItem is nil ! id --> ", item.id)
        end

        local strKey = ""
        local activityText = ""
        local awardType = data.type
        if awardType == StageAwardType.First then
            strKey = "str_discovery_first_award"
        elseif awardType == StageAwardType.Star then
            strKey = "str_discovery_3star_award"
        elseif awardType == StageAwardType.Activity then
            strKey = "str_discovery_activity_award"
            activityText = "str_item_xianshi"
        elseif awardType == StageAwardType.HasGen then
            strKey = "str_discovery_already_collect"
        else
            strKey = "str_discovery_normal_award"
        end

        items[i]:SetData(
            {
                text1 = item.count,
                awardText = StringTable.Get(strKey),
                icon = cfgItem.Icon,
                itemId = item.id,
                quality = cfgItem.Color,
                activityText = StringTable.Get(activityText)
            }
        )
        items[i]:SetClickCallBack(
            function(go)
                self:ItemInfo(item.id, go.transform.position)
            end
        )
    end
end
function UIWeekTowerController:InitWord()
    local word = self._currentMissionData:GetWord()
    local haveWord = false
    
    if word ~= nil then
        if type(word) == "table" then
            if #word > 0 then
                haveWord = true
            end
        else
            if word ~= 0 then
                haveWord = true
            end
        end
    end
    self._wordParent:SetActive(haveWord)
    if haveWord then
        local wordStr = nil
        --词缀
        if type(word) == "table" then
            for _, wordId in ipairs(word) do
                local wordCfg = Cfg.cfg_word_buff[wordId]
                if wordCfg == nil then
                    Log.error("###[UIWeekTowerController] 找不到尖塔词缀，word：", wordId)
                else
                    local desc = StringTable.Get(wordCfg.Desc)
                    if wordStr then
                        wordStr = wordStr .. "\n" .. desc
                    else
                        wordStr = desc
                    end
                end
            end
        else
            local wordCfg = Cfg.cfg_word_buff[word]
            if wordCfg == nil then
                Log.error("###[UIWeekTowerController] 找不到尖塔词缀，word：", word)
            else
                wordStr = StringTable.Get(wordCfg.Desc)
            end
        end
        self._word:SetText(wordStr)
    end
    local awardPosY
    local enemyPosY
    if haveWord then
        awardPosY = -351.2
        enemyPosY = -154.3
    else
        awardPosY = -290.9
        enemyPosY = -33
    end
    self._awardGo.anchoredPosition = Vector2(self._awardGo.anchoredPosition.x,awardPosY)
    self._enemyGo.anchoredPosition = Vector2(self._enemyGo.anchoredPosition.x,enemyPosY)
end
--endregion

function UIWeekTowerController:BattleButtonOnClick(go)
    --判断解锁
    local lock = self._currentMissionData:GetPassTime()
    if lock == WeekTowerMissionBattleStatus.Lock then
        local tips = StringTable.Get("str_week_tower_stage_lock_tips")
        ToastManager.ShowToast(tips)
        return
    end
    -- 打开编队
    ---@type TeamsContext
    local ctx = GameGlobal.GetModule(MissionModule):TeamCtx()

    local param = {
        self._currentMissionData:GetID(),
        self._component:GetCampaignMissionComponentId(),
        self._component:GetCampaignMissionParamKeyMap()
    }

    ctx:Init(TeamOpenerType.Campaign, param)
    self:Lock("DoEnterTeam")
    ctx:ShowDialogUITeams()
end

function UIWeekTowerController:ItemInfo(id, pos)
    self._selectInfo:SetData(id, pos)
end

--点背景右侧信息关闭
function UIWeekTowerController:bgOnClick(go)
    if self._infoIsOpen then
        self:MoveInfoRect(false)
    end
end
--信息动画
function UIWeekTowerController:MoveInfoRect(open)
    if self._moveTweener then
        self._moveTweener:Kill()
    end
    self._infoIsOpen = open
    local lockTime = 100
    self:Lock("UIWeekTowerController:MoveInfoRect")
    if open then
        self._infoRectAnim:Play(self._infoAnim["open"])
        self._infoRectCanvasGroup.blocksRaycasts = true
        lockTime = 467
    else
        self._infoRectAnim:Play(self._infoAnim["close"])
        self._infoRectCanvasGroup.blocksRaycasts = false
        lockTime = 333
    end
    
    GameGlobal.Timer():AddEvent(lockTime,function()
        self:UnLock("UIWeekTowerController:MoveInfoRect")
    end)
end
