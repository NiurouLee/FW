--[[------------------------------------------------------------------------------------------
    PetShadowRenderComponent : 
]]--------------------------------------------------------------------------------------------

---@class PetShadowRenderComponent: Object
_class( "PetShadowRenderComponent", Object )
PetShadowRenderComponent = PetShadowRenderComponent
function PetShadowRenderComponent:Constructor()

end

function PetShadowRenderComponent:SetOwnerEntityID(ownerEntityID)
    self._ownerEntityID = ownerEntityID
end
function PetShadowRenderComponent:GetOwnerEntityID()
    return self._ownerEntityID
end

-- As IWorldEntityComponent:
--//////////////////////////////////////////////////////////

---@param owner Entity
function PetShadowRenderComponent:WEC_PostInitialize(owner)
    --ToDo WEC_PostInitialize
end

function PetShadowRenderComponent:WEC_PostRemoved()
    --Do WEC_PostRemoved
end

-- This:
--//////////////////////////////////////////////////////////


--[[------------------------------------------------------------------------------------------
    Entity Extensions
]]--------------------------------------------------------------------------------------------
---@return PetShadowRenderComponent
function Entity:PetShadowRender()
    return self:GetComponent(self.WEComponentsEnum.PetShadowRender)
end


function Entity:HasPetShadowRender()
    return self:HasComponent(self.WEComponentsEnum.PetShadowRender)
end


function Entity:AddPetShadowRender()
    local index = self.WEComponentsEnum.PetShadowRender;
    local component = PetShadowRenderComponent:New()
    self:AddComponent(index, component)
end


function Entity:ReplacePetShadowRender()
    local index = self.WEComponentsEnum.PetShadowRender;
    local component = PetShadowRenderComponent:New()
    self:ReplaceComponent(index, component)
end


function Entity:RemovePetShadowRender()
    if self:HasPetShadowRender() then
        self:RemoveComponent(self.WEComponentsEnum.PetShadowRender)
    end
end