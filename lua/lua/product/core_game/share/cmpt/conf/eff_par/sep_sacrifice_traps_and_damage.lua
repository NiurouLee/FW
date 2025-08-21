require("skill_damage_effect_param")
---@class SkillEffectSacrificeTrapsAndDamageParam: SkillEffectParamBase
_class("SkillEffectSacrificeTrapsAndDamageParam", SkillEffectParamBase)
SkillEffectSacrificeTrapsAndDamageParam = SkillEffectSacrificeTrapsAndDamageParam

function SkillEffectSacrificeTrapsAndDamageParam:Constructor(t)
    self._trapID = {}
    if type(t.trapID) == "number" then
        self._trapID[t.trapID] = true
    elseif type(t.trapID) == "table" then
        for _, id in ipairs(t.trapID) do
            self._trapID[id] = true
        end
    end

    self._basePercent = t.basePercent
    self._addValue = t.addValue
    self._damageScopeType = t.damageScopeType
    self._damageScopeParam = t.damageScopeParam
    self._damageScopeCenterType = t.damageScopeCenterType
    self._damageTargetType = t.damageTargetType
    self._formulaID = t.formulaID
end

function SkillEffectSacrificeTrapsAndDamageParam:GetBasePercent()
    return self._basePercent
end
function SkillEffectSacrificeTrapsAndDamageParam:GetTrapID()
    return self._trapID
end
function SkillEffectSacrificeTrapsAndDamageParam:GetAddValue()
    return self._addValue
end
function SkillEffectSacrificeTrapsAndDamageParam:GetDamageScopeType()
    return self._damageScopeType
end
function SkillEffectSacrificeTrapsAndDamageParam:GetDamageScopeParam()
    return self._damageScopeParam
end
function SkillEffectSacrificeTrapsAndDamageParam:GetDamageScopeCenterType()
    return self._damageScopeCenterType
end
function SkillEffectSacrificeTrapsAndDamageParam:GetDamageTargetType()
    return self._damageTargetType
end

function SkillEffectSacrificeTrapsAndDamageParam:GetEffectType()
    return SkillEffectType.SacrificeTrapsAndDamage
end

function SkillEffectSacrificeTrapsAndDamageParam:GetSacrificeFormulaID()
    return self._formulaID
end

-- ---@class SacrificeTrapsAndDamageDevice : Object
-- _class("SacrificeTrapsAndDamageDevice", Object)
-- SacrificeTrapsAndDamageDevice = SacrificeTrapsAndDamageDevice

-- function SacrificeTrapsAndDamageDevice:Constructor()
--     self:Reset()
-- end

-- function SacrificeTrapsAndDamageDevice:SetBasicDamagePercent(val)
--     self._basicDamagePercent = val
-- end

-- function SacrificeTrapsAndDamageDevice:SetAdvanceDamagePercent(val)
--     self._advanceDamagePercent = val
-- end

-- function SacrificeTrapsAndDamageDevice:GetBasicDamagePercent()
--     return self._basicDamagePercent
-- end

-- function SacrificeTrapsAndDamageDevice:GetAdvanceDamagePercent()
--     return self._advanceDamagePercent
-- end

-- function SacrificeTrapsAndDamageDevice:Reset()
--     self._basicDamagePercent = 0
--     self._advanceDamagePercent = 0
-- end
