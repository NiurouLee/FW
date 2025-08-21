---@class UIActivityN6ReviewEventItem : UICustomWidget
_class("UIActivityN6ReviewEventItem", UICustomWidget)
UIActivityN6ReviewEventItem = UIActivityN6ReviewEventItem

function UIActivityN6ReviewEventItem:OnShow()
    self._go = self:GetGameObject("Go")
    self._tran = self:GetUIComponent("RectTransform", "Go")
    self._btnTran = self:GetUIComponent("RectTransform", "Btn")
    self._spineLoader = self:GetUIComponent("SpineLoader", "Spine")
    self._selectEffect = self:GetGameObject("SelectEffect")
    self:HideSelectEffect()
    self:AttachEvent(GameEventType.NPlusSixEventInfoItemClick, self.OnEventInfoItemClick)
    self._isPlayEffect = false
end

function UIActivityN6ReviewEventItem:OnHide()
    self:DetachEvent(GameEventType.NPlusSixEventInfoItemClick, self.OnEventInfoItemClick)
    if self._timerHandler then
        GameGlobal.Timer():CancelEvent(self._timerHandler)
        self._timerHandler = nil
    end
end

function UIActivityN6ReviewEventItem:OnEventInfoItemClick(eventId)
    if not self._eventData then
        return
    end
    if eventId == self._eventData:GetEventId() then
        self:ShowSelectEffect()
    else
        self:HideSelectEffect()
    end
end

function UIActivityN6ReviewEventItem:HideSelectEffect()
    self._selectEffect:SetActive(false)
end

function UIActivityN6ReviewEventItem:ShowSelectEffect()
    self._selectEffect:SetActive(true)
end

---@param eventData UIActivityNPlusSixEventData
function UIActivityN6ReviewEventItem:Refresh(campaign, eventData)
    self._campaign = campaign
    ---@type CCampaingN6
    self._localProcess = self._campaign:GetLocalProcess()
    ---@type CampaignBuildComponent
    self._buildComponent = self._localProcess:GetComponent(ECampaignReviewN6ComponentID.BUILD)
    ---@type BuildComponentInfo
    self._buildComponentInfo = self._localProcess:GetComponentInfo(ECampaignReviewN6ComponentID.BUILD)
    ---@type UIActivityNPlusSixEventData
    self._eventData = eventData
    if not self._eventData then
        self._go:SetActive(false)
        return
    end
    self._go:SetActive(true)
    self._tran.anchoredPosition = Vector2(self._eventData:GetPosX(), self._eventData:GetPosY())
    self._btnTran.sizeDelta = Vector2(self._eventData:GetTriggerAreaWidth(), self._eventData:GetTriggerAreaHeight())
    self._btnTran.anchoredPosition = Vector2(self._eventData:GetTriggerAreaPosX(), self._eventData:GetTriggerAreaPosY())
    self._spineLoader:LoadSpine(self._eventData:GetSpineName())
    self._spineLoader:SetAnimation(0, self._eventData:GetIdleAnimName(), true)
    self:PlayIdleEffect()
end

function UIActivityN6ReviewEventItem:PlayIdleEffect()
    if self._isPlayEffect then
        return
    end
    self._isPlayEffect = true

    if self._timerHandler then
        GameGlobal.Timer():CancelEvent(self._timerHandler)
        self._timerHandler = nil
    end

    local go = self:GetGameObject("Spine")
    ---@type Spine.Unity.SkeletonGraphic spine骨骼
    local spineSke = go:GetComponentInChildren(typeof(Spine.Unity.SkeletonGraphic))
    spineSke.material:SetColor("_Black", Color(0, 0, 0, 0))

    local isStageOne = true
    local timer = 0
    --第一段
    local startValue1 = 0
    local endValue1 = 0.7
    local length1 = 1.5
    local speed1 = (endValue1 - startValue1) / length1
    --第二段
    local startValue2 = 0.7
    local endValue2 = 0
    local length2 = 1.5
    local speed2 = (endValue2 - startValue2) / length2

    self._timerHandler =  GameGlobal.Timer():AddEventTimes(0, TimerTriggerCount.Infinite,
        function()
            timer = timer + UnityEngine.Time.deltaTime
            local value = 0
            if isStageOne then
                value = startValue1 + timer * speed1
            else
                value = startValue2 + timer * speed2
            end
            spineSke.material:SetColor("_Black", Color(value, value, value, 0))

            if isStageOne then
                if timer > length1 then
                    isStageOne = false
                    timer = 0
                end
            else
                if timer > length2 then
                    isStageOne = true
                    timer = 0
                end
            end
        end
    )
end

function UIActivityN6ReviewEventItem:BtnOnClick()
    GameGlobal.TaskManager():StartTask(self.HandleEvent, self)
end

function UIActivityN6ReviewEventItem:HandleEvent(TT)
    self:Lock("UIActivityN6ReviewEventItem_HandleEvent")
    ---@type BuildComponentInfo
    local componetInfo = self._buildComponent:ComponentInfo()
    --今日完成的事件总数
    local num = componetInfo.event_info.today_complete_event_num
    local componentId = self._buildComponent:GetComponentCfgId(self._campaign._id, componetInfo.m_component_id)
    local cfg = Cfg.cfg_component_bulid_event_extra[componentId]
    if cfg and cfg.DayMaxEventNum then
        if num >= cfg.DayMaxEventNum then
            ToastManager.ShowToast(StringTable.Get("str_n_plus_six_today_event_num_reach_max"))
            self:UnLock("UIActivityN6ReviewEventItem_HandleEvent")
            return
        end
    end
    local res = AsyncRequestRes:New()
    ---@type AsyncRequestRes
    local result = self._buildComponent:HandleCompleteEvent(TT, res, self._eventData:GetEventId())
    if result:GetSucc() then
        AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N6RandomItemDisapper)
        local completeName = self._eventData:GetCompleteAnimName()
        if completeName and completeName ~= "" then
            self._spineLoader:SetAnimation(0, completeName, false)
            YIELD(TT, self._eventData:GetCompleteAnimLength())
        end
        self:ShowDialog("UIActivityNPlusSixEventCompleteController", self._eventData)
        self._isPlayEffect = false
        self._go:SetActive(false)
        GameGlobal.EventDispatcher():Dispatch(GameEventType.NPlusSixEventComplete)
    else
        Log.error("HandleCompleteEvent error")
    end
    self:UnLock("UIActivityN6ReviewEventItem_HandleEvent")
end
