--[[------------------------------------------------------------------------------------------
    GhostComponent : 
]] --------------------------------------------------------------------------------------------

---@class GuideGhostComponent: Object
_class("GuideGhostComponent", Object)
GuideGhostComponent=GuideGhostComponent

function GuideGhostComponent:Constructor(ownerID)
    self._ownerID = ownerID
end

function GuideGhostComponent:GetOwnerID()
    return self._ownerID
end
-- As IWorldEntityComponent:
--//////////////////////////////////////////////////////////

---@param owner Entity
function GuideGhostComponent:WEC_PostInitialize(owner)
    --ToDo WEC_PostInitialize
end

function GuideGhostComponent:WEC_PostRemoved()
    --Do WEC_PostRemoved
end
--------------------------------------------------------------------------------------------

-- This:
--//////////////////////////////////////////////////////////

--[[------------------------------------------------------------------------------------------
    Entity Extensions
]]
---@return GhostComponent
function Entity:GuideGhost()
    return self:GetComponent(self.WEComponentsEnum.GuideGhost)
end

function Entity:HasGuideGhost()
    return self:HasComponent(self.WEComponentsEnum.GuideGhost)
end

function Entity:AddGuideGhost(ownerID)
    local index = self.WEComponentsEnum.GuideGhost
    local component = GuideGhostComponent:New(ownerID)
    self:AddComponent(index, component)
end

function Entity:ReplaceGuideGhost(ownerID)
    local index = self.WEComponentsEnum.GuideGhost
    local component = GuideGhostComponent:New(ownerID)
    self:ReplaceComponent(index, component)
end

function Entity:RemoveGuideGhost()
    if self:HasGuideGhost() then
        self:RemoveComponent(self.WEComponentsEnum.GuideGhost)
    end
end
