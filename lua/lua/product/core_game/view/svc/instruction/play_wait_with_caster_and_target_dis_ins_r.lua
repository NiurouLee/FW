require("base_ins_r")
---@class PlayWaitWithCasterAndTargetDisInstruction: BaseInstruction
_class("PlayWaitWithCasterAndTargetDisInstruction", BaseInstruction)
PlayWaitWithCasterAndTargetDisInstruction = PlayWaitWithCasterAndTargetDisInstruction

function PlayWaitWithCasterAndTargetDisInstruction:Constructor(paramList)
    self._baseTime = tonumber(paramList["baseTime"]) or 0
    self._oneGridTime = tonumber(paramList["oneGridTime"]) or 0
end

---@param casterEntity Entity
---@param phaseContext SkillPhaseContext
function PlayWaitWithCasterAndTargetDisInstruction:DoInstruction(TT, casterEntity, phaseContext)
    ---@type MainWorld
    local world = casterEntity:GetOwnerWorld()

    local targetEntityID = phaseContext:GetCurTargetEntityID()
    if targetEntityID == nil or targetEntityID < 0 then
        return
    end
    local targetEntity = world:GetEntityByID(targetEntityID)
    local posCaster = casterEntity:GetRenderGridPosition()
    local posTarget = targetEntity:GetRenderGridPosition()

    local dis = Vector2.Distance(posCaster, posTarget)

    local waitTime = self._baseTime + (dis * self._oneGridTime)

    YIELD(TT, waitTime)
end
