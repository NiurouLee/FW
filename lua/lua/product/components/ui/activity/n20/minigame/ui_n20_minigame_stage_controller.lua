---@class UIN20MiniGameStageController : UIController
_class("UIN20MiniGameStageController", UIController)
UIN20MiniGameStageController = UIN20MiniGameStageController

function UIN20MiniGameStageController:Constructor()
    ---@type table<number, UIN20MiniGameWayPoint>
    self._wayPointCell = {}
    self._wayLineCell = {}
    self._curMissionID = 0
    self._firstMissionID = 1
    self._rewards = {}
    self._textColor = {
        [true] = Color(1, 1, 1, 1),
        [false] = Color(169/255, 169/255, 169/255, 1)
    }
    self._sabImg = {
        [true] = "n20_game_di5",
        [false] = "n20_game_di4",
    }
    ---@type UIN20MiniGameWayPoint
    self._preWayPointCell = nil
end
function UIN20MiniGameStageController:LoadDataOnEnter(TT, res, uiParams)
    self._svrTimeModule = self:GetModule(SvrTimeModule)
    self._loginModule = self:GetModule(LoginModule)
    local campaignModule = self:GetModule(CampaignModule)
    ---@type UIActivityCampaign
    self._campaign = UIActivityCampaign:New()
    self._campaign:LoadCampaignInfo(
        TT,
        res,
        ECampaignType.CAMPAIGN_TYPE_N20,
        ECampaignN20ComponentID.ECAMPAIGN_N20_MINI_GAME
    )
    if res and not res:GetSucc() then
        campaignModule:CheckErrorCode(res.m_result, self._campaign._id, nil, nil)
        return
    end
    self._component = self._campaign:GetLocalProcess()._campaignShavingIceComponent
    self._componentInfo = self._campaign:GetLocalProcess()._shavingIceComponentInfo
    local openTime = self._componentInfo.m_unlock_time
    local closeTime = self._componentInfo.m_close_time
    local nowtime = self._svrTimeModule:GetServerTime() / 1000
    if nowtime < openTime then
        res.m_result = CampaignErrorType.E_CAMPAIGN_ERROR_TYPE_CAMPAIGN_NO_OPEN
        campaignModule:ShowErrorToast(res.m_result, true)
        return
    end
    if nowtime > closeTime then
        res.m_result = CampaignErrorType.E_CAMPAIGN_ERROR_TYPE_CAMPAIGN_FINISHED
        campaignModule:ShowErrorToast(res.m_result, true)
        return
    end
end
function UIN20MiniGameStageController:OnShow(uiParams)
    self._callBack = uiParams[1]
    self._cfg_stage = Cfg.cfg_component_mini_game_mission{ComponentID = 106310008}
    table.sort(self._cfg_stage, 
    function(a, b) 
        return a.ID < b.ID
    end)
    self._firstMissionID = self._cfg_stage[1].ID
    self._lastBGMResName = AudioHelperController.GetCurrentBgm()
    self:_GetComponents()
    self:_OnValue()
end
function UIN20MiniGameStageController:_GetComponents()
    self._backBtn = self:GetUIComponent("UISelectObjectPath", "BackBtn")
    self._commonTopBtn = self._backBtn:SpawnObject("UICommonTopButton")
    self._commonTopBtn:SetData(
        function()
            self:_Close()
        end,
        function()
            self:ShowDialog("UIN20MiniGameHelp", "UIN20MiniGameStageController") --UIMiniGameStageController UIN20MiniGameStageController
        end
    )
    self._remainTime = self:GetUIComponent("UILocalizationText", "Time")
    self._itemTips = self:GetUIComponent("UISelectObjectPath", "ItemTips")
    self._tips = self._itemTips:SpawnObject("UISelectInfo")
    self._content = self:GetUIComponent("RectTransform", "Content")
    self._wayPoint = self:GetUIComponent("UISelectObjectPath", "WayPoint")
    self._wayLine = self:GetUIComponent("UISelectObjectPath", "WayLine")
    self._title = self:GetUIComponent("UILocalizationText", "Title")
    self._stageDescription = self:GetUIComponent("UILocalizationText", "StageDescription")
    self._bestScore = self:GetUIComponent("UILocalizationText", "BestScore")
    self._mark = self:GetGameObject("Mark")
    self._SABRawImage = {}
    self._SABRawImage[ScoreType.S] = self:GetUIComponent("RawImageLoader", "S")
    self._SABRawImage[ScoreType.A] = self:GetUIComponent("RawImageLoader", "A")
    self._SABRawImage[ScoreType.B] = self:GetUIComponent("RawImageLoader", "B")
    self._SABScore = {}
    self._SABScore[ScoreType.S] = self:GetUIComponent("UILocalizationText", "SScore")
    self._SABScore[ScoreType.A] = self:GetUIComponent("UILocalizationText", "AScore")
    self._SABScore[ScoreType.B] = self:GetUIComponent("UILocalizationText", "BScore")
    self._SABRedPoint = {}
    self._SABRedPoint[ScoreType.S] = self:GetGameObject("SRedPoint")
    self._SABRedPoint[ScoreType.A] = self:GetGameObject("ARedPoint")
    self._SABRedPoint[ScoreType.B] = self:GetGameObject("BRedPoint")
    self._SABState = {}
    self._SABState[ScoreType.S] = self:GetGameObject("SState")
    self._SABState[ScoreType.A] = self:GetGameObject("AState")
    self._SABState[ScoreType.B] = self:GetGameObject("BState")
    self._SABStateText = {}
    self._SABStateText[ScoreType.S] = self:GetUIComponent("UILocalizationText", "SStateText")
    self._SABStateText[ScoreType.A] = self:GetUIComponent("UILocalizationText", "AStateText")
    self._SABStateText[ScoreType.B] = self:GetUIComponent("UILocalizationText", "BStateText")
    self._SABRewards = {}
    self._SABRewards[ScoreType.S] = self:GetUIComponent("UISelectObjectPath", "SReward")
    self._SABRewards[ScoreType.A] = self:GetUIComponent("UISelectObjectPath", "AReward")
    self._SABRewards[ScoreType.B] = self:GetUIComponent("UISelectObjectPath", "BReward")
    self._storyBtn = self:GetGameObject("StoryBtn")
    self._atlas = self:GetAsset("N20MiniGame.spriteatlas", LoadType.SpriteAtlas)
    self._stageAnimation = self:GetUIComponent("Animation", "StageAnimation")
    self._blackMask = self:GetGameObject("black_mask")
    ---@type UnityEngine.RectTransform
    self._scrollView = self:GetUIComponent("RectTransform", "ScrollView")
end
function UIN20MiniGameStageController:_OnValue()
    local bangWidth = ResolutionManager.RealWidth() - ResolutionManager.BangWidth() * 2
    self._scrollView.sizeDelta = Vector2(bangWidth - 900, 788)
    self:_PlayStory()
    self:_SetRemainTime()
    self:_CreateStageMap()
    self:_ClickWayPoint(self._cfg_stage[1].ID, false)
end
function UIN20MiniGameStageController:_PlayStory()
    if LocalDB.GetInt("ui_n20_minigame_first_story" .. self._loginModule:GetRoleShowID()) > 0 then
        return
    end
    self:_hide(true)
    GameGlobal.GetModule(StoryModule):StartStory(
        self._componentInfo.m_first_story_id,
        function()
            self:_hide(false)
            AudioHelperController.PlayBGM(self._lastBGMResName, AudioConstValue.BGMCrossFadeTime)
            LocalDB.SetInt("ui_n20_minigame_first_story" .. self._loginModule:GetRoleShowID(), 1)
        end
    )
end
function UIN20MiniGameStageController:_SetRemainTime()
    local time = math.floor(self._svrTimeModule:GetServerTime() * 0.001)
    time = self._componentInfo.m_close_time - time
    self._remainTime:SetText(self:_GetRemainTime(time))
end
function UIN20MiniGameStageController:_CreateStageMap()
    local wayPointCount = table.count(self._cfg_stage)
    local vector = Vector2(0.5, 0.5)
    local waypoint_offset_y = {[0] = -166, [1] = 108}
    local rotation_z = {[0] = -50, [1] = 50}
    if wayPointCount > 5 then
        self._content.sizeDelta = Vector2(1500 + (wayPointCount - 5) * 500, 0)
    end
    local servertime = math.floor(self._svrTimeModule:GetServerTime() * 0.001)
    --路点
    self._wayPoint:SpawnObjects("UIN20MiniGameWayPoint", wayPointCount)
    self._wayPointCell = self._wayPoint:GetAllSpawnList()
    for key, value in pairs(self._wayPointCell) do
        self:_SetWayInfo(
            value.view.transform,
            vector,
            Vector3(self._content.sizeDelta.x * -0.5 + 250 + (key - 1) * 295, waypoint_offset_y[key % 2], 0),
            Vector3.zero
        )
        local missionID = self._cfg_stage[key].ID
        value:SetData(
            self,
            missionID,
            self._cfg_stage[key],
            self._componentInfo.mission_info_list[missionID],
            servertime,
            function(missionID)
                self:_ClickWayPoint(missionID, true)
            end,
            self:_IsNewUnLockMission(missionID)
        )
    end
    --路线
    self._wayLine:SpawnObjects("UIN20MiniGameWayLine", wayPointCount - 1)
    self._wayLineCell = self._wayLine:GetAllSpawnList()
    for key, value in pairs(self._wayLineCell) do
        local pos = nil
        if key % 2 == 0 then
            pos = Vector3(self._content.sizeDelta.x * -0.5 + 269 + (key - 1) * 295, -137, 0)
        else
            pos = Vector3(self._content.sizeDelta.x * -0.5 + 517 + (key - 1) * 295, -137, 0)
        end
        self:_SetWayInfo(
            value.view.transform,
            vector,
            pos,
            Vector3(0, 0, rotation_z[key % 2])
        )
        value:SetData(self._componentInfo.mission_info_list[self._cfg_stage[key + 1].ID].unlock_time <= servertime)
    end
end
function UIN20MiniGameStageController:_RefreshWayPointWayLineInfo()
    local servertime = math.floor(self._svrTimeModule:GetServerTime() * 0.001)
    for key, value in pairs(self._wayPointCell) do
        value:RefreshUnLockState(servertime)
    end
    for key, value in pairs(self._wayLineCell) do
        value:SetData(self._componentInfo.mission_info_list[self._cfg_stage[key + 1].ID].unlock_time <= servertime)
    end
end
function UIN20MiniGameStageController:_SetWayInfo(transform, vector2, vector3, eulerAngles)
    transform.anchorMin = vector2
    transform.anchorMax = vector2
    transform.pivot = vector2
    transform.anchoredPosition = vector3
    transform.eulerAngles = eulerAngles
end
function UIN20MiniGameStageController:_IsNewUnLockMission(id)
    local str = LocalDB.GetString("N20MiniGameNewStage" .. self._loginModule:GetRoleShowID())
    local ids = string.split(str, ",")
    local nowTime = self._svrTimeModule:GetServerTime() * 0.001
    local mission = self._componentInfo.mission_info_list[id]
    if mission.unlock_time <= nowTime then
        for i = 1, #ids do
            if ids[i] == tostring(id) then
                return false
            end
        end
        return true
    else
        return false
    end
end
function UIN20MiniGameStageController:_Close()
    local str = LocalDB.GetString("N20MiniGameNewStage" .. self._loginModule:GetRoleShowID())
    local ids = string.split(str, ",")
    local nowTime = self._svrTimeModule:GetServerTime() * 0.001
    for key, value in pairs(self._componentInfo.mission_info_list) do
        if value.unlock_time <= nowTime then
            local recorded = false
            for j = 1, #ids do
                if ids[j] == tostring(key) then
                    recorded = true
                end
            end
            if not recorded then
                str = str .. key .. ","
            end
        end
    end
    LocalDB.SetString("N20MiniGameNewStage" .. self._loginModule:GetRoleShowID(), str)
    self:CloseDialog()
    if self._callBack then
        self._callBack()
    end
    GameGlobal.EventDispatcher():Dispatch(GameEventType.ActivityDialogRefresh)
end
function UIN20MiniGameStageController:_ClickWayPoint(missionID, manual)
    if manual then
        AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1ClickNormal)
    end
    if self:_CheckCampaignClose() then
        return
    end
    if not manual then
        self._stageAnimation:Play(MGAnimations.Other["Switch"])
    end
    local servertime = math.floor(self._svrTimeModule:GetServerTime() * 0.001)
    local miss_info = self._componentInfo.mission_info_list[missionID]
    if miss_info.unlock_time > servertime then
        ToastManager.ShowToast(StringTable.Get("str_n20_minigame_lock", self:_GetRemainTime(miss_info.unlock_time - servertime)))
        return
    end
    if self._curMissionID ~= missionID then
        self._curMissionID = missionID
        self:_RefreshUIInfo()
        self:_RefreshSelectMark()
    end
end
function UIN20MiniGameStageController:_RefreshUIInfo()
    self._current_stage_cfg = self._cfg_stage[self:_GetMissionIndex(self._curMissionID)]
    if self._current_stage_cfg then
        self._title:SetText(StringTable.Get(self._current_stage_cfg.Title))
        self._stageDescription:SetText(StringTable.Get(self._current_stage_cfg.Description))
        local mission_info = self._componentInfo.mission_info_list[self._curMissionID].mission_info
        self._bestScore:SetText(mission_info.max_score)
        self:_RefreshBASInfo(mission_info, self._current_stage_cfg)
        self._storyBtn:SetActive(mission_info.story_mask > 0)
    end
end
function UIN20MiniGameStageController:_RefreshBASInfo(mission_info, cfg_stage)
    for _, value in pairs(ScoreType) do
        self._SABScore[value]:SetText(cfg_stage.Score[math.min(value, 3)])
        local showredpoint = mission_info.mission_grade >= value and mission_info.reward_mask & value == 0
        self._SABRedPoint[value]:SetActive(showredpoint)
        self._SABState[value]:SetActive(mission_info.mission_grade >= value and not showredpoint)
        local str = ""
        if mission_info.mission_grade < value then
            str = StringTable.Get("str_n20_minigame_get_not")
        else
            if mission_info.reward_mask & value == 0 then
                str = StringTable.Get("str_n20_minigame_get")
            else
                str = StringTable.Get("str_n20_minigame_got")
            end
        end
        local state = mission_info.reward_mask & value == 0 and mission_info.mission_grade >= value
        self._SABStateText[value]:SetText(str)
        self._SABStateText[value].color = self._textColor[state]
        self._SABRawImage[value]:LoadImage(self._sabImg[state])
        self:_SetRewards(self._SABRewards[value], value)
    end
end

---@param widget UISelectObjectPath
---@param scoreType ScoreType
function UIN20MiniGameStageController:_SetRewards(widget, scoreType)
    if self._current_stage_cfg then
        local rewards
        if scoreType == ScoreType.B then
            rewards = self._current_stage_cfg.ScoreBReward
        elseif scoreType == ScoreType.A then
            rewards = self._current_stage_cfg.ScoreAReward
        elseif scoreType == ScoreType.S then
            rewards = self._current_stage_cfg.ScoreSReward
        end
        local mission_info = self._componentInfo.mission_info_list[self._curMissionID].mission_info
        local count = table.count(rewards)
        if count > 0 then
            widget:SpawnObjects("UIN20MiniGameRewardItem", count)
            self._rewards[scoreType] = widget:GetAllSpawnList()
            for i = 1, #self._rewards[scoreType] do
                self._rewards[scoreType][i]:SetData(
                    rewards[i],
                    scoreType,
                    mission_info,
                    function(id, pos)
                        self:_ShowRewardTips(id, pos)
                    end
                )
            
            end
        end
    end
end

function UIN20MiniGameStageController:_RefreshRewardInfo(mission_info)
    for _, value in pairs(ScoreType) do
        local state = mission_info.mission_grade >= value and mission_info.reward_mask & value == 0
        self._SABRedPoint[value]:SetActive(state)
        self._SABState[value]:SetActive(mission_info.mission_grade >= value and not state)
        local str = ""
        if mission_info.mission_grade < value then
            str = StringTable.Get("str_n20_minigame_get_not")
        else
            if mission_info.reward_mask & value == 0 then
                str = StringTable.Get("str_n20_minigame_get")
            else
                str = StringTable.Get("str_n20_minigame_got")
            end
        end
        self._SABStateText[value]:SetText(str)
        self._SABStateText[value].color = self._textColor[state]
        self._SABRawImage[value]:LoadImage(self._sabImg[state])
    end
end
function UIN20MiniGameStageController:_RewardState(mission_info)
    if self._rewards then
        for _, value in pairs(ScoreType) do
            for i = 1, #self._rewards[value] do
                self._rewards[value][i]:RefreshUIInfo(mission_info)
            end
        end
    end
end
function UIN20MiniGameStageController:_RefreshSelectMark()
    local widget = self._wayPointCell[self:_GetMissionIndex(self._curMissionID)]
    if self._preWayPointCell and widget ~= self._preWayPointCell then
        self._preWayPointCell:SetNameBg(false)
    end
    self._preWayPointCell = widget
    widget:SetNameBg(true)
    self._mark.transform.position = widget._nameBg.transform.position
    self._mark.transform.localPosition = Vector3(self._mark.transform.localPosition.x, self._mark.transform.localPosition.y + 76)
end

function UIN20MiniGameStageController:_ShowRewardTips(id, pos)
    self._tips:SetData(id, pos)
end
function UIN20MiniGameStageController:_GetRemainTime(time)
    local day, hour, minute
    day = math.floor(time / 86400)
    hour = math.floor(time / 3600) % 24
    minute = math.floor(time / 60) % 60
    local timestring = ""
    if day > 0 then
        timestring =
            day .. StringTable.Get("str_activity_common_day") .. hour .. StringTable.Get("str_activity_common_hour")
    elseif hour > 0 then
        timestring =
            hour ..
            StringTable.Get("str_activity_common_hour") .. minute .. StringTable.Get("str_activity_common_minute")
    elseif minute > 0 then
        timestring = minute .. StringTable.Get("str_activity_common_minute")
    else
        timestring = StringTable.Get("str_activity_common_less_minute")
    end
    return string.format(StringTable.Get("str_activity_common_over"), timestring)
end
function UIN20MiniGameStageController:BOnClick()
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1ClickNormal)
    self:GetRewards(ScoreType.B)
end
function UIN20MiniGameStageController:AOnClick()
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1ClickNormal)
    self:GetRewards(ScoreType.A)
end
function UIN20MiniGameStageController:SOnClick()
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1ClickNormal)
    self:GetRewards(ScoreType.S)
end
function UIN20MiniGameStageController:GetRewards(scoreType)
    if not self._componentInfo.mission_info_list[self._curMissionID] then
        return
    end
    local mission_info = self._componentInfo.mission_info_list[self._curMissionID].mission_info
    if not mission_info then
        return
    end
    local state = mission_info.mission_grade >= scoreType and mission_info.reward_mask & scoreType == 0
    if not state then
        return
    end
    self._current_scoretype = scoreType
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1ClickNormal)
    self:Lock("UIN20MiniGameStageController:GetRewards")
    self:StartTask(
        function(TT)
            local res = AsyncRequestRes:New()
            local result, rewards =
                self._component:HandleRecvRewardMsg(
                TT,
                res,
                self._cfg_stage[self:_GetMissionIndex(self._curMissionID)].ID,
                self._current_scoretype
            )
            if result and result:GetSucc() then
                self:ShowDialog("UIGetItemController", rewards)
                self:_RefreshUIWhenReceiveReward()
            else
                self:_Close()
            end
            self:UnLock("UIN20MiniGameStageController:GetRewards")
        end
    )
end
function UIN20MiniGameStageController:_RefreshUIWhenReceiveReward()
    local miss_info = self._componentInfo.mission_info_list[self._curMissionID].mission_info
    local showredpoint = miss_info.mission_grade >= self._current_scoretype and miss_info.reward_mask & self._current_scoretype == 0
    self._SABRedPoint[self._current_scoretype]:SetActive(showredpoint)
    self._SABState[self._current_scoretype]:SetActive(not showredpoint and miss_info.mission_grade >= self._current_scoretype)
    self:_RefreshRewardInfo(miss_info)
    self:_RewardState(miss_info)
    self._wayPointCell[self:_GetMissionIndex(self._curMissionID)]:RefreshRedpointStateZi(miss_info)
end
function UIN20MiniGameStageController:_RefreshUIWhenGameOver()
    local mission_info = self._componentInfo.mission_info_list[self._curMissionID].mission_info
    self._bestScore:SetText(mission_info.max_score)
    self:_RefreshBASInfo(mission_info, self._current_stage_cfg)
    self:_RefreshRewardInfo(mission_info)
    self:_RewardState(mission_info)
    self._wayPointCell[self:_GetMissionIndex(self._curMissionID)]:RefreshRedpointStateZi(mission_info)
    self._storyBtn:SetActive(mission_info.story_mask > 0)
    self:_RefreshWayPointWayLineInfo()
end
--剧情回顾
function UIN20MiniGameStageController:StoryBtnOnClick()
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1ClickNormal)
    self:_PlayMissStory()
end
function UIN20MiniGameStageController:_PlayMissStory()
    if self._current_stage_cfg.StoryID[1] then
        self:_hide(true)
        GameGlobal.GetModule(StoryModule):StartStory(
            self._current_stage_cfg.StoryID[1],
            function()
                self:_hide(false)
                if self._current_stage_cfg.StoryID[2] then
                    self:_hide(true)
                    GameGlobal.GetModule(StoryModule):StartStory(
                        self._current_stage_cfg.StoryID[2],
                        function()
                            self:_hide(false)
                            AudioHelperController.PlayBGM(self._lastBGMResName, AudioConstValue.BGMCrossFadeTime)
                        end
                    )
                else
                    AudioHelperController.PlayBGM(self._lastBGMResName, AudioConstValue.BGMCrossFadeTime)
                end
            end
        )
    else
        AudioHelperController.PlayBGM(self._lastBGMResName, AudioConstValue.BGMCrossFadeTime)
    end
end
function UIN20MiniGameStageController:GameBtnOnClick()
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.Summer1ClickNormal)
    if self:_CheckCampaignClose() then
        return
    end
    if not self:_CheckPreMission(self._curMissionID) then
        ToastManager.ShowToast(StringTable.Get("str_summer_minigame_premissionunfinished"))
        return
    end
    if
        table.icontains(self._current_stage_cfg.StoryActiveType, 1) and
            self._componentInfo.mission_info_list[self._curMissionID].mission_info.story_mask & 1 == 0
     then
        self:_hide(true)
        GameGlobal.GetModule(StoryModule):StartStory(
            self._current_stage_cfg.StoryID[1],
            function()
                self:StartTask(
                    function(TT)
                        local res = AsyncRequestRes:New()
                        res = self._component:HandleStoryMsg(TT, res, self._cfg_stage[self:_GetMissionIndex(self._curMissionID)].ID, 1)
                        if res:GetSucc() then
                            self:ShowDialog(
                                "UIN20MiniGameController",
                                self._current_stage_cfg.ID,
                                self._component,
                                self._componentInfo,
                                self._lastBGMResName,
                                function()
                                    self:_hide(false)
                                    self:_RefreshUIWhenGameOver()
                                end
                            )
                        end
                    end
                )
            end
        )
    else
        self:ShowDialog(
            "UIN20MiniGameController",
            self._current_stage_cfg.ID,
            self._component,
            self._componentInfo,
            self._lastBGMResName,
            function()
                self:_hide(false)
                self:_RefreshUIWhenGameOver()
            end
        )
    end
end
function UIN20MiniGameStageController:_CheckCampaignClose()
    local time = self._componentInfo.m_close_time - math.floor(self._svrTimeModule:GetServerTime() * 0.001)
    if time <= 0 then
        ToastManager.ShowToast(StringTable.Get("str_activity_common_notice_content"))
        self:_Close()
        return true
    end
    return false
end
function UIN20MiniGameStageController:_CheckPreMission(missionID)
    if missionID == self._firstMissionID then
        return true
    end
    return self._componentInfo.mission_info_list[missionID - 1].mission_info.max_score > 0
end

function UIN20MiniGameStageController:_hide(hide)
    self._blackMask:SetActive(hide)
end

function UIN20MiniGameStageController:_GetMissionIndex(missionID)
    for key, value in pairs(self._cfg_stage) do
        if value.ID == missionID then
            return key
        end
    end
    return 1
end

function UIN20MiniGameStageController:StoryReviewBtnOnClick(go)
    self:_hide(true)
    GameGlobal.GetModule(StoryModule):StartStory(
        self._componentInfo.m_first_story_id,
        function()
            self:_hide(false)
            AudioHelperController.PlayBGM(self._lastBGMResName, AudioConstValue.BGMCrossFadeTime)
        end
    )
end