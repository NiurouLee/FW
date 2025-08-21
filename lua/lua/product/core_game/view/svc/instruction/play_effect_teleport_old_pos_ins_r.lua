require("base_ins_r")
---在瞬移结果的旧坐标播放特效
---@class PlayEffectTeleportOldPosInstruction: BaseInstruction
_class("PlayEffectTeleportOldPosInstruction", BaseInstruction)
PlayEffectTeleportOldPosInstruction = PlayEffectTeleportOldPosInstruction

function PlayEffectTeleportOldPosInstruction:Constructor(paramList)
    self._effectID = tonumber(paramList["effectID"])
    self._stageIndex = tonumber(paramList["stageIndex"]) or 1
    self._useCasterDir = tonumber(paramList["useCasterDir"])
    self._useTeleportDir = tonumber(paramList["useTeleportDir"])
end

---@param casterEntity Entity
---@param phaseContext SkillPhaseContext
function PlayEffectTeleportOldPosInstruction:DoInstruction(TT, casterEntity, phaseContext)
    ---@type SkillEffectResultContainer
    local skillEffectResultContainer = casterEntity:SkillRoutine():GetResultContainer()
    ---@type SkillEffectResult_Teleport
    local teleportEffectResult =
        skillEffectResultContainer:GetEffectResultByArray(SkillEffectType.Teleport, self._stageIndex)
    if not teleportEffectResult then
        return
    end

    local oldPos = teleportEffectResult:GetPosOld()
    local newPos = teleportEffectResult:GetPosNew()

    local world = casterEntity:GetOwnerWorld()
    ---@type EffectService
    local sEffect = world:GetService("Effect")
    local effectEntity = sEffect:CreateWorldPositionEffect(self._effectID, oldPos)
    if self._useCasterDir == 1 then
        --设置特效方向
        local dir = casterEntity:Location():GetDirection()
        effectEntity:SetDirection(dir)
    end
    if self._useTeleportDir == 1 then
        --设置特效方向
        local dir = newPos - oldPos
        effectEntity:SetDirection(dir)
    end
end

function PlayEffectTeleportOldPosInstruction:GetCacheResource()
    local t = {}
    if self._effectID and self._effectID > 0 then
        table.insert(t, {Cfg.cfg_effect[self._effectID].ResPath, 1})
    end
    return t
end
