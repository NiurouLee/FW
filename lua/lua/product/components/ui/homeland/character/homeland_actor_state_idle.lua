--[[
    HomelandActorStateIdle : 家园角色状态机Idle状态
]]
require "homeland_actor_state"

---@class HomelandActorStateIdle: HomelandActorState
_class( "HomelandActorStateIdle", HomelandActorState )
HomelandActorStateIdle = HomelandActorStateIdle

function HomelandActorStateIdle:Constructor()

end

function HomelandActorStateIdle:GetType()
    return HomelandActorStateType.Idle
end

function HomelandActorStateIdle:Enter()
end

function HomelandActorStateIdle:Exit()
end