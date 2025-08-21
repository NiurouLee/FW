---@class UIActivityNPlusSixBuildingMainController: UIController
_class("UIActivityNPlusSixBuildingMainController", UIController)
UIActivityNPlusSixBuildingMainController = UIActivityNPlusSixBuildingMainController

function UIActivityNPlusSixBuildingMainController:LoadDataOnEnter(TT, res, uiParams)
    ---@type SvrTimeModule
    self._timeModule = GameGlobal.GetModule(SvrTimeModule)
    ---@type CampaignModule
    self._campaignModule = GameGlobal.GetModule(CampaignModule)

    -- 获取活动 以及本窗口需要的组件
    ---@type UIActivityCampaign
    self._campaign = UIActivityCampaign:New()
    self._campaign:LoadCampaignInfo(
        TT,
        res,
        ECampaignType.CAMPAIGN_TYPE_HALLOWEEN,
        ECampaignN6ComponentID.ECAMPAIGN_N6_BUILD,
        ECampaignN6ComponentID.ECAMPAIGN_N6_QUEST
    )
    -- 错误处理
    if res and not res:GetSucc() then
        self._campaignModule:CheckErrorCode(res.m_result, self._campaign._id, nil, nil)
    end
    if not self._campaign then
        return
    end
    ---@type CCampaingN6
    self._localProcess = self._campaign:GetLocalProcess()
    if not self._localProcess then
        return
    end

    --获取组件
    --重建组件
    ---@type CampaignBuildComponent
    self._buildComponent = self._localProcess:GetComponent(ECampaignN6ComponentID.ECAMPAIGN_N6_BUILD)
    ---@type BuildComponentInfo
    self._buildComponentInfo = self._localProcess:GetComponentInfo(ECampaignN6ComponentID.ECAMPAIGN_N6_BUILD)
    ---任务组件（重建奖励）
    ---@type CampaignQuestComponent
    self._questComponent = self._localProcess:GetComponent(ECampaignN6ComponentID.ECAMPAIGN_N6_QUEST)
    ---@type CamQuestComponentInfo
    self._questComponentInfo = self._localProcess:GetComponentInfo(ECampaignN6ComponentID.ECAMPAIGN_N6_QUEST)
    ---剧情组件
    ---@type StoryComponent
    self._storyComponent = self._localProcess:GetComponent(ECampaignN6ComponentID.ECAMPAIGN_N6_STORY)
    ---@type CStoryComponentInfo
    self._storyComponentInfo = self._localProcess:GetComponentInfo(ECampaignN6ComponentID.ECAMPAIGN_N6_STORY)
    --建筑数据
    ---@type UIActivityNPlusSixBuildingDatas
    self._buildingDatas = uiParams[1]
    if self._buildingDatas == nil then
        local componentId =
            self._buildComponent:GetComponentCfgId(self._campaign._id, self._buildComponentInfo.m_component_id)
        ---@type UIActivityNPlusSixBuildingDatas
        self._buildingDatas = UIActivityNPlusSixBuildingDatas:New(componentId, self._localProcess)
    end
    self._maxBuildingCount = 2
    self:RefreshEventData()
end

function UIActivityNPlusSixBuildingMainController:RefreshData()
    ---@type ItemModule
    local itemModule = GameGlobal.GetModule(ItemModule)
    self._itemCount = itemModule:GetItemCount(UIActivityNPlusSixConst.GetCoinItemId())
end

function UIActivityNPlusSixBuildingMainController:RefreshEventData()
    --随机事件数据
    ---@type UIActivityNPlusSixEventData[]
    self._eventDatas = {}
    ---@type BuildEventInfo
    local eventInfo = self._buildComponentInfo.event_info
    if eventInfo.cur_event_list then
        for i = 1, #eventInfo.cur_event_list do
            self._eventDatas[#self._eventDatas + 1] = UIActivityNPlusSixEventData:New(eventInfo.cur_event_list[i])
        end
    end
    table.sort(
        self._eventDatas,
        function(a, b)
            return a:GetEventId() < b:GetEventId()
        end
    )
end

function UIActivityNPlusSixBuildingMainController:OnShow(uiParams)
    self._completeSpineLoader = self:GetUIComponent("UISelectObjectPath", "Complete")
    self._BGLoader = self:GetUIComponent("RawImageLoader", "BG")
    self._showBtn = self:GetGameObject("ShowBtn")
    self._btnPanel = self:GetGameObject("BtnPanel")
    self._showBtn:SetActive(false)
    self._btnPanel:SetActive(true)
    self._eventItemLoader = self:GetUIComponent("UISelectObjectPath", "EventItems")
    local s = self:GetUIComponent("UISelectObjectPath", "itemTips")
    ---@type UISelectInfo
    self._tips = s:SpawnObject("UISelectInfo")
    self._rewardRed = self:GetGameObject("RewardRed")
    local btns = self:GetUIComponent("UISelectObjectPath", "TopBtn")
    ---@type UICommonTopButton
    self._backBtn = btns:SpawnObject("UICommonTopButton")
    self._backBtn:SetData(
        function()
            GameGlobal.EventDispatcher():Dispatch(GameEventType.NPlusSixMainRefresh)
            self:CloseDialog()
        end,
        nil,
        nil,
        false,
        function()
            self._showBtn:SetActive(true)
            self._btnPanel:SetActive(false)
        end
        -- function()
        --     self:ShowDialog("UIHelpController", "UIActivityNPlusSixBuildingMainController")
        -- end
    )
    self._scoreLabel = self:GetUIComponent("UILocalizationText", "Score")
    self:AttachEvent(GameEventType.NPlusSixBuildingMainRefresh, self.RefreshUI)
    self:AttachEvent(GameEventType.NPlusSixBuildingBuildingComplete, self.PlayBuildingCompleteEffect)
    self:AttachEvent(GameEventType.NPlusSixBuildingAllBuildingComplete, self.BuildingAllBuildingComplete)
    self:AttachEvent(GameEventType.NPlusSixEventRefresh, self.RefreshEvent)
    self:AttachEvent(GameEventType.NPlusSixEventComplete, self.EventCompleteHandle)
    self:AttachEvent(GameEventType.NPlusSixShowEventRewardTips, self.ShowTips)
    self._iconLoader = self:GetUIComponent("RawImageLoader", "Icon")
    local iconName = UIActivityNPlusSixConst.GetItemIconName()
    if iconName then
        self._iconLoader:LoadImage(iconName)
    end
    self:RefreshUI()
    self:RefreshEventUI()
    self:CheckStory()
    self._buildingDatas:EnterBuilding()
end

function UIActivityNPlusSixBuildingMainController:OnHide()
    self:DetachEvent(GameEventType.NPlusSixBuildingMainRefresh, self.RefreshUI)
    self:DetachEvent(GameEventType.NPlusSixBuildingBuildingComplete, self.PlayBuildingCompleteEffect)
    self:DetachEvent(GameEventType.NPlusSixBuildingAllBuildingComplete, self.BuildingAllBuildingComplete)
    self:DetachEvent(GameEventType.NPlusSixShowEventRewardTips, self.ShowTips)
    self:DetachEvent(GameEventType.NPlusSixEventRefresh, self.RefreshEvent)
    self:DetachEvent(GameEventType.NPlusSixEventComplete, self.EventCompleteHandle)
end

--显示所有按钮
function UIActivityNPlusSixBuildingMainController:ShowBtnOnClick()
    self._showBtn:SetActive(false)
    self._btnPanel:SetActive(true)
end

function UIActivityNPlusSixBuildingMainController:RefreshUI()
    self:RefreshData()
    self._scoreLabel.text = self:GetItemCountStr(self._itemCount)
    self:RefreshBuildings()
    self:RefreshRed()
    self:RefreshBg()
end

function UIActivityNPlusSixBuildingMainController:RefreshBg()
    local buildingRoot = self:GetGameObject("Buildings")
    local isComplete = self._buildingDatas:IsAllBuildingComplete()
    if isComplete then
        if self._completeSpineLoader then
            local list = self._completeSpineLoader:GetAllSpawnList()
            for i = 1, #list do
                list[i]:SetVisible(true)
            end
        end
        self._BGLoader:LoadImage("n6_rebuild_bg1")
    else
        if self._completeSpineLoader then
            local list = self._completeSpineLoader:GetAllSpawnList()
            for i = 1, #list do
                list[i]:SetVisible(false)
            end
        end
        self._BGLoader:LoadImage("n6_rebuild_bg")
    end
    buildingRoot:SetActive(true)
end

function UIActivityNPlusSixBuildingMainController:GetItemCountStr(count)
    local dight = 0
    local tmpCount = count
    while tmpCount > 0 do
        tmpCount = math.floor(tmpCount / 10)
        dight = dight + 1
    end
    local pre = ""
    for i = 1, 7 - dight do
        pre = pre .. "0"
    end
    if count > 0 then
        return string.format("<color=#5e5e5e>%s</color><color=#f2c641>%s</color>", pre, count)
    else
        return string.format("<color=#5e5e5e>%s</color>", pre)
    end
end

function UIActivityNPlusSixBuildingMainController:RefreshRed()
    self._rewardRed:SetActive(self._questComponent:HaveRedPoint())
end

function UIActivityNPlusSixBuildingMainController:RefreshBuildings()
    if not self._buildingDatas then
        return
    end
    local buildingList = self._buildingDatas:GetBuildingList()
    if not buildingList then
        return
    end

    local buildingDatas = {}
    for k, v in pairs(buildingList) do
        buildingDatas[#buildingDatas + 1] = v
    end

    table.sort(
        buildingDatas,
        function(a, b)
            if a:GetLayer() ~= b:GetLayer() then
                return a:GetLayer() < b:GetLayer()
            end
            return a:GetBuildingId() < b:GetBuildingId()
        end
    )

    local buildingLoader = self:GetUIComponent("UISelectObjectPath", "Buildings")
    buildingLoader:SpawnObjects("UIActivityNPlusSixBuildingItem", #buildingDatas)
    local buildingItems = buildingLoader:GetAllSpawnList()
    for i = 1, #buildingItems do
        ---@type UIActivityNPlusSixBuildingItem
        local item = buildingItems[i]
        item:Refresh(buildingDatas[i])
    end

    --建筑名字标签
    local buildingNameLoader = self:GetUIComponent("UISelectObjectPath", "BuildingNames")
    buildingNameLoader:SpawnObjects("UIActivityNPlusSixBuildingItemName", #buildingDatas)
    local buildingItems = buildingNameLoader:GetAllSpawnList()
    for i = 1, #buildingItems do
        ---@type UIActivityNPlusSixBuildingItemName
        local item = buildingItems[i]
        item:Refresh(buildingDatas[i])
    end

    --创建完成后的Spine
    local cfgs = Cfg.cfg_component_build_item_extra {}
    if not cfgs then
        return
    end

    local parent = self:GetUIComponent("Transform", "Buildings")

    local findChildIndexInTrans = function(tran)
        for i = 0, parent.childCount - 1 do
            if parent:GetChild(i) == tran then
                return i
            end
        end
        return nil
    end

    local findInserIndex = function(layer)
        for i = 1, #buildingItems do
            local buildingData = buildingItems[i]._buildingData
            if layer < buildingData:GetLayer() then
                return findChildIndexInTrans(buildingItems[i]._go.transform)
            end
        end
        return nil
    end

    self._completeSpineLoader:SpawnObjects("UIActivityNPlusSixBuildingSpine", #cfgs)

    local items = self._completeSpineLoader:GetAllSpawnList()
    for i = 1, #cfgs do
        items[i]:Refresh(parent, cfgs[i])
        local index = findInserIndex(cfgs[i].Layer)
        if index then
            items[i]._tran:SetSiblingIndex(index)
        end
    end
end

function UIActivityNPlusSixBuildingMainController:BuildingAllBuildingComplete()
    self:RefreshBg()
end

---@param buildingData UIActivityNPlusSixBuildingData
function UIActivityNPlusSixBuildingMainController:PlayBuildingCompleteEffect(buildingData)
    local isComplete = self._buildingDatas:IsAllBuildingComplete()
    local finishEffect = self:GetGameObject("FinishEffect")
    if isComplete then
        if finishEffect then
            finishEffect:SetActive(true)
        end
    else
        if finishEffect then
            finishEffect:SetActive(false)
        end
    end

    local buildingLoader = self:GetUIComponent("UISelectObjectPath", "Buildings")
    local buildingItems = buildingLoader:GetAllSpawnList()
    for i = 1, #buildingItems do
        ---@type UIActivityNPlusSixBuildingItem
        local item = buildingItems[i]
        if item._buildingData == buildingData then
            item:PlayBuildingCompleteEffect()
            return
        end
    end
end

function UIActivityNPlusSixBuildingMainController:EventCompleteHandle()
    self:RefreshData()
    self._scoreLabel.text = self:GetItemCountStr(self._itemCount)
end

function UIActivityNPlusSixBuildingMainController:RefreshEvent()
    self:RefreshData()
    self._scoreLabel.text = self:GetItemCountStr(self._itemCount)
    self:RefreshEventData()
    self:RefreshEventUI()
end

function UIActivityNPlusSixBuildingMainController:RefreshEventUI()
    self._eventItemLoader:SpawnObjects("UIActivityNPlusSixEventItem", #self._eventDatas)
    local items = self._eventItemLoader:GetAllSpawnList()
    for i = 1, #items do
        ---@type UIActivityNPlusSixEventItem
        local item = items[i]
        item:Refresh(self._campaign, self._eventDatas[i])
    end
end

function UIActivityNPlusSixBuildingMainController:RebuildingRewardBtnOnClick()
    self:ShowDialog("UIActivityNPlusSixRewardController", self._buildingDatas)
end

function UIActivityNPlusSixBuildingMainController:ShowTips(itemId, pos)
    self._tips:SetData(itemId, pos)
end

function UIActivityNPlusSixBuildingMainController:CheckStory()
    local pstId = GameGlobal.GetModule(RoleModule):GetPstId()
    local firstEnterKey = "NP6FirstEnterRebuild_" .. pstId
    -- local firstEnterKey = "NP6FirstEnterRebuild_"
    if UnityEngine.PlayerPrefs.GetInt(firstEnterKey, 0) == 0 then
        if not self._buildComponentInfo.m_first_story_id then
            Log.exception("首次进入重建界面,但找不到剧情id")
        end
        --首次进入重建界面，播剧情
        --MSG30701	【需测试】首次进入装修界面需要支持播放第一个剧情		小开发任务-待开发	靳策, 1951	10/18/2021
        UnityEngine.PlayerPrefs.SetInt(firstEnterKey, 1)
        self:ShowDialog("UIStoryController", self._buildComponentInfo.m_first_story_id)
    else
        local storyList = self._buildingDatas:GetUnPlayStoryList()
        if storyList == nil or #storyList <= 0 then
            return
        end
        self:PlayStoryList(storyList)
    end
end

function UIActivityNPlusSixBuildingMainController:PlayStoryList(storyList)
    if table.count(storyList) <= 0 then
        return
    end
    local storyInfo = storyList[1]
    table.remove(storyList, 1)
    self:PlayStory(
        storyInfo,
        function()
            self:PlayStoryList(storyList)
        end
    )
end

function UIActivityNPlusSixBuildingMainController:PlayStory(storyInfo, callback)
    local storyType = storyInfo[1]
    local storyId = storyInfo[2]
    local curStatus = storyInfo[3]
    local buildingId = storyInfo[4]
    -- 1:纯局外立绘对话 2:通用的剧情形式 3:终端对话
    if storyType == 1 or storyType == 3 then
        self:ShowDialog(
            "UIStoryBanner",
            storyId,
            StoryBannerShowType.HalfPortrait,
            function()
                GameGlobal.TaskManager():StartTask(self.CompleteStory, self, curStatus, buildingId, callback)
            end
        )
    elseif storyType == 2 then
        self:ShowDialog(
            "UIStoryController",
            storyId,
            function()
                GameGlobal.TaskManager():StartTask(self.CompleteStory, self, curStatus, buildingId, callback)
            end
        )
    end
end

function UIActivityNPlusSixBuildingMainController:CompleteStory(TT, curStatus, buildingId, callback)
    self:Lock("UIActivityNPlusSixBuildingMainController_CompleteStory")
    local res = AsyncRequestRes:New()
    self._buildComponent:HandleStory(TT, res, buildingId, curStatus)
    self:UnLock("UIActivityNPlusSixBuildingMainController_CompleteStory")
    if callback then
        callback()
    end
end
