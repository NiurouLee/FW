require "homelandpet_component_base"
---@class HomelandPetComponentInteractionAnimation:HomelandPetComponentBase
_class("HomelandPetComponentInteractionAnimation", HomelandPetComponentBase)
HomelandPetComponentInteractionAnimation = HomelandPetComponentInteractionAnimation

function HomelandPetComponentInteractionAnimation:Constructor(componentType, pet, behavior)
    HomelandPetComponentInteractionAnimation.super.Constructor(self, componentType, pet, behavior)
    ---@type UnityEngine.Animation
    self._animation = self._pet:GetAnimation()
    ---@type cfg_homeland_building_pet
    self._buildingPetCfg = nil
    ---@type HomeBuilding 当前交互的建筑
    self._building = nil
    ---@type InteractPoint
    self._interactPoint = nil
    ---@type UnityEngine.Vector3 目标点
    self._targetPosition = nil
    ---@type UnityEngine.Quaternion 目标点旋转
    self._targetRotation = nil
    ---@type UnityEngine.Vector3 动作挂点
    self._animationPosition = nil
    ---@type UnityEngine.Quaternion 目标点旋转
    self._animationRotation = nil
    self._loopTime = 0
    ---@type table<string, ResRequest>
    self._petEffectReqs = {}
    ---@type table<UnityEngine.GameObject, string>
    self._petEffectObj = {} --光灵交互的特效GameObject
    ---@type table<string, boolean>
    self._buildingEffects = {}
    self._bubbleComponent = nil
    self._moveToAnimationPosition = false
    self._trFollowBuilding = nil
    ---@type UnityEngine.AnimationState[]
    self._animationStates = {}
    self._interactVisible = self._pet:FinalVisible()
    self._bindingSkeletoned = false --交互的时候是否做过骨骼绑定
end

---光灵替换皮肤后，删除了旧模型，需要重新加载一下新模型上的动画组件
function HomelandPetComponentInteractionAnimation:ReLoadPetComponent()
    ---@type UnityEngine.Animation
    self._animation = self._pet:GetAnimation()
end

function HomelandPetComponentInteractionAnimation:Init()
    ---@type HomelandPetComponentBubble
    self._bubbleComponent = self._behavior:GetComponent(HomelandPetComponentType.Bubble)
end
function HomelandPetComponentInteractionAnimation:OnExcute()
    if self.state == HomelandPetComponentState.Resting then
        if not self._buildingPetCfg then
            return
        end
        if not self._animation then
            self._animation = self._pet:GetAnimation()
        end
        if self._building and not self._building:Interactable() then
            return
        end
        self._interactVisible = self._pet:FinalVisible()
        --- 邀请逻辑
        if self._isInvite then
           -- GameGlobal.EventDispatcher():Dispatch(GameEventType.OnPetBehaviorInteractingFurniture,true,self._pet,self._building,self._isInvite,nil)
        end
        self._pet:SetBipObstacleEnabled(true)
        self._pet:SetNavMeshObstacleEnabled(false)
        self._pet:LoadExtraAnimation()
        self.state = HomelandPetComponentState.Running
        self._moveToAnimationPosition = true
        self._trFollowBuilding = nil
        self._building:AddInteractObject(self._pet:SkinID())
        self._animationTask =
            GameGlobal.TaskManager():StartTask(
            function(TT)
                self:_PlayAnimationAndEffect(TT, self._buildingPetCfg.In, HomelandInteractAnimationType.In)
                self:_PlayInteractionBubble()
                self:_PlayAnimationAndEffect(TT, self._buildingPetCfg.Loop, HomelandInteractAnimationType.Loop)
                self:_PlayAnimationAndEffect(TT, self._buildingPetCfg.Out, HomelandInteractAnimationType.Out)
                if self._trFollowBuilding ~= nil then
                    self._pet:FollowBuilding(nil)
                end
                ---@type UIHomelandModule
                local uiModule = GameGlobal.GetUIModule(HomelandModule)
                local isVisit = uiModule:GetClient():IsVisit()
                if isVisit then
                    return
                end
                self._pet:AgentTransform():DOMove(self._targetPosition, 0)
                self._pet:SetRotation(self._targetRotation)
                self:PlayStand()
                self:_StopBuildingAnimation(self._pet:SkinID())
                self.state = HomelandPetComponentState.Success
            end
        )
    end
end
function HomelandPetComponentInteractionAnimation:_PlayInteractionBubble()
    if (self._buildingPetCfg.InteractionBubbles == nil) then
        return
    end
    local index = math.random(1, #self._buildingPetCfg.InteractionBubbles)
    local bubbleid = self._buildingPetCfg.InteractionBubbles[index]
    Log.assert(bubbleid > 0, "_PlayInteractionBubble error id ", bubbleid)
    self._bubbleComponent:ShowBubble(bubbleid)
end

---@param buildingPetCfg cfg_homeland_building_pet
---@param building HomeBuilding
---@param targetTransform UnityEngine.Transform
---@param animationTransform UnityEngine.Transform
---@param loopTime number
function HomelandPetComponentInteractionAnimation:Play(
    buildingPetCfg,
    building,
    interactPoint,
    targetTransform,
    animationTransform,
    loopTime,
    isInvite )
    self._buildingPetCfg = buildingPetCfg
    self._building = building
    self._interactPoint = interactPoint
    self._targetPosition = targetTransform.position
    self._targetRotation = targetTransform.rotation
    self._animationPosition = animationTransform.position
    self._animationRotation = animationTransform.rotation
    self._loopTime = loopTime or 0
    self._isInvite = isInvite
end

function HomelandPetComponentInteractionAnimation:Exit()
    local preState = self.state
    HomelandPetComponentInteractionAnimation.super.Exit(self)
    if self._animationTask then
        GameGlobal.TaskManager():KillTask(self._animationTask)
        self._animationTask = nil
    end
    if self._targetPosition then
        if preState == HomelandPetComponentState.Running then
            local interrupt = self:_GetInterruptCfg(self._building._cfgID)
            if interrupt then
                local position = HomelandNavmeshTool:GetInstance():GetReachablePosition(self._pet:GetBoneNode(interrupt[2]).position)
                self._pet:SetPosition(position)
                if self._animation then
                    self:PlayStand()
                end
            else
                self._pet:AgentTransform():DOMove(self._targetPosition, 0)
                if self._animation then
                    self:PlayStand()
                end
            end
        end
    end
    self._isInvite = false
    for _, animationState in pairs(self._animationStates) do
        if animationState then
            animationState.speed = 1
        end
    end
    self._pet:SetBipObstacleEnabled(false)
    self._pet:SetNavMeshObstacleEnabled(true)
    self:_StopBuildingAnimation(self._pet:SkinID())
    self:_BindingSkeleton(false)
    self._buildingPetCfg = nil
    self._targetPosition = nil
    self._targetRotation = nil
    self._animationPosition = nil
    self._animationRotation = nil
    self._loopTime = 0
    for _, _req in pairs(self._petEffectReqs) do
        _req:Dispose()
    end
    table.clear(self._petEffectReqs)
    table.clear(self._petEffectObj)
    table.clear(self._buildingEffects)
    table.clear(self._animationStates)
    self._bindingSkeletoned = false
end

--播放交互动画、特效
---@param animationType HomelandInteractAnimationType
function HomelandPetComponentInteractionAnimation:_PlayAnimationAndEffect(TT, info, animationType)
    local data = self:_RandomAnimationAndEffect(info)
    if data == nil then
        return
    end
    -- duration
    if animationType == HomelandInteractAnimationType.Loop and data.duration ~= nil then
        self._loopTime = data.duration * 1000
    end

    -- 配置离开交互点
    if animationType == HomelandInteractAnimationType.Out and data.leaveTransform ~= nil then
        local index = self._interactPoint:GetIndex()
        local leaveTransform = self._building:GetInteractLeaveNode(index, data.leaveTransform)
        if leaveTransform ~= nil then
            self._targetPosition = leaveTransform.position
            self._targetRotation = leaveTransform.rotation
        end
    end

    -- followBuilding
    if data.followBuilding ~= nil then
        local fnFindRecursively = HomeBuilding.FindRecursively
        self._trFollowBuilding = fnFindRecursively(self._building, data.followBuilding)
    end

    local animationState = self._building:GetCurAnimationState()
    if animationState then
        while animationType == HomelandInteractAnimationType.Loop and not self:_IsFirstInteractObject() and self._building:GetCurAnimationType() ~= animationType do
            YIELD(TT)
        end
        while animationType == HomelandInteractAnimationType.Loop and not self:_IsFirstInteractObject() and not self:_AnimationStateZero(animationState) do
            YIELD(TT)
        end
        if animationType == HomelandInteractAnimationType.Loop then
            if self:_IsFirstInteractObject() then
                self._building:PlayAnimation(data.anim, self._pet:SkinID(), animationType)
            end
            self:_PlayEffect(data)
            self:_PlayAnimation(TT, info, data, animationType)
        else
            if self:_IsFirstInteractObject() then
                if animationType == HomelandInteractAnimationType.In then
                    self._building:PlayAnimation(data.anim, self._pet:SkinID(), animationType)
                    self:_PlayEffect(data)
                    self:_PlayAnimation(TT, info, data, animationType)
                elseif animationType == HomelandInteractAnimationType.Out then
                    if not self._building:IsMultiInteract() then
                        self._building:PlayAnimation(data.anim, self._pet:SkinID(), animationType)
                        self:_PlayEffect(data)
                        self:_PlayAnimation(TT, info, data, animationType)
                    end
                    self._building:RemoveInteractObject(self._pet:SkinID())
                end
            end
        end
    else
        if self:_IsFirstInteractObject() then
            self._building:PlayAnimation(data.anim, self._pet:SkinID(), animationType)
        end
        self:_PlayEffect(data)
        self:_PlayAnimation(TT, info, data, animationType)
    end
end

function HomelandPetComponentInteractionAnimation:_RandomAnimationAndEffect(info)
    if not info then
        return nil
    end
    if table.count(info) <= 1 then
        return info[1]
    end
    local totalWeight = 0
    local weightArray = {}
    for key, value in pairs(info) do
        if value.weight then
            weightArray[key] = {totalWeight, value.weight}
            totalWeight = totalWeight + value.weight
        end
    end
    local randomWeight = math.random(1, totalWeight)
    for key, value in pairs(weightArray) do
        if randomWeight > value[1] and randomWeight <= value[2] then
            return info[key]
        end
    end
end

function HomelandPetComponentInteractionAnimation:Dispose()
    HomelandPetComponentInteractionAnimation.super.Dispose()
    if self._animationTask then
        GameGlobal.TaskManager():KillTask(self._animationTask)
        self._animationTask = nil
    end
end

function HomelandPetComponentInteractionAnimation:PlayStand()
    --如果动作类型是游泳
    if self._pet:GetMotionType() == HomelandPetMotionType.Swim then
        self._animation:Play(HomelandPetAnimName.Float)
    else
        self._animation:Play(HomelandPetAnimName.Stand)
    end
end

---@param animationType HomelandInteractAnimationType
function HomelandPetComponentInteractionAnimation:_PlayAnimation(TT, info, data, animationType)
    ---@type UnityEngine.AnimationState
    self._animationStates[data.anim] = self._animation:get_Item(data.anim)
    if self._animationStates[data.anim] then
        self._building:UpdateInteractObject(self._pet:SkinID(), data.anim)
        if data.crossFadeTime then
            self._animation:CrossFade(self._animationStates[data.anim].name, data.crossFadeTime)
        else
            self._animation:Play(self._animationStates[data.anim].name)
        end
        if self._interactVisible then
            self._animationStates[data.anim].speed = 1
        else
            self._animationStates[data.anim].speed = 0
        end
        if not self:_IsFirstInteractObject() and self._building then
            YIELD(TT)
            local buildingAnimationState = self._building:GetCurAnimationState()
            if buildingAnimationState then
                local deltaTime = GameGlobal:GetInstance():GetDeltaTime()
                local offset = buildingAnimationState.time --(buildingAnimationState.time % buildingAnimationState.length) / buildingAnimationState.length
                self._animationStates[data.anim].time = offset + deltaTime * 0.001
            end
        end
        if self._moveToAnimationPosition then
            self._pet:AgentTransform():DOMove(self._animationPosition, 0)
            self._pet:SetRotation(self._animationRotation)
            self._moveToAnimationPosition = false
            self:_BindingSkeleton(true, TT)
        end

        if self._trFollowBuilding ~= nil then
            self._pet:FollowBuilding(self._trFollowBuilding)
        end

        if animationType == HomelandInteractAnimationType.Loop then
            YIELD(TT, self._loopTime)
        else
            local animationTime = self._animationStates[data.anim].length * 1000
            YIELD(TT, animationTime)
        end
    end
end

function HomelandPetComponentInteractionAnimation:_PlayEffect(data)
    if data.peff and not self._petEffectReqs[data.peff] then
        ---@type UnityEngine.Transform
        local bone = self._pet:GetBoneNode(data.pholder)
        local req = ResourceManager:GetInstance():SyncLoadAsset(data.peff .. ".prefab", LoadType.GameObject)
        if req and req.Obj then
            for _, obj in pairs(self._petEffectObj) do
                if obj and obj.activeSelf then
                    obj:SetActive(false)
                end
            end
            local effect = req.Obj
            effect:SetActive(true)
            effect.transform:SetParent(bone)
            effect.transform.localPosition = Vector3.zero
            effect.transform.localRotation = Quaternion.Euler(0, 0, 0)
            self._petEffectReqs[data.peff] = req
            self._petEffectObj[data.peff] = req.Obj
        end
    end
    if data.beff and not self._buildingEffects[data.beff] then
        self._building:PlayInteractEffect(data.beff, data.bholder)
        self._buildingEffects[data.beff] = true
    end
end

function HomelandPetComponentInteractionAnimation:_IsFirstInteractObject()
    return self._building:IsFirstInteractObject(self._pet:SkinID())
end

--停止建筑的动画和特效
function HomelandPetComponentInteractionAnimation:_StopBuildingAnimation(id)
    if self._building then
        if self._building:IsLastInteractObject(id) then
            self._building:StopInteractEffect()
            if self._buildingPetCfg then
                local data = self:_RandomAnimationAndEffect(self._buildingPetCfg.In)
                if data then
                    self._building:SetAnimTime(data.anim, 0)
                end
            end
            self._building:RemoveInteractObject(self._pet:SkinID())
            self._building:StopAnimation(self._pet:SkinID())
        else
            self._building:RemoveInteractObject(self._pet:SkinID())
            self._building:TryStopAnimation()
        end
        self._building = nil
    end
end

--动画归零
---@param animationState UnityEngine.AnimationState
function HomelandPetComponentInteractionAnimation:_AnimationStateZero(animationState)
    if animationState then
        local deltaTime = GameGlobal:GetInstance():GetDeltaTime()
        return (animationState.time % animationState.length) <= deltaTime * 0.001
    end
    return true
end

--设置光灵交互特效的显隐以及交互动作的暂停与播放，例如光灵如果被当任务NPC、建造模式的时候需要隐藏光灵交互特效和暂停交互动作
function HomelandPetComponentInteractionAnimation:SetInteractVisible(visible)
    self._interactVisible = visible
    for _, gameObject in pairs(self._petEffectObj) do
        gameObject:SetActive(self._interactVisible)
    end
    for _, animationState in pairs(self._animationStates) do
        if animationState then
            if self._interactVisible then
                animationState.speed = 1
            else
                animationState.speed = 0
            end
        end
    end
    if self._building then
        self._building:SetInteractVisible(self._interactVisible)
    end
end

function HomelandPetComponentInteractionAnimation:_GetInterruptCfg(buildingCfgID)
    local interrupts = self._behavior._cfgBehaviorLib.InterruptInteraction[1]
    if interrupts then
        for _, value in pairs(interrupts) do
            if value[1] == buildingCfgID then
                return value
            end
        end
    end
    return nil
end

---播放交互动画的时候把光灵绑定到家具的指定骨骼上
function HomelandPetComponentInteractionAnimation:_BindingSkeleton(isBinding, TT)
    if isBinding then
        if self._buildingPetCfg.BindingSkeleton then
            local index = self._interactPoint:GetIndex()
            local bindingSkeleton = self._buildingPetCfg.BindingSkeleton
            if bindingSkeleton[index + 1] then
                local skeleton = self._building:GetBoneNodeNoRoot(bindingSkeleton[index + 1])
                if skeleton then
                    YIELD(TT)
                    self._pet:BindingSkeleton(isBinding, skeleton)
                    self._bindingSkeletoned = true
                end
            end
        end
    else
        if self._bindingSkeletoned then
            self._pet:BindingSkeleton(isBinding)
        end
    end
end