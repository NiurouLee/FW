---@class UITrailLevelDetail:UIController
_class("UITrailLevelDetail", UIController)
UITrailLevelDetail = UITrailLevelDetail

function UITrailLevelDetail:LoadDataOnEnter(TT, res, uiParams)
    ---@type TalePetModule
    self._talePetModule = GameGlobal.GetModule(TalePetModule)
    --请求编队数据编队
    self._talePetModule:RequestServerFormationList(TT)
    ---@type TeamsContext
    local ctx = self:GetModule(MissionModule):TeamCtx()
    ctx:InitTrailTeam(self._talePetModule:GetFormationList())
end

function UITrailLevelDetail:OnShow(uiParams)
    self:AttachEvent(GameEventType.ShowItemTips, self.ShowTips)
    local levelId = uiParams[1]

    -- MSG53060	（QA_李松岩）旧印QA_试用关可以试用所有光灵
    local talePetCfg = Cfg.cfg_tale_pet{PracticeLevelId = levelId}
    local cfg = talePetCfg and talePetCfg[1]
    if cfg then
        self:_InitTabBtnsInfo()
        self:_SetTabBtns()
        self:_SetTabSelect(cfg.Sort)
    end
    
    self:_Refresh(levelId)
end

function UITrailLevelDetail:OnHide()
    self:DetachEvent(GameEventType.ShowItemTips, self.ShowTips)
end

function UITrailLevelDetail:_Refresh(levelId)
    self._levelId = levelId
    self._levelBg1Img = self:GetUIComponent("RawImageLoader", "LevelBg1")
    self._levelBgGo = self:GetGameObject("LevelPanel")
    self._pet1Img = self:GetUIComponent("RawImageLoader", "Pet1")
    self._pet1Go = self:GetGameObject("Pet1")
    self._pet1Go:SetActive(false)
    self._pet2Img = self:GetUIComponent("RawImageLoader", "Pet2")
    self._petGo = self:GetGameObject("PetPanel")
    self._enemyMsg = self:GetUIComponent("UISelectObjectPath", "enemyMsg")
    local s = self:GetUIComponent("UISelectObjectPath", "itemTips")
    self._tips = s:SpawnObject("UISelectInfo")
    ---@type UIEnemyMsg
    local enemy = self._enemyMsg:SpawnObject("UIEnemyMsg")
    self._monsterNameLabel = self:GetUIComponent("UILocalizationText", "MonsterName")
    self._levelStatusGo = self:GetGameObject("LevelStatus")
    self._btnPlot = self:GetGameObject("BtnPlot")
    self._mask = self:GetGameObject("Mask")
    self._mask:SetActive(false)

    local cfg = Cfg.cfg_tale_stage[self._levelId]
    enemy:SetData(cfg.FightLevelid)
    self:InitAwards(cfg.FirstDropId)
    if cfg.Type == 1 then --练习关卡
        self._levelBgGo:SetActive(false)
        self._petGo:SetActive(true)
        -- self._pet1Img:LoadImage(cfg.LevelBg)
        self._pet2Img:LoadImage(cfg.LevelBg)
    else --试炼关卡
        self._levelBgGo:SetActive(true)
        self._petGo:SetActive(false)
        self._levelBg1Img:LoadImage(cfg.LevelBg)
        self._monsterNameLabel.text = StringTable.Get(cfg.MonsterName)
        self._levelStatusGo:SetActive(self._talePetModule:HasCompletLevel(self._levelId))
    end
    self:RefreshPlotBtnStatus()
end

function UITrailLevelDetail:RefreshPlotBtnStatus()
    if not self._talePetModule:HasCompletLevel(self._levelId) then
        self._btnPlot:SetActive(false)
        return
    end

    ---@type MissionModule
    local mission = GameGlobal.GetModule(MissionModule)
    local afterFightStory = mission:GetStoryByStageIdStoryType(self._levelId, StoryTriggerType.AfterFight)
    local beforeFightStory = mission:GetStoryByStageIdStoryType(self._levelId, StoryTriggerType.BeforeFight)

    if afterFightStory ~= nil and afterFightStory > 0 then
        self._btnPlot:SetActive(true)
    elseif beforeFightStory ~= nil and beforeFightStory > 0 then
        self._btnPlot:SetActive(true)
    else
        self._btnPlot:SetActive(false)
    end
end

function UITrailLevelDetail:ShowTips(itemId, pos)
    self._tips:SetData(itemId, pos)
end

function UITrailLevelDetail:InitAwards(dropId)
    ---@type Award[]
    local awards = {}
    local normalArr = self:GetSortedArr(dropId)
    local hasCompleteLevel = self._talePetModule:HasCompletLevel(self._levelId)
    if normalArr then
        for i, v in ipairs(normalArr) do
            if hasCompleteLevel and v.type == StageAwardType.First then
                v:FlushType(StageAwardType.HasGen)
            end
            awards[#awards + 1] = v
        end
    end
    local count = table.count(awards)
    ---@type UISelectObjectPath
    local sop = self:GetUIComponent("UISelectObjectPath", "Content")
    sop:SpawnObjects("UIAwardItem", count)
    ---@type UIAwardItem[]
    local list = sop:GetAllSpawnList()
    for i, v in ipairs(list) do
        v:Flush(awards[i])
    end
end

function UITrailLevelDetail:GetSortedArr(dropId)
    local list = UICommonHelper:GetInstance():ParseDrop(dropId)
    local vecSort = SortedArray:New(Algorithm.COMPARE_CUSTOM, UIExtraMissionStageController._LessComparer)
    if list then
        for i, v in ipairs(list) do
            local award = Award:New()
            award:InitWithCount(v.ItemID, v.Count, v.Type)
            award:FlushType(StageAwardType.First)
            vecSort:Insert(award)
        end
    end
    return vecSort.elements
end

function UITrailLevelDetail:_InitTabBtnsInfo()
    self.talePets = self._talePetModule:GetActivityTalePet()

    self._tabBtnsInfo = {}
    for i = 1, #self.talePets do
        local cfg = Cfg.cfg_tale_pet[self.talePets[i].ID]
        table.insert(self._tabBtnsInfo, cfg)
    end
end

function UITrailLevelDetail:_SetTabBtns()
    ---@type UIHomelandShopTabBtn[]
    self._tabBtns = UIWidgetHelper.SpawnObjects(self, "_tabBtns", "UIActivityCommonTextTabBtn", #self._tabBtnsInfo)
    for i, v in ipairs(self._tabBtns) do
        local cfg_pet = Cfg.cfg_pet[self._tabBtnsInfo[i].ID]
        local name = cfg_pet and cfg_pet.Name
        local title = name and StringTable.Get(name) or ""
        v:SetData(
            i, -- 索引
            {
                indexWidgets = {}, -- 与索引相关的状态组
                onoffWidgets = {{"OnBtn"}, {"OffBtn"}}, -- 与是否选中相关的状态组 [1] = 选中 [2] = 非选中
                lockWidgets = {{"lock"}, {}}, --- 与是否锁定相关的状态组 [1] = 锁定 [2] = 正常
                titleWidgets = {"txtTitle_off", "txtTitle_on"}, -- 标题列表组
                titleText = title, -- 标题文字
                callback = function(index, isOffBtnClick) -- 点击按钮回调
                    if isOffBtnClick then
                        self:_SetTabSelect(index)
                    end
                end
            }
        )
    end
end

-- 刷新 tab
function UITrailLevelDetail:_SetTabSelect(index)
    if self._tabIndex == index then
        return
    end

    self._tabIndex = index
    for i = 1, #self._tabBtns do
        self._tabBtns[i]:SetSelected(i == index)
    end

    self:_Refresh(self._tabBtnsInfo[index].PracticeLevelId)
end

function UITrailLevelDetail:Close()
    self:CloseDialog()
end

function UITrailLevelDetail:MaskOnClick()
    self:Close()
end

function UITrailLevelDetail:btnFightOnClick(go)
    ---@type MissionModule
    local missiontModule = GameGlobal.GetModule(MissionModule)
    ---@type TeamsContext
    local ctx = missiontModule:TeamCtx()
    ctx:Init(TeamOpenerType.Trail, self._levelId)
    ctx:ShowDialogUITeams(false)
end

function UITrailLevelDetail:BtnPlotOnClick()
    ---@type MissionModule
    local mission = GameGlobal.GetModule(MissionModule)
    local afterFightStory = mission:GetStoryByStageIdStoryType(self._levelId, StoryTriggerType.AfterFight)
    local beforeFightStory = mission:GetStoryByStageIdStoryType(self._levelId, StoryTriggerType.BeforeFight)

    local storyIds = {}

    if beforeFightStory ~= nil and beforeFightStory > 0 then
        storyIds[#storyIds + 1] = beforeFightStory
    end

    if afterFightStory ~= nil and afterFightStory > 0 then
        storyIds[#storyIds + 1] = afterFightStory
    end

    if #storyIds <= 0 then
        return
    end

    self._mask:SetActive(true)

    self:PlayStory(storyIds, 1)
end

function UITrailLevelDetail:PlayStory(storyIds, index)
    if index > #storyIds then
        self._mask:SetActive(false)
        return
    end
    self:ShowDialog(
        "UIStoryController",
        storyIds[index],
        function()
            self:PlayStory(storyIds, index + 1)
        end
    )
end
