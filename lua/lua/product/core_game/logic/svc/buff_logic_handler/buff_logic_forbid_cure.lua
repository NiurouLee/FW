--[[
    禁止治疗，只对队长有效
]]
_class("BuffLogicForbidCure", BuffLogicBase)
BuffLogicForbidCure = BuffLogicForbidCure

function BuffLogicForbidCure:Constructor(buffInstance, logicParam)
end

function BuffLogicForbidCure:DoLogic(notify)
    if not self._entity:HasTeam() then
        Log.fatal("确定要给非队长加禁疗Buff?")
    end
    ---@type AttributesComponent
    local cpt = self._entity:Attributes()
    cpt:SetSimpleAttribute("BuffForbidCure", 1)
end

--------------------------------------------------------------------------------

--[[
    移除禁疗Buff
]]
_class("BuffLogicRemoveForbidCure", BuffLogicBase)
BuffLogicRemoveForbidCure = BuffLogicRemoveForbidCure

function BuffLogicRemoveForbidCure:Constructor(buffInstance, logicParam)
end

function BuffLogicRemoveForbidCure:DoLogic(notify)
    ---@type AttributesComponent
    local cpt = self._entity:Attributes()
    if cpt:GetAttribute("BuffForbidCure") then
        cpt:RemoveSimpleAttribute("BuffForbidCure")
    else
        Log.fatal("No forbid cure buff on target")
    end
end
