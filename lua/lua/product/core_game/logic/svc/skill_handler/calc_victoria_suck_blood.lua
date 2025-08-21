--[[
    136 维多利亚大招
]]
---@class SkillEffectCalc_VictoriaSuckBlood: Object
_class("SkillEffectCalc_VictoriaSuckBlood", Object)
SkillEffectCalc_VictoriaSuckBlood = SkillEffectCalc_VictoriaSuckBlood

function SkillEffectCalc_VictoriaSuckBlood:Constructor(world)
    ---@type MainWorld
    self._world = world
end

---@param skillEffectCalcParam SkillEffectCalcParam
function SkillEffectCalc_VictoriaSuckBlood:DoSkillEffectCalculator(skillEffectCalcParam)
    ---@type SkillEffectParam_VictoriaSuckBlood
    local skillParam = skillEffectCalcParam.skillEffectParam
    local targets = skillEffectCalcParam:GetTargetEntityIDs()
    local totalTargetCount = skillEffectCalcParam:GetTotalTargetCount()
    local formulaID = skillParam:GetDamageFormulaID()
    if totalTargetCount == 1 then
        formulaID = skillParam:GetDamageFormulaID2()
    end
    ---@type SkillEffectCalcService
   local skillEffectService = self._world:GetService("SkillEffectCalc")
    local results = {}
    local attackPos = skillEffectCalcParam.attackPos
    local gridPos = skillEffectCalcParam.gridPos
    local attacker = self._world:GetEntityByID(skillEffectCalcParam.casterEntityID)

    for _, targetID in ipairs(targets) do
        local target = self._world:GetEntityByID(targetID)
        if not target then
            goto CONTINUE
        end
        local damageParam = SkillDamageEffectParam:New({
              percent = skillParam:GetDamagePercent(),
              formulaID = formulaID,
              damageStageIndex = 1
          })

          local nTotalDamage, listDamageInfo = skillEffectService:ComputeSkillDamage(
              attacker,
              skillEffectCalcParam.attackPos,
              target,
              gridPos,
              skillEffectCalcParam.skillID,
              damageParam,
              SkillEffectType.VictoriaSuckBlood,
              1
          )

          local damageEffectResult =
              skillEffectService:NewSkillDamageEffectResult(
              gridPos,
              targetID,
              nTotalDamage,
              listDamageInfo,
              1
          )
          results[#results + 1] = damageEffectResult

        ::CONTINUE::
    end

    return results
end
