--[[
    ----------------------------------------------------------------
    SkillEffectResult_MonsterMoveGridFarthest
    ----------------------------------------------------------------
]]
require("skill_effect_result_base")

_class("SkillEffectResult_MonsterMoveGridFarthest", SkillEffectResultBase)
---@class SkillEffectResult_MonsterMoveGridFarthest: SkillEffectResultBase
SkillEffectResult_MonsterMoveGridFarthest = SkillEffectResult_MonsterMoveGridFarthest

function SkillEffectResult_MonsterMoveGridFarthest:GetEffectType()
    return SkillEffectType.MonsterMoveGridFarthest
end
---@param walkResultList MonsterMoveGridResult[]
function SkillEffectResult_MonsterMoveGridFarthest:Constructor(walkResultList,isDead)
    self._walkResultList = walkResultList
    self._isDead = isDead
end
---@return MonsterWalkResult[]
function SkillEffectResult_MonsterMoveGridFarthest:GetWalkResultList()
    return self._walkResultList
end

function SkillEffectResult_MonsterMoveGridFarthest:IsCasterDead()
    return self._isDead
end
