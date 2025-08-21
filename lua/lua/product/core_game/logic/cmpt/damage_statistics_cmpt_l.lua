--[[
    单位受到伤害时的统计组件

    初版用于精英化怪物的一个buff效果：记录自身受到的伤害，达成条件时选择伤害最高的单位执行逻辑
]]
_class("DamageStatisticsComponent", Object)
DamageStatisticsComponent = DamageStatisticsComponent

function DamageStatisticsComponent:Constructor()
    self._damageDict = {}
end

---@param attacker Entity
function DamageStatisticsComponent:Append(attacker, val)
    local e = attacker
    local eid = attacker:GetID()
    if attacker:HasSuperEntity() then
        e = attacker:SuperEntityComponent():GetSuperEntity()
        eid = e:GetID()
    end

    if not self._damageDict[eid] then
        self._damageDict[eid] = 0
    end

    self._damageDict[eid] = self._damageDict[eid] + val
end

_class("DamageStatisticsSourceElement", Object)
DamageStatisticsSourceElement = DamageStatisticsSourceElement

function DamageStatisticsSourceElement:Constructor(eid, val)
    self.entityID = eid
    self.value = val
end

---@return DamageStatisticsSourceElement[]
function DamageStatisticsComponent:GetDamageSourceArray()
    local t = {}

    for eid, value in pairs(self._damageDict) do
        table.insert(t, DamageStatisticsSourceElement:New(eid, value))
    end

    table.sort(t, function (a, b)
        if a.value == b.value then
            return a.entityID < b.entityID
        end

        return a.value < b.value
    end)

    return t
end
function DamageStatisticsComponent:GetTotalDamage()
    local totalDamage = 0
    for eid, value in pairs(self._damageDict) do
        totalDamage = totalDamage + value
    end
    return totalDamage
end

------------------------------------------------------------------------------------------
---ENTITY EXTENSIONS
------------------------------------------------------------------------------------------
---@return DamageStatisticsComponent
function Entity:DamageStatisticsComponent()
    return self:GetComponent(self.WEComponentsEnum.DamageStatistics)
end

function Entity:HasDamageStatisticsComponent()
    return self:HasComponent(self.WEComponentsEnum.DamageStatistics)
end

function Entity:AddDamageStatisticsComponent()
    local index = self.WEComponentsEnum.DamageStatistics
    local component = DamageStatisticsComponent:New()
    self:AddComponent(index, component)
end

function Entity:ReplaceDamageStatisticsComponent()
    local index = self.WEComponentsEnum.DamageStatistics
    local component = DamageStatisticsComponent:New()
    self:ReplaceComponent(index, component)
end

function Entity:RemoveDamageStatisticsComponent()
    if self:HasDamageStatisticsComponent() then
        self:RemoveComponent(self.WEComponentsEnum.DamageStatistics)
    end
end
