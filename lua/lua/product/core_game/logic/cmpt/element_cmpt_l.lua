--[[------------------------------------------------------------------------------------------
    ElementComponent : 元素组件，表明该单位的元素属性
]] --------------------------------------------------------------------------------------------

_class("ElementComponent", Object)
---@class ElementComponent: Object
ElementComponent = ElementComponent

---@param primaryType ElementType
---@param secondaryType ElementType
function ElementComponent:Constructor(primaryType, secondaryType)
    self._primaryType = primaryType
    self._secondaryType = secondaryType
    ---是否使用元素副属性
    self._useSecondaryElement = false
end
---@return ElementType
function ElementComponent:GetPrimaryType()
    return self._primaryType
end

function ElementComponent:GetSecondaryType()
    return self._secondaryType
end

function ElementComponent:HasSecondaryType()
    return self._secondaryType ~= nil
end

function ElementComponent:IsUseSecondaryType()
    if self._secondaryType ~= nil then
        return self._useSecondaryElement
    end
    return false
end

function ElementComponent:SetUseSecondaryType(isEnable)
    if self._secondaryType ~= nil then
        self._useSecondaryElement = isEnable
    end
end
--------------------------------------------------------------------------------------------

--[[------------------------------------------------------------------------------------------
    Entity Extensions
]]
---@return ElementComponent
function Entity:Element()
    return self:GetComponent(self.WEComponentsEnum.Element)
end

function Entity:HasElement()
    return self:HasComponent(self.WEComponentsEnum.Element)
end

function Entity:AddElement(primaryType, secondaryType)
    local index = self.WEComponentsEnum.Element
    local component = ElementComponent:New(primaryType, secondaryType)
    self:AddComponent(index, component)
end

function Entity:ReplaceElement(primaryType, secondaryType)
    local index = self.WEComponentsEnum.Element
    local component = ElementComponent:New(primaryType, secondaryType)
    self:ReplaceComponent(index, component)
end

function Entity:RemoveElement()
    if self:HasElement() then
        self:RemoveComponent(self.WEComponentsEnum.Element)
    end
end
