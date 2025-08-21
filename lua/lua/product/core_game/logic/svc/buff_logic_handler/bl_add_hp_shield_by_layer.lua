--添加护盾buff
require("buff_logic_shield_hp")
_class("BuffLogicAddHPShieldByLayer", BuffLogicBase)
---@class BuffLogicAddHPShieldByLayer:BuffLogicBase
BuffLogicAddHPShieldByLayer = BuffLogicAddHPShieldByLayer

function BuffLogicAddHPShieldByLayer:Constructor(buffInstance, logicParam)
    self._layerType = logicParam.layerType or self._buffInstance:GetBuffEffectType()
    self._shieldPercent = logicParam.shieldPercent
    self._shieldFromType = logicParam.shieldFromType or HPShieldFromType.OwnerHP
    self._shieldFromParam = logicParam.shieldFromParam
end

function BuffLogicAddHPShieldByLayer:DoLogic(notify)
    --默认血条盾加给队伍
    ---@type Entity
    local teamEntity = nil
    if self._entity:HasTeam() then
        teamEntity = self._entity
    elseif self._entity:HasPet() then
        teamEntity = self._entity:Pet():GetOwnerTeamEntity()
    end

    local value = 0
    if self._shieldFromType == HPShieldFromType.OwnerHP then
        value = self._entity:Attributes():GetCurrentHP()
    elseif self._shieldFromType == HPShieldFromType.CasterHP then
        local casterEntity = self._buffInstance:Context().casterEntity
        if casterEntity:HasPetPstID() then
            --Log.error("petData:GetPetHealth()   ", petData:GetPetHealth())
            local pstid = casterEntity:PetPstID():GetPstID()
            local petData = self._world.BW_WorldInfo:GetPetData(pstid)
            value = petData:GetPetHealth()
        elseif casterEntity:HasMonsterID() then
            --怪物也可以加血条盾
            teamEntity = casterEntity

            ---@type ConfigService
            local configService = self._world:GetService("Config")
            ---@type MonsterConfigData
            local monsterConfigData = configService:GetMonsterConfigData()
            local monsterid = casterEntity:MonsterID():GetMonsterID()
            local maxhp = monsterConfigData:GetMonsterHealth(monsterid)
            value = maxhp
        else
            value = 0
        end
    elseif self._shieldFromType == HPShieldFromType.LastDamage then
        value = notify:GetDamage()
    elseif self._shieldFromType == HPShieldFromType.SpecificPet then
        local pets = teamEntity:Team():GetTeamPetEntities()
        for i, e in ipairs(pets) do
            local cPetPstID = e:PetPstID()
            if self._shieldFromParam == cPetPstID:GetTemplateID() then
                value = e:Attributes():GetCurrentHP()
                break
            end
        end
    elseif self._shieldFromType == HPShieldFromType.SpilledHP then
        value = self._buffInstance:Context().hpSpilled
    elseif self._shieldFromType == HPShieldFromType.OwnerDefence then
        ---@type AttributesComponent
        local attributesComponent = self._entity:Attributes()
        local totalDefence =attributesComponent:GetDefence()
        value = totalDefence
    elseif self._shieldFromType == HPShieldFromType.OwnerBaseDefence then
        ---@type AttributesComponent
        local attributesComponent = self._entity:Attributes()
        local baseDefence = attributesComponent:GetAttribute("Defense")
        value = baseDefence
    end
    local curMarkLayer = self._buffLogicService:GetBuffLayer(self._entity, self._layerType)

    local addShield = math.floor(self._shieldPercent * value * curMarkLayer)
    local curHpSh = teamEntity:BuffComponent():AddBuffValue("HPShield", addShield)
    local damageInfo = DamageInfo:New(0, DamageType.Recover)
    damageInfo:SetHPShield(curHpSh)
    Log.debug("Buff AddShieldByLayer, entityID: ", self._entity:GetID() ," addShield: ",addShield," setShield: ",curHpSh)
    local buffResult = BuffResultAddHPShield:New(teamEntity:GetID(), damageInfo)
    return buffResult
end

function BuffLogicAddHPShieldByLayer:DoOverlap(logicParam)
    self._shieldPercent = logicParam.shieldPercent
    return self:DoLogic()
end

--去除护盾buff
_class("BuffLogicRemoveHPShieldByLayer", BuffLogicBase)
BuffLogicRemoveHPShieldByLayer = BuffLogicRemoveHPShieldByLayer
function BuffLogicRemoveHPShieldByLayer:Constructor(buffInstance, logicParam)
    self._isOwner = logicParam.isOwner
    self._ignoreCheckShieldToHPEffect = logicParam.ignoreCheckShieldToHPEffect
end
function BuffLogicRemoveHPShieldByLayer:DoLogic()
    ---@type Entity
    local entity = nil
    if self._isOwner then
        entity = self._buffInstance:Entity()
    end
    if self._entity:HasTeam() then
        entity = self._entity
    elseif self._entity:HasPet() then
        entity:Pet():GetOwnerTeamEntity()
    end

    if self._ignoreCheckShieldToHPEffect == 1 or not entity:BuffComponent():HasBuffEffect(BuffEffectType.ShieldToHP) then 
        entity:BuffComponent():SetBuffValue("HPShield", 0)
    end

    local damageInfo = DamageInfo:New(0, DamageType.Recover)
    damageInfo:SetHPShield(0)
    Log.debug("Buff RemoveShieldByLayer,entityID: ",entity:GetID())
    local buffResult = BuffResultRemoveHPShield:New(entity:GetID(), damageInfo)
    return buffResult
end
function BuffLogicRemoveHPShieldByLayer:DoOverlap(logicParam)
end
