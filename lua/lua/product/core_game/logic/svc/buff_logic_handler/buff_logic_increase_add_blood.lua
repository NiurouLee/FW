--[[
    提升回血、吸血效果
]]
AddBloodRateValueType = {
    ConfigValue = 1, --配置的值
    BleedMonster = 2, --场上流血状态的怪物数量
    BuffLayer = 3 --根据层数
}

--设置
_class("BuffLogicSetIncreaseAddBlood", BuffLogicBase)
BuffLogicSetIncreaseAddBlood = BuffLogicSetIncreaseAddBlood

function BuffLogicSetIncreaseAddBlood:Constructor(buffInstance, logicParam)
    self._mulValue = logicParam.mulValue or 0
    self._valType = logicParam.valType or AddBloodRateValueType.ConfigValue
    self._specificModifyID = logicParam.specificModifyID--处理跨buff使用set和reset的情况 指定同一个modifyID
end

function BuffLogicSetIncreaseAddBlood:DoLogic()
    local e = self._buffInstance:Entity()
    if e:PetPstID() then
        e = e:Pet():GetOwnerTeamEntity()
    end

    local mulValue = 0
    if self._valType == AddBloodRateValueType.ConfigValue then
        mulValue = self._mulValue
    elseif self._valType == AddBloodRateValueType.BleedMonster then
        local group = self._world:GetGroup(self._world.BW_WEMatchers.MonsterID)
        for i, e in ipairs(group:GetEntities()) do
            if e:BuffComponent():HasBuffEffect(BuffEffectType.Bleed) then
                mulValue = mulValue + self._mulValue
            end
        end
    elseif self._valType == AddBloodRateValueType.BuffLayer then
        ---@type BuffLogicService
        local svc = self._world:GetService("BuffLogic")
        svc:AddBuffLayer(self._entity, self._buffInstance:GetBuffEffectType(), 1)
        local layer = svc:GetBuffLayer(self._entity, self._buffInstance:GetBuffEffectType())
        mulValue = self._mulValue * layer
    end
    local modifyID = self._buffInstance:BuffSeq()
    if self._specificModifyID then
        modifyID = tonumber(self._specificModifyID)
    end
    e:Attributes():Modify("AddBloodRate", mulValue, modifyID)
end

function BuffLogicSetIncreaseAddBlood:DoOverlap(logicParam)
    return self:DoLogic()
end

--取消
_class("BuffLogicResetIncreaseAddBlood", BuffLogicBase)
BuffLogicResetIncreaseAddBlood = BuffLogicResetIncreaseAddBlood

function BuffLogicResetIncreaseAddBlood:Constructor(buffInstance, logicParam)
    self._specificModifyID = logicParam.specificModifyID
end

function BuffLogicResetIncreaseAddBlood:DoLogic()
    local e = self._buffInstance:Entity()
    if e:PetPstID() then
        e = e:Pet():GetOwnerTeamEntity()
    end
    local modifyID = self._buffInstance:BuffSeq()
    if self._specificModifyID then
        modifyID = tonumber(self._specificModifyID)
    end
    e:Attributes():RemoveModify("AddBloodRate", modifyID)

    ---@type BuffLogicService
    local svc = self._world:GetService("BuffLogic")
    svc:ClearBuffLayer(self._entity, self._buffInstance:GetBuffEffectType())
end

function BuffLogicResetIncreaseAddBlood:DoOverlap() 
end