---@class UIBonusInfo : UIController
_class("UIBonusInfo", UIController)
UIBonusInfo = UIBonusInfo

function UIBonusInfo:OnShow(uiParams)
    self._animRoot = self:GetGameObject("UIAnim")
    self._closeBtn = self:GetGameObject("CloseBtn")

    ---@type UILocalizationText 三星条件1
    self._allStarCondition1Txt = self:GetUIComponent("UILocalizationText", "Condition1Text")
    ---@type UILocalizationText 三星条件2
    self._allStarCondition2Txt = self:GetUIComponent("UILocalizationText", "Condition2Text")
    ---@type UILocalizationText 三星条件3
    self._allStarCondition3Txt = self:GetUIComponent("UILocalizationText", "Condition3Text")
    ---@type table<int, UILocalizationText>
    self._allStarConditionTxtList = {self._allStarCondition1Txt, self._allStarCondition2Txt, self._allStarCondition3Txt}

    ---@type UILocalizationText 胜利条件
    self._victoryConditionTxt = self:GetUIComponent("UILocalizationText", "VictoryConditionText")

    ---@type UnityEngine.GameObject 三星条件根节点
    self._allStarConditionList = self:GetGameObject("ConditionList")
    --三星条件金星星
    self._Star3ConditionIcon2List = {
        self:GetGameObject("conditionIcon2"),
        self:GetGameObject("condition1Icon2"),
        self:GetGameObject("condition2Icon2")
    }
    --三星条件白星星
    self._Star3ConditionFalseIcon2List = {
        self:GetGameObject("conditionFalseIcon"),
        self:GetGameObject("conditionFalseIcon1"),
        self:GetGameObject("conditionFalseIcon2")
    }
    ---@type UnityEngine.GameObject 无三星条件
    self._noAllStarConditionGO = self:GetGameObject("NoAllStartCondition")

    self._panelRect = self:GetUIComponent("RectTransform", "UIAnim")

    --maze--
    self._mazeInfo = self:GetGameObject("MazeInfo")
    self._mazeRoomName = self:GetUIComponent("UILocalizationText", "MazeRoomName")
    self._allStarInfo = self:GetGameObject("AllStartInfo")
    --end--

    local match = self:GetModule(MatchModule)
    local enterData = match:GetMatchEnterData()

    if not enterData then
        Log.fatal("enterData为空，可能是进局内时断线重登，matchmodule reset了，导致enterdata丢失，此时应该处于force switch login ui状态，直接返回即可")
        return
    end

    if MatchType.MT_Mission == enterData._match_type then
        local mission = self:GetModule(MissionModule)
        ---三星数据
        local missionID = enterData:GetMissionCreateInfo().mission_id
        if mission:Has3StarCondition(missionID) then
            local allStarConditions = ConfigServiceHelper.GetMission3StarCondition(missionID)
            for i = 1, #allStarConditions do
                local showProgress = Cfg.cfg_threestarcondition[allStarConditions[i]].ShowProgress
                local cur3StarProgress = BattleStatHelper.Get3StarProgress(allStarConditions[i])
                local cur3StarMatchResult = BattleStatHelper.GetBonusMatchResult()
                local missionDesc = mission:Get3StarConditionDesc(allStarConditions[i], "5BA8F6")
                if missionDesc ~= nil then
                    if showProgress then
                        self._allStarConditionTxtList[i]:SetText(i .. ".  " .. missionDesc .. "  " .. cur3StarProgress)
                    else
                        self._allStarConditionTxtList[i]:SetText(i .. ".  " .. missionDesc)
                    end
                else
                    Log.fatal("mission desc is nil ", missionID)
                end
                --检查是否满足
                local checkComplete = false
                self._Star3ConditionIcon2List[i]:SetActive(false)
                self._Star3ConditionFalseIcon2List[i]:SetActive(true)
                for _, conditionId in ipairs(cur3StarMatchResult) do
                    if conditionId == allStarConditions[i] then
                        checkComplete = true
                    end
                end
                if checkComplete then
                    self._Star3ConditionIcon2List[i]:SetActive(true)
                    self._Star3ConditionFalseIcon2List[i]:SetActive(false)
                end
            end
        else
            self._allStarConditionList:SetActive(false)
            self._noAllStarConditionGO:SetActive(true)
        end
    elseif MatchType.MT_ExtMission == enterData._match_type then
        local extMission = self:GetModule(ExtMissionModule)
        local matchCreateData = enterData:GetMissionCreateInfo()
        local detailExtTask =
            extMission:UI_GetExtTaskDetail(matchCreateData.m_nExtMissionID, matchCreateData.m_nExtTaskID)
        for i = 1, #detailExtTask.m_vecCondition do
            local checkComplete = detailExtTask.m_vecCondition[i].m_bPass
            self._allStarConditionTxtList[i]:SetText(i .. ".  " .. detailExtTask.m_vecCondition[i].m_stDest)
            self._Star3ConditionIcon2List[i]:SetActive(false)
            self._Star3ConditionFalseIcon2List[i]:SetActive(true)
            if checkComplete then
                self._Star3ConditionIcon2List[i]:SetActive(true)
                self._Star3ConditionFalseIcon2List[i]:SetActive(false)
            end
        end
        self._allStarConditionList:SetActive(true)
        self._noAllStarConditionGO:SetActive(false)
    elseif MatchType.MT_ResDungeon == enterData._match_type then
        -- local resDungeon = self:GetModule(ResDungeonModule)
        -- local resDungeonInfo = enterData:GetResDungeonInfo()
        -- local resDungeonDetail = resDungeon:GetResDungeonDetail(resDungeonInfo.res_dungeon_id, "5BA8F6")
        -- -- for i = 1, #resDungeonDetail.m_vecCondition do
        -- --     local checkComplete = resDungeonDetail.m_vecCondition[i].m_bPass
        -- --     self._Star3ConditionIcon2List[i]:SetActive(false)
        -- --     self._Star3ConditionFalseIcon2List[i]:SetActive(true)
        -- --     if checkComplete then
        -- --         self._Star3ConditionIcon2List[i]:SetActive(true)
        -- --         self._Star3ConditionFalseIcon2List[i]:SetActive(false)
        -- --     end
        -- --     self._allStarConditionTxtList[i]:SetText(i .. ".  " .. resDungeonDetail.m_vecCondition[i].m_stDest)
        -- -- end
        self._allStarConditionList:SetActive(false)
        self._noAllStarConditionGO:SetActive(true)
    elseif MatchType.MT_Maze == enterData._match_type then
        self._mazeInfo:SetActive(true)
        self._allStarInfo:SetActive(false)
        local createInfo = enterData:GetMazeCreateInfo()
        local cfgName = StringTable.Get(Cfg.cfg_maze_room[createInfo.maze_room_id].Title[1])
        self._mazeRoomName.text = cfgName

        local size = self._panelRect.sizeDelta
        size.y = 423
        self._panelRect.sizeDelta = size
    elseif MatchType.MT_Tower == enterData._match_type then
        self._mazeInfo:SetActive(true)
        self._allStarInfo:SetActive(false)
        ---@type TowerModule
        local tModule = self:GetModule(TowerModule)
        local matchInfo = tModule:GetMatchInfo()
        local tCfg = Cfg.cfg_tower_detail[matchInfo.nId]
        local name = tModule:GetTowerName(tCfg.Type)
        local cfgName = StringTable.Get("str_tower_tower_layer", name, tCfg.stage)
        self._mazeRoomName.text = cfgName

        local size = self._panelRect.sizeDelta
        size.y = 423
        self._panelRect.sizeDelta = size
    elseif MatchType.MT_MiniMaze == enterData._match_type then
        self._mazeInfo:SetActive(true)
        self._allStarInfo:SetActive(false)
        local matchInfo = enterData:GetMissionCreateInfo()
        local cfg = Cfg.cfg_component_bloodsucker { CampaignMissionID = matchInfo.mission_id }
        self._mazeRoomName:SetText(StringTable.Get(cfg[1].MissionName))
        

        local size = self._panelRect.sizeDelta
        size.y = 423
        self._panelRect.sizeDelta = size
    elseif MatchType.MT_EightPets == enterData._match_type then
        self._allStarConditionList:SetActive(false)
        self._noAllStarConditionGO:SetActive(true)
    end
    ---胜利条件
    self._victoryConditionTxt:SetText(ConfigServiceHelper.GetLevelConfigData():GetLevelCompleteConditionStr())

    self:_OnTweenShow()
end

function UIBonusInfo:_OnTweenShow()
    ---@type UnityEngine.Transform
    local transWork = self._animRoot.transform
    self._closeBtn:SetActive(false)

    transWork.localPosition = Vector3(-2300, 0, 0)

    self._tweenQueue = DG.Tweening.DOTween.Sequence()
    --0.4s 移动到屏幕中间
    self._tweenQueue:Append(transWork:DOLocalMoveX(0, 0.4))

    --等待1s 可以点击关闭界面
    self._tweenQueue:AppendInterval(1):AppendCallback(
        function()
            self._closeBtn:SetActive(true)
        end
    )

    --一共等待3s 关闭界面
    local stayTime = (BattleConst.BonusShowDuration / 1000) - 1
    self._tweenQueue:AppendInterval(stayTime):OnComplete(
        function()
            GameGlobal.EventDispatcher():Dispatch(GameEventType.OnClickUIBonusInfo)
        end
    )
end

function UIBonusInfo:CloseBtnOnClick(go)
    if self._tweenQueue then
        self._tweenQueue:Kill(false)
    end

    GameGlobal.EventDispatcher():Dispatch(GameEventType.OnClickUIBonusInfo)
end
