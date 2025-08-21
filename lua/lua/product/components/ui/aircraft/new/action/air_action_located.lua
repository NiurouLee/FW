--[[
    风船行为 直接定位到一个坐标
]]
---@class AirActionLocated:AirActionBase
_class("AirActionLocated", AirActionBase)
AirActionLocated = AirActionLocated

---@param pet AircraftPet
function AirActionLocated:Constructor(pet, target, floor)
    if target == nil then
        Log.fatal("[AircraftMove] 移动目标点为空")
    end
    self._pet = pet
    if not self._pet:IsAlive() then
        self:Log("星灵已被销毁：", self._pet:TemplateID())
    end
    self._target = target
    ---@type UnityEngine.AI.NavMeshAgent
    self._navMeshAgent = self._pet:NaviMesh()
    self._navMeshAgent.speed = 0.9
    self._navMeshAgent.areaMask = 1 << (floor + 2) --unity预留3个且从0开始
    -- self._navMeshAgent.enabled = true
    self._pet:SetNaviEnable(true)
    -- self._navMeshAgent.isStopped = true
end

function AirActionLocated:Start()
    self._pet:Anim_Stand()
    self._pet:SetPosition(self._target)
    self._running = false
end
function AirActionLocated:Update(deltaTimeMS)
    if not self._running then
        return
    end
end

function AirActionLocated:IsOver()
    return not self._running
end

function AirActionLocated:Stop()
    self._running = false
    -- self._pet:Anim_Stand()
    -- self._navMeshAgent.isStopped = true
    -- self._navMeshAgent.enabled = false
end

function AirActionLocated:GetPets()
    return {self._pet}
end
