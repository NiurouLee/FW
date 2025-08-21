--[[------------------------------------------------------------------------------------------
    TeamComponent : 队伍组件
]] --------------------------------------------------------------------------------------------

_class("TeamComponent", Object)
---@class TeamComponent: Object
TeamComponent = TeamComponent

function TeamComponent:Constructor()
    ---@type Entity
    self._teamLeader = nil
    self._teamPetEntities = nil
    ---@type table<number,number>  队伍的逻辑顺序 key是序号 value是PetPstID
    self._teamOrder = {}
    self._teamPetEntityDict = {} --pstid:entity
    self._helpPetPstID = nil
    self._selectedTeamOrderPosition = 0

    self._cmdOldTeamOrder = {}
    self._cmdNewTeamOrder = {}
end

function TeamComponent:GetTeamLeaderEntity()
    return self._teamLeader
end

function TeamComponent:GetTeamLeaderEntityID()
    return self._teamLeader:GetID()
end

function TeamComponent:GetTeamLeaderPetPstID()
    return self._teamLeader:PetPstID():GetPstID()
end

function TeamComponent:SetTeamLeader(entity)
    self._teamLeader = entity
end

---在需要临时替换队长的地方需要保存原本的队长属性
function TeamComponent:SetOriginalTeamLeaderID(entityID)
    self._originalTeamLeaderID = entityID
end
---
function TeamComponent:GetOriginalTeamLeaderID()
    return self._originalTeamLeaderID
end

---@return Entity[]
function TeamComponent:GetTeamPetEntities()
    return self._teamPetEntities
end

function TeamComponent:SetTeamPetEntities(pets)
    self._teamPetEntities = pets
    for _, e in ipairs(pets) do
        self._teamPetEntityDict[e:PetPstID():GetPstID()] = e
    end
end

---@return Entity|nil
function TeamComponent:GetPetEntityByPetPstID(pstid)
    return self._teamPetEntityDict[pstid]
end

function TeamComponent:SetTeamOrder(teamOrder)
    self._teamOrder = teamOrder
end

function TeamComponent:GetTeamOrder()
    return self._teamOrder
end

function TeamComponent:GetTeamIndexByPetPstID(petPstID)
    for i, v in ipairs(self._teamOrder) do
        if v == petPstID then
            return i
        end
    end
end
---@return Entity
---@param petIndex number
function TeamComponent:GetPetEntityByTeamIndex(petIndex)
    local petPstID = self._teamOrder[petIndex]
    local petEntity = self:GetPetEntityByPetPstID(petPstID)
    return petEntity
end

function TeamComponent:ChangeTeamLeader(newLeaderPetPstID)
    local newLeaderIndex = self:GetTeamIndexByPetPstID(newLeaderPetPstID)
    self._teamOrder[1], self._teamOrder[newLeaderIndex] = self._teamOrder[newLeaderIndex], self._teamOrder[1]
end

function TeamComponent:GetEnemyTeamEntity()
    return self._enemyTeamEntity
end

function TeamComponent:SetEnemyTeamEntity(teamEntity)
    self._enemyTeamEntity = teamEntity
end

function TeamComponent:IsTeamLeaderByEntityId(entityId)
    return (self:GetTeamLeaderEntityID() == entityId)
end

function TeamComponent:SetHelpPetPstID(val)
    self._helpPetPstID = val
end

---@return number|nil PstID if exists
function TeamComponent:GetHelpPetPstID()
    return self._helpPetPstID
end

function TeamComponent:CloneTeamOrder()
    local t = {}
    for k, v in pairs(self._teamOrder) do
        t[k] = v
    end
    return t
end

function TeamComponent:SetSelectedTeamOrderPosition(v)
    self._selectedTeamOrderPosition = v
end

function TeamComponent:ClearSelectedTeamOrderPosition()
    self._selectedTeamOrderPosition = 0
end

function TeamComponent:GetSelectedTeamOrderPosition()
    return self._selectedTeamOrderPosition
end

---
function TeamComponent:SetChangeTeamLeaderCmdData(oldTeamOrder, newTeamOrder)
    self._cmdOldTeamOrder = oldTeamOrder
    self._cmdNewTeamOrder = newTeamOrder
end

---
function TeamComponent:GetChangeTeamLeaderCmdData()
    return self._cmdOldTeamOrder, self._cmdNewTeamOrder
end

--------------------------------------------------------------------------------------------

--[[------------------------------------------------------------------------------------------
    Entity Extensions
]]
---@return TeamComponent
function Entity:Team()
    return self:GetComponent(self.WEComponentsEnum.Team)
end

function Entity:HasTeam()
    return self:HasComponent(self.WEComponentsEnum.Team)
end

function Entity:AddTeam()
    local index = self.WEComponentsEnum.Team
    local component = TeamComponent:New()
    self:AddComponent(index, component)
end

function Entity:ReplaceTeam()
    local index = self.WEComponentsEnum.Team
    local component = TeamComponent:New()
    self:ReplaceComponent(index, component)
end

function Entity:RemoveTeam()
    if self:HasTeam() then
        self:RemoveComponent(self.WEComponentsEnum.Team)
    end
end

function Entity:SetTeamLeaderPetEntity(petEntity)
    if not self:HasTeam() then
        local index = self.WEComponentsEnum.Team
        local component = TeamComponent:New()
        self:AddComponent(index, component)
    end
    local team = self:Team()
    local petPstID = petEntity:PetPstID():GetPstID()
    team:SetTeamLeader(petEntity)
    team:ChangeTeamLeader(petPstID)
    ---@type ElementComponent
    local element = petEntity:Element()
    self:ReplaceElement(element:GetPrimaryType(), element:GetSecondaryType())
end

---@return Entity
function Entity:GetTeamLeaderPetEntity()
    if not self:HasTeam() then
        return nil
    end
    ---@type TeamComponent
    local team = self:Team()
    ---@type Entity
    local teamLeaderPetEntity = team:GetTeamLeaderEntity()
    return teamLeaderPetEntity
end
