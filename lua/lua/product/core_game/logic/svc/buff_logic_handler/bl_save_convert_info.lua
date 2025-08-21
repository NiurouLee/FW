--[[
    设置buff value
]]
--------------------------------
_class("BuffLogicSaveConvertValue", BuffLogicBase)
---@class BuffLogicSaveConvertValue:BuffLogicBase
BuffLogicSaveConvertValue = BuffLogicSaveConvertValue

function BuffLogicSaveConvertValue:Constructor(buffInstance, logicParam)
    self._resetEffectType = logicParam.resetEffectType or {}
    self._convertEffectType = logicParam.convertEffectType or {}
end
---@param notify NTGridConvert
function BuffLogicSaveConvertValue:DoLogic(notify)
    ---@type BuffComponent
    local buffComponent = self._entity:BuffComponent()
    if not buffComponent then
        return
    end

    if notify:GetNotifyType() ~= NotifyType.GridConvert then
        return
    end
    ---@type Entity
    local entity =notify:GetNotifyEntity()
    if not entity then
        return
    end
    ---@type NTGridConvert_ConvertInfo[]
    local convertInfoArray = notify:GetConvertInfoArray()
    if not buffComponent:GetBuffValue("SaveConvertInfo") then
        buffComponent:SetBuffValue("SaveConvertInfo",{})
    end
    if not buffComponent:GetBuffValue("SaveResetConvertInfo") then
        buffComponent:SetBuffValue("SaveResetConvertInfo",{})
    end
    if table.icontains(self._resetEffectType,notify:GetConvertEffectType()) then
        local saveResetConvertInfo =buffComponent:GetBuffValue("SaveResetConvertInfo")
        table.appendArray(saveResetConvertInfo,convertInfoArray)
        return
    end
    if table.icontains(self._convertEffectType,notify:GetConvertEffectType()) then
        ---@type NTGridConvert_ConvertInfo[]
        local saveConvertInfo =buffComponent:GetBuffValue("SaveConvertInfo")
        table.appendArray(saveConvertInfo,convertInfoArray)
    end
end
