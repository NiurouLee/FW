--[[------------------------------------------------------------------------------------------
    主状态机：棋子光灵预览阶段
]]--------------------------------------------------------------------------------------------

---这个系统不会在服务端运行
---@class PreviewChessPetStateSystem_Render:UniqueReactiveSystem
_class("PreviewChessPetStateSystem_Render", UniqueReactiveSystem )

function PreviewChessPetStateSystem_Render:Constructor(world)
    self._world = world
end

function PreviewChessPetStateSystem_Render:TearDown()
    self._world = nil
end

function PreviewChessPetStateSystem_Render:IsInterested(index, previousComponent, component)
    if(component == nil) then
        return false;
    end

    if(not GameFSMComponent:IsInstanceOfType(component)) then
        return false;
    end

    if(component:CurStateID() == GameStateID.PreviewChessPet) then
        return true
    end
    return false
end


function PreviewChessPetStateSystem_Render:Filter(world)
    return true
end

function PreviewChessPetStateSystem_Render:ExecuteWorld(world)
    Log.notice("PreviewChessPetStateSystem_Render ExecuteWorld")
end

