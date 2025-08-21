--
---@class UISeasonS1MusicTab : UICustomWidget
_class("UISeasonS1MusicTab", UICustomWidget)
UISeasonS1MusicTab = UISeasonS1MusicTab
--初始化
function UISeasonS1MusicTab:OnShow(uiParams)
    self:InitWidget()
    self._lastBGMAudioID = AudioHelperController.GetCurrentBgm()
    Log.info("正在播放的bgm:", self._lastBGMAudioID)

    self._timerHolder = UITimerHolder:New()
    self._pause = true
end

function UISeasonS1MusicTab:OnHide()
    if self._curIdx and self._curIdx > 0 then
        local audioID = self._collageData:GetMusicByIndex(self._curIdx):AudioID()
        if audioID ~= self._lastBGMAudioID then
            AudioHelperController.PlayBGM(self._lastBGMAudioID)
            Log.info("恢复正在播放的bgm:", self._lastBGMAudioID)
        end
    end
    if self._tweener and self._tweener:IsPlaying() then
        self._tweener:Kill()
    end
    if self._timerHolder then
        self._timerHolder:Dispose()
        self._timerHolder = nil
    end
end

--获取ui组件
function UISeasonS1MusicTab:InitWidget()
    --generated--
    ---@type UICustomWidgetPool
    self.content = self:GetUIComponent("UISelectObjectPath", "Content")
    ---@type UILocalizationText
    self.musicName = self:GetUIComponent("UILocalizationText", "musicName")
    ---@type UILocalizationText
    self.author = self:GetUIComponent("UILocalizationText", "author")
    ---@type UnityEngine.UI.Button
    self.play = self:GetUIComponent("Button", "Play")
    ---@type UnityEngine.UI.Button
    self.pause = self:GetUIComponent("Button", "Pause")
    --generated end--
    ---@type UnityEngine.UI.Button
    self.next = self:GetUIComponent("Button", "Next")
    ---@type UnityEngine.UI.Button
    self.last = self:GetUIComponent("Button", "Last")

    self.time = self:GetUIComponent("UILocalizationText", "time")
    self.progress = self:GetUIComponent("Image", "progress")

    ---@type UnityEngine.UI.HorizontalLayoutGroup
    local contentLayout = self:GetUIComponent("HorizontalLayoutGroup", "Content")
    self._paddingLeft = contentLayout.padding.left
    self._cellSizeX = 472
    self._cellSpaceX = contentLayout.spacing
    ---@type UnityEngine.RectTransform
    self._contentRect = self:GetUIComponent("RectTransform", "Content")
    self._viewPortWidth = self:GetUIComponent("RectTransform", "Viewport").rect.width

    self._anim = self:GetGameObject():GetComponent(typeof(UnityEngine.Animation))
end

--设置数据
---@param data UISeasonCollageData
function UISeasonS1MusicTab:SetData(data)
    self._collageData = data
    self._musicCount = self._collageData:GetMusicCount()
    ---@type UISeasonS1CollageMusicItem[]
    self._items = self.content:SpawnObjects("UISeasonS1CollageMusicItem", self._musicCount)

    local onSelect = function(data)
        self:_OnSelect(data)
    end

    local defaultData = nil
    for i = 1, self._musicCount do
        local data = self._collageData:GetMusicByIndex(i)
        self._items[i]:SetData(data, onSelect)
        if data:IsUnlock() and self._lastBGMAudioID == data:AudioID() then
            defaultData = data
        end
    end

    if defaultData then
        Log.info("选中默认bgm:", defaultData:ID())
        self:_OnSelect(defaultData, true)
    else
        self:_RefreshPlayBar()
    end

    self._unlockCount, self._totalCount = self._collageData:GetMusicProgress()
end

function UISeasonS1MusicTab:SetShow(show)
    self:GetGameObject():SetActive(show)
    if show then
        self._timerHolder:StartTimerInfinite(
            "PlayingTick",
            1000,
            function()
                self:_PlayingTick()
            end
        )
        self:_PlayingTick()
    else
        self._timerHolder:StopTimer("PlayingTick")
    end
end

---@param data UISeasonCollageData_Music
function UISeasonS1MusicTab:_OnSelect(data, isInit)
    if not data:IsValid() then
        return
    end
    if not data:IsUnlock() then
        return
    end

    if self._curIdx == data:Index() then
        return
    end

    if data:IsNew() then
        self._collageData:MusicCancelNew(data)
        self._items[data:Index()]:SetNew(false)
        self:DispatchEvent(GameEventType.UISeasonS1OnSelectCollageItem)
    end

    if self._curIdx then
        self._items[self._curIdx]:Deselect()
    end
    self._curIdx = data:Index()
    self._items[self._curIdx]:Select()

    --初始化选择一条不需要播音频 只需要处理ui信息
    if not isInit then
        AudioHelperController.PlayBGM(data:AudioID())
        -- self:_SnapTo(self._curIdx, true)
    else
        -- self:_SnapTo(self._curIdx, false)
    end
    self._pause = false
    self:_RefreshPlayBar()
    self:_ResetProgress()
end

--按钮点击
function UISeasonS1MusicTab:PlayOnClick(go)
    if not self._curIdx then
        return
    end
    if not self._pause then
        Log.info("当前bgm正在播放")
        return
    end
    self._pause = false
    self:_RefreshPlayBar()
    self._items[self._curIdx]:PlayEft()
    AudioHelperController:UnpauseBGM()
end

--按钮点击
function UISeasonS1MusicTab:PauseOnClick(go)
    if not self._curIdx then
        return
    end
    if self._pause then
        Log.info("当前bgm已暂停")
        return
    end
    self._pause = true
    self:_RefreshPlayBar()
    self._items[self._curIdx]:PauseEft()
    AudioHelperController.PauseBGM()
end

--按钮点击
function UISeasonS1MusicTab:LastOnClick(go)
    if not self._curIdx then
        return
    end

    if self._unlockCount == 1 then
        Log.info("只有一首，别切了")
        return
    end

    local target
    if self._curIdx <= 1 then
        Log.info("当前bgm是第一首")
        target = self._unlockCount --切到最后一首可播放的
    else
        target = self._curIdx - 1
    end
    local data = self._collageData:GetMusicByIndex(target)
    self:_OnSelect(data)
end

--按钮点击
function UISeasonS1MusicTab:NextOnClick(go)
    if not self._curIdx then
        return
    end
    if self._unlockCount == 1 then
        Log.info("只有一首，别切了")
        return
    end
    local target
    if self._curIdx >= self._unlockCount then
        Log.info("当前bgm是最后一首")
        target = 1
    else
        target = self._curIdx + 1
    end
    local data = self._collageData:GetMusicByIndex(target)
    self:_OnSelect(data)
end

function UISeasonS1MusicTab:_RefreshPlayBar()
    if self._curIdx then
        local data = self._collageData:GetMusicByIndex(self._curIdx)
        local cfg = Cfg.cfg_role_music[data:ID()]
        self.musicName:SetText(StringTable.Get(cfg.Name))
        self.author:SetText(StringTable.Get(cfg.Author))
        if self._pause then
            self.play.gameObject:SetActive(true)
            self.play.interactable = true
            self.pause.gameObject:SetActive(false)
        else
            self.play.gameObject:SetActive(false)
            self.pause.gameObject:SetActive(true)
            self.pause.interactable = true
        end

        self.last.interactable = true
        self.next.interactable = true
    else
        self.musicName:SetText("")
        self.author:SetText("")
        self.play.gameObject:SetActive(true)
        self.play.interactable = false
        self.next.interactable = false
        self.last.interactable = false
        self.pause.gameObject:SetActive(false)
        self:_ResetProgress()
    end
end

function UISeasonS1MusicTab:_ResetProgress()
    self.progress.fillAmount = 0
    self.time:SetText("")
end

function UISeasonS1MusicTab:_PlayingTick()
    if self._pause then
        return
    end
    local data = self._collageData:GetMusicByIndex(self._curIdx)
    if data:AudioID() ~= AudioHelperController.GetCurrentBgm() then --切换bgm需要淡入淡出 有可能正在播的不是当前选中的
        return
    end
    if AudioHelperController.BGMPlayerIsPlaying() then
        local time = AudioHelperController.GetPlayingBGMTimeSyncedWithAudio()
        if time < 0 then
            -- Log.exception("当前播放时间错误：", time)
            time = 0
        end
        local duration = data:Duration()
        if self._development then
            local realDua = AudioHelperController.GetPlayingBGMTotalTimeMs()
            if realDua > 0 and math.abs(realDua / 1000 - duration) > 0.5 then
                ToastManager.ShowToast("音乐配置时长错误！ID:" .. self._curPlaying .. "，真实时长:" ..
                    realDua / 1000)
            end
        end
        time = math.floor((time / 1000) % duration)
        self.time:SetText(
            UIBgmHelper.FormatTime(time) .. "/" .. UIBgmHelper.FormatTime(duration)
        )
        self.progress.fillAmount = time / duration
    end
end

function UISeasonS1MusicTab:_SnapTo(index, animate)
    UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self._contentRect)
    local width = self._contentRect.rect.width

    local x = self._paddingLeft + (self._cellSizeX + self._cellSpaceX) * (index - 1) + self._cellSizeX / 2 -
        self._viewPortWidth / 2
    x = -Mathf.Clamp(x, 0, width - self._viewPortWidth)
    if animate then
        if self._tweener and self._tweener:IsPlaying() then
            self._tweener:Kill()
        end
        self._tweener = self._contentRect:DOAnchorPosX(x, 0.7):SetEase(DG.Tweening.Ease.OutCubic)
    else
        self._contentRect.anchoredPosition = Vector2(x, 0)
    end
end

function UISeasonS1MusicTab:PlayExitAnim()
    self._anim:Play("uieffanim_UISeasonS1MusicTab_out")
    for i = 1, self._musicCount do
        self._items[i]:PlayExitAnim()
    end
end
