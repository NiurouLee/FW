require("base_ins_r")

---@class PlayCasterAnimationByBuffLayerInstruction: BaseInstruction
_class("PlayCasterAnimationByBuffLayerInstruction", BaseInstruction)
PlayCasterAnimationByBuffLayerInstruction = PlayCasterAnimationByBuffLayerInstruction

function PlayCasterAnimationByBuffLayerInstruction:Constructor(paramList)
    local strNameList = string.split(paramList["animNameList"], "|")
    local strLayerList = string.split(paramList["layerCountList"], "|")
    self._animNameList = {}
    for _, value in ipairs(strNameList) do
        table.insert(self._animNameList, value)
    end
    self._buffLayerCountList = {}
    for _, value in ipairs(strLayerList) do
        table.insert(self._buffLayerCountList, tonumber(value))
    end
    if #self._animNameList ~= #self._buffLayerCountList then
        Log.fatal("PlayCasterAnimationByBuffLayer: count error.")
    end
end

---@param casterEntity Entity
function PlayCasterAnimationByBuffLayerInstruction:DoInstruction(TT, casterEntity, phaseContext)
    ---@type SkillEffectResultContainer
    local routineComponent = casterEntity:SkillRoutine():GetResultContainer()
    ---@type SkillDamageEffectResult
    local damageResult = routineComponent:GetEffectResultByArray(SkillEffectType.Damage)

    if not damageResult then
        return
    end

    local layerCount = damageResult:GetBuffLayerCountForDamage()
    local animName = self._animNameList[1]
    for index, value in ipairs(self._buffLayerCountList) do
        if layerCount >= value then
            animName = self._animNameList[index]
        end
    end

    casterEntity:SetAnimatorControllerTriggers({ animName })
end
