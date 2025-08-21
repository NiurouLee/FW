---@class HomelandPetBehaviorBase:Object
_class("HomelandPetBehaviorBase", Object)
HomelandPetBehaviorBase = HomelandPetBehaviorBase

---@param behaviorType HomelandPetBehaviorType
---@param pet HomelandPet

function HomelandPetBehaviorBase:Constructor(behaviorType, pet)
    ---@type HomelandPetBehaviorType
    self._behaviorType = behaviorType
    ---@type HomelandPet
    self._pet = pet
    ---@type HomelandPetBehaviorStructure
    self._behaviorStructure = HomelandPetBehaviorStructure[self._behaviorType]
    ---@type table<HomelandPetComponentType, HomelandPetComponentBase>
    self._components = {}
    --- @type HomelandClient
    self._homelandClient = self._pet:GetHomelandClient()
    ---@type HomelandPetComponentFactory
    self._componentFactory = self._homelandClient:PetManager():GetComponentFactory()
    self._sequence = "SequenceNode"
    self:_InitComponent()
    local cfg_behavior_lib = Cfg.cfg_homeland_pet_behavior_lib{TemplateID = self._pet:TemplateID(), BehaviorType = self._behaviorType}
    if not cfg_behavior_lib then
        cfg_behavior_lib = Cfg.cfg_homeland_pet_behavior_lib{TemplateID = 0, BehaviorType = self._behaviorType}
        --Log.error("Homeland Pet Cfg_homeland_pet_behavior_lib Not Exist.", self._pet:TemplateID(), self._behaviorType)
    end
    self._cfgBehaviorLib = cfg_behavior_lib[1]
    self._duration = 0
    self._modeChangeProcessType = HomelandPetModeChangeProcessType.RefreshNavmeshPos
    self.triggerSuccParam = nil
end
function HomelandPetBehaviorBase:_InitComponent()
    if not self._behaviorStructure then
        Log.error("Homeland Pet Behavior Structure Not Exist.", self._behaviorType)
        return
    end
    for behaviorType, componentType in pairs(self._behaviorStructure) do
        if type(componentType) == "table" then
            self._components[self._sequence] = {}
            for _, sequenceComponentType in pairs(componentType) do
                if not self._components[self._sequence][sequenceComponentType] then
                    self._components[self._sequence][sequenceComponentType] = self._componentFactory:CreateHomelandPetComponent(sequenceComponentType, self._pet,self)
                end
            end
        else
            if not self._components[componentType] then
                self._components[componentType] = self._componentFactory:CreateHomelandPetComponent(componentType, self._pet,self)
            end
        end
    end
end

function HomelandPetBehaviorBase:OnEnter(params, index)
    self._params = params
    self._index = index
end

function HomelandPetBehaviorBase:Enter()
    self._duration = self._cfgBehaviorLib.Duration * 1000
end
function HomelandPetBehaviorBase:Update(deltaTime)
    local isFinish = true
    for componentType, component in pairs(self._components) do
        if componentType == self._sequence then
            for sequenceComponentType, sequenceComponent in pairs(component) do
                if sequenceComponent.state == HomelandPetComponentState.Resting then
                    sequenceComponent:OnExcute()
                end
                if sequenceComponent.state == HomelandPetComponentState.Running then
                    sequenceComponent:Update(deltaTime)
                end
                if sequenceComponent:Failure() then
                    break
                end
                if not sequenceComponent:Finish() then
                    isFinish = false 
                    break
                end
            end
        else
            if component.state == HomelandPetComponentState.Resting then
                component:OnExcute()
            end
            if component.state == HomelandPetComponentState.Running then
                component:Update(deltaTime)
            end
            if not component:Finish() and not component:Failure()  then
                isFinish = false 
            end
        end
    end
    if self._duration > 0 and isFinish then
        self._duration = self._duration - deltaTime
    end
end
function HomelandPetBehaviorBase:Exit()
    for componentType, component in pairs(self._components) do
        if componentType == self._sequence then
            for sequenceComponentType, sequenceComponent in pairs(component) do
                sequenceComponent:Exit()
            end
        else
            component:Exit()
        end
    end
end
function HomelandPetBehaviorBase:Done()
    for componentType, component in pairs(self._components) do
        if componentType == self._sequence then
            for sequenceComponentType, sequenceComponent in pairs(component) do
                if sequenceComponent:Failure() then
                    return self:_DurationEnd()
                end
                if not sequenceComponent:Finish() then
                    return false
                end
            end
        else
            if not component:Finish() then
                return false
            end
        end
    end
    return self:_DurationEnd()
end

function HomelandPetBehaviorBase:ReLoadBehaviorComponent()
    for componentType, component in pairs(self._components) do
        if componentType == self._sequence then
            for sequenceComponentType, sequenceComponent in pairs(component) do
                sequenceComponent:ReLoadPetComponent()
            end
        else
            component:ReLoadPetComponent()
        end
    end
end

function HomelandPetBehaviorBase:CD()
    return self._cfgBehaviorLib.CD * 1000
end

function HomelandPetBehaviorBase:CanInterrupt()
    return true
end
function HomelandPetBehaviorBase:Dispose()
    for componentType, component in pairs(self._components) do
        if componentType == self._sequence then
            for sequenceComponentType, sequenceComponent in pairs(component) do
                sequenceComponent:Dispose()
            end
        else
            component:Dispose()
        end
    end
end
---@return HomelandPetBehaviorType
function HomelandPetBehaviorBase:GetBehaviorType()
    return self._behaviorType
end
function HomelandPetBehaviorBase:_DurationEnd()
    return self._duration <= 0
end

---@param componentType HomelandPetComponentType
---@return HomelandPetComponentBase
function HomelandPetBehaviorBase:GetComponent(componentType)
    for _componentType, component in pairs(self._components) do
        if _componentType == self._sequence then
            for _sequenceComponentType, _sequenceComponent in pairs(component) do
                if _sequenceComponentType == componentType then
                    return _sequenceComponent
                end
            end
        else
            if _componentType == componentType then
                return component
            end
        end
    end
    return nil
end

function HomelandPetBehaviorBase:GetCfg()
    return self._cfgBehaviorLib
end
function HomelandPetBehaviorBase:HideBubble()
    ---@type HomelandPetComponentBubble
    self._bubbleComponent = self:GetComponent(HomelandPetComponentType.Bubble)
    if self._bubbleComponent then
        self._bubbleComponent:Hide()
    end
end
function HomelandPetBehaviorBase:OnClientModeChange(lastMode, currentMode)
    if self._modeChangeProcessType == HomelandPetModeChangeProcessType.RefreshNavmeshPos then
        if lastMode == HomelandMode.Build and currentMode == HomelandMode.Normal then
            self._pet:ResetNavmeshPos()
        end
    end
end

function HomelandPetBehaviorBase:HideBubble()
    ---@type HomelandPetComponentBubble
    self._bubbleComponent = self:GetComponent(HomelandPetComponentType.Bubble)
    if self._bubbleComponent then
        self._bubbleComponent:Hide()
    end
end
function HomelandPetBehaviorBase:GetTriggerSuccParam()
    return self.triggerSuccParam
end