---@class UIAircraftRoomCamera:Object
_class("UIAircraftRoomCamera", Object)
UIAircraftRoomCamera = UIAircraftRoomCamera

function UIAircraftRoomCamera:Constructor()
    self._enable = false

    ---@type AircraftCameraControllerBase
    self._controller = nil
    ---@type AircraftCameraSphere
    self._sphereCamera = AircraftCameraSphere:New()
    ---@type AircraftCameraStrange
    self._strangeCamera = AircraftCameraStrange:New()

    self._lerpParam = Cfg.cfg_aircraft_camera["lerpParam"].Value

    ---@type AircraftRoom 目标room
    self._roomData = nil

    self.PressState = {
        None = 1,
        Timing = 2, --计时中进度条增长
        Pressing = 3, --星灵抬起但未拖动
        Dragging = 4 --抬起后拖动
    }

    --当前长按状态
    self.pressState = self.PressState.None
    ---@type AircraftPet
    self.pressingPet = nil

    --长按开始的时间
    self.pressStartTime = 10000

    self.pickUpTime = Cfg.cfg_aircraft_camera["petLongPressTime"].Value

    self._layers = {}
    self._layers.ground = 1 << 13
    self._layers.pet = 1
    self._layers.award = 1 << 18

    self.zhanliReq = nil
    self.bukezhanliReq = nil
    self.zhanliEff = nil
    self.bukezhanliEff = nil
    self.curEff = nil
end

function UIAircraftRoomCamera:Init(camera, _3dmanager)
    ---@type UnityEngine.Camera
    self._camera = camera
    ---@type UIAircraft3DManager
    self._3dManager = _3dmanager
    ---@type AircraftInputManager
    self._input = self._3dManager:InputManager()

    self.zhanliReq = ResourceManager:GetInstance():SyncLoadAsset("eff_bukezhanli.prefab", LoadType.GameObject)
    self.bukezhanliReq = ResourceManager:GetInstance():SyncLoadAsset("eff_kezhanli.prefab", LoadType.GameObject)
    self.zhanliEff = self.zhanliReq.Obj
    self.bukezhanliEff = self.bukezhanliReq.Obj
    self.curEff = self.zhanliEff
end

function UIAircraftRoomCamera:SetActive(active)
    self._enable = active
end

function UIAircraftRoomCamera:FadeIn(TT)
    local duration = 0
    local startTime = GameGlobal:GetInstance():GetCurrentTime()
    local groundPos = self._roomData:GetGroundPos()

    local cfg = Cfg.cfg_aircraft_room_camera[self._roomData:GetRoomLogicData():SpaceId()]
    local offset = Vector3(cfg.CamDeltaPos[1], cfg.CamDeltaPos[2], cfg.CamDeltaPos[3])
    local originPos = self._camera.transform.position
    local originRot = self._camera.transform.rotation
    local targetPos = groundPos + offset
    local targetRot = nil

    if self._controller:GetType() == AircraftCameraType.Strange then
        local rot = Vector3(cfg.CamInitRot[1], cfg.CamInitRot[2], cfg.CamInitRot[3])
        targetRot = Quaternion.Euler(rot)
        while duration < 1000 do
            duration = GameGlobal:GetInstance():GetCurrentTime() - startTime

            self._camera.transform.position = Vector3.Lerp(originPos, targetPos, duration / 1000)
            YIELD(TT)
        end
        self._camera.transform.position = targetPos

        duration = 0
        startTime = GameGlobal:GetInstance():GetCurrentTime()
        while duration < 500 do
            duration = GameGlobal:GetInstance():GetCurrentTime() - startTime
            self._camera.transform.rotation = Quaternion.Lerp(originRot, targetRot, duration / 500)
            YIELD(TT)
        end
    elseif self._controller:GetType() == AircraftCameraType.Sphere then
        local lookAtPos = groundPos + Vector3(cfg.SphereOffset[1], cfg.SphereOffset[2], cfg.SphereOffset[3])
        targetRot = Quaternion.LookRotation(lookAtPos - targetPos, Vector3.up)
        while duration < 1000 do
            duration = GameGlobal:GetInstance():GetCurrentTime() - startTime

            self._camera.transform.position = Vector3.Lerp(originPos, targetPos, duration / 1000)
            self._camera.transform.rotation = Quaternion.Lerp(originRot, targetRot, duration / 1000)
            YIELD(TT)
        end
    end

    self._camera.transform.position = targetPos
    self._camera.transform.rotation = targetRot
    local guideModule = GameGlobal.GetModule(GuideModule)
end

function UIAircraftRoomCamera:SwitchFromInteract(TT)
    local totalTime = Cfg.cfg_aircraft_camera["translateTime"].Value * 1000
    local duration = 0
    local startTime = GameGlobal:GetInstance():GetCurrentTime()
    local camOrgPos = self._camera.transform.position
    local camOrgRot = self._camera.transform.rotation
    while duration < totalTime do
        duration = GameGlobal:GetInstance():GetCurrentTime() - startTime
        if duration > totalTime then
            duration = totalTime
        end

        self._camera.transform.position = Vector3.Lerp(camOrgPos, self._currentPos, duration / totalTime)
        self._camera.transform.rotation = Quaternion.Lerp(camOrgRot, self._currentRot, duration / totalTime)
        YIELD(TT)
    end
    self._camera.transform.position = self._currentPos
    self._camera.transform.rotation = self._currentRot
end

function UIAircraftRoomCamera:SetTargetRoom(room)
    self._roomData = room
    ---@type AircraftRoom

    local spaceID = self._roomData:GetRoomLogicData():SpaceId()
    local cfg = Cfg.cfg_aircraft_room_camera[spaceID]
    if not cfg then
        Log.exception("找不到相机控制器，空间id：", spaceID)
    end
    if cfg.CamController == 1 then
        --球形
        self._controller = self._sphereCamera
    elseif cfg.CamController == 2 then
        --平视
        self._controller = self._strangeCamera
    end
    --房间内摄像机每次进入房间都初始化一次
    self._controller:Init(self._camera, self._3dManager, room)

    ---某些物体在摄像机靠近时的参数
    local fadeObjects = {}
    if cfg.FadeObjects then
        for i = 1, #cfg.FadeObjects do
            local data = cfg.FadeObjects[i]
            local fo = {}
            fo.position = Vector3(data.pos[1], data.pos[2], data.pos[3])
            fo.minRadius = data.radius[1]
            fo.maxRadius = data.radius[2]
            fadeObjects[i] = fo
        end
    end
    self.fadeObjectsCfg = fadeObjects
    local objs = self._roomData:GetFadeObjects()
    ---@type table<int,FadeComponent>
    self.fadeObjects = {}
    if objs then
        for idx, obj in pairs(objs) do
            self.fadeObjects[idx] = obj:AddComponent(typeof(FadeComponent))
        end
    end
    ---end---
end

function UIAircraftRoomCamera:Dispose()
    self.zhanliReq:Dispose()
    self.bukezhanliReq:Dispose()
    self._controller = nil
    self._sphereCamera:Dispose()
    self._strangeCamera:Dispose()
    self._roomData = nil
end

function UIAircraftRoomCamera:Update(deltaTime)
    if not self._enable then
        return
    end

    ---处理点击操作
    local clicked, clickPos = self._input:GetClick()
    if clicked then
        local clickRay = self._camera:ScreenPointToRay(clickPos)

        ---@type RaycastHit
        local castRes, hitInfo = UnityEngine.Physics.Raycast(clickRay, nil, 1000, self._layers.pet | self._layers.award)
        if castRes then
            if self._roomData:TryClickPet(hitInfo.transform.gameObject) then
                return
            end

            --点到了收集奖励的区域
            if hitInfo.transform.gameObject.name == "award" then
                if self._3dManager:SceneManager():TryCollectAwardInRoom(self._roomData:SpaceID()) then
                    return
                end
            end
        end
    end

    ---处理长按操作
    local longPressing, pressTime, pressPos = self._input:GetLongPress()
    if self.pressState == self.PressState.None then
        if longPressing then
            local pressRay = self._camera:ScreenPointToRay(pressPos)
            local castRes, hitInfo = UnityEngine.Physics.Raycast(pressRay, nil, 1000, self._layers.pet)
            if castRes then
                local pet = self._roomData:TryGetPet(hitInfo.transform.gameObject)
                if pet and pet:CurrentState() ~= AircraftPetActionState.Responding then
                    self.pressState = self.PressState.Timing
                    self.pressingPet = pet
                    self.pressingPet:OnPressBegin()
                    self.pressStartTime = pressTime
                    --显示进度条
                    self._3dManager:SetPressSlider(true, self.pressingPet:CalSliderWorldPos())
                end
            end
        end
    elseif self.pressState == self.PressState.Timing then
        -- self.pressStartTime = pressTime
        local curPressTime = pressTime - self.pressStartTime
        if longPressing then
            if curPressTime < self.pickUpTime then
                --更新计时器
                -- Log.notice(pressTime / self.pickUpTime)
                self._3dManager:SetPressSliderValue(curPressTime / self.pickUpTime)
            else
                self.pressState = self.PressState.Pressing
                self.pressingPet:PickUp()
                self._3dManager:SetPressSlider(false, nil)
            end
        else
            --计时停止
            self.pressState = self.PressState.None
            self.pressingPet:OnCountEnd()
            self._3dManager:SetPressSlider(false, nil)
        end
    elseif self.pressState == self.PressState.Pressing then
        local dragging, dragStartPos, dragEndPos = self._3dManager:InputManager():GetDrag()

        if dragging then
            self.pressState = self.PressState.Dragging
        elseif not dragging and not longPressing then
            --停止长按
            self.pressingPet:OnPressEnd()
            self.pressState = self.PressState.None
        end
    elseif self.pressState == self.PressState.Dragging then
        local dragging, dragStartPos, dragEndPos = self._3dManager:InputManager():GetDrag()
        if dragging then
            --每帧更新
            self:HandleDragPet(dragStartPos, dragEndPos)
        else
            --停止
            self.pressState = self.PressState.None
            self.pressingPet:OnDrop()
            self.pressingPet = nil
            self.curEff:SetActive(false)
        end
    end

    if self.pressState == self.PressState.None then
        --正在发生星灵拖拽则不更新摄像机位置
        self._controller:Update(deltaTime)
        self._currentPos = self._camera.transform.position:Clone()
        self._currentRot = self._camera.transform.rotation:Clone()
        self._currentPos = Vector3.Lerp(self._currentPos, self._controller:GetPos(), self._lerpParam)
        self._currentRot = Quaternion.Lerp(self._currentRot, self._controller:GetRot(), self._lerpParam)
        self._camera.transform.position = self._currentPos
        self._camera.transform.rotation = self._currentRot
    end

    self:HandleFadeObjects()
end

function UIAircraftRoomCamera:SetActive(active)
    self._enable = active
end

function UIAircraftRoomCamera:HandleFadeObjects()
    local pos = self._camera.transform.position
    if self.fadeObjectsCfg then
        for idx, fadeCpt in pairs(self.fadeObjects) do
            local cfg = self.fadeObjectsCfg[idx]
            local min = cfg.minRadius ^ 2
            local max = cfg.maxRadius ^ 2
            local sqrMagnitude = (pos - cfg.position).sqrMagnitude
            if sqrMagnitude > max and fadeCpt.Alpha < 1 then
                fadeCpt.Alpha = 1
            elseif sqrMagnitude < min and fadeCpt.Alpha > 0 then
                fadeCpt.Alpha = 0
            elseif sqrMagnitude > min and sqrMagnitude < max then
                fadeCpt.Alpha = (sqrMagnitude - min) / (max - min)
            end
        end
    end
end

function UIAircraftRoomCamera:HandleDragPet(dragStartPos, dragEndPos)
    local dragRay = self._camera:ScreenPointToRay(dragEndPos)
    ---@type RaycastHit
    local castRes, hitInfo = UnityEngine.Physics.Raycast(dragRay, nil, 1000, self._layers.ground)

    if castRes and self._roomData:CheckGround(hitInfo.transform) then
        local canStay = UnityEngine.AI.NavMesh.SamplePosition(hitInfo.point, nil, 0.5, UnityEngine.AI.NavMesh.AllAreas)

        if canStay then
            self.curEff:SetActive(false)
            self.curEff = self.zhanliEff
        else
            self.curEff:SetActive(false)
            self.curEff = self.bukezhanliEff
        end
        self.curEff:SetActive(true)
        self.curEff.transform.position = hitInfo.point + Vector3(0, 0.1, 0)
        self.pressingPet:OnDrag(hitInfo.point)
    end
end
