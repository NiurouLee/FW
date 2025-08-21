---@class UIAircraftRoomInfoItem : UICustomWidget
_class("UIAircraftRoomInfoItem", UICustomWidget)
UIAircraftRoomInfoItem = UIAircraftRoomInfoItem

function UIAircraftRoomInfoItem:OnShow(uiParams)
    self.active = true
    self:InitWidget()
    ---@type table<UnityEngine.GameObject,UIAircraftRoomInfoItem>
    self.settledWidget = {}

    self.facilityWindow:SetActive(false)
    self.settleInfoWindow:SetActive(false)

    ---@type AircraftModule
    self._module = GameGlobal.GameLogic():GetModule(AircraftModule)
    --增益
    self.addedFormat = "%.2f<color=#1fe0ff>%+.2f</color>"
    --减益
    self.reduceFormat = "%.2f<color=#ff8200>%+.2f</color>"

    self:RefreshSettleMsg()

    self.countDownTimer = {}

    self:AttachEvent(GameEventType.AircraftOnFireFlyChanged, self.OnFireFlyChanged)
    self:AttachEvent(GameEventType.UpdateBookRedPointStatus, self.UpdateRedPointStatus)

    ---@type EZTL_Player
    self._tlPlayer = EZTL_Player:New()
end

function UIAircraftRoomInfoItem:SpawnListView()
    local contentRect = self:GetUIComponent("RectTransform", "Content")
    contentRect.anchoredPosition = Vector2(contentRect.anchoredPosition.x, 0)
    local count = self.settledCeiling
    self._contentPool = self:GetUIComponent("UISelectObjectPath", "Content")
    self._contentPool:SpawnObjects("UIAircraftSettleSpiritItem", count)
    ---@type UIAircraftSettleSpiritItem[]
    local items = self._contentPool:GetAllSpawnList()
    self.items = items
    for i = 1, count do
        items[i]:SetData(
            self.settledPets[i],
            self.roomData,
            function(pstid, idx)
                GameGlobal.TaskManager():StartTask(self.RequestRemoveOnePet, self, pstid, idx)
            end,
            i
        )
    end
end

function UIAircraftRoomInfoItem:OnHide()
    self:DetachEvent(GameEventType.UpdateBookRedPointStatus, self.UpdateRedPointStatus)
    self:CleanFacilityMsg()
    self:CleanSettleMsg()
    self.active = false
end

--genarated
function UIAircraftRoomInfoItem:InitWidget()
    self.textRoomName = self:GetUIComponent("UILocalizationText", "TextRoomName")
    self.textRoomLevel = self:GetUIComponent("UILocalizationText", "TextRoomLevel")
    self.localizationTextDes = self:GetUIComponent("UILocalizationText", "LocalizationTextDes")
    self.textSettleCount = self:GetUIComponent("UILocalizationText", "TextSettleCount")
    self.scrollViewSettleSpirits = self:GetUIComponent("UIDynamicScrollView", "ScrollViewSettleSpirits")
    -- self.baseInfo = self:GetUIComponent("UISelectObjectPath", "BaseInfo")
    self.facilityWindow = self:GetGameObject("ImageFacilityMask")
    self.settleInfoWindow = self:GetGameObject("ImageSettleMask")
    self.buttonFacility = self:GetUIComponent("Button", "ButtonFacility")
    self.buttonSettle = self:GetUIComponent("Button", "ButtonSettle")
    self.rawImageUsage = self:GetUIComponent("RawImageLoader", "RawImageUsage")
    self.levelDownText = self:GetUIComponent("UILocalizationText", "LevelDownText")
    self.levelUpText = self:GetUIComponent("UILocalizationText", "LevelUpText")
    self.levelUpButton = self:GetUIComponent("Button", "ButtonLevelUp")
    self.levelDownButton = self:GetUIComponent("Button", "ButtonLevelDown")
    self.bookBtnGo = self:GetGameObject("BookBtn")
    self.bookNewGo = self:GetGameObject("BookNew")
    self._panelAnim = self:GetUIComponent("Animation", "UIAircraftRoomInfoItem")

    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self.levelUpButton.gameObject),
        UIEvent.Press,
        function(go)
            if self.roomData:Level() < self.roomData:MaxLevel() then
                self:DoTextColor(self.levelUpText, Color(1, 133 / 255, 14 / 255), 0)
            end
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self.levelUpButton.gameObject),
        UIEvent.Release,
        function(go)
            if self.roomData:Level() < self.roomData:MaxLevel() then
                self:DoTextColor(self.levelUpText, Color(1, 1, 1), 0)
            end
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self.levelDownButton.gameObject),
        UIEvent.Press,
        function(go)
            if self._canLevelDown then
                self:DoTextColor(self.levelDownText, Color(0, 166 / 255, 1), 0)
            end
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get(self.levelDownButton.gameObject),
        UIEvent.Release,
        function(go)
            if self._canLevelDown then
                self:DoTextColor(self.levelDownText, Color(1, 1, 1), 0)
            end
        end
    )

    self.levelupRedTip = self:GetGameObject("LevelUpRedTip")
    self.settleRedTip = self:GetGameObject("SettleRedTip")
    self.levelBtnRedTip = self:GetGameObject("LevelBtnRedTip")

    self._facilityItems = {}
    ---@type UnityEngine.Transform
    local facilityParent = self:GetGameObject("facilityEffect").transform
    for i = 1, facilityParent.childCount do
        local t = facilityParent:GetChild(i - 1)
        ---@type UIView
        local uiview = t:GetComponent(typeof(UIView))
        local item = {}
        item.parent = uiview.gameObject
        item.title = uiview:GetUIComponent("RollingText", "title")
        item.value = uiview:GetUIComponent("UILocalizationText", "value")
        item.center = uiview:GetUIComponent("RollingText", "center")
        self._facilityItems[i] = item
    end

    self._settleItems = {}
    ---@type UnityEngine.Transform
    local settleParent = self:GetGameObject("settleEffect").transform
    for i = 1, settleParent.childCount do
        local t = settleParent:GetChild(i - 1)
        ---@type UIView
        local uiview = t:GetComponent(typeof(UIView))
        local item = {}
        item.parent = uiview.gameObject
        item.title = uiview:GetUIComponent("RollingText", "title")
        item.value = uiview:GetUIComponent("UILocalizationText", "value")
        self._settleItems[i] = item
    end

    self._decorateBtn = self:GetGameObject("ButtonDecorate")
end

function UIAircraftRoomInfoItem:OnFireFlyChanged()
    local canLevelUp = self._module:CanRoomLevelUp(self.roomData:SpaceId())
    self.levelupRedTip:SetActive(canLevelUp)
    self.levelBtnRedTip:SetActive(canLevelUp)
end

function UIAircraftRoomInfoItem:Refresh(roomData, _closeInfoWindow)
    ---@type AircraftRoomBase
    self.roomData = roomData

    if self.roomData:GetRoomType() == AirRoomType.CoffeeRoom and self.roomData:Level() > 1 then
        self.bookBtnGo:SetActive(true)
        self:UpdateRedPointStatus()
    else
        self.bookBtnGo:SetActive(false)
    end

    self._decorateBtn:SetActive(self._module:IsDecorateUnLocked())

    if self._module:IsAmusementRoom(self.roomData:GetRoomType()) then
        self.buttonFacility.gameObject:SetActive(false)
        self.buttonSettle.gameObject:SetActive(false)
        self.levelupRedTip:SetActive(false)
        self.levelBtnRedTip:SetActive(false)
        self.settleRedTip:SetActive(false)
        return
    end

    self.buttonFacility.gameObject:SetActive(true)
    self.buttonSettle.gameObject:SetActive(true)

    if _closeInfoWindow then
        self:CloseFacilityMsg()
        self:CloseSettleMsg()
    else
        if self.facilityWindow.activeSelf then
            self:RefreshFacilityMsg()
        elseif self.settleInfoWindow.activeSelf then
            self:RefreshSettleMsg()
        end
    end

    local spaceID = self.roomData:SpaceId()
    local canLevelUp = self._module:CanRoomLevelUp(spaceID)
    self.levelupRedTip:SetActive(canLevelUp)
    self.levelBtnRedTip:SetActive(canLevelUp)

    local canSettle = self._module:CanRoomSettlePet(spaceID)
    self.settleRedTip:SetActive(canSettle)
end

function UIAircraftRoomInfoItem:UpdateRedPointStatus()
    ---@type ItemModule
    local itemModule = GameGlobal.GetModule(ItemModule)
    self.bookNewGo:SetActive(itemModule:HasNewBook())
end

function UIAircraftRoomInfoItem:OnClose()
    self:CloseFacilityMsg()
    self:CloseSettleMsg()
end

function UIAircraftRoomInfoItem:SetRoomFunction()
    local _roomType = self.roomData:GetRoomType()

    local facilityCfg = UIAircraftRoomFunctions[_roomType].facilityFunc
    self:DetachEvent(GameEventType.AircraftOnAtomChanged, self.RefreshAtom)

    self.countDownTimer = {}
    --设施信息固定3条
    for i = 1, 3 do
        local cfg = facilityCfg[i]
        local ui = self._facilityItems[i]
        if cfg == nil then
            ui.parent:SetActive(false)
        else
            ui.parent:SetActive(true)
            ui.value.gameObject:SetActive(false)
            ui.title.gameObject:SetActive(false)
            ui.center.transform.parent.gameObject:SetActive(false)
            if cfg.specialTag == nil then
                ui.title:RefreshText(StringTable.Get(cfg.name))

                --倒计时数值
                if cfg.countDown then
                    local time = self.roomData[cfg.func](self.roomData)
                    if time == -1 then
                        ui.value:SetText("--:--:--")
                    elseif time > 0 then
                        self:AddCountdown(
                            function()
                                local _text = nil
                                local time = self.roomData[cfg.func](self.roomData)
                                if time == -1 then
                                    _text = "--:--:--"
                                elseif time == 0 then
                                    --倒计时为0时，不在此处更新数据
                                    _text = "00:00:00"
                                else
                                    _text = HelperProxy:GetInstance():FormatTime_2(math.floor(time))
                                end
                                ui.value:SetText(_text)
                            end
                        )
                    else
                        ui.value:SetText("00:00:00")
                    end
                    ui.value.gameObject:SetActive(true)
                    ui.title.gameObject:SetActive(true)
                else
                    if cfg.isText then
                        --居中显示的文本
                        ui.center.transform.parent.gameObject:SetActive(true)
                        ui.center:RefreshText(StringTable.Get(cfg.name))
                    else
                        ui.value.gameObject:SetActive(true)
                        ui.title.gameObject:SetActive(true)
                        local base, add = self.roomData[cfg.func](self.roomData)
                        if base == nil then
                            base = 0
                        end
                        --速度类数值需乘3600
                        if cfg.isSpeed then
                            base = base * 3600
                        end
                        if cfg.isInt then
                            base = math.floor(base)
                        else
                            base = string.format("%.2f", base)
                        end

                        if cfg.isPercent then
                            base = (math.floor(base * 100)) .. "%"
                        end

                        ui.value:SetText(base)
                    end
                end
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.RoomAndRelic then
                ui.title:RefreshText(StringTable.Get(cfg.name))
                --房间与圣物类型，特殊处理
                local base, add = self.roomData[cfg.func](self.roomData)
                ui.value:SetText(math.floor(base) .. "/" .. math.floor(add))
                ui.value.gameObject:SetActive(true)
                ui.title.gameObject:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.DoubleCouponStore then
                ui.title:RefreshText(StringTable.Get(cfg.name))
                --资源室，双倍券存储
                local cur = self.roomData:GetResCardCount()
                local ceiling, bonus = self.roomData:GetResCardLimit()
                ceiling = math.floor(ceiling)
                -- if cur > ceiling then
                --     cur = ceiling
                -- end
                ui.value:SetText(math.floor(cur) .. "/" .. math.floor(ceiling))
                ui.value.gameObject:SetActive(true)
                ui.title.gameObject:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.DrawCouponStore then
                ui.title:RefreshText(StringTable.Get(cfg.name))
                --灯塔室，抽卡券存储
                local cur = self.roomData:GetHeartAmberCount()
                local ceiling, bonus = self.roomData:GetOutputLimit()
                ceiling = math.floor(ceiling)
                if bonus then
                    bonus = math.floor(bonus)
                end
                ui.value:SetText(math.floor(cur) .. "/" .. math.floor(ceiling))
                ui.value.gameObject:SetActive(true)
                ui.title.gameObject:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.AtomStore then
                ui.title:RefreshText(StringTable.Get(cfg.name))
                self._atomValue = ui.value
                self:RefreshAtom()
                self:AttachEvent(GameEventType.AircraftOnAtomChanged, self.RefreshAtom)
                ui.value.gameObject:SetActive(true)
                ui.title.gameObject:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.SmeltRoomTip then
                ui.title:RefreshText(StringTable.Get(self.roomData:FacilityTip()))
                ui.value:SetText("")
                ui.value.gameObject:SetActive(true)
                ui.title.gameObject:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.DispatchMaxCount then --派遣次数上限
                ui.title:RefreshText(StringTable.Get(cfg.name))
                local cfg = self.roomData:GetRoomConfig()
                ui.value:SetText(cfg.DispatchMax)
                ui.value.gameObject:SetActive(true)
                ui.title.gameObject:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.DispatchRecoverOne then --恢复1次派遣
                ui.title:RefreshText(StringTable.Get(cfg.name))
                local seconds = self.roomData:GetRestoreTime()
                local hour = seconds / 3600
                ui.value:SetText(StringTable.Get("str_dispatch_room_hour", string.format("%.1f", hour)))
                ui.value.gameObject:SetActive(true)
                ui.title.gameObject:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.DispatchTaskMaxStr then --任务最高星级
                ui.title:RefreshText(StringTable.Get(cfg.name))
                local cfg = self.roomData:GetRoomConfig()
                ui.value:SetText(StringTable.Get("str_dispatch_room_task_max_star_num", cfg.MaxTaskStar))
                ui.value.gameObject:SetActive(true)
                ui.title.gameObject:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.TapeStorage then
                ui.title:RefreshText(StringTable.Get(cfg.name))
                ---@type AircraftTacticRoom
                local room = self.roomData
                local num = room:GetCartridgeGiftCount() + #room:GetCartridgeList()
                local ceiling = room:GetCartridgeLimit()
                ui.value:SetText(num .. "/" .. ceiling)
                ui.value.gameObject:SetActive(true)
                ui.title.gameObject:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.TapeCountdown then
            end
        end
    end

    local settleCfg = UIAircraftRoomFunctions[_roomType].settleFunc
    --入住信息固定2条
    for i = 1, 2 do
        local cfg = settleCfg[i]
        local ui = self._settleItems[i]
        if cfg == nil then
            ui.parent:SetActive(false)
        else
            if cfg.specialTag == nil then
                local base, add = self.roomData[cfg.func](self.roomData)

                --增益
                local gain = false
                if cfg.isNagative then
                    --负面效果时，add为负数为增益效果
                    if add and add < 0 then
                        gain = true
                    end
                else
                    if add and add > 0 then
                        gain = true
                    end
                end

                --有增益
                if gain then
                    ui.parent:SetActive(true)
                    ui.title:RefreshText(StringTable.Get(cfg.name))

                    if cfg.isSpeed then
                        add = add * 3600
                    end
                    if cfg.isInt then
                        add = math.ceil(add)
                    else
                        add = string.format("%.2f", add)
                    end
                    if cfg.isPercent then
                        add = math.floor((math.abs(add) / base) * 100) .. "%"
                    end
                    ui.value:SetText(add)
                else
                    ui.parent:SetActive(false)
                end
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.Ambient2Liking then
                --氛围与好感度/时，特殊处理
                local base, add = self.roomData[cfg.func](self.roomData)
                local cfgValue = Cfg.cfg_aircraft_central_room[self.roomData:RoomId()].AmbientToAffinity
                cfgValue = math.floor(cfgValue / 3600)
                base = math.floor(base / 3600)
                --有增益
                if base ~= cfgValue then
                    ui.parent:SetActive(true)
                    ui.title:RefreshText(StringTable.Get(cfg.name))
                    ui.value:SetText(base .. "/" .. add)
                else
                    ui.parent:SetActive(false)
                end
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.AtomDiscount then
                ui.title:RefreshText(StringTable.Get(cfg.name))
                local dis = self.roomData:AtomDiscount()
                if dis < 1 then
                    ui.value:SetText(string.format("%.2f%%", (1 - dis) * 100))
                else
                    ui.value:SetText("0%")
                end
                ui.parent:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.DispatchRecoverSpeedUp then
                ui.parent:SetActive(true)
                local seconds = self.roomData:GetSpeedUpTime()
                ui.title:RefreshText(StringTable.Get(cfg.name))
                local timeStr = ""
                if seconds >= 1 then
                    local hour = math.floor(seconds / 3600)
                    seconds = seconds - hour * 3600
                    if hour > 0 then
                        timeStr = StringTable.Get("str_dispatch_room_task_detail_hour", hour)
                    end
                    local min = math.floor(seconds / 60)
                    if min > 0 then
                        timeStr = timeStr .. StringTable.Get("str_dispatch_room_task_detail_min", min)
                    end
                end
                ui.value:SetText(timeStr)
                ui.parent:SetActive(true)
            elseif cfg.specialTag == UIAircraftRoomFuncSpecailTag.TacticWorkSkill then
                ui.parent:SetActive(false)
                ---@type AircraftTacticRoom
                local room = self.roomData
                local base, add = room:GetRoomResCD()
                if add and add < 0 then --小于0代表有工作技加成
                    ui.title:RefreshText(StringTable.Get(cfg.name))
                    add = -math.ceil(add)
                    ui.value:SetText(HelperProxy:GetInstance():FormatTime_3(add))
                    ui.parent:SetActive(true)
                end
            end
        end
    end
end

function UIAircraftRoomInfoItem:AddCountdown(func)
    func()
    local timer = GameGlobal.Timer():AddEventTimes(1000, TimerTriggerCount.Infinite, func)
    self.countDownTimer[#self.countDownTimer + 1] = timer
end

-----------------------facility------------------------------
function UIAircraftRoomInfoItem:CleanFacilityMsg()
    for _, value in ipairs(self.countDownTimer) do
        GameGlobal.Timer():CancelEvent(value)
    end
    self.countDownTimer = {}
    self:DetachEvent(GameEventType.AircraftOnAtomChanged, self.RefreshAtom)
end

function UIAircraftRoomInfoItem:RefreshAtom()
    ---@type RoleModule
    local roleModule = GameGlobal.GetModule(RoleModule)
    local count = roleModule:GetAtom()
    if self.roomData == nil then
        Log.exception("房间数据为空，不能刷新原子剂数量")
    end

    if self.roomData:GetRoomType() ~= AirRoomType.SmeltRoom then
        Log.exception("房间类型错误！不能刷新原子剂数量:", self.roomData:GetRoomType())
    end

    local ceiling = self.roomData:GetStorageMax()
    self._atomValue:SetText(count .. "/" .. ceiling)
end

function UIAircraftRoomInfoItem:ShowFacilityMsg()
    self._panelAnim:Play("uieff_FCRoomInfo_Panel_Show")
    self.facilityWindow:SetActive(true)
    self:RefreshFacilityMsg()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.GuideOpenAirRoomFacilityUI, self.roomData:GetRoomType())
end

function UIAircraftRoomInfoItem:RefreshFacilityMsg()
    --建筑用途
    self.localizationTextDes:SetText(self.roomData:GetRoomDescription())
    self.textRoomName:SetText(StringTable.Get(self.roomData:GetRoomName()))
    self.textRoomLevel:SetText(" Lv." .. self.roomData:Level())
    self.rawImageUsage:LoadImage(self.roomData:GetRoomIcon2())

    --每次刷新都清除之前的计时器
    self:CleanFacilityMsg()
    self:SetRoomFunction()

    --是否可打开升级界面
    local _canOpenLevelUp = self.roomData:Level() < self.roomData:MaxLevel()

    self._canLevelDown, self._cantLevelDownReason = self:CanLevelDown()

    if _canOpenLevelUp then
        self:DoTextColor(self.levelUpText, Color(1, 1, 1), 0)
        self.levelUpButton.interactable = true
    else
        self:DoTextColor(self.levelUpText, Color(70 / 255, 70 / 255, 70 / 255), 0)
        self.levelUpButton.interactable = false
    end

    if self._canLevelDown then
        self:DoTextColor(self.levelDownText, Color(1, 1, 1), 0)
        self.levelDownButton.interactable = true
    else
        self:DoTextColor(self.levelDownText, Color(70 / 255, 70 / 255, 70 / 255), 0)
        self.levelDownButton.interactable = false
    end
end

function UIAircraftRoomInfoItem:CloseFacilityMsgAnim()
    if not self._tlPlayer:IsPlaying() then
        local tl =
            EZTL_Sequence:New(
            {
                EZTL_PlayAnimation:New(self._panelAnim, "uieff_FCRoomInfo_Panel_Hide"),
                EZTL_Callback:New(
                    function()
                        self.buttonFacility.interactable = true
                        self:CleanFacilityMsg()
                        self.facilityWindow:SetActive(false)
                        self:UnLock(self:GetName())
                    end
                )
            }
        )
        self:Lock(self:GetName())
        self._tlPlayer:Play(tl)
    end
end

function UIAircraftRoomInfoItem:CloseFacilityMsg()
    self.buttonFacility.interactable = true
    self:CleanFacilityMsg()
    self.facilityWindow:SetActive(false)
end
---------------------end------------------------------
-----------------settle---------------------
function UIAircraftRoomInfoItem:CleanSettleMsg()
    for k, v in pairs(self.settledWidget) do
        v:Close()
    end
    self.settledWidget = {}
    self:DetachEvent(GameEventType.AircraftSettledPetChanged, self.RefreshSettleMsg)
end

function UIAircraftRoomInfoItem:ShowSettleMsg()
    self.settleInfoWindow:SetActive(true)
    self._panelAnim:Play("uieff_FCRoomInfo_Panel_Show")
    self:RefreshSettleMsg()
    self:AttachEvent(GameEventType.AircraftSettledPetChanged, self.RefreshSettleMsg)
    GameGlobal.EventDispatcher():Dispatch(GameEventType.GuideOpenAirRoomSettleUI, self.roomData:GetRoomType())
end

function UIAircraftRoomInfoItem:RefreshSettleMsg()
    if not self.settleInfoWindow.activeSelf then
        return
    end

    self:CleanSettleMsg()

    self.settledCount = self.roomData:GetPetCount()
    self.settledCeiling = self.roomData:GetPetCountLimit()
    self.settledPets = self.roomData:GetPetsId()
    self.textSettleCount:SetText(string.format("%s/%s", self.settledCount, self.settledCeiling))

    self:SpawnListView()
end

function UIAircraftRoomInfoItem:CloseSettleMsgAnim()
    self.buttonSettle.interactable = true
    self:CleanSettleMsg()
    if not self._tlPlayer:IsPlaying() then
        local tl =
            EZTL_Sequence:New(
            {
                EZTL_PlayAnimation:New(self._panelAnim, "uieff_FCRoomInfo_Panel_Hide"),
                EZTL_Callback:New(
                    function()
                        self.settleInfoWindow:SetActive(false)
                        self:UnLock(self:GetName())
                    end
                )
            }
        )
        self:Lock(self:GetName())
        self._tlPlayer:Play(tl)
    end
end

function UIAircraftRoomInfoItem:CloseSettleMsg()
    self.buttonSettle.interactable = true
    self:CleanSettleMsg()
    self.settleInfoWindow:SetActive(false)
end
-------end----------
--房间是否可升级
function UIAircraftRoomInfoItem:CanLevelUp()
    return self.roomData:Level() < self.roomData:MaxLevel()
end

---@return boolean,string 判断是否可降级，返回结果和不可降级原因
function UIAircraftRoomInfoItem:CanLevelDown()
    local level = self.roomData:Level()
    local type = self.roomData:GetRoomType()

    if type == AirRoomType.CentralRoom then
        --主控室不可降级
        return false, string.format(
            StringTable.Get("str_aircraft_tip_cant_leveldown"),
            StringTable.Get(self.roomData:GetRoomName())
        )
    end

    if level == 1 then
        --棱镜室、秘境室、资源室、灯塔室不可清除
        if
            type == AirRoomType.MazeRoom or type == AirRoomType.PrismRoom or type == AirRoomType.ResourceRoom or
                type == AirRoomType.TowerRoom or
                type == AirRoomType.SmeltRoom or
                type == AirRoomType.DispatchRoom or
                type == AirRoomType.TacticRoom
         then
            return false, string.format(
                StringTable.Get("str_aircraft_tip_cant_clear"),
                StringTable.Get(self.roomData:GetRoomName())
            )
        end
    end

    if type == AirRoomType.PowerRoom then
        --能源室需判定星能是否足够
        local deltaPower = 0
        local room_cfg = self.roomData:GetConfig()
        local prev_powerroom_cfg = Cfg.cfg_aircraft_power_room[room_cfg.PrevLevelID]
        if prev_powerroom_cfg == nil then
            deltaPower = self.roomData:GetPowerLimit()
        else
            deltaPower = self.roomData:GetPowerLimit() - prev_powerroom_cfg.AddPower
        end

        if self._module:GetMaxPower() - deltaPower < self._module:CalcAllRoomUsePower() then
            return false, StringTable.Get("str_aircraft_tip_power_not_enough")
        end
    end
    return true, nil
end

function UIAircraftRoomInfoItem:ButtonFacilityOnClick(go)
    if self.buttonFacility.interactable then
        --打开面板时通知场景内点击交互的星灵停止行为
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftTryStopClickAction)
        GameGlobal.TaskManager():StartTask(
            self.ReqData,
            self,
            function()
                if self.active then
                    self:CloseSettleMsgAnim()
                    self:ShowFacilityMsg()
                end
            end
        )
        self.buttonFacility.interactable = false
    else
        self:CloseFacilityMsgAnim()
    end
end

function UIAircraftRoomInfoItem:ReqData(TT, callBack)
    self:Lock(self:GetName())
    local ack = self._module:AircraftUpdate(TT)
    if ack:GetSucc() then
        callBack()
    else
        ToastManager.ShowToast(self._module:GetErrorMsg(ack:GetResult()))
    end
    self:UnLock(self:GetName())
end

function UIAircraftRoomInfoItem:ButtonSettleOnClick(go)
    if self.buttonSettle.interactable then
        --打开面板时通知场景内点击交互的星灵停止行为
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftTryStopClickAction)
        GameGlobal.TaskManager():StartTask(
            self.ReqData,
            self,
            function()
                if self.active then
                    self:CloseFacilityMsgAnim()
                    self:ShowSettleMsg()
                end
            end
        )
        self.buttonSettle.interactable = false
    else
        self:CloseSettleMsgAnim()
    end
end

function UIAircraftRoomInfoItem:BookBtnOnClick(go)
    self:ShowDialog("UIBookController")
end

function UIAircraftRoomInfoItem:ButtonLevelUpOnClick(go)
    if self.roomData:Level() < self.roomData:MaxLevel() then
        self:ShowDialog("UIAircraftRoomLevelUpController", self.roomData)
    end
end

function UIAircraftRoomInfoItem:ButtonLevelDownOnClick(go)
    if not self._canLevelDown then
        ToastManager.ShowToast(self._cantLevelDownReason)
        return
    end

    local level = self.roomData:Level()
    if level == 1 then
        self:ShowDialog("UIAircraftConfirmDialogController", self.roomData)
    elseif level > 1 then
        self:ShowDialog("UIAircraftRoomLevelDownController", self.roomData)
    end
end

function UIAircraftRoomInfoItem:ImageFacilityMaskOnClick(go)
    self:CloseFacilityMsgAnim()
end
function UIAircraftRoomInfoItem:ImageSettleMaskOnClick(go)
    self:CloseSettleMsgAnim()
end
function UIAircraftRoomInfoItem:ButtonClearAllOnClick(go)
    if #self.settledPets <= 0 then
        return
    end

    GameGlobal.TaskManager():StartTask(self.RequestClearPets, self)
end

function UIAircraftRoomInfoItem:RequestClearPets(TT)
    if #self.settledPets == 0 then
        Log.warn("[Aircraft] not pet to clear")
        return
    end

    self:Lock(self:GetName())
    local result = self._module:RequestEnterPet(TT, self.roomData:SpaceId(), {})
    if result:GetSucc() then
        --移除交互的星灵
        GameGlobal.EventDispatcher():Dispatch(GameEventType.ForceRemoveInteractivePets, self.settledPets)

        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftSettledPetChanged)
    else
        ToastManager.ShowToast(self._module:GetErrorMsg(result:GetResult()))
    end
    self:UnLock(self:GetName())
end

function UIAircraftRoomInfoItem:RequestRemoveOnePet(TT, pstid, idx)
    self:Lock(self:GetName())
    local result = self._module:RequestCheckInOnePet(TT, self.roomData:SpaceId(), idx, 0, 0, 0)
    if result:GetSucc() then
        local tab = {}
        table.insert(tab, pstid)
        --移除交互的星灵
        GameGlobal.EventDispatcher():Dispatch(GameEventType.ForceRemoveInteractivePets, tab)

        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftSettledPetChanged)
    else
        ToastManager.ShowToast(self._module:GetErrorMsg(result:GetResult()))
    end
    self:UnLock(self:GetName())
end

function UIAircraftRoomInfoItem:DoTextColor(text, targetColor, time)
    text:CrossFadeColor(targetColor, time, true, false)
end

function UIAircraftRoomInfoItem:GetItem(index)
    return self.items and self.items[index] and self.items[index]:GetGameObject()
end

--打开入住
function UIAircraftRoomInfoItem:OpenEnterBuild()
    self:ButtonSettleOnClick()
end
--打开升级
function UIAircraftRoomInfoItem:OpenLvUp()
    self:ButtonFacilityOnClick()
end

function UIAircraftRoomInfoItem:ButtonDecorateOnClick()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftEnterDecorateMode, self.roomData:SpaceId())
end
