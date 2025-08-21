---@class UIN28AVGStoryOption:UICustomWidget
---@field _uis  UIN28AVGStoryOption[]
_class("UIN28AVGStoryOption", UICustomWidget)
UIN28AVGStoryOption = UIN28AVGStoryOption

function UIN28AVGStoryOption:Constructor()
    self.mCampaign = GameGlobal.GetModule(CampaignModule)
    self.data = self.mCampaign:GetN28AVGData()
    self.animNames = {
        "uieff_UIN28AVGStoryOption_in", --1
        "uieff_UIN28AVGStoryOption_lock",
        "uieff_UIN28AVGStoryOption_out", --6
    }
    self.taskIdChangePos = 0
    self.taskId = 0
end

function UIN28AVGStoryOption:OnShow()
    ---@type UnityEngine.Animation
    self.anim = self:GetUIComponent("Animation", "anim")
    ---@type UnityEngine.RectTransform
    self.rt = self:GetGameObject():GetComponent(typeof(UnityEngine.RectTransform))
    UICommonHelper:GetInstance():RectTransformAnchor2Center(self.rt)
    self.rt.gameObject:SetActive(false)
    self.normal = self:GetGameObject("normal")
    self.lock = self:GetGameObject("lock")
    ---@type UnityEngine.RectTransform
    self.rtNormal = self:GetUIComponent("RectTransform", "normal")
    ---@type UnityEngine.RectTransform
    self.rtLock = self:GetUIComponent("RectTransform", "lock")
    --self.imgSelected = self:GetGameObject("imgSelected")
    --self.imgNotSelected = self:GetGameObject("imgNotSelected")
    ---@type UILocalizationText
    self.txtOption = self:GetUIComponent("UILocalizationText", "txtOption")
    ---@type UILocalizationText
    self.txtUnlockCondition = self:GetUIComponent("UILocalizationText", "txtUnlockCondition")
    self.isShowUnlock = false
    self:AttachEvent(GameEventType.AVGShowHideOptionInfluence, self.AVGShowHideOptionInfluence)
end

function UIN28AVGStoryOption:OnHide()
    self.anim = nil
    self.option = nil
    self.taskIdChangePos = 0
    self.taskId = 0
    self:DetachEvent(GameEventType.AVGShowHideOptionInfluence, self.AVGShowHideOptionInfluence)
end

---@param option N28AVGStoryOption 选项
---@param uis UIN28AVGStoryOption
function UIN28AVGStoryOption:Flush(option, len, callback, uis)
    self.option = option
    self.optionLen = len
    self.callback = callback
    self._uis = uis

    if option:IsSatisfyUnlock() then
        if option:IsSelected() then
            self.txtOption.color = Color(245 / 255, 93 / 255, 148 / 255, 1)
        else
            self.txtOption.color = Color(93 / 255, 94 / 255, 105 / 255, 1)
        end
        self.txtOption:SetText(option:Content())
    end
    self.txtUnlockCondition:SetText(option.unlockConditionDesc)
    --位置
    self:PlayAnimChangePos()
end

function UIN28AVGStoryOption:BtnOnClick(go)
    if not self.option:IsSatisfyUnlock() then
        return
    end
    for i, ui in ipairs(self._uis) do
        if i == self.option.index then
            self:PlayAnimClick(self.callback) -- 播放点击动效
        else
            ui:PlayAnimOut() -- 通知其他按钮播放退出动效
        end
    end
end

function UIN28AVGStoryOption:GetPos()
    local posTarget = self.data.optionPos[self.option.index] or Vector2.zero
    return posTarget
end
function UIN28AVGStoryOption:ResetRectTransform()
    self.rtNormal.anchoredPosition = Vector2.zero
    self.rtLock.anchoredPosition = Vector2.zero
end

--region Anim
function UIN28AVGStoryOption:AVGShowHideOptionInfluence(isShowInfluence, first)
    if isShowInfluence then
        self:PlayAnimOut()
    else
        self:PlayAnimIn(first)
    end
end
function UIN28AVGStoryOption:GetState(first)
    if not self.option then
        return
    end
    local state = 0
    if self.option:IsSatisfyUnlock() then
        if self.option:HasCondition() then
            state = 2
        else
            state = 1
        end
    else
        state = 3
    end
    if first then
        self.normal:SetActive(state == 1 or state == 2)
        self.lock:SetActive(state == 3 or state == 2)
    end
    return state
end
function UIN28AVGStoryOption:PlayAnimChangePos()
    if self.taskIdChangePos > 0 then
        GameGlobal.TaskManager():KillTask(self.taskIdChangePos)
    end
    self.taskIdChangePos =
        self:StartTask(
        function(TT)
            local key = "PlayAnimChangePos" .. self.option.index
            self:Lock(key)
            local posTarget = self:GetPos()
            local duration = 0.222
            local delay = (self.optionLen - self.option.index + 1) * 0.1
            self.rt.gameObject:SetActive(false)
            self.rt.anchoredPosition = posTarget
            -- self.rt:DOAnchorPos(posTarget, duration):SetDelay(delay):OnStart(
            --     function()
            --         self.rt.gameObject:SetActive(true)
            --         self:AVGShowHideOptionInfluence(false)
            --     end
            -- )
            YIELD(TT, delay * 1000)
            self.rt.gameObject:SetActive(true)
            self:AVGShowHideOptionInfluence(false, true)
            self.taskIdChangePos = 0
            self:UnLock(key)
        end,
        self
    )
end
function UIN28AVGStoryOption:PlayAnimIn(first)
    if not self.anim then
        return
    end
    self:ResetRectTransform()
    if self.taskId > 0 then
        GameGlobal.TaskManager():KillTask(self.taskId)
    end
    self.taskId =
        self:StartTask(
        function(TT)
            self:StopAnim()
            local state = self:GetState(first)
            local animId = (state == 2 and first) and state or 1
            local animName = self.animNames[animId]
           --self.isShowUnlock = state == 2
            self.anim:Play(animName)
            YIELD(TT, 833)
            self.taskId = 0
            if state == 2 then
                self.lock:SetActive(false)
            end
            --self:PlayAnimLoop()
        end,
        self
    )
end
-- function UIN28AVGStoryOption:PlayAnimLoop()
--     if not self.anim then
--         return
--     end
--     local offset = math.random(1, 3)
--     local state = self:GetState() + offset
--     self.anim:Play(self.animNames[state])
-- end
function UIN28AVGStoryOption:PlayAnimOut()
    if not self.anim then
        return
    end
    self:GetState()
    self:StopAnim()
    self.anim:Play(self.animNames[3])
end
function UIN28AVGStoryOption:StopAnim()
    if not self.anim then
        return
    end
    for index, animName in ipairs(self.animNames) do
        ---@type UnityEngine.AnimationState
        local state = self.anim:get_Item(animName)
        if state then
            state.normalizedTime = 0
        end
    end
    self.anim:Stop()
end
function UIN28AVGStoryOption:PlayAnimClick(callback)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.SoundStoryClick)
    UIWidgetHelper.PlayAnimation(self, "anim", "uieff_UIN28AVGStoryOption_click", 400, callback)
end
--endregion
