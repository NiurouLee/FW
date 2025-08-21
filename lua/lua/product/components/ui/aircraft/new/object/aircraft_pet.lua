---@class AircraftPet:Object
_class("AircraftPet", Object)
AircraftPet = AircraftPet

function AircraftPet:Constructor(petData, main)
    ---@type AircraftPetData
    self._petData = petData
    ---@type AircraftMain
    self._main = main
    self._tmpID = self._petData:TmpID()
    --皮肤ID临时获取方式，风船里所有与表现有关的资源，如：模型、动作、特效等都用皮肤ID获取
    self._prefabName = self._petData:Prefab()
    local id = string.gsub(self._prefabName, ".prefab", "")
    self._skinID = tonumber(id)                --20210706 这里是prefab的前缀 并不是本次增加的时装id
    self._clothSkinID = self._petData:SkinID() --20210706 这里是时装id
    ---@type UnityEngine.GameObject 星灵壳物体
    self._petShell = GameObjectHelper.CreateEmpty(self._skinID .. "_shell", nil)
    self._shellTransform = self._petShell.transform
    ---@type AirPetState
    self._state = AirPetState.None

    --当前交互家具id
    self._currentFurnitureType = 0
    --该星灵占据了的家具，星灵在走到家具上之前就已经占据了该家具上的点
    self._occupyFurnitureInstanceID = 0

    local cfg = Cfg.cfg_aircraft_pet[self._tmpID]
    if not cfg then
        AirError("aircraft_pet表中找不到配置：", self._tmpID)
    end
    --导航组件挂在shell上
    ---@type UnityEngine.AI.NavMeshAgent
    self._navMeshAgent = self._petShell:AddComponent(typeof(UnityEngine.AI.NavMeshAgent))
    self._navMeshObstacle = self._petShell:AddComponent(typeof(UnityEngine.AI.NavMeshObstacle))
    --navmeshAgent
    if cfg.NaviRadius > 0.5 then
        self._navMeshAgent.agentTypeID = HelperProxy:GetInstance():GetNavAgentID(AircraftNavAgent.Oversize)
    else
        self._navMeshAgent.agentTypeID = HelperProxy:GetInstance():GetNavAgentID(AircraftNavAgent.Normal)
    end
    self._navMeshAgent.angularSpeed = 1000
    self._navMeshAgent.stoppingDistance = 0.1
    self._navMeshAgent.radius = cfg.NaviRadius
    self._navMeshAgent.autoBraking = false
    self._navMeshAgent.enabled = false
    --navmeshObstacle
    ---@type UnityEngine.AI.NavMeshObstacle
    self._navMeshObstacle.shape = UnityEngine.AI.NavMeshObstacleShape.Capsule
    self._navMeshObstacle.radius = cfg.NaviRadius
    self._navMeshObstacle.carving = true
    self._navMeshObstacle.enabled = false

    self._isShow = false
    --是否存活（未被销毁）
    self._alive = true
    ---@type AirActionBase
    self._mainAction = nil
    ---@type ArrayList
    self._viceAction = ArrayList:New()

    --默认表情行为
    ---@type AirActionFace
    self._defaultFaceAction = nil

    --当前的喊话action
    ---@type AirActionSentence
    self._sectenceAction = nil
    ---@type AirActionSentence
    self._lastSectenceAction = nil

    ---@type AirActionGroupTalk
    self._socialGroupTalkAction = nil

    self._wisperTime = nil
    self._wisperWeight = Cfg.cfg_aircraft_pet[self._tmpID].WhisperWeight

    self._naviRadius = cfg.NaviRadius

    --[[
        特殊行为，目前具体的类型为AirActionFace，在停止时只调用了Stop
        因为AirActionFace的Stop中调用了自己的Dispose，如果是其他类型的AirAction，需要确定何时析构
    ]]
    ---@type table<AircraftSpecialActionType,AirActionEffect>
    self._specialAction = {}
    self._presentGameObject = nil

    self._petName = StringTable.Get(Cfg.cfg_pet[self._tmpID].Name)

    self._ownerName = ""

    self.cfg_aircraft_weapon_tex_2_unload = Cfg.cfg_aircraft_weapon_tex_2_unload()

    self._moveSpeed = 0.9 --默认移速
    local speedCfg = Cfg.cfg_pet_move_speed[self._skinID]
    if speedCfg and speedCfg.AircraftSpeed then
        self._moveSpeed = speedCfg.AircraftSpeed
        AirLog("星灵移速读取配置:", self._skinID, ",", self._moveSpeed)
    end
end

function AircraftPet:Dispose()
    self:Hide()

    if self._mainAction then
        if not self._mainAction:IsOver() then
            self._mainAction:Stop()
        end
        self._mainAction:Dispose()
    end

    if self._viceAction:Size() > 0 then
        self._viceAction:ForEach(
            function(action)
                action:Dispose()
            end
        )
    end

    for _, action in pairs(self._specialAction) do
        action:Dispose()
    end
    self._specialAction = {}

    if self._defaultFaceAction then
        self._defaultFaceAction:Dispose()
    end
    self._defaultFaceAction = nil

    if self._petDataChangeHandler then
        GameGlobal.EventDispatcher():RemoveCallbackListener(
            GameEventType.PetDataChangeEvent,
            self._petDataChangeHandler
        )
    end
    self._alive = false

    UnityEngine.Object.Destroy(self._petShell)
end

function AircraftPet:IsAlive()
    return self._alive
end

function AircraftPet:Update(deltaTimeMS)
    if not self._alive then
        return
    end

    if self._mainAction then
        self._mainAction:Update(deltaTimeMS)
        if self._mainAction:IsOver() then
            AirLog("[AircraftPet] 主行为结束：", self:TemplateID())
        end
    end

    if self._viceAction:Size() > 0 then
        local removes = {}
        for idx, value in ipairs(self._viceAction.elements) do
            ---@type AirActionBase
            local action = value
            action:Update(deltaTimeMS)
            if action:IsOver() then
                removes[#removes + 1] = idx
            end
        end
        for _, idx in ipairs(removes) do
            self._viceAction:RemoveAt(idx)
        end
    end

    if self._sectenceAction then
        self._sectenceAction:Update(deltaTimeMS)
        if self._sectenceAction:IsOver() then
            self._sectenceAction = nil
        end
    end
    if self._lastSectenceAction then
        self._lastSectenceAction:Update(deltaTimeMS)
        if self._lastSectenceAction:IsOver() then
            self._lastSectenceAction = nil
        end
    end
    if self._socialGroupTalkAction then
        self._socialGroupTalkAction:Update(deltaTimeMS)
        if self._socialGroupTalkAction:IsOver() then
            self._socialGroupTalkAction = nil
        end
    end

    if self._specialAction then
        for _k, action in pairs(self._specialAction) do
            action:Update(deltaTimeMS)
            if action:IsOver() then
                self._sectenceAction[_k] = nil
            end
        end
    end

    --默认表情动作处理
    if self:HasFaceAction() then --已经有表情
        self:DefaultFaceActionOver()
    else                         --没有其它表情的时候播放默认表情
        if self._defaultFaceAction then
            self._defaultFaceAction:Update(deltaTimeMS)
            if self._defaultFaceAction:IsOver() then
                self:DefaultFaceActionOver()
            end
        else
            self:CreateDefaultFaceAction(deltaTimeMS)
        end
    end
end

function AircraftPet:DefaultFaceActionOver()
    if self._defaultFaceAction then
        self._defaultFaceAction:Dispose()
        self._defaultFaceAction = nil
    end
end

function AircraftPet:CreateDefaultFaceAction(deltaTimeMS)
    local bubble = nil
    if math.random(1, 2) == 1 then
        bubble = 4001
    else
        bubble = 4002
    end

    local delayTime = math.random(3, 5) * 1000
    self._defaultFaceAction = AirActionFace:New(self, bubble, delayTime)
    self._defaultFaceAction:Start()
end

function AircraftPet:HasFaceAction()
    if self._mainAction and self._mainAction:GetActionType() == AircraftActionType.Face then
        if not self._mainAction:IsOver() then
            return true
        end
    end

    if self._viceAction and self._viceAction:Size() > 0 then
        for idx, value in ipairs(self._viceAction.elements) do
            ---@type AirActionBase
            local action = value
            if action:GetActionType() == AircraftActionType.Face and not action:IsOver() then
                return true
            end
        end
    end

    return false
end

---@return string 星灵名字（国际化之后）
function AircraftPet:PetName()
    return self._petName
end

function AircraftPet:PstID()
    return self._petData:PstID()
end

function AircraftPet:TemplateID()
    return self._tmpID
end

--星灵皮肤ID（不是时装id，是资源前缀）
function AircraftPet:SkinID()
    return self._skinID
end

--时装（皮肤id）
function AircraftPet:ClothSkinID()
    return self._clothSkinID
end

function AircraftPet:GetState()
    return self._state
end

function AircraftPet:SetState(state)
    self._state = state
end

--工作中星灵会有
function AircraftPet:SetSpace(id)
    self._spaceID = id
end

function AircraftPet:GetSpace()
    return self._spaceID
end

--星灵上一个执行的随机行为ID，下一个不能随到此行为
function AircraftPet:SetRandomActionCfgID(id)
    self._randomActionCfgID = id
end

function AircraftPet:GetRandomActionCfgID()
    return self._randomActionCfgID
end

--正在散步的区域
function AircraftPet:SetWanderingArea(area)
    self._wanderingArea = area
end

function AircraftPet:GetWanderingArea()
    return self._wanderingArea
end

function AircraftPet:SetBelongArea(area)
    self._belongArea = area
end

function AircraftPet:GetBelongArea()
    return self._belongArea
end

function AircraftPet:SetAsWorkingPet()
    self._isWorking = true
end

function AircraftPet:IsWorkingPet()
    return self._isWorking
end

--正在离开的星灵添加永久标志
function AircraftPet:SetAsLeavingPet()
    self._isLeaving = true
end

function AircraftPet:IsLeavingPet()
    return self._isLeaving == true
end

--家具
function AircraftPet:GetFurnitureType()
    return self._currentFurnitureType
end

function AircraftPet:SetFurnitureType(fType)
    self._currentFurnitureType = fType
end

function AircraftPet:SetOccupyFurniture(insID)
    self._occupyFurnitureInstanceID = insID
end

function AircraftPet:GetOccupyFurniture()
    return self._occupyFurnitureInstanceID
end

--当前所在楼层
function AircraftPet:SetFloor(floor)
    if floor == nil then
        Log.exception("楼层为空：", self:TemplateID(), "，", debug.traceback())
        Log.fatal("楼层为空--：", self:TemplateID())
    end
    self._floor = floor
end

function AircraftPet:GetFloor()
    if self._floor == nil then
        Log.fatal("[AircraftPet] 星灵的楼层为空：", self:TemplateID())
    end
    return self._floor
end

--坐电梯要去的楼层，到达后置为nil
function AircraftPet:SetTargetFloor(target)
    self._targetFloor = target
end

function AircraftPet:GetTargetFloor()
    return self._targetFloor
end

--这里暂存跨楼层之后的行为，楼梯或电梯操作完星灵后开始执行这个行为，并置空
function AircraftPet:SetFloorTargetAction(action)
    self._elevatorTargetAction = action
end

function AircraftPet:GetFloorTargetAction()
    return self._elevatorTargetAction
end

function AircraftPet:TryStopFloorTargetAction()
    if self._elevatorTargetAction then
        self._elevatorTargetAction:Stop()
        self._elevatorTargetAction = nil
        AirLog("跨层行为被打断：", self._tmpID)
    end
end

--暂存
function AircraftPet:SetMoveToAction(action)
    self._moveToDoAction = action
end

function AircraftPet:GetMoveToDoAction()
    return self._moveToDoAction
end

--移动的目标区域
function AircraftPet:SetMovingTargetArea(area)
    self._movingTargetArea = area
end

function AircraftPet:GetMovingTargetArea()
    return self._movingTargetArea
end

function AircraftPet:SetWaitElevatorTime(time)
    self._waitElevatorTime = time
end

function AircraftPet:GetWaitElevatorTime()
    return self._waitElevatorTime
end

--派遣离开控制器控制星灵进入的时间
function AircraftPet:SetEnterTime(time)
    self._enterTime = time
end

function AircraftPet:GetEnterTime()
    return self._enterTime
end

function AircraftPet:SetAsVisitPet()
    --不允许置为false
    self._isVisitPet = true
end

function AircraftPet:IsVisitPet()
    return self._isVisitPet == true
end

function AircraftPet:SetVisitGift(has)
    self._hasVisitGift = has
end

--拜访星灵有礼物
function AircraftPet:HasVisitGift()
    return self._hasVisitGift
end

function AircraftPet:Affinity()
    if self._isVisitPet then
        return 0
    else
        ---@type PetModule
        local petModule = GameGlobal.GetModule(PetModule)
        return petModule:GetPetByTemplateId(self._tmpID):GetPetAffinityExp()
    end
end

function AircraftPet:AwakeLevel()
    return self._petData:Awake()
end

function AircraftPet:SetGiftFlag(flag)
    self._hasPreset = flag
end

function AircraftPet:IsGiftPet()
    return self._hasPreset
end

--endregion

--根据权重随机一个表情id
function AircraftPet:GetIDWithRandomWeight(randomWeights)
    local id = 0
    local all = 0
    local weightTab = {}
    for i = 1, #randomWeights do
        all = all + randomWeights[i][2]
        local weightTabItem = {}
        weightTabItem.id = randomWeights[i][1]
        weightTabItem.weight = all
        table.insert(weightTab, weightTabItem)
    end
    local randomNumber = math.random(1, all)
    for i = 1, #weightTab do
        if randomNumber <= weightTab[i].weight then
            id = weightTab[i].id
            break
        end
    end
    return id
end

--开始主行为，之前行为未停止的话会被打断
---@param action AirActionBase
function AircraftPet:StartMainAction(action)
    if self._mainAction and not self._mainAction:IsOver() then
        self._mainAction:Stop()
    end
    self._mainAction = action
    self._mainAction:Start()
    self:StopAllViceAction()

    --主行为切换后，上一次的随机行为id重置
    -- if self._randomActionCfgID then
    --     self._randomActionCfgID = nil
    -- end
end

--主动停止主行为，慎用
function AircraftPet:StopMainAction()
    if self._mainAction and not self._mainAction:IsOver() then
        self._mainAction:Stop()
        self._mainAction = nil
    end
end

--主行为为空，什么也不干
function AircraftPet:StartIdleAction()
    local action = AirActionEmpty:New(self)
    self:StartMainAction(action)
end

function AircraftPet:IsMainActionOver()
    if self._mainAction == nil then
        return true
    end
    return self._mainAction:IsOver()
end

--开始副行为，可存在多个，并行
---@param action AirActionBase
function AircraftPet:StartViceAction(action)
    action:Start()
    self._viceAction:PushBack(action)
end

--开始喊话行为，特殊
function AircraftPet:StartSentenceAction(action)
    if self._sectenceAction then
        if self._lastSectenceAction and not self._lastSectenceAction:IsOver() then
            self._lastSectenceAction:Stop()
        end
        self._lastSectenceAction = self._sectenceAction
        self._lastSectenceAction:StartClose()
    end
    self._sectenceAction = action
    self._sectenceAction:Start()
end

--開始永久存在的行為（禮包、头顶显示名字,光圈用）
---@param action AirActionEffect
function AircraftPet:StartSpecialAction(actionType, action)
    self._specialAction[actionType] = action
    action:Start()
end

function AircraftPet:SetPresentObject(object)
    self._presentGameObject = object
    -- Log.fatal("###",object.name)
end

function AircraftPet:GetPresentObject()
    return self._presentGameObject
end

--結束禮包
function AircraftPet:StopSpecialAction(actionType)
    if self._specialAction[actionType] then
        self._specialAction[actionType]:Stop()
        self._specialAction[actionType] = nil
    end
end

--结束喊话
function AircraftPet:StopSentenceAction()
    if self._sectenceAction then
        if self._lastSectenceAction and not self._lastSectenceAction:IsOver() then
            self._lastSectenceAction:Stop()
        end
        self._lastSectenceAction = self._sectenceAction
        self._lastSectenceAction:StartClose()
        self._sectenceAction = nil
    end
end

function AircraftPet:DoingSentence()
    return self._sectenceAction and (not self._sectenceAction:IsOver())
end

function AircraftPet:SetSocialGroupTalk(action)
    if self._socialGroupTalkAction then
        if self._socialGroupTalkAction and not self._socialGroupTalkAction:IsOver() then
            self._socialGroupTalkAction:Stop()
        end
    end
    self._socialGroupTalkAction = action
end

function AircraftPet:StopSocialGroupTalk()
    if self._socialGroupTalkAction then
        if self._socialGroupTalkAction and not self._socialGroupTalkAction:IsOver() then
            self._socialGroupTalkAction:Stop()
        end
        self._socialGroupTalkAction = nil
    end
end

function AircraftPet:StopAllViceAction()
    self._viceAction:ForEach(
        function(a)
            ---@type AirActionBase
            local action = a
            action:Stop()
        end
    )
    self._viceAction:Clear()

    if self._sectenceAction then
        self._sectenceAction:StartClose()
        self._sectenceAction = nil
    end
    if self._lastSectenceAction then
        self._lastSectenceAction:Stop()
        self._lastSectenceAction = nil
    end
    if self._socialGroupTalkAction then
        self._socialGroupTalkAction:Stop()
        self._socialGroupTalkAction = nil
    end
end

---@return AircraftPetSaveData
function AircraftPet:Encode()
    if self:IsWorkingPet() then
        return
    end
    ---@type AircraftPetSaveData
    local t = {}
    t.floor = self._floor
    t.state = self._state
    t.belongArea = self._belongArea
    --当前行为的剩余时长
    t.remainTime = 0
    --只保存3种状态下的星灵
    if self._state == AirPetState.Wandering then
        if self._mainAction == nil then
            Log.exception("[AircraftPet] 漫游主行为为空，无法序列化：", self:TemplateID())
        end

        if
            self._mainAction._className == "AirActionWandering" or
            self._mainAction._className == "AirActionMoveAndWandering" or
            self._mainAction._className == "AirActionStand"
        then
        else
            Log.exception("[AircraftPet] 漫游主行为类型错误：", self._mainAction._className)
        end

        local time = self._mainAction:CurrentTime()
        local duration = self._mainAction:Duration()
        t.remainTime = math.floor(duration - time)
        t.area = self._wanderingArea
        t.actionIndex = self._randomActionCfgID
        return t
    elseif self._state == AirPetState.OnFurniture then
        if self._mainAction == nil then
            Log.exception("[AircraftPet] 家具主行为为空，无法序列化：", self:TemplateID())
        end

        if
            self._mainAction._className == "AirActionOnFurniture" or
            self._mainAction._className == "AirActionMoveAndFurniture"
        then
        else
            Log.exception("[AircraftPet] 家具主行为类型错误：", self._mainAction._className, "，ID：",
                self:TemplateID())
        end

        local time = self._mainAction:CurrentTime()
        local duration = self._mainAction:Duration()
        t.remainTime = math.floor(duration - time)
        t.furnID, t.point = self._mainAction:GetEncodeInfo()
        t.actionIndex = self._randomActionCfgID
        return t
    elseif self._state == AirPetState.Social then
        -- 社交类型
        t.airSocialActionType = self._socialActionType          --社交行为类型
        t.socialRound = self._socialRound or 1                  -- 第几回合
        t.socialFurnitureId = self._socialFurnitureKey          -- 具体交互的家具index
        t.socialPointHolderIndex = self._socialPointHolderIndex -- 占据的pointHolder
        t.socialLocationIndex = self._socialLocationIndex       -- 坐标index
        t.socialAreaType = self._socialAreaType                 -- 社交娱乐类型
        t.socialPetCount = self._socialPetCount                 -- 这次社交的数量
        t.remainTime = self._socialRemainTime or 0
        return t
    else
        return nil
    end
end

---@param t AircraftPetSaveData
---@param deltaTime number
---@param main AircraftMain
function AircraftPet:Decode(t, time, main)
    self._floor = t.floor
    self._state = t.state
    self._belongArea = t.belongArea
    --属于一个房间
    local room = main:GetRoomByArea(self._belongArea)
    if room then
        room:PetIn(self:TemplateID())
    end
    if self._state == AirPetState.Wandering then
        self._wanderingArea = t.area
        local holder = main:GetPointHolder(t.area)
        local pos = main:GetInitPos(holder)
        self:SetPosition(pos)
        local action = AirActionWandering:New(self, holder, time, "恢复的漫游行为", main)
        main:StartInitAction(self, action, t.actionIndex)
        return true
    elseif self._state == AirPetState.OnFurniture then
        local furn = main:GetFurnitureByKey(t.furnID)
        if furn == nil then
            AirLog("反序列化找不到家具：", t.furnID)
            return false
        end
        --反序列化回来发现点被占据，则反序列化失败
        if furn:IsPointOccupied(t.point) then
            return false
        end
        AirLog("家具交互反序列化占据一个点，家具ID：", furn:CfgID(), "，索引：", t.point)
        local point = furn:OccupyPointByIndex(t.point)
        local cond = AircraftPetFurPointCondition:New(self, furn, nil, point)
        --设置当前占据的家具
        self:SetOccupyFurniture(furn:InstanceID())
        local action = AirActionOnFurniture:New(self, furn, point, cond, time, true)
        main:StartInitAction(self, action, t.actionIndex)
        return true
    elseif self._state == AirPetState.Social then
        self._socialAreaType = t.socialAreaType
        local holder = main:GetPointHolder(self._socialAreaType)
        local pos = main:GetInitPos(holder)
        self:SetPosition(pos)
        self._socialActionType = t.airSocialActionType
        self._socialRound = t.socialRound
        self._socialFurnitureKey = t.socialFurnitureId
        self._socialPointHolderIndex = t.socialPointHolderIndex
        self._socialLocationIndex = t.socialLocationIndex
        self._socialPetCount = t.socialPetCount
        self._socialRemainTime = t.remainTime
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AirForceTriggerSocialAction, self)
        return true
    end
end

-- 一个星灵可以交互的家具
function AircraftPet:GetInteractFurnitures()
    if not self._interactFurnitures then
        --TODO: 这里暂定漫游中触发社交只找能坐的家具
        self._interactFurnitures = { { AirFurnitureType.RestChair } }
        -- local id = Cfg.cfg_aircraft_pet[self:TemplateID()].ActionLib
        -- local cfg = Cfg.cfg_aircraft_random_action_lib[id]
        -- if cfg == nil then
        --     Log.fatal("[AircraftRandom] 找不到随机行为库：", id)
        --     return
        -- end
        -- --过滤掉当前行为
        -- for idx, lib in ipairs(cfg.Lib) do
        --     local type = lib[1]
        --     if type == AirRandomActionType.Furniture then
        --         local furnitureType = lib[2]
        --         local duration = lib[3]
        --         table.insert(self._interactFurnitures, {furnitureType, duration})
        --     end
        -- end
    end
    return self._interactFurnitures
end

function AircraftPet:GetRandomFace()
    local cfg = Cfg.cfg_aircraft_pet[self._tmpID]
    return cfg and self:GetIDWithRandomWeight(cfg.CharactorFace) or 1
end

--------------------------------------社交行为状态相关(序列化用)--------------------------------
---
function AircraftPet:ResetSocialParam()
    self:SetSocialActionType()
    self:SetSocialRound()
    self:SetSocialFurnitureKey()
    self:SetSocialRemainTime()
    self:SetSocialLocationIndex()
    self:SetSocialPointHolderIndex()
    self:SetSocialAreaType()
    self:SetSocialPetCount()
end

----- 设置社交类型
---@type AirSocialActionType
function AircraftPet:SetSocialActionType(type)
    self._socialActionType = type
end

function AircraftPet:GetSocialActionType()
    return self._socialActionType
end

function AircraftPet:SetSocialRound(round)
    self._socialRound = round
end

function AircraftPet:GetSocialRound()
    return self._socialRound
end

function AircraftPet:SetSocialFurnitureKey(furnitureKey)
    self._socialFurnitureKey = furnitureKey
end

function AircraftPet:GetSocialFurnitureKey()
    return self._socialFurnitureKey
end

function AircraftPet:SetSocialRemainTime(time)
    self._socialRemainTime = time
end

function AircraftPet:GetSocialRemainTime()
    return self._socialRemainTime
end

function AircraftPet:SetSocialLocationIndex(index)
    self._socialLocationIndex = index
end

function AircraftPet:GetSocialLocationIndex()
    return self._socialLocationIndex
end

function AircraftPet:SetSocialPointHolderIndex(pointHolderIndex)
    self._socialPointHolderIndex = pointHolderIndex
end

function AircraftPet:GetSocialPointHolderIndex()
    return self._socialPointHolderIndex
end

function AircraftPet:SetSocialAreaType(type)
    self._socialAreaType = type
end

function AircraftPet:GetSocialAreaType()
    return self._socialAreaType
end

function AircraftPet:SetSocialPetCount(count)
    self._socialPetCount = count
end

function AircraftPet:GetSocialPetCount()
    return self._socialPetCount
end

function AircraftPet:NaviRadius()
    return self._naviRadius
end

function AircraftPet:SetMoveTarget(t)
    self._moveTarget = t
end

function AircraftPet:GetMoveTarget()
    return self._moveTarget
end

function AircraftPet:HasMoveTarget()
    return self._moveTarget ~= nil
end

function AircraftPet:SetMoveAction(action)
    self._moveAction = action
end

function AircraftPet:GetMoveAction()
    return self._moveAction
end

--------------------------------------社交行为状态相关(序列化用)--------------------------------
--region---------------------------------亲近/远离-------
-- 我亲近他
function AircraftPet:IsCloserToMe(targetPetTempId)
    return self:_IsRelationPet(targetPetTempId, true, "CloserType", "CloserParam")
end

-- 我远离他
function AircraftPet:IsFarAwayFromMe(targetPetTempId)
    return self:_IsRelationPet(targetPetTempId, false, "FarAwayType", "FarAwayParam")
end

function AircraftPet:_IsRelationPet(targetPetTempId, isCloser, typeStr, paramStr)
    local cfg = Cfg.cfg_aircraft_pet[self:TemplateID()]
    if not cfg then
        return false
    end
    local type = cfg[typeStr]
    if not type then
        return false
    end
    local relationPets
    if isCloser then
        relationPets = self._closerPets
    else
        relationPets = self._farAwayPets
    end
    if not relationPets then
        relationPets = {}
        -- CloserType:ie	CloserParam:iae,	FarAwayType:ie	FarAwayParam:iae,
        local param = cfg[paramStr]
        if type == AirRelationType.Pets then
            for index, petTempId in ipairs(param) do
                relationPets[petTempId] = true
            end
        elseif type == AirRelationType.ShiLi then
            for index, shili in ipairs(param) do
                local pets = AirHelper.GetPetTempIdsByShiLi(shili)
                for key, petTempId in pairs(pets) do
                    relationPets[petTempId] = true
                end
            end
        end
        if isCloser then
            self._closerPets = relationPets
        else
            self._farAwayPets = relationPets
        end
    end
    -- 亲近所有人/远离所有人
    if type == AirRelationType.All then
        return true
    else
        return relationPets[targetPetTempId]
    end
end

--endregion

--region 自言自语
--获取上次自言自语的时间，第一次返回0
function AircraftPet:GetWisperTime()
    return self._wisperTime or 0
end

--开始自言自语时设置一次当前时间
function AircraftPet:SetWisperTime(time)
    self._wisperTime = time
end

--自言自语权重
function AircraftPet:WisperWeight()
    return self._wisperWeight
end

--特殊交互动作
---@param anim Animation
function AircraftPet:SetExtraAnim(anim)
    if self._isShow and anim then
        HelperProxy:GetInstance():AddAnimTo(anim, self._animation)
    elseif self._isShow and anim == nil and self._extraAnim then
        HelperProxy:GetInstance():RemoveAnimTo(self._extraAnim, self._animation)
    end
    self._extraAnim = anim
end

--endregion

--region--------------------------------------------------------------------------------------表现

function AircraftPet:PrefabName()
    return self._prefabName
end

---@param req AircraftPetRequestBase
function AircraftPet:Show(req)
    self._isShow = true
    ---@type AircraftPetRequestBase
    self._assetReq = req

    ---@type UnityEngine.GameObject
    self._petGO = req:PetGameObject()
    self._petTransform = self._petGO.transform

    GameObjectHelper.SetGameObjectLayer(self._petGO, AircraftLayer.Pet)
    GameObjectHelper.AddVolumeComponent(self._petGO)

    ---@type UnityEngine.Animation
    self._animation = self._petTransform:Find("Root"):GetComponent(typeof(UnityEngine.Animation))
    local clickAnim = self._animation:get_Item(AirPetAnimName.Click)
    if clickAnim == nil then
        AirError("严重错误，找不到点击动作：", self._tmpID)
    end
    --头部挂点
    local head = GameObjectHelper.FindChild(self._petTransform, "Bip001 Head")
    if not head then
        AirError("[AircraftPet] 严重错误：找不到头部挂点，星灵ID:", self:TemplateID())
    end
    self._headSlot = head

    local bip = GameObjectHelper.FindChild(self._petGO.transform, "Bip001")
    if bip == nil then
        AirError("[AircraftPet] 严重错误，找不到模型根骨骼：", self:TemplateID())
    end
    ---@type UnityEngine.BoxCollider
    local collider = bip.gameObject:AddComponent(typeof(UnityEngine.BoxCollider))
    local cfg = Cfg.cfg_aircraft_pet[self._tmpID]
    if not cfg then
        AirError("aircraft_pet表中找不到配置：", self._tmpID)
    end
    collider.size = Vector3(cfg.BoxSize[1], cfg.BoxSize[3], cfg.BoxSize[2])
    collider.center = Vector3(0, 0, 0)

    self._collider = collider

    --点击特效
    self.clickEffCfg = Cfg.cfg_aircraft_click_eff[self._skinID]
    if self.clickEffCfg and self.clickEffCfg.EffName then
        self.clickEffReq =
            ResourceManager:GetInstance():SyncLoadAsset(self.clickEffCfg.EffName .. ".prefab", LoadType.GameObject)
        self.clickEff = self.clickEffReq.Obj
        self.clickEff.transform.localScale = Vector3.one
        local cfgPos = self.clickEffCfg.PosOffset
        self.clickEffOffset = Vector3(cfgPos[1], cfgPos[2], cfgPos[3])
    end

    local face_name = self._skinID .. "_face"
    local face = GameObjectHelper.FindChild(self._petGO.transform, face_name)
    if face then
        local render = face.gameObject:GetComponent(typeof(UnityEngine.SkinnedMeshRenderer))
        if not render then
            AirError("面部表情节点上找不到SkinnedMeshRenderer：", face_name)
        else
            ---@type UnityEngine.Material
            self._faceMat = render.material
        end
    else
        AirError("找不到面部表情节点：", face_name)
    end

    if self._extraAnim then
        HelperProxy:GetInstance():AddAnimTo(self._extraAnim, self._animation)
    end

    self._petTransform:SetParent(self._shellTransform)
    local petScale = Cfg.cfg_aircraft_camera["petScale"].Value
    self._petGO.transform.localScale = Vector3(petScale, petScale, petScale)
    self._petTransform.localPosition = Vector3.zero
    self._petTransform.localRotation = Quaternion.identity

    local root = self._petTransform:Find("Root")
    --默认隐藏武器
    for i = 0, root.childCount - 1 do
        local child = root:GetChild(i)
        if string.find(child.name, "weapon") then
            child.gameObject:SetActive(false)
        end
    end
    -- self:UnloadWeaponTexture(root.gameObject)

    ---@type Animation
    self._selectAnim = self._petGO:GetComponent(typeof(UnityEngine.Animation))
    if not self._selectAnim then
        self._selectAnim = self._petGO:AddComponent(typeof(UnityEngine.Animation))
        self._selectAnim.playAutomatically = false
        --直接给.clip赋值在手机上无效
        -- self._selectAnim.clip = req:ClickAnimClip()
        self._selectAnim:AddClip(req:ClickAnimClip(), "aircraft_select")
    end
    ---@type OutlineComponent
    self._outLine = root.gameObject:GetComponent(typeof(OutlineComponent))
    if not self._outLine then
        self._outLine = root.gameObject:AddComponent(typeof(OutlineComponent))
        self._outLine.blurNum = 3
        self._outLine.intensity = 2.5
        self._outLine.outlineSize = 1
        self._outLine.blendType = OutlineComponent.BlendType.Blend
        self._outLine.enabled = false
    end

    self._petGO:SetActive(true)

    if self._curAnim then
        self._animation:CrossFade(self._curAnim, 0)
        local time = self._main:Time() - self._curAnimPlayTime
        ---@type UnityEngine.AnimationState
        local animState = self._animation:get_Item(self._curAnim)
        if animState then
            local duration = math.floor(animState.length * 1000)
            local t = time % duration
            animState.enabled = true
            animState.time = t

            HelperProxy:GetInstance():TriggerAircraftAnimationEvent(self._animation, self._curAnim, t)
        else
            local log = "[Aircraft_Exception]星灵没有动作:" .. self._curAnim .. "，id:" .. self._skinID
            AirException(log)
        end
    end
end

function AircraftPet:Hide()
    if not self._isShow then
        return
    end
    self._isShow = false

    self._assetReq:Dispose()
    self._assetReq = nil

    if self._sectenceAction then
        self._sectenceAction:Stop()
        self._sectenceAction = nil
    end
    if self._lastSectenceAction then
        self._lastSectenceAction:Stop()
        self._lastSectenceAction = nil
    end

    if self.clickEffReq then
        self.clickEffReq:Dispose()
        self.clickEffReq = nil
    end

    if self._MaterialAnimationContainer then
        self._MaterialAnimationContainer:Dispose()
        self._MaterialAnimationContainer = nil
    end

    self._faceMat = nil
end

---@param root UnityEngine.GameObject
function AircraftPet:UnloadWeaponTexture(root)
    local cfgv = self.cfg_aircraft_weapon_tex_2_unload[self._tmpID]
    if not cfgv then
        return
    end
    local propertyNames = {
        "_MainTex",
        "_ShadowColorTex",
        "_SLHTex",
        "_EffectTex"
    }
    for goname, tname in pairs(cfgv) do
        local tranWeapon = root.transform:Find(goname)
        if tranWeapon then
            local go = tranWeapon.gameObject
            ---@type UnityEngine.SkinnedMeshRenderer
            local smr = go:GetComponent(typeof(UnityEngine.SkinnedMeshRenderer))
            local m = smr.material
            for _, propertyName in ipairs(propertyNames) do
                local texture = m:GetTexture(propertyName)
                if texture and table.icontains(tname, texture.name) then
                    m:SetTexture(propertyName, nil)
                    UnityEngine.Resources.UnloadAsset(texture)
                    -- Log.warn("### unload.", goname, tname)
                end
            end
        else
            Log.warn("### tranWeapon nil.", goname)
        end
    end
end

--头部挂点位置
function AircraftPet:HeadPos()
    if self._isShow then
        return self._headSlot.position
    else
        return self._shellTransform.position + Vector3(0, 1.5, 0)
    end
end

function AircraftPet:GetFaceMat()
    if self._isShow then
        return self._faceMat
    end
end

---@return UnityEngine.GameObject
function AircraftPet:GameObject()
    -- return self._petGO
    return self._petShell
end

---@return UnityEngine.Transform
function AircraftPet:Transform()
    -- return self._petTransform
    return self._shellTransform
end

function AircraftPet:SetPosition(pos)
    -- self._petTransform.position = pos
    self._shellTransform.position = pos
end

function AircraftPet:SetRotation(rot)
    -- self._petTransform.rotation = rot
    self._shellTransform.rotation = rot
end

function AircraftPet:SetEuler(v3)
    -- self._petTransform.eulerAngles = v3
    self._shellTransform.eulerAngles = v3
end

--region 动画相关
function AircraftPet:Anim_CrossFade(name, time)
    self._curAnim = name
    self._curAnimPlayTime = self._main:Time()
    if not self._isShow then
        return
    end
    if time then
        self._animation:CrossFade(name, time)
    else
        self._animation:CrossFade(name, 0.2)
    end
end

function AircraftPet:Anim_Walk()
    self:Anim_CrossFade(AirPetAnimName.Walk)
end

function AircraftPet:Anim_Stand()
    self:Anim_CrossFade(AirPetAnimName.Stand)
end

function AircraftPet:Anim_Sit()
    self:Anim_CrossFade(AirPetAnimName.Sit)
end

function AircraftPet:Anim_Stop()
    if not self._isShow then
        return
    end
    self._animation:Stop()
end

--播放click动作
function AircraftPet:Anim_Click(animName)
    if self.clickEff then
        self.clickEff.transform.rotation = self._petTransform.rotation
        self.clickEff.transform.position = self._petTransform.position + self.clickEffOffset
        self.clickEff:SetActive(false)
        self.clickEff:SetActive(true)
    end
    if animName then
        --判断传入的动作名和动作列表中是否匹配，兜底处理（bug号：MSG45996）
        local animState = self._animation:get_Item(animName)
        if animState then
            self:Anim_CrossFade(animName)
        else
            self:Anim_CrossFade(AirPetAnimName.Click)
        end
    else
        self:Anim_CrossFade(AirPetAnimName.Click)
    end
end

function AircraftPet:WorldPosition()
    return self._shellTransform.position
end

---@return UnityEngine.Animation
function AircraftPet:Animation()
    if self._isShow then
        return self._animation
    end
end

--寻路开关
function AircraftPet:SetNaviEnable(enable)
    -- self._navMeshObstacle.enabled = not enable
    self._navMeshAgent.enabled = enable
end

---@return UnityEngine.AI.NavMeshAgent
function AircraftPet:NaviMesh()
    return self._navMeshAgent
end

function AircraftPet:SetAsObstacle()
    self._navMeshObstacle.enabled = true
end

function AircraftPet:NaviObstacle()
    return self._navMeshObstacle
end

function AircraftPet:PlaySelectAnim()
    if self._selectAnim then
        -- self._outLine.enabled = true
        self._selectAnim:Play("aircraft_select")
    end
end

function AircraftPet:StopMatAnim()
    -- if self._selectAnim then
    --     self._selectAnim:Stop()
    --     self._outLine.enabled = false
    -- end
end

--缓存主人名字
function AircraftPet:SetOwnerName(ownerName)
    self._ownerName = ownerName
end

function AircraftPet:GetOwnerName()
    return self._ownerName
end

function AircraftPet:GetMainActionName()
    if self._mainAction then
        return self._mainAction._className
    end
end

function AircraftPet:GetMoveSpeed()
    return self._moveSpeed
end

--设置星灵头顶特效的碰撞器 点到特效相当于点到星灵
function AircraftPet:SetEffectCollider(eftCollider)
    self._eftCollider = eftCollider
end

--检查一个碰撞器是不是属于星灵
function AircraftPet:CheckCollider(collider)
    if (self._collider) and self._collider == collider then
        return true
    end
    if self._eftCollider and self._eftCollider == collider then
        return true
    end
    return false
end
