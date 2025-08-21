require("pick_up_policy_base")

_class("PickUpPolicy_Pet1601751", PickUpPolicy_Base)
---@class PickUpPolicy_Pet1601751: PickUpPolicy_Base
PickUpPolicy_Pet1601751 = PickUpPolicy_Pet1601751

---@param calcParam PickUpPolicy_CalcParam
function PickUpPolicy_Pet1601751:CalcAutoFightPickUpPolicy(calcParam)
    local petEntity = calcParam.petEntity
    local activeSkillID = calcParam.activeSkillID
    local policyParam = calcParam.policyParam
    local casterPos = petEntity:GridLocation().Position

    local validPosIdxList,validPosList = self:_CalcPickUpValidGridList(petEntity,activeSkillID)
    local pickPosList, atkPosList, targetIds, extraParam =
        self:_CalPickPosPolicyPet1601751(petEntity, activeSkillID,policyParam,casterPos,validPosList,validPosIdxList )
    return pickPosList, atkPosList, targetIds, extraParam
end
---@param petEntity Entity
function PickUpPolicy_Pet1601751:_CalPickPosPolicyPet1601751(petEntity, activeSkillID, policyParam, casterPos, validPosList, validPosIdxList)
    local eTeam = petEntity:Pet():GetOwnerTeamEntity()
    ---@type CalcDamageService
    local lsvcCalcDamage = self._world:GetService("CalcDamage")
    local teamHP, teamMaxHP = lsvcCalcDamage:GetTeamLogicHP(eTeam)
    local percent = teamHP / teamMaxHP
    if percent >= 0.5 then
        local autoActiveSkillCount = petEntity:PetRender():GetPet1601751HPAboveLimitAutoCastActiveCount()
        --50%+血量自动放过一次之后便不再释放
        if autoActiveSkillCount > 0 then
            return {}, {}, {}
        end

        local pickPos, atkPos, targetList = self:_CalPickupPosPolicyPet1601751SummonHealTrap(petEntity, activeSkillID, policyParam, casterPos, validPosList, validPosIdxList)
        petEntity:PetRender():TickPet1601751HPAboveLimitAutoCastActiveCount()
        return pickPos, atkPos, targetList
    else
        ---@type Entity[]
        local globalTrapGroupEntities = self._world:GetGroupEntities(self._world.BW_WEMatchers.Trap)
        local tSelectedTrap = {}
        for _, e in ipairs(globalTrapGroupEntities) do
            if (not e:HasDeadMark()) and (e:TrapID():GetTrapID() == policyParam.healTrapID) and (table.Vector2Include(validPosList, e:GetGridPosition())) then
                table.insert(tSelectedTrap, e)
            end
        end
        if #tSelectedTrap > 0 then
            local firstTrap = table.remove(tSelectedTrap, 1)
            local trapGridPos = firstTrap:GetGridPosition()
            return {trapGridPos}, {trapGridPos}, {}
        else
            local pickPos, atkPos, targetList = self:_CalPickupPosPolicyPet1601751SummonHealTrap(petEntity, activeSkillID, policyParam, casterPos, validPosList, validPosIdxList)
            return pickPos, atkPos, targetList
        end
    end
end

function PickUpPolicy_Pet1601751:_CalPickupPosPolicyPet1601751SummonHealTrap(petEntity, activeSkillID, policyParam, casterPos, validPosList, validPosIdxList)
    ---@type UtilDataServiceShare
    local utilData = self._world:GetService("UtilData")
    local pool = {}
    for _, v2 in ipairs(validPosList) do
        local tTrapEntities = utilData:GetAllTrapEntitiesAtPosByTrapID(v2, policyParam.healTrapID)
        if #tTrapEntities == 0 then
            table.insert(pool, v2)
        end
    end

    if #pool == 0 then
        return {}, {}, {}
    end

    local luckyPosIndex = math.random(1, #pool)
    local luckyPos = table.remove(pool, luckyPosIndex)
    return {luckyPos}, {luckyPos}, {}
end