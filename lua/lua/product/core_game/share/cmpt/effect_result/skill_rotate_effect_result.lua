---@class SkillRotateEffectResult: SkillEffectResultBase
_class("SkillRotateEffectResult", SkillEffectResultBase)
SkillRotateEffectResult = SkillRotateEffectResult

---@param dirOld Vector2
---@param dirNew Vector2
function SkillRotateEffectResult:Constructor(targetID, dirOld, dirNew)
    self._targetID = targetID
    self._dirOld = dirOld:Clone()
    self._dirNew = dirNew:Clone()
end

function SkillRotateEffectResult:GetEffectType()
    return SkillEffectType.Rotate
end

function SkillRotateEffectResult:GetTargetID()
    return self._targetID
end

function SkillRotateEffectResult:GetDirOld()
    return self._dirOld
end

function SkillRotateEffectResult:GetDirNew()
    return self._dirNew
end
