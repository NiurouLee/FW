---@class UIDiscoveryPartChaperItem : UICustomWidget
_class("UIDiscoveryPartChaperItem", UICustomWidget)
UIDiscoveryPartChaperItem = UIDiscoveryPartChaperItem
function UIDiscoveryPartChaperItem:OnShow(uiParams)
    self:InitWidget()
end
function UIDiscoveryPartChaperItem:OnHide()
    if self._timer then
        self._timer:Dispose()
    end
end
function UIDiscoveryPartChaperItem:InitWidget()
    --generated--
    ---@type UILocalizationText
    self.title = self:GetUIComponent("UILocalizationText", "Title")
    ---@type UILocalizationText
    self.subtitle = self:GetUIComponent("UILocalizationText", "Subtitle")
    ---@type UnityEngine.GameObject
    self.lockGo = self:GetGameObject("LockGo")
    ---@type UILocalizationText
    self.unlockTime = self:GetUIComponent("UILocalizationText", "UnlockTime")
    ---@type UILocalizationText
    self.unlockCond = self:GetUIComponent("UILocalizationText", "UnlockCond")
    ---@type RawImageLoader
    self.bg = self:GetUIComponent("RawImageLoader", "bg")
    --generated end--
    ---@type UILocalizationText
    self.unlockCond1 = self:GetUIComponent("UILocalizationText", "UnlockCond1")
    self.LockCond1 = self:GetGameObject("LockCond1")
    self.LockCond2 = self:GetGameObject("LockCond2")
    self._anim = self:GetGameObject():GetComponent(typeof(UnityEngine.Animation))
    self.subtitle_1 = self:GetUIComponent("UILocalizationText", "Subtitle_1")
end
---@param section DiscoverySection
function UIDiscoveryPartChaperItem:SetData(idx, section)
end

---@param section DiscoverySection
function UIDiscoveryPartChaperItem:SetShow(idx, section, onTimeup)
    self._idx = idx
    self._onTimeup = onTimeup
    local state, _ = section:State()
    local chapterId = section.id
    self.isLock = state == nil
    -- self.title:SetText(section.name)
    local stitle = section.name
    self.subtitle:SetText(stitle)
    self.subtitle_1:SetText(stitle)
    self.bg:LoadImage(section.icon)
    if self.isLock then
        if self._timer then
            self._timer:StopTimer(self:GetName())
        else
            self._timer = UITimerHolder:New()
        end
        --篇章的解锁时间取绝于篇章里第一章节的解锁时间
        local cfg = Cfg.cfg_global["ui_chapter_unlock_time"].TableValue
        local minKey = math.huge --取篇章里章节id最小的为第一章节
        for v, _ in pairs(section.chapterIds) do
            minKey = math.min(minKey, v)
        end
        local time = cfg[minKey] or -1
        local now = GetSvrTimeNow()

        if time > 0 and time > now then
            self.unlockCond:SetText(StringTable.Get("str_discovery_section_" .. section.id .. "_unlock_condition"))
            local countDown = function()
                local delta = time - GetSvrTimeNow()
                if delta > 0 then
                    local timeStr = HelperProxy:GetInstance():FormatTime_3(delta)
                    if self._timeStr ~= timeStr then
                        self.unlockTime:SetText(StringTable.Get("str_discovery_section_open_after", timeStr))
                        self._timeStr = timeStr
                    end
                else
                    -- self.isLock = false
                    -- self.lockGo:SetActive(false)
                    self._timer:StopTimer(self:GetName())
                    self._onTimeup(self, self._idx)
                end
            end

            countDown()

            self._timer:StartTimerInfinite(self:GetName(), 1000, countDown)
            self.LockCond1:SetActive(false)
            self.LockCond2:SetActive(true)
        else
            self.unlockCond1:SetText(StringTable.Get("str_discovery_section_" .. section.id .. "_unlock_condition"))
            self.LockCond1:SetActive(true)
            self.LockCond2:SetActive(false)
        end

        self.lockGo:SetActive(true)
    else
        self.lockGo:SetActive(false)
    end

    self._isBetween = section.isBetween
end

function UIDiscoveryPartChaperItem:SetHide()
    if self._timer then
        self._timer:StopTimer(self:GetName())
    end
end

-- function UIDiscoveryPartChaperItem:EnterBtnOnClick(go)
--     if self.isLock then
--         return
--     end

--     self._onEnter(self._idx)
-- end

function UIDiscoveryPartChaperItem:Index()
    return self._idx
end

function UIDiscoveryPartChaperItem:IsLock()
    return self.isLock
end

function UIDiscoveryPartChaperItem:PlayEnterAnim()
    if self._isBetween then
        self._anim:Play("UIDiscoveryPartChaperItem_open_jian")
    else
        self._anim:Play("UIDiscoveryPartChaperItem_open_zhu")
    end
end
