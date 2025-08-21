---风船建造界面
---@class UIAircraftBuildRoomController : UIController
_class("UIAircraftBuildRoomController", UIController)
UIAircraftBuildRoomController = UIAircraftBuildRoomController

function UIAircraftBuildRoomController:OnShow(uiParams)
    --空间ID
    self._spaceID = uiParams[1]

    self._topBar = self:GetUIComponent("UISelectObjectPath", "Topbar")

    self._matsPool = self:GetUIComponent("UISelectObjectPath", "matsPool")
    self._matsPoolGrid = self:GetUIComponent("GridLayoutGroup", "matsPool")
    self._matsPoolScrollRect = self:GetUIComponent("ScrollRect", "matsScrollView")

    self._icon = self:GetUIComponent("RawImageLoader", "Icon")
    self._power = self:GetUIComponent("UILocalizationText", "power")
    self._buildCount = self:GetUIComponent("UILocalizationText", "buildCount")
    self._buildName = self:GetUIComponent("UILocalizationText", "buildName")
    self._time = self:GetUIComponent("UILocalizationText", "time")
    self._des = self:GetUIComponent("UILocalizationText", "roomDes")

    self._powerBg = self:GetUIComponent("Image", "powerBg")

    local topBar = self._topBar:SpawnObject("UIAircraftTopBarItem")
    topBar:SetData(
        true,
        function()
            self:CloseDialog()
        end,
        nil,
        nil,
        true
    )

    self:AttachEvent(GameEventType.ItemCountChanged, self.OnItemCountChanged)

    --获取所有可建筑列表
    -- BuildType,Count, MaxNum, IsFull
    self._buildArray = self._module:GetBuildTypeSorted(self._spaceID)
    local buildID = self:BuildType2BuildID(self._buildArray[1].BuildType)
    self._room_cfg = Cfg.cfg_aircraft_room {}
    self._build = self:GetBuildCls(self._room_cfg[buildID], self._buildArray[1].Count, self._buildArray[1].MaxNum)

    self._atlas = self:GetAsset("UIAircraftBuildRoom.spriteatlas", LoadType.SpriteAtlas)

    self:OnValue()

    self:InitMatsList()
end

function UIAircraftBuildRoomController:OnValue()
    self._icon:LoadImage(self._build._icon)
    self._power:SetText(StringTable.Get("str_aircraft_tip_build_room_need_power") .. self._build._needPower)
    self._buildName:SetText(StringTable.Get(self._build._name))
    self._buildCount.text =
        "<color=#ffffff>" ..
        self._build._nCount .. "</color><color=#ff6b0d>/</color><color=#d5d5d5>" .. self._build._uCount .. "</color>"
    self._time:SetText(self:GetBuildTime(self._build._upLvTime))
    self._des:SetText(self._build._des)
end

function UIAircraftBuildRoomController:GetBuildTime(min)
    local timeStr = ""
    if min > 60 then
        local hourStr = ""
        if min / 60 >= 10 then
            hourStr = min / 60
        else
            hourStr = "0" .. min / 60
        end
        local minStr = ""
        if min % 60 >= 10 then
            minStr = min % 60
        else
            minStr = "0" .. min % 60
        end
        timeStr = hourStr .. ":" .. minStr .. ":" .. "00"
    else
        local minStr = ""
        if min >= 10 then
            minStr = min
        else
            minStr = "0" .. min
        end
        timeStr = minStr .. ":" .. "00"
    end
    return timeStr
end

function UIAircraftBuildRoomController:BuildType2BuildID(type)
    local cfg = Cfg.cfg_aircraft_room {RoomType = type, Level = 1}
    if cfg then
        return cfg[1].ID
    end
end

function UIAircraftBuildRoomController:OnHide()
    self:DetachEvent(GameEventType.ItemCountChanged, self.OnItemCountChanged)
    self._spaceID = nil
    self._topBar = nil
    self._matsPool = nil
    self._matsPoolGrid = nil
    self._matsPoolScrollRect = nil
    self._icon = nil
    self._power = nil
    self._buildCount = nil
    self._buildName = nil
    self._time = nil
    self._itemInfo = nil
    self._buildArray = nil
    self._build = nil
    self._matItems = nil
    self._module = nil
end

function UIAircraftBuildRoomController:OnItemCountChanged()
    self:InitMatsList()
end

---@field UpperLeft UnityEngine.TextAnchor
---@field UpperCenter UnityEngine.TextAnchor
---@field UpperRight UnityEngine.TextAnchor
---@field MiddleLeft UnityEngine.TextAnchor
---@field MiddleCenter UnityEngine.TextAnchor
---@field MiddleRight UnityEngine.TextAnchor
---@field LowerLeft UnityEngine.TextAnchor
---@field LowerCenter UnityEngine.TextAnchor
---@field LowerRight UnityEngine.TextAnchor
---@param matList AircrafBuildNeedMat
---需要的材料集合
function UIAircraftBuildRoomController:InitMatsList()
    local len = table.count(self._build._upLvCost)

    if len > 4 then
        self._matsPoolScrollRect.inertia = false
        self._matsPoolGrid.childAlignment = UnityEngine.TextAnchor.MiddleLeft
    else
        self._matsPoolGrid.childAlignment = UnityEngine.TextAnchor.MiddleCenter
        self._matsPoolScrollRect.inertia = true
    end

    self._matsPool:SpawnObjects("UIAircraftMatPrefab", len)
    ---@type UIAircraftMatPrefab[]
    self._matItems = self._matsPool:GetAllSpawnList()
    for i = 1, len do
        self._matItems[i]:SetData(
            i,
            self._build._upLvCost[i],
            function(matid, pos)
                --打开获取途径
                self:ShowDialog("UIItemGetPathController", matid)
            end
        )
    end

    local tmpPower = self._module:GetPower()

    if self._build._needPower > tmpPower then
        self._powerBg.sprite = self._atlas:GetSprite("wind_jianzao_di3")
    end
end

--注册选中事件
function UIAircraftBuildRoomController:Constructor()
    ---@type AircraftModule
    self._module = GameGlobal.GetModule(AircraftModule)
    if not self._module then
        ToastManager.ShowToast("module is nil!")
    end
    self._centralRoomID = self._module:GetCentralRoom():RoomId()
end

---@param v buildInfo 读表取出的建筑信息
---@return AircrafBuildData
function UIAircraftBuildRoomController:GetBuildCls(v, nCount, uCount)
    ---@type AircrafBuildData
    local build = AircrafBuildData:New()

    --建筑需要类集合
    local needBuildCondition = {}
    for i = 1, table.count(v.NeedRoom) do
        ---@type AircrafBuildNeedCondition
        local condition = AircrafBuildNeedCondition:New()
        condition:Init(v.NeedRoom[i][1], v.NeedRoom[i][2], v.NeedRoom[i][3])
        needBuildCondition[i] = condition
    end

    --升级需要材料
    local upNeedMat = {}
    for i = 1, table.count(v.Need) do
        ---@type AircrafBuildNeedMat
        local need = AircrafBuildNeedMat:New()
        need:Init(v.Need[i][1], v.Need[i][2])
        upNeedMat[i] = need
    end

    --降级返还材料
    local downReturnMat = {}

    local des
    local cfgs = Cfg.cfg_aircraft_room{RoomType=v.RoomType}
    if cfgs and table.count(cfgs) > 0 then
        des = StringTable.Get(cfgs[1].SimpleDes)
    end

    build:Init(
        v.ID,
        v.RoomType,
        v.Level,
        v.Name,
        v.RoomTypeIcon2,
        des,
        v.PetNum,
        v.ChangeMood,
        v.PrevLevelID,
        v.NextLevelID,
        needBuildCondition,
        upNeedMat,
        downReturnMat,
        v.NeedPower,
        v.LevelUpTime,
        nCount,
        uCount
    )

    return build
end

function UIAircraftBuildRoomController:sureOnClick()
    local tmpPower = self._module:GetPower()

    if self._build._needPower > tmpPower then
        ToastManager.ShowToast(StringTable.Get("str_toast_manager_star_power_is_not_enough"))
        return
    end
    local enough = true
    local idx = 0

    for i = 1, #self._matItems do
        if false == self._matItems[i]:CheckCountEnough() then
            enough = false
            idx = i
            break
        end
    end

    if enough then
        GameGlobal.TaskManager():StartTask(self.BuildBuilding, self, self._build._id)
    else
        self._matItems[idx]:Blink()
        ToastManager.ShowToast(StringTable.Get("str_aircraft_tip_mat_not_enough"))
    end
end

function UIAircraftBuildRoomController:BuildBuilding(TT, buildID)
    --[[
        点击未清理的空间，直接打开建造界面，确定后清理+建造，不再单独单独清理空间，也不考虑清理后获得奖励
        2020.11.12 Track任务：12520
        清理和建造都走这里
    ]]
    self:Lock(self:GetName())
    local needClean = true
    local spaceData = self._module:GetSpaceInfo(self._spaceID)
    if spaceData then
        local spaceState = spaceData.space_status
        if spaceState == SpaceState.SpaceStateNeedClean then
            needClean = true
        elseif spaceState == SpaceState.SpaceStateEmpty then
            needClean = false
        else
            Log.exception("空间状态错误，不能建造：", spaceState)
        end
    else
        Log.exception("空间数据为空，不能建造，spaceid：", self._spaceID)
    end

    if needClean then
        local cleanRes, msg = self._module:RequestCleanAndBuild(TT, self._spaceID, buildID)
        if not cleanRes:GetSucc() then
            Log.error("RequestCleanAndBuild空间失败：", self._spaceID)
            ToastManager.ShowToast(self._module:GetErrorMsg(cleanRes:GetResult()))
            self:UnLock(self:GetName())
            return
        end
    else
        local res = self._module:RequestBuildRoom(TT, self._spaceID, buildID)
        if not res:GetSucc() then
            Log.error("RequestBuildRoom空间失败：", self._spaceID)
            ToastManager.ShowToast(self._module:GetErrorMsg(res:GetResult()))
            self:UnLock(self:GetName())
            return
        end
    end
    GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftPlayDoorAnim, AircraftDoorAnim.BuildRoom, self._spaceID)
    --刷新ui
    GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftRequestDataAndRefreshMainUI)
    self:CloseDialog()
    ToastManager.ShowToast(StringTable.Get("str_aircraft_build_success"))

    self:UnLock(self:GetName())
end

function UIAircraftBuildRoomController:cancelOnClick()
    --星能不足
    if self._event then
        GameGlobal.Timer():CancelEvent(self._event)
    end
    self._powerBg.sprite = self._atlas:GetSprite("wind_jianzao_di3")
    self:CloseDialog()
end

--帮助说明
function UIAircraftBuildRoomController:infoBtnOnClick()
    if not self._build then
        return
    end
    local roomType = self._build._roomType
    if roomType == AirRoomType.AisleRoom then --过道
    elseif roomType == AirRoomType.CentralRoom then --主控室
        self:ShowDialog("UIHelpController", "UIAircraftCentralRoom")
    elseif roomType == AirRoomType.PowerRoom then --能源室
        self:ShowDialog("UIHelpController", "UIAircraftPowerRoom")
    elseif roomType == AirRoomType.MazeRoom then --秘境室
        self:ShowDialog("UIHelpController", "UIAircraftMazeRoom")
    elseif roomType == AirRoomType.ResourceRoom then --资源室
        self:ShowDialog("UIHelpController", "UIAircraftResourceRoom")
    elseif roomType == AirRoomType.PrismRoom then --棱镜室
        self:ShowDialog("UIHelpController", "UIAircraftPrismRoom")
    elseif roomType == AirRoomType.TowerRoom then --灯塔室
        self:ShowDialog("UIHelpController", "UIAircraftTowerRoom")
    elseif roomType == AirRoomType.EvilRoom then --恶鬼室
    elseif roomType == AirRoomType.PurifyRoom then --净化室
    elseif roomType == AirRoomType.DispatchRoom then --派遣室
        self:ShowDialog("UIHelpController", "UIDispatchDetailController")
    elseif roomType == AirRoomType.SmeltRoom then
        self:ShowDialog("UIHelpController", "UIAircraftSmeltRoom")
    elseif roomType == AirRoomType.TacticRoom then
        self:ShowDialog("UIHelpController", "UIAircraftTactic")
    end
end

function UIAircraftBuildRoomController:maskOnClick()
    self:cancelOnClick()
end
