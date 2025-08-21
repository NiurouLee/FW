---@class WorldCreationContext:Object
_class("WorldCreationContext", Object)
WorldCreationContext = WorldCreationContext

function WorldCreationContext:Constructor()
    self.WCC_StartCreationIndex = 1
    self.WCC_EntityCreationProto = Entity
    self.WCC_EntityIdThreshold = 100000000 --逻辑和渲染实体id阈值
    self.WCC_StartEntityIdLogic = 1
    self.WCC_StartEntityIdRender = 1
end

function WorldCreationContext:WCC_EntityTotalComponents()
    return 0
end
