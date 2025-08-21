--[[
    风船行为，随机剧情触发
]]
---@class AirAction_RS_Look:AirActionBase
_class("AirAction_RS_Look", AirActionBase)
AirAction_RS_Look = AirAction_RS_Look

function AirAction_RS_Look:Constructor(pet, main, storyid, gotReward, gotAffinity)
    ---@type AircraftPet
    self._pet = pet

    Log.debug("###[AirAction_RS_Look] 触发一个随机剧情-id-->", self._pet:TemplateID())

    ---@type AircraftMain
    self._main = main

    self._storyid = storyid

    self._gotReward = gotReward
    self._gotAffinity = gotAffinity

    local cfg = Cfg.cfg_aircraft_pet_stroy_refresh[self._storyid]
    if not cfg then
        Log.error("###[AirAction_RS_Look] cfg_aircraft_pet_stroy_refresh is nil ! id --> ", self._storyid)
        return
    end
    local cfg_pet_story = Cfg.cfg_pet_story[storyid]
    if not cfg_pet_story then
        Log.error("###[AirAction_RS_Look] cfg_pet_story is nil ! id --> ", storyid)
        return
    end

    --故事id
    self._storyEventID = cfg_pet_story.StoryID
    --触发类型
    self._triggerType = cfg.TriggerType
    --随机事件点击表现（用的点击库）
    self._clickShowID = cfg.ClickShowID
    --如果配了点击表现，多少毫秒之后进剧情
    self._afterClickTime = cfg.AfterClick
    --运镜时间
    self._startRandomStoryTimeOut = 1200

    self._startTime = 0
end

--随机事件被点击了
function AirAction_RS_Look:Start()
    self._running = true
    Log.debug("###[AirAction_RS_Look] click story test --> start trigger")
end

function AirAction_RS_Look:ReadyPlayStory()
    if self._gotReward then
        Log.debug("###[AirAction_RS_Look] click story test --> trigger req succ")
        if self._clickShowID then
            --开始计时
            self._startTalk = true
            self:ClickShow()
        else
            --看剧情
            self:OpenStroyDialog()
        end
    else
        GameGlobal.TaskManager():StartTask(self.OnReadyPlayStory, self)
    end
end

function AirAction_RS_Look:OnReadyPlayStory(TT)
    Log.debug("###[AirAction_RS_Look] click story test --> trigger req")

    ---@type PetModule
    local petModule = GameGlobal.GetModule(PetModule)
    local res = petModule:RequestPetViewTriggeredStory(TT, self._pet:PstID(), self._triggerType, self._storyid)
    if res:GetSucc() then
        Log.debug("###[AirAction_RS_Look]click story test --> trigger req succ")
        if self._clickShowID then
            --开始计时
            self._startTalk = true
            self:ClickShow()
        else
            --看剧情
            self:OpenStroyDialog()
        end
    else
        Log.error("AirAction_RS_Look:OnReadyPlayStory-->res:GetResult()-->" .. res:GetResult())
        local errorMsg = petModule:GetErrorMsg(res:GetResult())
        ToastManager.ShowToast(errorMsg)
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftUILock, false, "ReadyPlayStory")

        Log.error(res:GetResult())
    end
end

function AirAction_RS_Look:ClickShow()
    local cfg = Cfg.cfg_aircraft_click_action_lib[self._clickShowID]
    if cfg then
        --喊话
        local sentence = cfg.Sentence
        --气泡
        local bubble = cfg.Bubble
        --动作
        local anim = cfg.Anim
        --声音
        local audio = cfg.Audio

        local skinList = cfg.SkinID
        local currSkinID = self._pet:ClothSkinID()
        local _playIdx = 0
        if skinList then
            for i = 1, #skinList do
                local skinid = skinList[i]
                if skinid == currSkinID then
                    _playIdx = i
                    break
                end
            end
        end

        local playIdx = _playIdx + 1

        local sentenceTex = nil
        --开一个喊话action
        if sentence then
            sentenceTex = sentence[playIdx]
        else
            if audio then
                local cfg_voice = AudioHelperController.GetCfgAudio(audio[playIdx])
                sentenceTex = cfg_voice.Content
            end
        end
        if sentenceTex ~= nil then
            local sentenceAction = AirActionSentence:New(self._pet, sentenceTex, self._main)
            self._pet:StartSentenceAction(sentenceAction)
        end
        --加载气泡要不要使用faceaction
        if bubble then
            local faceAction = AirActionFace:New(self._pet, bubble[playIdx])
            self._pet:StartViceAction(faceAction)
        end
        if anim then
            local animationAction = AirAnimationAction:New(self._pet, anim[playIdx])
            self._pet:StartViceAction(animationAction)
        end
        if audio then
            ---@type PetAudioModule
            local audioModule = GameGlobal.GetModule(PetAudioModule)
            audioModule:PlayAudio(audio[playIdx])
        end
    else
        Log.error("###[AirAction_RS_Look]cfg_aircraft_click_action_lib is nil ! id --> ", self._clickShowID)
    end
end

--看完剧情
function AirAction_RS_Look:EndStoryDialog()
    Log.debug("###[AirAction_RS_Look] click story test --> end story")

    GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftUILock, true, "EndStoryDialog")

    GameGlobal.EventDispatcher():Dispatch(GameEventType.RandomStoryStartOrEnd, false, 0)

    self._main:LookRandomStoryCameraAnimStart(false, 0)

    if self._gotReward then
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftUILock, false, "EndStoryDialog")
        self:OnStoryFinished(self._gotReward, self._gotAffinity)
    else
        GameGlobal.TaskManager():StartTask(
            function(TT)
                ---@type PetModule
                local petModule = GameGlobal.GetModule(PetModule)
                local pstid = self._pet:PstID()
                ---@type AsyncRequestRes
                local res, replay = petModule:RequestPetFinishTriggeredStory(TT, pstid, self._triggerType, self._storyid)
                GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftUILock, false, "EndStoryDialog")

                if res:GetSucc() then
                    self:OnStoryFinished(replay.reward, replay.affinity)
                    Log.debug("###[AirAction_RS_Look] story Look end")
                else
                    Log.error(res:GetResult())
                end
            end,
            self
        )
    end
end

--剧情结束动画 靳策添加
function AirAction_RS_Look:OnStoryFinished(award, affinity)
    local tip = nil
    if affinity and affinity > 0 then
        local petData = GameGlobal.GetModule(PetModule):GetPetByTemplateId(self._pet:TemplateID())
        local maxLevel = petData:GetPetAffinityMaxLevel()
        local level = petData:GetPetAffinityLevel()
        if level == self._maxLevel then
            tip = StringTable.Get("str_aircraft_room_affinity_add_value_max")
        else
            local petName = StringTable.Get(petData:GetPetName())
            tip = string.format(StringTable.Get("str_aircraft_room_pet_affinity_add_value"), petName, affinity)
        end
    end

    local anim =
        AircraftAffinityAnim:New(
            self._pet:GameObject(),
            award,
            tip,
            function()
                if not self._running then
                    return
                end
                Log.debug("11关闭获得物品动画")
                self:Close()
            end
        )
    anim:Play()
end

function AirAction_RS_Look:OpenStroyDialog()
    Log.debug("###[AirAction_RS_Look] click story test --> trigger and open story")

    GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftUILock, false, "ReadyPlayStory")

    GameGlobal.EventDispatcher():Dispatch(GameEventType.RandomStoryStartOrEnd, true, self._startRandomStoryTimeOut)

    --运镜
    self._main:LookRandomStoryCameraAnimStart(true, self._startRandomStoryTimeOut)

    self._startRandomStory = true
end

function AirAction_RS_Look:ShowStoryDialog()
    Log.debug("###[AirAction_RS_Look] click story test --> show story")

    GameGlobal.UIStateManager():ShowDialog(
        "UIStoryController",
        self._storyEventID,
        function()
            self:EndStoryDialog()
        end
    )
end

--如果规定时间内没被点击，取消随机事件
function AirAction_RS_Look:Update(deltaTimeMS)
    if self._running then
        if self._startTalk then
            self._startTime = self._startTime + deltaTimeMS

            if self._startTime >= self._afterClickTime then
                self._startTalk = false
                self._startTime = 0
                self:OpenStroyDialog()
            end
        end

        if self._startRandomStory then
            self._startTime = self._startTime + deltaTimeMS

            if self._startTime >= self._startRandomStoryTimeOut then
                self._startRandomStory = false
                self._startTime = 0
                self:ShowStoryDialog()
            end
        end
    end
end

function AirAction_RS_Look:Close()
    self._main:RemoveOneRandomEvent(self._storyid)

    self:Stop()
end

function AirAction_RS_Look:IsOver()
    return not self._running
end

function AirAction_RS_Look:Stop()
    self._running = false
end
