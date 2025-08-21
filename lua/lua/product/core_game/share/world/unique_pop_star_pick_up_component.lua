--[[------------------------------------------------------------------------------------------
    PopStarPickUpComponent : 处理消灭星星玩法的点选
]]
--------------------------------------------------------------------------------------------

---@class PopStarPickUpComponent: Object
_class("PopStarPickUpComponent", Object)
PopStarPickUpComponent = PopStarPickUpComponent

---@param world World
function PopStarPickUpComponent:Constructor(world)
    self._world = world
    self._clickPos = Vector3(0, 0, 0)
end

function PopStarPickUpComponent:Initialize()
    Log.notice("PopStarPickUpComponent Initialize")
end

function PopStarPickUpComponent:SetPopStarClickPos(clickPos)
    self._clickPos = clickPos
end

function PopStarPickUpComponent:GetPopStarClickPos()
    return self._clickPos
end

--------------------------------------------------------------------------------------------

--[[------------------------------------------------------------------------------------------
    MainWorld Extensions
]]
---@return PopStarPickUpComponent
function MainWorld:PopStarPickUp()
    return self:GetUniqueComponent(self.BW_UniqueComponentsEnum.PopStarPickUp)
end

function MainWorld:HasPopStarPickUp()
    return self:GetUniqueComponent(self.BW_UniqueComponentsEnum.PopStarPickUp) ~= nil
end

function MainWorld:AddPopStarPickUp(world)
    local index = self.BW_UniqueComponentsEnum.PopStarPickUp
    local component = PopStarPickUpComponent:New(self)
    component:Initialize()
    self:SetUniqueComponent(index, component)
end

function MainWorld:RemovePopStarPickUp()
    if self:HasPopStarPickUp() then
        self:SetUniqueComponent(self.BW_UniqueComponentsEnum.PopStarPickUp, nil)
    end
end
