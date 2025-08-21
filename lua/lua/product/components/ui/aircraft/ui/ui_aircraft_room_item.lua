---@class UIAircraftRoomItem : UICustomWidget
_class("UIAircraftRoomItem", UICustomWidget)
UIAircraftRoomItem = UIAircraftRoomItem
function UIAircraftRoomItem:OnShow(uiParams)
    self._roomName = self:GetUIComponent("UILocalizationText", "TextTitle")
    self._roomLevel = self:GetUIComponent("UILocalizationText", "TextLevel")
    self._roomFuncs = self:GetUIComponent("UISelectObjectPath", "functions")
    local _infoLoader = self:GetUIComponent("UISelectObjectPath", "RoomInfo")
    ---@type UIAircraftRoomInfoItem
    self._roomInfo = _infoLoader:SpawnObject("UIAircraftRoomInfoItem")
    self._show = false

    self.countDownTimer = {}

    self._module = self:GetModule(AircraftModule)

    self._roomInfoSpaceY = -7

    self._extraTip = self:GetGameObject("ExtraTip")
    self._extraTipText = self:GetUIComponent("UILocalizationText", "ExtraTipText")
end

function UIAircraftRoomItem:OnHide()
    for _, value in ipairs(self.countDownTimer) do
        GameGlobal.Timer():CancelEvent(value)
    end
    self.countDownTimer = {}

    self:Close()
end

function UIAircraftRoomItem:Refresh(roomData, _closeInfoWindow)
    ---@type AircraftRoomBase
    self._roomData = roomData
    self._spaceID = self._roomData:SpaceId()
    self._show = true
    self:GetGameObject():SetActive(true)
    -- local guideModule = self:GetModule(GuideModule)
    -- if not guideModule:GuideInProgress() then
    --     local triggerGuide = false
    --     GameGlobal.EventDispatcher():Dispatch(
    --         GameEventType.GuideRoomEnter,
    --         self._spaceID,
    --         function(guide)
    --             triggerGuide = guide
    --         end
    --     )
    --     if triggerGuide then
    --         local _main = self._module:GetClientMain()
    --         _main:GotoSpace(self._spaceID, true)
    --     end
    -- end
    self._roomName:SetText(StringTable.Get(self._roomData:GetRoomName()))
    self._roomType = self._roomData:GetRoomType()
    if self._module:IsAmusementRoom(self._roomType) then
        self._roomLevel:SetText(
            (self._roomData:Level() - 1) .. "/<color=#FF8200>" .. (self._roomData:MaxLevel() - 1) .. "</color>"
        )
    else
        self._roomLevel:SetText(self._roomData:Level() .. "/<color=#FF8200>" .. self._roomData:MaxLevel() .. "</color>")
    end

    local roomCfg = Cfg.cfg_aircraft_room[self._roomData:RoomId()]
    if not roomCfg then
        AirError("cfg_aircraft_room中找不到配置:", self._roomData:RoomId())
    end
    if roomCfg.ExtraTip then
        self._extraTip:SetActive(true)
        self._extraTipText:SetText(StringTable.Get(roomCfg.ExtraTip))
    else
        self._extraTip:SetActive(false)
    end
    
    -- if self._module:IsAmusementRoom(self._roomType) then
    --     self._roomInfo:Refresh(self._roomData, _closeInfoWindow)
    --     return
    -- end

    local functionParent = self:GetUIComponent("Transform", "functions")

    if self.centerRoomWidget then
        self.centerRoomWidget:GetGameObject():SetActive(false)
    end
    ---@type UnityEngine.GameObject
    local roomTip = functionParent:Find("DoubleFull").gameObject
    roomTip:SetActive(false)
    --主控室和资源室各需要额外显示一条信息
    if self._roomType == AirRoomType.CentralRoom then
        -- local centerLoader = self:GetUIComponent("UISelectObjectPath", "centerroomfunc")
        -- if self.centerRoomWidget == nil then
        --     ---@type UIAircraftCenterRoomFuncItem
        --     self.centerRoomWidget = centerLoader:SpawnObject("UIAircraftCenterRoomFuncItem")
        --     self.centerRoomWidget:GetGameObject().transform:SetParent(functionParent)
        --     self.centerRoomWidget:GetGameObject().transform:SetAsFirstSibling()
        -- end
        -- self.centerRoomWidget:GetGameObject():SetActive(true)
        -- self.centerRoomWidget:SetData(self._roomData)
    elseif self._roomType == AirRoomType.ResourceRoom then
        local cur = self._roomData:GetResCardCount()
        local ceiling, bonus = self._roomData:GetResCardLimit()
        --双倍券是否已满
        if cur >= ceiling then
            roomTip:SetActive(true)
            local text = roomTip:GetComponentInChildren(typeof(UILocalizationText))
            text:SetText(StringTable.Get("str_aircraft_double_coupon_full"))
        end
    elseif self._roomType == AirRoomType.TacticRoom then
        ---@type AircraftTacticRoom
        local room = self._roomData
        local num = room:GetCartridgeGiftCount() + #room:GetCartridgeList()
        local ceiling = room:GetCartridgeLimit()
        if num >= ceiling then
            roomTip:SetActive(true)
            local text = roomTip:GetComponentInChildren(typeof(UILocalizationText))
            text:SetText(StringTable.Get("str_aircraft_tactic_tape_have_reached_limit"))
        end
    end

    local funcCfg = UIAircraftRoomFunctions[self._roomType].roomFunc
    local funcCount = #funcCfg

    self._roomFuncs:SpawnObjects("UIAircraftRoomFuncItem", funcCount)
    ---@type table<int,UIAircraftRoomFuncItem>
    self._funcWidgets = self._roomFuncs:GetAllSpawnList()

    for _, value in ipairs(self.countDownTimer) do
        GameGlobal.Timer():CancelEvent(value)
    end
    self.countDownTimer = {}

    for i = 1, funcCount do
        local cfg = funcCfg[i]
        self._funcWidgets[i]:GetGameObject():SetActive(true)

        if cfg.specialTag == UIAircraftRoomFuncSpecailTag.DoubleCouponStore then
            --特殊处理，资源室双倍券存储
            local cur = self._roomData:GetResCardCount()
            local ceiling, bonus = self._roomData:GetResCardLimit()
            ceiling = math.floor(ceiling)
            if bonus then
                bonus = math.floor(bonus)
            end
            -- if cur > ceiling then
            --     cur = ceiling
            -- end
            self._funcWidgets[i]:SetDataSpecial(cfg.name, cur .. "/" .. ceiling, bonus)
        elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.DrawCouponStore then
            --特殊处理，灯塔室抽奖券存储
            local cur = self._roomData:GetHeartAmberCount()
            local ceiling, bonus = self._roomData:GetOutputLimit()
            ceiling = math.floor(ceiling)
            if bonus then
                bonus = math.floor(bonus)
            end
            self._funcWidgets[i]:SetDataSpecial(cfg.name, cur .. "/" .. ceiling, bonus)
        elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.AtomDiscount then
            local dis = self._roomData:AtomDiscount()
            if dis < 1 then
                dis = string.format("<color=#63ff72>(%.2f%%)</color>", (1 - dis) * 100)
            else
                dis = "0%"
            end
            self._funcWidgets[i]:SetDataSpecial(cfg.name, dis)
        elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.AtomStore then
            --特殊处理，原子剂需要监听消息，实时刷新
            self._funcWidgets[i]:SetAsAtom(cfg.name)
        elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.DispatchCount then
            local dispatchCount = self._roomData:GetDispatchCount()
            local roomCfg = self._roomData:GetRoomConfig()
            self._funcWidgets[i]:SetDataSpecial(cfg.name, dispatchCount .. "/" .. roomCfg.DispatchMax, 0)
        elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.DispatchTeam then
            local dispatchTeamCount = self._roomData:GetDispatchTeamCount()
            local roomCfg = self._roomData:GetRoomConfig()
            self._funcWidgets[i]:SetDataSpecial(cfg.name, dispatchTeamCount .. "/" .. roomCfg.TeamMax, 0)
        elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.TapeStorage then
            ---@type AircraftTacticRoom
            local room = self._roomData
            local num = room:GetCartridgeGiftCount() + #room:GetCartridgeList()
            local ceiling = room:GetCartridgeLimit()
            self._funcWidgets[i]:SetDataSpecial(cfg.name, num .. "/" .. ceiling, 0)
        elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.TapeCountdown then
            ---@type AircraftTacticRoom
            local room = self._roomData
            if room:IsCartridgeLimit() then
                self._funcWidgets[i]:SetDataSpecial(cfg.name, "--:--:--", 0)
            else
                self:AddCountdown(
                    function()
                        local time = room:GetCartridgeCountDown()
                        local now = math.floor(GameGlobal.GetModule(SvrTimeModule):GetServerTime() / 1000)
                        local delta = time - now
                        if delta <= 0 then
                            self._funcWidgets[i]:SetDataSpecial(cfg.name, "00:00:00", 0)
                            self:StartTask(self.RefreshTacticRoom, self)
                        else
                            self._funcWidgets[i]:SetDataSpecial(
                                cfg.name,
                                HelperProxy:GetInstance():FormatTime_2(delta),
                                0
                            )
                        end
                    end
                )
            end
        else
            if cfg.countDown then
                local time = self._roomData[cfg.func](self._roomData)
                if time == -1 then
                    local str = "--:--:--"
                    if self._roomType == AirRoomType.DispatchRoom then
                        str = StringTable.Get("str_dispatch_room_dispatch_stop_recover")
                    end
                    self._funcWidgets[i]:SetDataSpecial(cfg.name, str, 0)
                elseif time > 0 then
                    local funcName = cfg.func
                    local name = cfg.name
                    self:AddCountdown(
                        function()
                            local _text = nil
                            if self._roomData[funcName] == nil then
                                Log.fatal(
                                    "[Airctaft] room function not found, roomType: ",
                                    self._roomType,
                                    " function name: ",
                                    funcName,
                                    "，spaceID:",
                                    self._roomData:SpaceId()
                                )
                            end
                            local time = self._roomData[funcName](self._roomData)
                            if time == -1 then
                                _text = "--:--:--"
                                if self._roomType == AirRoomType.DispatchRoom then
                                    _text = StringTable.Get("str_dispatch_room_dispatch_stop_recover")
                                end
                            elseif time == 0 then
                                _text = "00:00:00"
                                self:ReqDataAndRefreshRoomMsg()
                            else
                                _text = HelperProxy:GetInstance():FormatTime_2(math.floor(time))
                            end
                            self._funcWidgets[i]:SetDataSpecial(name, _text, 0)
                        end
                    )
                else
                    self._funcWidgets[i]:SetDataSpecial(cfg.name, "00:00:00", 0)
                end
            else
                local base, add = self._roomData[cfg.func](self._roomData)
                if base == nil then
                    base = 0
                end
                --速度类数值需乘3600
                if cfg.isSpeed then
                    base = base * 3600
                    if add then
                        add = add * 3600
                    end
                end
                self._funcWidgets[i]:SetData(cfg.name, base, add, cfg.isInt, cfg.isPercent)
            end
        end
    end
    self._roomInfo:Refresh(self._roomData, _closeInfoWindow)
end

function UIAircraftRoomItem:AddCountdown(func)
    func()
    local timer = GameGlobal.Timer():AddEventTimes(1000, TimerTriggerCount.Infinite, func)
    self.countDownTimer[#self.countDownTimer + 1] = timer
end

function UIAircraftRoomItem:ReqDataAndRefreshRoomMsg()
    GameGlobal.TaskManager():StartTask(self.ReqData, self)
end

function UIAircraftRoomItem:ReqData(TT, callBack)
    self:Lock(self:GetName())
    local ack = self._module:AircraftUpdate(TT)
    self:UnLock(self:GetName())
    if ack:GetSucc() then
        self._roomData = self._module:GetRoom(self._spaceID)
        self:Refresh(self._roomData, false)
    else
        ToastManager.ShowToast(self._module:GetErrorMsg(ack:GetResult()))
    end
end

--请求刷新战术室
function UIAircraftRoomItem:RefreshTacticRoom(TT)
    local key = self:GetName() .. "-RefreshTacticRoom"
    self:Lock(key)
    local ack = self._module:RequestRefreshTacticRoom(TT)
    self:UnLock(key)
    if ack:GetSucc() then
        self._roomData = self._module:GetRoom(self._spaceID)
        self:Refresh(self._roomData, false)
    else
        ToastManager.ShowToast(self._module:GetErrorMsg(ack:GetResult()))
    end
end

function UIAircraftRoomItem:Close()
    self:GetGameObject():SetActive(false)
    self._show = false
    for _, value in ipairs(self.countDownTimer) do
        GameGlobal.Timer():CancelEvent(value)
    end
    self.countDownTimer = {}

    if self.centerRoomWidget then
        self.centerRoomWidget:OnClose()
    end
end

function UIAircraftRoomItem:IsClosed()
    return not self._show
end

function UIAircraftRoomItem:GetRoomData()
    return self._roomData
end

function UIAircraftRoomItem:SpaceID()
    return self._spaceID
end

--打开入住
function UIAircraftRoomItem:OpenEnterBuild()
    self._roomInfo:OpenEnterBuild()
end
--打开升级
function UIAircraftRoomItem:OpenLvUp()
    self._roomInfo:OpenLvUp()
end

--引导用
function UIAircraftRoomItem:GetDecorateBtn()
    return self._roomInfo:GetGameObject("ButtonDecorate")
end

function UIAircraftRoomItem:GetRoomInfoGameobject()
    local leftBottomRect = self:GetUIComponent("RectTransform", "LeftBottom")
    local maxWidth = 0
    local height = 0
    for i = 1, #self._funcWidgets do
        local layout = self._funcWidgets[i]:GetLayoutRect()
        if layout.sizeDelta.x > maxWidth then
            maxWidth = layout.sizeDelta.x
        end

        height = height + layout.sizeDelta.y

        if i > 1 then
            height = height + self._roomInfoSpaceY
        end
    end

    leftBottomRect.sizeDelta = Vector2(maxWidth, height)

    return leftBottomRect.gameObject
end
