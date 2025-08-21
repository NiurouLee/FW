---@class UIBlackFightMain:UIController
_class("UIBlackFightMain", UIController)
UIBlackFightMain = UIBlackFightMain

function UIBlackFightMain:Constructor()
    local mCampaign = GameGlobal.GetModule(CampaignModule)
    self.data = mCampaign:GetN7BlackFightData()

    self.difficultyButtonUIData = {
        [BlackFightDifficulty.Light] = {pos = {44, 198}},
        [BlackFightDifficulty.Middle] = {pos = {0, 0}},
        [BlackFightDifficulty.Heavy] = {pos = {-41, -200}}
    }
end

---@param res AsyncRequestRes
function UIBlackFightMain:LoadDataOnEnter(TT, res, uiParams)
    self.data:RequestCampaign(TT)
    local c = self.data:GetComponentBlackFight()
    if (not c) or (not c:ComponentIsOpen()) then
        res:SetSucc(false)
        ToastManager.ShowToast(StringTable.Get("str_n7_black_figh_component_close_tips"))
        return
    end
    c:OnEnterBlackFist()
end

function UIBlackFightMain:OnShow(uiParams)
    self.difficulty = uiParams[1]
    self.showLevelDetails = uiParams[2]

    ---@type UnityEngine.Animation
    self.animation = self:GetGameObject():GetComponent("Animation")
    ---@type UnityEngine.MeshRenderer
    local mr = self:GetGameObject("imgB"):GetComponent("MeshRenderer")
    self.req = ResourceManager:GetInstance():SyncLoadAsset("n7_box_bg3" .. ".mat", LoadType.Mat)
    mr.material:SetTexture("_MainTex", self.req.Obj:GetTexture("_MainTex"))

    ---@type UICustomWidgetPool
    local btns = self:GetUIComponent("UISelectObjectPath", "btns")
    ---@type UICommonTopButton
    self._backBtns = btns:SpawnObject("UICommonTopButton")
    self._backBtns:SetData(
        function()
            if self.b.activeInHierarchy then
                self:StartTask(
                    function(TT)
                        local lockKey = "UIBlackFightMainbtnFightOnClick"
                        self:Lock(lockKey)
                        self:PlayAnimBtnsOut()
                        self.animation:Play("uieff_N7_BlackFight_Back")
                        YIELD(TT, 600)
                        self:FlushF()
                        self:UnLock(lockKey)
                    end
                )
            else
                self:SwitchState(UIStateType.UIActivityN7MainController)
            end
        end
    )
    ---@type RawImageLoader
    self.btnReputation = self:GetUIComponent("RawImageLoader", "btnReputation")
    ---@type UILocalizationText
    self.txtSalutation = self:GetUIComponent("UILocalizationText", "txtSalutation")
    ---@type UILocalizationText
    self.txtSalutationOL = self:GetUIComponent("UILocalizationText", "txtSalutationOL")
    ---@type UILocalizationText
    self.txtSalutationGlow = self:GetUIComponent("UILocalizationText", "txtSalutationGlow")
    self.f = self:GetGameObject("f")
    ---@type UILocalizationText
    self.txtResetTime = self:GetUIComponent("UILocalizationText", "txtResetTime")
    self.txtNotFightYet = self:GetGameObject("txtNotFightYet")
    self.maxReputation = self:GetGameObject("maxReputation")
    ---@type UILocalizationText
    self.txtMaxReputation = self:GetUIComponent("UILocalizationText", "txtMaxReputation")
    ---@type UILocalizationText
    self.txtMaxStage = self:GetUIComponent("UILocalizationText", "txtMaxStage")
    self.b = self:GetGameObject("b")
    self.b:SetActive(false)
    ---@type UICustomWidgetPool
    self.btnsDiff = self:GetUIComponent("UISelectObjectPath", "btnsDiff")

    local len = table.count(BlackFightDifficulty)
    self.btnsDiff:SpawnObjects("UIBlackFightMainBtn", len)
    ---@type UIBlackFightMainBtn[]
    local uis = self.btnsDiff:GetAllSpawnList()
    for i, ui in ipairs(uis) do
        local pos = self.difficultyButtonUIData[i].pos
        ui:Init(i, Vector2(pos[1], pos[2]))
    end

    self:RegisterTimeEvent()
    self:FlushF()
    self:CheckShowLevelDetails()
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N7EnterBoxing)
end

function UIBlackFightMain:OnHide()
    self.req = nil
    self:CancelTimerEvent()
end

function UIBlackFightMain:FlushF()
    self:FlushSalutation()
    self:FlushMaxReputation()
    self:FlushResetTime()
end
function UIBlackFightMain:FlushB()
    self:FlushReputations()
end

function UIBlackFightMain:FlushSalutation()
    local curSalutation = self.data:GetCurSalutation()
    if curSalutation then
        UIBlackFightMain.FlushTextColorOutline(
            curSalutation,
            self.txtSalutation,
            self.txtSalutationOL,
            self.txtSalutationGlow,
            self.btnReputation,
            1
        )
    end
end
---@param salutation BlackFightSalutationData
---@param txt UILocalizationText
---@param txtGlow UILocalizationText
---@param rawImg RawImageLoader
---@param rawType number 1 n7_box_belt ； 2 n7_prestige_reward_bg
function UIBlackFightMain.FlushTextColorOutline(salutation, txt, txtOL, txtGlow, rawImg, rawType)
    txt:SetText(salutation.salutation)
    txtOL:SetText(salutation.salutation)
    txtGlow:SetText(salutation.salutation)
    local cfg = Cfg.cfg_n7_black_fight_salutation()
    if cfg then
        local arr2color = function(arr)
            local color = Color.white
            if arr then
                color:Set(arr[1] / 255, arr[2] / 255, arr[3] / 255)
            end
            return color
        end
        for index, cfgv in pairs(cfg) do
            if salutation.reputation == cfgv.Reputation then
                txt.color = arr2color(cfgv.UI.colorSalutation)
                ---@type H3D.UGUI.CircleOutline[]
                local ols = {
                    txt.gameObject:GetComponent(typeof(H3D.UGUI.CircleOutline)),
                    txtOL.gameObject:GetComponent(typeof(H3D.UGUI.CircleOutline))
                }
                for i, ol in ipairs(ols) do
                    ol.effectColor = arr2color(cfgv.UI["colorOutline" .. i])
                end
                if rawType == 1 then
                    rawImg:LoadImage("n7_box_belt" .. cfgv.ID)
                else
                    rawImg:LoadImage("n7_prestige_reward_bg" .. cfgv.ID)
                end
                return
            end
        end
    end
end
function UIBlackFightMain:FlushMaxReputation()
    local diff, max = self.data:GetTodayMaxReputation()
    if max > 0 then
        self.txtNotFightYet:SetActive(false)
        self.maxReputation:SetActive(true)
        self.txtMaxStage.gameObject:SetActive(true)
        self.txtMaxReputation:SetText(max)
        local strDiff = StringTable.Get("str_n7_black_fight_level_" .. diff)
        local level, m = self.data:GetRoundInfoByDifficulty(diff)
        self.txtMaxStage:SetText(StringTable.Get("str_n7_black_fight_main_diff_level", strDiff, level))
    else
        self.txtNotFightYet:SetActive(true)
        self.maxReputation.gameObject:SetActive(false)
        self.txtMaxStage.gameObject:SetActive(false)
    end
end
function UIBlackFightMain:FlushResetTime()
    local resetTime = GameGlobal.GetModule(LoginModule):GetCampaignRefreshTime()
    local leftSeconds = UICommonHelper.CalcLeftSeconds(resetTime)
    if leftSeconds == 0 then --当过了重置时间，表示跨天了
        self:SwitchState(UIStateType.UIBlackFightMain)
        return
    end
    local d, h, m, s = UICommonHelper.S2DHMS(leftSeconds)
    if d >= 1 then
        self.txtResetTime:SetText(StringTable.Get("str_n7_black_fight_reset_d_h", math.floor(d), math.floor(h)))
    else
        if h >= 1 then
            self.txtResetTime:SetText(StringTable.Get("str_n7_black_fight_reset_h_m", math.floor(h), math.floor(m)))
        else
            if m >= 1 then
                self.txtResetTime:SetText(StringTable.Get("str_n7_black_fight_reset_m", math.floor(m)))
            else
                self.txtResetTime:SetText(StringTable.Get("str_n7_black_fight_reset_m", "<1"))
            end
        end
    end
end

function UIBlackFightMain:RegisterTimeEvent()
    self:CancelTimerEvent()
    self.te =
        GameGlobal.Timer():AddEventTimes(
        1000,
        TimerTriggerCount.Infinite,
        function()
            self:FlushResetTime()
        end
    )
end
function UIBlackFightMain:CancelTimerEvent()
    if self.te then
        GameGlobal.Timer():CancelEvent(self.te)
    end
end

function UIBlackFightMain:FlushReputations()
    ---@type UIBlackFightMainBtn[]
    local uis = self.btnsDiff:GetAllSpawnList()
    for i, ui in ipairs(uis) do
        ui:Flush()
    end
end
function UIBlackFightMain:PlayAnimBtnsIn()
    self:StartTask(
        function(TT)
            ---@type UIBlackFightMainBtn[]
            local uis = self.btnsDiff:GetAllSpawnList()
            local lockKey = "UIBlackFightMainPlayAnimBtnsIn"
            self:Lock(lockKey)
            for i, ui in ipairs(uis) do
                ui.offset:SetActive(true)
                ui:PlayAnimIn()
                if i < table.count(BlackFightDifficulty) then
                    YIELD(TT, 66.6)
                end
            end
            self:UnLock(lockKey)
        end,
        self
    )
end
function UIBlackFightMain:PlayAnimBtnsOut()
    self:StartTask(
        function(TT)
            local lockKey = "UIBlackFightMainPlayAnimBtnsOut"
            self:Lock(lockKey)
            ---@type UIBlackFightMainBtn[]
            local uis = self.btnsDiff:GetAllSpawnList()
            for i, ui in ipairs(uis) do
                ui:PlayAnimOut()
            end
            self:UnLock(lockKey)
        end,
        self
    )
end

--region OnClick
function UIBlackFightMain:btnFightOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N7ClickChallenge)
    self:StartTask(
        function(TT)
            local lockKey = "UIBlackFightMainbtnFightOnClick"
            self:Lock(lockKey)
            ---@type UIBlackFightMainBtn[]
            local uis = self.btnsDiff:GetAllSpawnList()
            for i, ui in ipairs(uis) do
                ui.offset:SetActive(false)
            end
            self.animation:Play("uieff_N7_BlackFight_Click")
            YIELD(TT, 567)
            self:FlushB()
            self:PlayAnimBtnsIn()
            YIELD(TT, 400)
            self:UnLock(lockKey)
        end
    )
end

function UIBlackFightMain:btnReputationOnClick(go)
    self:ShowDialog("UIBlackFightReputation")
end

--endregion
function UIBlackFightMain:CheckShowLevelDetails()
    if self.showLevelDetails then
        self:ShowDialog("UIN7LevelDetailsController", self.difficulty)
    end
end
