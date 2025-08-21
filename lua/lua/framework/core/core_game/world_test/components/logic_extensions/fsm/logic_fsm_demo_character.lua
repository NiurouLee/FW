require "entity_ability"

---@class CharacterStateID
_enum("CharacterStateID", {
    Invalid = 0,
    Idle = 1,
    Move = 2,
    Skill = 3,
})

--[[------------------------------------------------------------------------------------------
    EntityStateNode : 
]]--------------------------------------------------------------------------------------------

---@class EntityStateNode: StateNode
_class( "EntityStateNode", StateNode )

function EntityStateNode:Constructor()
    Log.debug("EntityStateNode:Constructor()")
end

-- CustomNode: 
--//////////////////////////////////////////////////////////
---@param cfg table
---@param context CustomNodeContext
function EntityStateNode:InitializeNode(cfg, context)
    EntityStateNode.super.InitializeNode(self, cfg, context)
    self.m_owner = context.GenInfo.OwnerEntity
    self.m_world = context.GenInfo.World
end

function EntityStateNode:Enter()
    EntityStateNode.super.Enter(self)
end

function EntityStateNode:Exit()
    EntityStateNode.super.Exit(self)
end


--[[------------------------------------------------------------------------------------------
    CharacterIdleState : 
]]--------------------------------------------------------------------------------------------

---@class CharacterIdleState: EntityStateNode
_class( "CharacterIdleState", EntityStateNode )

function CharacterIdleState:Enter()
    CharacterIdleState.super.Enter(self)
    self.m_owner:EnableAbility(EntityAbilitysLookup.GroundMotion);
end

function CharacterIdleState:CheckTransitions()
    if self.m_owner:HasMovement() then
        return CharacterStateID.Move
    end
    return CharacterIdleState.super.CheckTransitions(self)
end

function CharacterIdleState:HandleCommand(cmd)
    return true
end


--[[------------------------------------------------------------------------------------------
    CharacterMoveState : 
]]--------------------------------------------------------------------------------------------

---@class CharacterMoveState: EntityStateNode
_class( "CharacterMoveState", EntityStateNode )

function CharacterMoveState:Enter()
    CharacterMoveState.super.Enter(self)
    self.m_owner:EnableAbility(EntityAbilitysLookup.GroundMotion);
end

function CharacterMoveState:CheckTransitions()
    if not self.m_owner:HasMovement() then
        return CharacterStateID.Idle
    end
    return CharacterIdleState.super.CheckTransitions(self)
end

function CharacterMoveState:HandleCommand(cmd)
    return true
end



--[[------------------------------------------------------------------------------------------
    CharacterSkillState : 
]]--------------------------------------------------------------------------------------------

---@class CharacterSkillState: EntityStateNode
_class( "CharacterSkillState", EntityStateNode )

function CharacterSkillState:Enter()
    CharacterSkillState.super.Enter(self)
    self.m_owner:DisableAbility(EntityAbilitysLookup.GroundMotion);
    self.testTime = 2   --test
end

function CharacterSkillState:CheckTransitions()
    if self.testTime <= 0 then
        return CharacterStateID.Idle
    end
    return CharacterIdleState.super.CheckTransitions(self)
end

function CharacterSkillState:Update(dt)
    self.testTime = self.testTime - dt
end