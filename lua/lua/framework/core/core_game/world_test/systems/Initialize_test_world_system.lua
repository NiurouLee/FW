---@class InitializeWorldSystem:Object
_class( "InitializeWorldSystem", Object )

---@param world BaseWorld
function InitializeWorldSystem:Constructor(world)
    self.world = world
end

function InitializeWorldSystem:Initialize()
     math.randomseed(self.world.BW_WorldInfo.world_seed)
end
