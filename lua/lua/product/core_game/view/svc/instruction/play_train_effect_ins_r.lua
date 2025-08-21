require("base_ins_r")
---@class PlayTrainEffectInstruction: BaseInstruction
_class("PlayTrainEffectInstruction", BaseInstruction)
PlayTrainEffectInstruction = PlayTrainEffectInstruction

function PlayTrainEffectInstruction:Constructor(paramList)
    self._trainEffectID = tonumber(paramList["effectID"])
end

---@param casterEntity Entity
---@param phaseContext SkillPhaseContext
function PlayTrainEffectInstruction:DoInstruction(TT, casterEntity, phaseContext)
    ---@type MainWorld
    self._world = casterEntity:GetOwnerWorld()
    ---@type RenderPickUpComponent
    local renderPickUpComponent = casterEntity:RenderPickUpComponent()
    local directionType = renderPickUpComponent:GetLastPickUpDirection()
    ---@type  Vector2
    local castPos = casterEntity:GridLocation().Position
    local trainCenterPos = self:_GetTrainEffectCenterPos(directionType, castPos, Vector2(5,5))
    ---@type EffectService
    local sEffect = self._world:GetService("Effect")
    local trainEffectEntity =
    sEffect:CreateWorldPositionDirectionEffect(self._trainEffectID, trainCenterPos, self:_GetDirection(directionType))
end

function PlayTrainEffectInstruction:_GetTrainEffectCenterPos(directionType, casterPos, boardCenterPos)
    local trainCenterPos = Vector2.zero
    --local boradCenterPos=Vector2(4,4)
    if directionType == HitBackDirectionType.Up or directionType == HitBackDirectionType.Down then
        --boardCenterPos.x = casterPos.x
        trainCenterPos = Vector2(casterPos.x, boardCenterPos.y)
    elseif directionType == HitBackDirectionType.Left or directionType == HitBackDirectionType.Right then
        trainCenterPos = Vector2(boardCenterPos.x, casterPos.y)
        --boardCenterPos.y = casterPos.y
    end
    return trainCenterPos
end
---@return Vector2
function PlayTrainEffectInstruction:_GetDirection(directionType)
    if directionType == HitBackDirectionType.Up then
        return Vector2(0, -1)
    elseif directionType == HitBackDirectionType.Down then
        return Vector2(0, 1)
    elseif directionType == HitBackDirectionType.Left then
        return Vector2(1, 0)
    elseif directionType == HitBackDirectionType.Right then
        return Vector2(-1, 0)
    else
        return Vector2(0, 0)
    end
end
function PlayTrainEffectInstruction:GetCacheResource()
    local t = {}
    if self._trainEffectID and self._trainEffectID > 0 then
        table.insert(t, {Cfg.cfg_effect[self._trainEffectID].ResPath, 1})
    end
    return t
end
