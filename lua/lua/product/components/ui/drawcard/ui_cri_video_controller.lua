---@class UICriVideoController:UIController
_class("UICriVideoController", UIController)
UICriVideoController = UICriVideoController

local VideoPlayerStatus = {
    Stop = "Stop",
    Dechead = "Dechead",
    WaitPrep = "WaitPrep",
    Prep = "Prep",
    Ready = "Ready",
    Playing = "Playing",
    PlayEnd = "PlayEnd",
    Error = "Error",
    StopProcessing = "StopProcessing"
}
_enum("VideoPlayerStatus", VideoPlayerStatus)

function UICriVideoController:OnShow(uiParams)
    self.uiParams = uiParams
    self:_GetComponents()
    self:_OnValue()
    self:PlayAudio()
end

function UICriVideoController:_GetComponents()
    self._playVideoScreenObj = self:GetGameObject("PlayVideo")
    self._videoPlayerObj = self:GetGameObject("VideoPlayer")
    self._skipAudioObj = self:GetGameObject("SkipAudioBtn")
    self._subTitle = self:GetGameObject("Subtitle")
    self._videoSubtitleText = self._subTitle:GetComponent("UILocalizationText")
    self._bgRawImage = self:GetUIComponent("RawImageLoader", "BgRawImage")
    self._bgRawImageObj = self:GetGameObject("BgRawImage")

    self._isPauseAudio = false
    self._isShowSkipBtn = false
    self._subTitledArray = {}

    self._twoSide = self:GetGameObject("TwoSides")
    self._leftImage = self:GetUIComponent("RawImageLoader", "Left")
    self._rightImage = self:GetUIComponent("RawImageLoader", "Right")
end

function UICriVideoController:_OnValue()
    self.videoName = self.uiParams[1]
    self.videoBgRawImageName = self.uiParams[2] --两个边时 这个值是左边
    self.closeCallback = self.uiParams[3]
    local rightVideoBg = self.uiParams[4]       --视频播放支持两个黑边 传入第4个参数说明有两个黑边
    if rightVideoBg then
        self._bgRawImage.gameObject:SetActive(false)
        self._twoSide:SetActive(true)
        self._leftImage:LoadImage(self.videoBgRawImageName)
        self._rightImage:LoadImage(rightVideoBg)
    else
        self._twoSide:SetActive(false)
        if self.videoBgRawImageName then
            self._bgRawImage.gameObject:SetActive(true)
            self._bgRawImage:LoadImage(self.videoBgRawImageName)
        else
            --默认背景
            self._bgRawImage.gameObject:SetActive(false)
        end
    end
end

function UICriVideoController:PlayAudio()
    self._playVideoScreenObj:SetActive(true)
    if self._videoPlayer == nil then
        ---@type CriWare.CriManaMovieControllerForUI
        self._videoPlayer = self._videoPlayerObj:GetComponent(typeof(CriWare.CriManaMovieControllerForUI))
        if not self._videoPlayer then
            self._videoPlayer = self._videoPlayerObj:AddComponent(typeof(CriWare.CriManaMovieControllerForUI))
        end
        local path = ResourceManager:GetInstance():GetAssetPath(self.videoName .. ".usme", LoadType.ADX2Audio, true)
        self._videoPlayer.moviePath = path
        self._videoPlayer.playOnStart = false
        self._videoPlayer.loop = false
    end

    if self._videoPlayerObj.activeSelf == false then
        self._videoPlayerObj:SetActive(true)
    end

    self._prepareVideTask = TaskManager:GetInstance():StartTask(
        function(TT)
            while not self._videoPlayerObj.activeInHierarchy do
                YIELD(TT)
            end
            self._subTitle:SetActive(true)
            while not self._videoPlayer.IsMonoBehaviourStartCalled do
                YIELD(TT)
            end
            while not self._subTitle.activeInHierarchy do
                YIELD(TT)
            end

            local nValue = math.ceil(Mathf.Log(self:GetLanguageKey(), 2))
            self._videoPlayer.player:SetSubtitleChannel(nValue)
            self._videoPlayer.player.OnSubtitleChanged =
                self._videoPlayer.player.OnSubtitleChanged + function(subtitleBuffer)
                    local content = LoginLuaHelper.GetOpVideoText(subtitleBuffer, self._videoPlayer.player.subtitleSize)
                    self._videoSubtitleText:SetText(content)
                end
            self._videoPlayer:Play()
            self.originBGM = AudioHelperController.GetCurrentBgm()
            AudioHelperController.StopBGM()
            self._waitPlayAudioTask = self:StartTask(self.WaitPlayAudio, self)
        end
    )
end

function UICriVideoController:OnHide()
    if self._prepareVideTask ~= nil then
        GameGlobal.TaskManager():KillTask(self._prepareVideTask)
        self._prepareVideTask = nil
    end
    if self._waitPlayAudioTask ~= nil then
        GameGlobal.TaskManager():KillTask(self._waitPlayAudioTask)
        self._waitPlayAudioTask = nil
    end
    if self._delayHideJumpBtnTask ~= nil then
        GameGlobal.TaskManager():KillTask(self._delayHideJumpBtnTask)
        self._delayHideJumpBtnTask = nil
    end
    if self.showBGTask ~= nil then
        GameGlobal.TaskManager():KillTask(self.showBGTask)
        self.showBGTask = nil
    end
    if self.closeCallback then
        self.closeCallback()
    end
    AudioHelperController.PlayBGM(self.originBGM, AudioConstValue.BGMCrossFadeTime)
end

function UICriVideoController:GetLanguageKey()
    local ls = {
        [1 << 0] = LanguageType.zh,  --简体中文
        [1 << 1] = LanguageType.tw,  --繁体中文
        [1 << 2] = LanguageType.us,  --英文
        [1 << 3] = LanguageType.kr,  --韩文
        [1 << 4] = LanguageType.jp,  --日文
        [1 << 5] = LanguageType.pt,  --葡萄牙语
        [1 << 6] = LanguageType.es,  --西班牙语
        [1 << 7] = LanguageType.idn, --印尼语
        [1 << 8] = LanguageType.th   --泰语
    }
    local languageType = Localization.GetCurLanguage()
    local languageIndex = 0
    for k, v in pairs(ls) do
        if languageType == v then
            languageIndex = k
            break
        end
    end
    return languageIndex
end

function UICriVideoController:WaitPlayAudio(TT)
    local bEndPlay = false
    while true do
        local currentVideoStatus = tostring(self._videoPlayer.player.status)
        if self._isPauseAudio then
            YIELD(TT)
        end
        if currentVideoStatus == VideoPlayerStatus.Playing then
            YIELD(TT)
            if not self.showBg then
                self.showBg = true
                self.showBGTask = self:StartTask(function(_TT)
                    YIELD(_TT, 100)
                    self._bgRawImageObj:SetActive(true)
                    self.showBGTask = nil
                end)
            end
        elseif currentVideoStatus == VideoPlayerStatus.Dechead then
            YIELD(TT)
        elseif currentVideoStatus == VideoPlayerStatus.WaitPrep then
            YIELD(TT)
        elseif currentVideoStatus == VideoPlayerStatus.Prep then
            YIELD(TT)
        elseif currentVideoStatus == VideoPlayerStatus.Ready then
            YIELD(TT)
        else
            Log.debug("WaitPlayAudio bEndPlay", self._videoPlayer.player.status)
            bEndPlay = true
        end

        if bEndPlay then
            break
        end
    end
    Log.debug("WaitPlayAudio Stop", self._videoPlayer.player.status)
    self._videoPlayer:Stop()
    self:PlayAudioComplete()
end

function UICriVideoController:PauseAudio()
    self._videoPlayer:Pause(true)
    self._isPauseAudio = true
end

function UICriVideoController:ResumeAudio()
    self._isPauseAudio = false
    self._videoPlayer:Pause(false)
end

function UICriVideoController:SkipAudio()
    self._isPauseAudio = false
    self._videoPlayer:Stop()
    self:CloseDialog()
end

function UICriVideoController:PlayAudioComplete()
    Log.debug("PlayAudioComplete Stop", self._videoPlayer.player.status)
    self._playVideoScreenObj:SetActive(false)
    self._skipAudioObj:SetActive(false)
    self._videoSubtitleText.text = ""
    self._subTitle:SetActive(false)
    self:CloseDialog()
end

function UICriVideoController:SkipAudioBtnOnClick()
    self:PauseAudio()
    PopupManager.Alert(
        "UICommonMessageBox",
        PopupPriority.Normal,
        PopupMsgBoxType.OkCancel,
        "",
        StringTable.Get("str_draw_card_video_close_desc"),
        function(param)
            self:SkipAudio()
        end,
        nil,
        function(param)
            self:ResumeAudio()
        end,
        nil
    )
end

function UICriVideoController:PlayVideoOnClick()
    if self._isShowSkipBtn == true then
        return
    end
    self._isShowSkipBtn = true
    self._skipAudioObj:SetActive(true)
    self._delayHideJumpBtnTask =
        self:StartTask(
            function(TT)
                YIELD(TT, 3000)
                self._skipAudioObj:SetActive(false)
                self._isShowSkipBtn = false
            end,
            self
        )
end
