require("pick_up_policy_base")

_class("PickUpPolicy_PetReinhardt", PickUpPolicy_Base)
---@class PickUpPolicy_PetReinhardt: PickUpPolicy_Base
PickUpPolicy_PetReinhardt = PickUpPolicy_PetReinhardt

---@param calcParam PickUpPolicy_CalcParam
function PickUpPolicy_PetReinhardt:CalcAutoFightPickUpPolicy(calcParam)
    local petEntity = calcParam.petEntity
    local activeSkillID = calcParam.activeSkillID
    local policyParam = calcParam.policyParam
    local casterPos = petEntity:GridLocation().Position
    local pickUpNum = self:_GetPickUpNumByConfig(activeSkillID)

    local validPosIdxList,validPosList = self:_CalcPickUpValidGridList(petEntity,activeSkillID)
    local pickPosList, atkPosList, targetIds, extraParam =
        self:_CalPickPosPolicy_PetReinhardt(petEntity, validPosList,pickUpNum)
    return pickPosList, atkPosList, targetIds, extraParam
end
--莱因哈特：场上摆放数量标记，每个标记能攻击配置范围，选择能攻击到格子数量最多的位置
---@param petEntity Entity
---@param activeSkillID number
---@param casterPos Vector2
function PickUpPolicy_PetReinhardt:_CalPickPosPolicy_PetReinhardt(petEntity, validPosList,pickUpNum)
    local targetEntity = {}
    local targetPosList = {}

    if self._world:MatchType() == MatchType.MT_BlackFist then
        targetEntity = petEntity:Pet():GetOwnerTeamEntity():Team():GetEnemyTeamEntity()
        local pos = targetEntity:GetGridPosition()
        local posIndex= Vector2.Pos2Index(pos)
        targetPosList[posIndex] = targetEntity:GetID()
    else
        ---@type Entity[]
        local groupEntities = self._world:GetGroupEntities(self._world.BW_WEMatchers.MonsterID)
        for i, v in ipairs(groupEntities) do
            ---@type BodyAreaComponent
            local areaCmpt = v:BodyArea()
            local pos = v:GetGridPosition()
            local areaList = areaCmpt:GetArea()
            for i, area in ipairs(areaList) do
                local newPos = area+pos
                local posIndex= Vector2.Pos2Index(newPos)
                targetPosList[posIndex] = v:GetID()
            end
        end
    end
    local pickPos = {}
    while pickUpNum >0 do
        local attackPosCount =0
        local pickUpPos = nil
        for i, pos in ipairs(validPosList) do
            ---@type Vector2[]
            local range = self:_GetReinhardtRange(pos)
            local tmpAPC =0
            for i, v in ipairs(range) do
                local index = Vector2.Pos2Index(v)
                if targetPosList[index] then
                    tmpAPC = tmpAPC + 1
                end
            end
            if tmpAPC> attackPosCount and not table.Vector2Include(pickPos,pos) then
                attackPosCount = tmpAPC
                pickUpPos = pos
            end
        end
        if  not pickUpPos then
            while not pickUpPos do
                local count = #validPosList
                local index = math.random(1,count)
                local pos = validPosList[index]
                if not table.Vector2Include(pickPos,pos) then
                    pickUpPos= pos
                    break
                end
            end
            --for i, pos in pairs(validPosList) do
            --    if not table.Vector2Include(pickPos,pos) then
            --        pickUpPos = pos
            --    end
            --end
        end
        pickUpNum = pickUpNum -1
        table.insert(pickPos,pickUpPos)
    end
    return pickPos,pickPos,{}
end
---@return Vector2
function PickUpPolicy_PetReinhardt:_GetReinhardtRange(pos)
    local retPos={}
    table.insert(retPos, pos+Vector2(0,0))
    table.insert(retPos, pos+Vector2(0,1))
    table.insert(retPos, pos+Vector2(0,-1))
    table.insert(retPos, pos+Vector2(1,0))
    table.insert(retPos, pos+Vector2(-1,0))
    return retPos
end