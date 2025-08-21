---@class UIInteractPointController:UICustomWidget
_class("UIInteractPointController", UICustomWidget)
UIInteractPointController = UIInteractPointController

function UIInteractPointController:Constructor()
    self._guideModule = GameGlobal.GetModule(GuideModule)
end

function UIInteractPointController:OnShow(uiParams)
    self._anim = self:GetUIComponent("Animation", "Anim")
    self._root = self:GetGameObject("Root")
    self._interactPointLoader = self:GetUIComponent("UISelectObjectPath", "InteractPoints")
    self._interactPoints = {}
    self._status = false
    self._go = self:GetGameObject()
    self._go:SetActive(true)

    self:AttachEvent(GameEventType.SetInteractPointUIStatus, self.SetStatusInternal)
    self:AttachEvent(GameEventType.EnterBuildInteract, self.EnterBuildInteractEventHandle)
    self:AttachEvent(GameEventType.LeaveBuildInteract, self.LeaveBuildInteractEventHandle)
end

function UIInteractPointController:OnHide()
    self:DetachEvent(GameEventType.EnterBuildInteract, self.EnterBuildInteractEventHandle)
    self:DetachEvent(GameEventType.LeaveBuildInteract, self.LeaveBuildInteractEventHandle)
    self:DetachEvent(GameEventType.SetInteractPointUIStatus, self.SetStatusInternal)
end

function UIInteractPointController:SetStatusInternal(status)
    self._root:SetActive(status)
end

function UIInteractPointController:SetStatus(status, clearDatas)
    if self._status ~= status then
        if status then
            self:_RefreshInteractPoint()
            self._go:SetActive(true)
        else
            if clearDatas then
                self._interactPoints = {}
            end
            self._go:SetActive(false)
        end
    end
    self._status = status
end

---@param interactPoint InteractPoint
function UIInteractPointController:EnterBuildInteractEventHandle(interactPoint)
    self:_AddInteractPoint(interactPoint)
end

---@param interactPoint InteractPoint
function UIInteractPointController:LeaveBuildInteractEventHandle(interactPoint)
    self:_RemoveInteractPoint(interactPoint)
end


function UIInteractPointController:OnUpdate(deltaTimeMS)
    if not self._go or not self._go.activeInHierarchy then
        return
    end
    if not self.items then
        return
    end
    for _, interactPoint in pairs(self.items) do
        if interactPoint then
            interactPoint:OnUpdate(deltaTimeMS)
        end
    end
end

---@param interactPoint InteractPoint
function UIInteractPointController:_AddInteractPoint(interactPoint)
    if not self:_CheckPointAvailable(interactPoint) then
        return
    end

    --检查是否已经添加
    for i = 1, #self._interactPoints do
        if self._interactPoints[i] == interactPoint then
            return
        end
    end
    --检查是否同类型
    local isSameType = false
    for _, v in pairs(self._interactPoints) do
        local type = interactPoint:GetPointType()
        local oldType = v:GetPointType()
        if oldType == type then
            isSameType = true
            ---@type UIHomelandModule
            local homeLandModule = GameGlobal.GetUIModule(HomelandModule)
            ---@type HomelandClient
            local homelandClient = homeLandModule:GetClient()
            ---@type HomelandMainCharacterController
            local characterController = homelandClient:CharacterManager():MainCharacterController()
            local characterPos = characterController:Position()
            --比较位置
            local oldDistance = v:GetDistance(characterPos)
            local newDistance = interactPoint:GetDistance(characterPos)
            if newDistance < oldDistance then
                self:_RemoveInteractPoint(v)
                self._interactPoints[#self._interactPoints + 1] = interactPoint
                self:_RefreshInteractPoint()
            end
            break
        end
    end
    if not isSameType then
        self._interactPoints[#self._interactPoints + 1] = interactPoint
        self:_RefreshInteractPoint()
    end
end

function UIInteractPointController:_RemoveInteractPoint(interactPoint)
    if not interactPoint then
        return
    end

    for i = 1, #self._interactPoints do
        if self._interactPoints[i] == interactPoint then
            table.remove(self._interactPoints, i)
            self:_RefreshInteractPoint()
            return
        end
    end
end

function UIInteractPointController:_RefreshInteractPoint()
    self._interactPointLoader:SpawnObjects("UIInteractPoint", #self._interactPoints)
    ---@type UIInteractPoint[]
    self.items = self._interactPointLoader:GetAllSpawnList()
    --排序
    local tmpPoints = {}
    local targetType = {InteractPointType.PetCommunication,InteractPointType.Invite,InteractPointType.RoleInteract,InteractPointType.Build}
    for _,targetType in pairs(targetType) do
        for i, v in pairs(self._interactPoints) do
            local type = v:GetPointType()
            if type == targetType then
                table.insert(tmpPoints,v)
                table.remove(self._interactPoints,i)
                break
            end
        end
    end
    for _, v in pairs(self._interactPoints) do
        table.insert(tmpPoints,v)
    end
    self._interactPoints = tmpPoints

    local index = 1
    for _,v in pairs(self._interactPoints) do
        self.items[index]:Refresh(v)
        index = index + 1
    end

    GameGlobal.EventDispatcher():Dispatch(GameEventType.HomelandInteractPointUIRefresh)
end

---@param interactPoint InteractPoint
function UIInteractPointController:_CheckPointAvailable(interactPoint)
    if not interactPoint then
        return false
    end

    local interactType = interactPoint:GetPointType()
    if interactType == InteractPointType.CutTree or
       interactType == InteractPointType.Mining or 
       interactType == InteractPointType.TracePoint or
       interactType == InteractPointType.PetBuilding then
        return false
    end

    if interactPoint:GetPointType() == InteractPointType.RoleInteract then
        --主角交互点在相同位置光灵交互点的下一个节点 找到对应光灵交互点并确认是否被占据
        local relatedPetInteractingTarget = interactPoint:GetBuild():GetInteractPoint(interactPoint:GetIndex())  -- -1+1

        ---@type HomelandPet
        local interactingTarget = relatedPetInteractingTarget:GetInteractObject()
        if not interactingTarget then
            return true
        elseif not HomelandPet:IsInstanceOfType(interactingTarget) or not interactingTarget:IsAlive() then
            return false
        else
            local moveComponent = interactingTarget:GetPetBehavior():GetCurBehavior():GetComponent(HomelandPetComponentType.Move)
            if moveComponent and moveComponent.state == HomelandPetComponentState.Running then
                return true
            else
                return false
            end
        end
    end

    return true
end

--N17 交互按钮引导
function UIInteractPointController:GetInteractBtn(param)
    if self._guideModule:GuideInProgress() then
        if self.items then
            for _, interactPoint in pairs(self.items) do
                local interactObjID = 0
                local interactObj = interactPoint:GetBuild()
                if HomelandTaskNPC:IsInstanceOfType(interactObj) then
                    interactObjID = interactObj.npcID
                end
                if HomelandPet:IsInstanceOfType(interactObj) then
                    interactObjID = interactObj:TemplateID()
                end
                if HomeBuilding:IsInstanceOfType(interactObj) then
                    interactObjID = interactObj:GetBuildId()
                end
                local id = param[1]
                local _type = param[2]
                if interactObjID == id and ((not _type) or (_type == interactPoint:GetPointType())) then
                    return interactPoint:GetInteractBtn()
                end
            end
        end
    end
end
