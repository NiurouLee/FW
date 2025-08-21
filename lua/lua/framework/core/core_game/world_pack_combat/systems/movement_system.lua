---@class MovementSystem:Object
_class( "MovementSystem", Object )

---@param world World
function MovementSystem:Constructor(world)
    self.world = world
    self.group = world:GetGroup(world.BW_WEMatchers.CanMove)
end

function MovementSystem:Execute()
    self.group:HandleForeach(self, self.SimpleMove)
end

---@param e Entity
function MovementSystem:SimpleMove(e)
    local movement = e:Movement()
    local location = e:Location()
    local deltaTime = 0.03
    movement:Update(location, deltaTime)
    
    e:SetLocation(movement:GetNextPosition(), movement:GetNextDirection())

    if movement:IsFinish() then
        e:RemoveMovement()
    end
end