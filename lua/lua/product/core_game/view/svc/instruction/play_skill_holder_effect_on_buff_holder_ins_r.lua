require("base_ins_r")

---@class PlaySkillHolderEffectOnBuffHolderInstruction : BaseInstruction
_class("PlaySkillHolderEffectOnBuffHolderInstruction", BaseInstruction)
PlaySkillHolderEffectOnBuffHolderInstruction = PlaySkillHolderEffectOnBuffHolderInstruction

function PlaySkillHolderEffectOnBuffHolderInstruction:Constructor(paramList)
    self._effectID = tonumber(paramList.effectID)

    if (not self._effectID) or (not Cfg.cfg_effect[self._effectID]) then
        Log.exception(self._className, "请使用该指令时填写正确的effectID: ", tostring(paramList.effectID))
    end
end

function PlaySkillHolderEffectOnBuffHolderInstruction:GetCacheResource()
    local t = {}
    if self._effectID and self._effectID > 0 then
        table.insert(t, {Cfg.cfg_effect[self._effectID].ResPath, 1})
    end
    return t
end

---@param TT TaskToken
---@param casterEntity Entity
---@param phaseContext SkillPhaseContext
function PlaySkillHolderEffectOnBuffHolderInstruction:DoInstruction(TT, casterEntity, phaseContext)
    if (not casterEntity:EntityType():IsSkillHolder()) then
        Log.error(self._className, "该指令只能用于创建了skillHolder的CastSkill技能内")
        return
    end

    ---@type MainWorld
    local world = casterEntity:GetOwnerWorld()

    ---@type EffectService
    local fxsvc = world:GetService("Effect")

    ---@type SuperEntityComponent
    local cSuperEntity = casterEntity:SuperEntityComponent()
    local eFxHolder = cSuperEntity:GetSuperEntity()

    fxsvc:CreateEffect(self._effectID, eFxHolder)
end