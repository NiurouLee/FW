--[[------------------------------------------------------------------------------------------
    MoveBoard = 140, --移动棋盘
]] --------------------------------------------------------------------------------------------
require("skill_effect_param_base")
_class("SkillEffectParamMoveBoard", SkillEffectParamBase)
---@class SkillEffectParamMoveBoard: SkillEffectParamBase
SkillEffectParamMoveBoard = SkillEffectParamMoveBoard

function SkillEffectParamMoveBoard:Constructor(t)
    self._times = t.times or 1 --传送次数

    if t.direction and t.direction[1] and t.direction[2] then
        self._direction = Vector2(t.direction[1], t.direction[2])
    else
        self._direction = Vector2(0, 1)
    end

    self._destroyOutTrap = t.destroyOutTrap or 0 --销毁传送出范围的机关
end

function SkillEffectParamMoveBoard:GetEffectType()
    return SkillEffectType.MoveBoard
end

function SkillEffectParamMoveBoard:GetTimes()
    return self._times
end

function SkillEffectParamMoveBoard:GetDirection()
    return self._direction
end

function SkillEffectParamMoveBoard:GetDestroyOutTrap()
    return self._destroyOutTrap
end
