---@class UIHomelandAlbum : UIController
_class("UIHomelandAlbum", UIController)
UIHomelandAlbum = UIHomelandAlbum

local alog = nil

function UIHomelandAlbum:Constructor()
    self._eulerAngles = Vector3(0, 0, 0)
end

function UIHomelandAlbum:OnShow(uiParams)
    alog = function(...)
        Log.debug("[Album] ", ...)
    end
    self:_GetComponents()
    --开发版本
    self._development = EngineGameHelper.IsDevelopmentBuild()
    self._development = false
    ---@type RoleModule
    self._roleModule = self:GetModule(RoleModule)
    local allCfg = Cfg.cfg_role_music {}
    local musics = {{}, {}, {}}
    local counts = {{0, 0}, {0, 0}, {0, 0}}
    local lockInfo = {}
    for _, cfg in pairs(allCfg) do
        if cfg.IsShow then
            local lock = self._roleModule:UI_CheckMusicLock(cfg)
            local show = true
            if lock then
                local unlockunshow = cfg.UnLockUnShow
                if unlockunshow then
                    show = false
                end
            end
            if show then
                table.insert(musics[cfg.Tag], cfg)
                counts[cfg.Tag][1] = counts[cfg.Tag][1] + 1
                if not lock then
                    counts[cfg.Tag][2] = counts[cfg.Tag][2] + 1
                end
                lockInfo[cfg.ID] = lock
            end
        end
    end
    self.tab1Count:SetText(counts[1][2] .. "/" .. counts[1][1])
    self.tab2Count:SetText(counts[2][2] .. "/" .. counts[2][1])
    self.tab3Count:SetText(counts[3][2] .. "/" .. counts[3][1])
    self._isLock = function(id)
        return lockInfo[id]
    end
    local sorter = function(a, b)
        if self._isLock(a.ID) == self._isLock(b.ID) then
            return a.ID < b.ID
        else
            return not self._isLock(a.ID)
        end
    end
    table.sort(musics[1], sorter)
    table.sort(musics[2], sorter)
    table.sort(musics[3], sorter)
    self._music = musics
    self._curHomelandMusic = self._roleModule:UI_GetMusic(EnumBgmType.E_Bgm_Homeland)
    local playing = AudioHelperController.GetCurrentBgm()
    local cfgs = Cfg.cfg_role_music{AudioID = playing}
    local curMainID = -1
    if cfgs and next(cfgs) then
        curMainID = cfgs[1].ID
    end
    if Cfg.cfg_role_music[curMainID].AudioID ~= playing then
        Log.exception("当前的背景音不正确：", playing, "，应该播放：", curMainID)
    end

    local onClickItem = function(idx)
        self:onClickItem(idx)
    end
    local getItem = function(scrollView, index)
        if index < 0 then
            return nil
        end
        local item = scrollView:NewListViewItem("item")
        local rowPool = self:GetUIComponentDynamic("UISelectObjectPath", item.gameObject)
        ---@type UIHomelandAlbumItem
        local m = rowPool:SpawnObject("UIHomelandAlbumItem")
        local cfg = self._music[self._curTab][index + 1]
        m:SetData(
            cfg,
            index + 1,
            self._isLock(cfg.ID),
            onClickItem,
            self._curSelectCfgID == cfg.ID,
            self._curPlaying == cfg.ID,
            self._isPause
        )
        return item
    end
    self.scrollList:InitListView(0, getItem)
    self._curPlaying = curMainID
    self._isPause = false
    self._curSelectCfgID = nil
    self._curTab = nil
    --当前正在播放的音乐属于哪个1级页签
    self._curPlayingTab = Cfg.cfg_role_music[self._curPlaying].Tag
    self:changeTab(1)
    --当前正在播放的音乐在列表中的索引，用于上一首下一首
    for idx, cfg in ipairs(self._music[self._curPlayingTab]) do
        if cfg.ID == curMainID then
            self._curPlayingIndex = idx
            break
        end
    end
    self:refreshBtmBar(Cfg.cfg_role_music[self._curPlaying])
    self:refreshSetBtn()
    self:_ChangeBlurBgBegin(Cfg.cfg_role_music[self._curPlaying].Icon)

    self._timerEvent =
        GameGlobal.Timer():AddEventTimes(
        1000,
        TimerTriggerCount.Infinite,
        function()
            self:musicTimeTick()
        end
    )
end

function UIHomelandAlbum:OnHide()
    GameGlobal.Timer():CancelEvent(self._timerEvent)
    if self._curHomelandMusic ~= self._curPlaying then
        local cfg
        if self._curHomelandMusic <= 0 then
            cfg = Cfg.cfg_role_music[CriAudioIDConst.BGMEnterHomeland]
        else
            cfg = Cfg.cfg_role_music[self._curHomelandMusic]
        end
        AudioHelperController.PlayBGM(cfg.AudioID)
    end
    alog = nil
end

function UIHomelandAlbum:_GetComponents()
    --generated--
    ---@type UICustomWidgetPool
    self.topButtons = self:GetUIComponent("UISelectObjectPath", "TopButtons")
    ---@type UILocalizationText
    self.tab1Count = self:GetUIComponent("UILocalizationText", "Tab1Count")
    ---@type UILocalizationText
    self.tab2Count = self:GetUIComponent("UILocalizationText", "Tab2Count")
    ---@type UILocalizationText
    self.tab3Count = self:GetUIComponent("UILocalizationText", "Tab3Count")
    ---@type RawImageLoader
    self.cover = self:GetUIComponent("RawImageLoader", "cover")
    ---@type UIDynamicScrollView
    self.scrollList = self:GetUIComponent("UIDynamicScrollView", "ScrollList")
    ---@type UnityEngine.UI.Image
    self.progress = self:GetUIComponent("Image", "progress")
    ---@type UILocalizationText
    self.time = self:GetUIComponent("UILocalizationText", "time")
    ---@type RawImageLoader
    self.cover_small = self:GetUIComponent("RawImageLoader", "cover_small")
    ---@type UnityEngine.GameObject
    self.pauseBtn = self:GetGameObject("PauseBtn")
    ---@type UnityEngine.GameObject
    self.resumeBtn = self:GetGameObject("ResumeBtn")
    ---@type RollingText
    self.nameText = self:GetUIComponent("RollingText", "nameText")
    ---@type RollingText
    self.authorText = self:GetUIComponent("RollingText", "authorText")
    ---@type RollingText
    self.mainMusicText = self:GetUIComponent("RollingText", "MainMusicText")
    ---@type RollingText
    self.aircraftMusicText = self:GetUIComponent("RollingText", "AircraftMusicText")
    ---@type RollingText
    self.homelandMusicText = self:GetUIComponent("RollingText", "HomelandMusicText")
    --generated end--

    self._tabBtns = {
        self:GetUIComponent("Button", "Tab1"),
        self:GetUIComponent("Button", "Tab2"),
        self:GetUIComponent("Button", "Tab3")
    }

    self._tabTexts = {self.tab1Count, self.tab2Count, self.tab3Count}

    ---@type RawImageLoader
    self._blurBg = self:GetUIComponent("RawImageLoader", "blurBg")
    ---@type RawImageLoader
    self._blurBgNew = self:GetUIComponent("RawImageLoader", "blurBgNew")
    ---@type RawImage
    self._blurBgNewImg = self:GetUIComponent("RawImage", "blurBgNew")

    ---@type UnityEngine.Animation
    self._anim = self:GetUIComponent("Animation", "UIAlbum")
    ---@type UnityEngine.RectTransform
    self._disc = self:GetUIComponent("RectTransform", "disc")
end

function UIHomelandAlbum:changeTab(tab)
    if self._curTab == tab then
        return
    end
    if self._curTab then
        self._tabBtns[self._curTab].interactable = true
        self._tabTexts[self._curTab].color = Color(131 / 255, 131 / 255, 131 / 255)
        self._anim:Play("uieff_Album_Switch")
    end
    self._curTab = tab
    self._tabBtns[self._curTab].interactable = false
    self._tabTexts[self._curTab].color = Color(252/255, 181/255, 87/255)
    self.scrollList:SetListItemCount(#self._music[self._curTab], true)
    --选中第1条
    self:onClickItem(1)
end

function UIHomelandAlbum:onClickItem(idx)
    local cfgID = self._music[self._curTab][idx].ID
    if self._curSelectCfgID == cfgID then
        if self._curPlaying == cfgID then
            if self._isPause then
                --继续播
                alog("当前暂停，继续播:", idx)
                AudioHelperController.UnpauseBGM()
                self.pauseBtn:SetActive(true)
                self.resumeBtn:SetActive(false)
                self._isPause = false
            else
                --暂停
                alog("当前正在播，暂停:", idx)
                AudioHelperController.PauseBGM()
                self.pauseBtn:SetActive(false)
                self.resumeBtn:SetActive(true)
                self._isPause = true
            end
        else
            -- self._anim:Play("uieff_Album_Switch")
            alog("切音乐，开始播:", idx)
            local cfg = Cfg.cfg_role_music[cfgID]
            self._curPlaying = cfgID
            self._isPause = false
            self._curPlayingIndex = idx
            self._curPlayingTab = cfg.Tag
            AudioHelperController.PlayBGM(cfg.AudioID)
            self:refreshBtmBar(cfg)

            self:_ChangeBlurBgBegin(cfg.Icon)
        end
    else
        alog("点了不同的音乐，切换:", idx)
        local cfg = Cfg.cfg_role_music[cfgID]
        self._curSelectCfgID = cfgID
        self:changeSelect(cfg)
    end

    self.scrollList:RefreshAllShownItem()
end

function UIHomelandAlbum:refreshBtmBar(cfg)
    alog("刷新底条信息")
    self.cover_small:LoadImage(cfg.Icon)
    self.pauseBtn:SetActive(not self._isPause)
    self.resumeBtn:SetActive(self._isPause)
    self:musicTimeTick()
    self.nameText:RefreshText(StringTable.Get(cfg.Name))
    self.authorText:RefreshText(StringTable.Get(cfg.Author))
end

function UIHomelandAlbum:refreshSetBtn(type)
    alog("刷新底部按钮")
    if self._curHomelandMusic == 0 then
        self.homelandMusicText:RefreshText(StringTable.Get("str_album_homeland"))
    else
        local cfg = Cfg.cfg_role_music[self._curHomelandMusic]
        self.homelandMusicText:RefreshText(StringTable.Get(cfg.Name))
    end
end

function UIHomelandAlbum:changeSelect(cfg)
    self.cover:LoadImage(cfg.Icon)
end

function UIHomelandAlbum:musicTimeTick()
    if AudioHelperController.BGMPlayerIsPlaying() then
        local time = AudioHelperController.GetPlayingBGMTimeSyncedWithAudio()
        if time < 0 then
            time = 0
        end
        local duration = Cfg.cfg_role_music[self._curPlaying].Duration
        if self._development then
            local realDua = AudioHelperController.GetPlayingBGMTotalTimeMs()
            if realDua > 0 and math.abs(realDua / 1000 - duration) > 0.5 then
                ToastManager.ShowToast("音乐配置时长错误！ID:" .. self._curPlaying .. "，真实时长:" .. realDua / 1000)
            end
        end
        time = math.floor((time / 1000) % duration)
        self.time:SetText(
            "<color=#fcb557>" .. UIHomelandBgmHelper.FormatTime(time) .. "</color><color=#838383>/" .. UIHomelandBgmHelper.FormatTime(duration) .. "</color>"
        )
        self.progress.fillAmount = time / duration
    end
end

function UIHomelandAlbum:Tab1OnClick(go)
    alog("切换tab1")
    self:changeTab(1)
end
function UIHomelandAlbum:Tab2OnClick(go)
    alog("切换tab2")
    self:changeTab(2)
end
function UIHomelandAlbum:Tab3OnClick(go)
    alog("切换tab3")
    self:changeTab(3)
end
function UIHomelandAlbum:PauseBtnOnClick(go)
    alog("暂停")
    self._isPause = true
    self.pauseBtn:SetActive(false)
    self.resumeBtn:SetActive(true)
    AudioHelperController.PauseBGM()
    self.scrollList:RefreshAllShownItem()
end
function UIHomelandAlbum:ResumeBtnOnClick(go)
    alog("继续播放")
    self._isPause = false
    self.pauseBtn:SetActive(true)
    self.resumeBtn:SetActive(false)
    AudioHelperController.UnpauseBGM()
    self.scrollList:RefreshAllShownItem()
end
function UIHomelandAlbum:LastBtnOnClick(go)
    alog("上一首")
    local index = self._curPlayingIndex - 1
    if index < 1 then
        local count = #self._music[self._curPlayingTab]
        index = count
    end

    local lastCfgID = self._music[self._curPlayingTab][index].ID
    if self._curPlayingTab == self._curTab then
        if self._curSelectCfgID == lastCfgID then
            self:onClickItem(index)
        else
            self:onClickItem(index)
            self:onClickItem(index)
        end
    else
        local cfg = self._music[self._curPlayingTab][index]
        self._curPlaying = cfg.ID
        self._curPlayingIndex = index
        AudioHelperController.PlayBGM(cfg.AudioID)
        self:refreshBtmBar(cfg)

        self:_ChangeBlurBgBegin(cfg.Icon)
    end
end
function UIHomelandAlbum:NextBtnOnClick(go)
    alog("下一首")
    local index = self._curPlayingIndex + 1
    local count = #self._music[self._curPlayingTab]
    if index > count then
        index = 1
    end

    local nextCfgID = self._music[self._curPlayingTab][index].ID
    if self._curPlayingTab == self._curTab then
        if self._curSelectCfgID == nextCfgID then
            self:onClickItem(index)
        else
            self:onClickItem(index)
            self:onClickItem(index)
        end
    else
        local cfg = self._music[self._curPlayingTab][index]
        self._curPlaying = cfg.ID
        self._curPlayingIndex = index
        AudioHelperController.PlayBGM(cfg.AudioID)
        self:refreshBtmBar(cfg)

        self:_ChangeBlurBgBegin(cfg.Icon)
    end
end

function UIHomelandAlbum:SetHomelandOnClick()
    alog("设置家园背景音")
    local id = 0
    if self._curHomelandMusic == 0 then
        --没设置过，直接设置
        id = self._curPlaying
    else
        if self._curHomelandMusic == self._curPlaying then
            id = 0
        else
            id = self._curPlaying
        end
    end
    self:StartTask(self.reqChangeBgm, self, EnumBgmType.E_Bgm_Homeland, id)
end

function UIHomelandAlbum:reqChangeBgm(TT, type, id)
    self:Lock(self:GetName())
    local res = self._roleModule:RequestRole_Music(TT, type, id)
    if res:GetSucc() then
        self._curHomelandMusic = self._roleModule:UI_GetMusic(EnumBgmType.E_Bgm_Homeland)
        self:refreshSetBtn(type)
        if id == 0 then
            ToastManager.ShowToast(StringTable.Get("str_album_homeland_default"))
        else
            ToastManager.ShowToast(StringTable.Get("str_album_homeland_changed"))
        end
    else
        ToastManager.ShowToast("unkown error:", res:GetResult())
    end
    self:UnLock(self:GetName())
end

function UIHomelandAlbum:_ChangeBlurBgBegin(icon)
    self._blurBgNew:LoadImage(icon)
    --关了再开，刷新模糊
    self._blurBgNew.gameObject:SetActive(false)
    self._blurBgNew.gameObject:SetActive(true)

    local lockId = "UIHomelandAlbum:_ChangeBlurBg"
    self:Lock(lockId)
    self._blurBgNewImg:DOFade(0, 0)
    local targetFade = 1
    local duration = 0.5
    self._blurBgNewImg:DOFade(targetFade, duration):OnComplete(
        function()
            self:_ChangeBlurBgEnd(icon)
            self:UnLock(lockId)
        end
    )
end

function UIHomelandAlbum:_ChangeBlurBgEnd(icon)
    self._blurBg:LoadImage(icon)
    --关了再开，刷新模糊
    self._blurBg.gameObject:SetActive(false)
    self._blurBg.gameObject:SetActive(true)
    self._blurBgNew.gameObject:SetActive(false)
end

function UIHomelandAlbum:BackBtnOnClick(go)
    self:CloseDialog()
end

function UIHomelandAlbum:OnUpdate(ms)
    if self._isPause then
        return
    end
    self._eulerAngles.z = self._disc.eulerAngles.z - ms / 50
    self._disc.eulerAngles = self._eulerAngles
end