--[[------------------------------------------------------------------------------------------
    PetComponent : 表示是宠物的组件
]] --------------------------------------------------------------------------------------------

_class("PetComponent", Object)
---@class PetComponent: Object
PetComponent=PetComponent

function PetComponent:Constructor()
    self._teamEntity = nil
end 

---@return Entity
function PetComponent:GetOwnerTeamEntity()
    return self._teamEntity
end

function PetComponent:SetOwnerTeamEntity(entity)
    self._teamEntity = entity
end

---@return PetComponent
 function Entity:Pet()
    return self:GetComponent(self.WEComponentsEnum.Pet)
end

function Entity:HasPet()
    return self:HasComponent(self.WEComponentsEnum.Pet)
end

function Entity:AddPet()
    local index = self.WEComponentsEnum.Pet
    local component = PetComponent:New()
    self:AddComponent(index, component)
end


function Entity:RemovePet()
    if self:HasPet() then
        self:RemoveComponent(self.WEComponentsEnum.Pet)
    end
end
