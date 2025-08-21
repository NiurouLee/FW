--[[-------------------------------------
    ActionTarget_SelectBomb 重新选择目标
    2020-07-03 韩玉信：击退小怪要动态切换攻击目标（玩家和炸弹之间选择一个）
    找到绑定炸弹则返回成功，否则返回失败
    每回合都要重新洗牌
    如下策略是以“炸弹”为第一人称描述
怪物回合开始时，当有空闲[炸弹]时，判断未占领[炸弹]的小怪到[炸弹]和玩家距离，以此挑选出怪物绑定[炸弹]。
优先判断小怪到[炸弹]的距离，距离近的绑定[炸弹]
若到[炸弹]的距离相等，则判断与玩家的距离，距离玩家远的绑定[炸弹]。
若距离都相等，则随机挑选一个怪物
--]] -------------------------------------
require "ai_node_new"
---@class ActionTarget_SelectBomb:AINewNode
_class("ActionTarget_SelectBomb", AINewNode)
ActionTarget_SelectBomb = ActionTarget_SelectBomb

--------------------------------
function ActionTarget_SelectBomb:Constructor()
end
function ActionTarget_SelectBomb:Reset()
    ActionTarget_SelectBomb.super.Reset(self)
end
--------------------------------
function ActionTarget_SelectBomb:OnBegin()
    ---@type AIComponentNew
    local aiCmpt = self.m_entityOwn:AI()
    ---@type Entity
    local entityPlayer = aiCmpt:GetTargetDefault()
    local posPlayer = entityPlayer:GetGridPosition()

    ---@type Entity
    local entityBombOld = aiCmpt:GetTargetEntity()
    ---旧炸弹解绑
    if entityBombOld then
        self:_UnBindBomb(entityBombOld)
    end

    local nGameRound = self:GetGameRountNow()
    local nSaveRound = self:GetRuntimeData("BombRound")
    ---保证逻辑只在回合开始时执行一次
    if nil == nSaveRound or nSaveRound ~= nGameRound then
        ---2020-07-06 每回合都重新洗牌
        self:_AllocBomb(nGameRound, posPlayer)
    end
    local nMobilityValid = aiCmpt:GetMobilityValid()
    ---2020-07-30 增加动态变更绑定炸弹的行为
    if nSaveRound == nGameRound then
        local listBindMonsterID = {}
        ---先判断一格行动范围内有没有有效炸弹
        local pFindNewBomb = self:_FindValidBomb(posPlayer, 1)
        if nil == pFindNewBomb then
            ---再判断所有行动范围内有没有有效的空余炸弹
            local sortFreeBomb = self:_FindBombAllFree(listBindMonsterID, nGameRound, posPlayer)
            if sortFreeBomb:Size() > 0 then
                local posSelf = self.m_entityOwn:GetGridPosition()
                for i = 1, sortFreeBomb:Size() do
                    ---@type AiSortByDistance
                    local sortData = sortFreeBomb:GetAt(i)
                    local posBomb = sortData:GetPosData()
                    local listBombAround = self:ComputeWalkRange(posBomb, 1, true)
                    for j = 1, #listBombAround do
                        ---@type ComputeWalkPos
                        local walkData = listBombAround[j]
                        local posPlan = walkData:GetPos()
                        if GameHelper.ComputeLogicStep(posSelf, posPlan) <= nMobilityValid then
                            if self:_IsOneLine(posPlan, posBomb, posPlayer) then
                                pFindNewBomb = self._world:GetEntityByID(sortData.m_nIndex)
                                break
                            end
                        end
                    end
                end
            end
        end
        if pFindNewBomb then
            local pOldBomb = nil
            local entityBombOld = aiCmpt:GetTargetEntity()
            if entityBombOld ~= entityPlayer then
                pOldBomb = entityBombOld
            end
            if pOldBomb and pOldBomb:GetID() == pFindNewBomb:GetID() then
            else
                ---旧炸弹解绑
                self:_UnBindBomb(pOldBomb)
                self:_UnBindBomb(pFindNewBomb)
                ---绑定新炸弹
                self:_BindBombAndMonster(nGameRound, pFindNewBomb, self.m_entityOwn)
            end
        end
    end
end
---@return AINewNodeStatus 每次Update返回状态
function ActionTarget_SelectBomb:OnUpdate()
    ---@type AIComponentNew
    local aiCmpt = self.m_entityOwn:AI()
    ---@type Entity
    local entityPlayer = aiCmpt:GetTargetDefault()
    local posPlayer = entityPlayer:GetGridPosition()
    local nGameRound = self:GetGameRountNow()

    local nSelectBomb = false
    ---一定要在分配过Bomb后调用如下代码
    ---@type Entity
    local entityTarget = aiCmpt:GetTargetEntity()
    if entityTarget == entityPlayer then
        nSelectBomb = false
        self:PrintLog("行动目标<无需修改>, nGameRound = ", nGameRound)
    else ---本身绑定了炸弹
        nSelectBomb = true
        local posSelf = self.m_entityOwn:GetGridPosition()
        local posBomb = entityTarget:GetGridPosition()
        local nDistanceFormBomb = GameHelper.ComputeLogicDistance(posSelf, posBomb)
        local nDistanceFormPlay = GameHelper.ComputeLogicDistance(posSelf, posPlayer)
        if nDistanceFormPlay < nDistanceFormBomb then
            aiCmpt:SetRuntimeData("Target", nil)
            nSelectBomb = false
            self:PrintLog("行动目标<修改失败>, nGameRound = ", nGameRound, ", BombID = ", entityTarget:GetID())
        else
            self:PrintLog("行动目标<修改成功>, nGameRound = ", nGameRound, ", BombID = ", entityTarget:GetID())
        end
    end
    if nSelectBomb then
        return AINewNodeStatus.Success
    end
    return AINewNodeStatus.Failure
end
function ActionTarget_SelectBomb:OnEnd()
end
--------------------------------
---查找空闲的炸弹
function ActionTarget_SelectBomb:_FindBombAllFree(listBindMonsterID, nRoundData, posPlayer)
    ---@type TrapServiceLogic
    local utilSvc = self._world:GetService("TrapLogic")
    local listBomb = utilSvc:FindTrapByType(TrapType.BombByHitBack)
    ---第一次遍历： 找到空闲炸弹
    ---@type SortedArray
    local sortFreeBomb = SortedArray:New(Algorithm.COMPARE_CUSTOM, AiSortByDistance._ComparerByNear)
    for i = 1, #listBomb do
        ---@type Entity
        local entityBomb = listBomb[i]
        ---@type TrapComponent
        local trapCmpt = listBomb[i]:Trap()
        local bFindFree = true
        if trapCmpt:IsTrapHaveOwner(nRoundData) then
            local nOwnerEntity = self._world:GetEntityByID(trapCmpt:GetOwnerID())
            if nOwnerEntity and not AINewNode.IsEntityDead(nOwnerEntity) then
                bFindFree = false
            end
        end
        if not bFindFree then
            table.insert(listBindMonsterID, trapCmpt:GetOwnerID())
        else
            local posBomb = entityBomb:GetGridPosition()
            sortFreeBomb:Insert(AiSortByDistance:New(posPlayer, posBomb, entityBomb:GetID()))
        end
    end
    return sortFreeBomb
end
---解绑炸弹
---@param entityBomb Entity
function ActionTarget_SelectBomb:_UnBindBomb(entityBomb)
    if nil == entityBomb then
        return
    end
    ---@type TrapComponent
    local cmptTrap = entityBomb:Trap()
    if nil == cmptTrap then
        return
    end
    ---先解绑怪物
    local nMonsterID = cmptTrap:GetOwnerID()
    if nMonsterID and nMonsterID > 0 then
        ---@type Entity
        local entityMonster = self._world:GetEntityByID(nMonsterID)
        if entityMonster then
            ---@type AIComponentNew
            local aiCmpt = entityMonster:AI()
            if aiCmpt then
                aiCmpt:SetRuntimeData("Target", nil)
            end
        end
    end
    ---再解绑炸
    cmptTrap:SetOwner(nil, -1)
end
---绑定炸弹和怪物
---@param entityBomb Entity
function ActionTarget_SelectBomb:_BindBombAndMonster(nRoundData, entityBomb, entityMonster)
    ---先给炸弹设置主人
    ---@type TrapComponent
    local trapCmpt = entityBomb:Trap()
    trapCmpt:SetOwner(entityMonster:GetID(), nRoundData)
    ---再设置自己的工作目标
    ---@type AIComponentNew
    local aiCmpt = entityMonster:AI()
    if aiCmpt then
        local nBombEntityID = entityBomb:GetID()
        aiCmpt:SetRuntimeData("Target", nBombEntityID)
        aiCmpt:SetRuntimeData("BombRound", nRoundData)
    end
    return entityMonster:GetID()
end
--------------------------------
---查找空闲的炸弹：并且分配到对应的Monster（会处理所有的Bomb）
function ActionTarget_SelectBomb:_AllocBomb(nRoundData, posPlayer)
    local listBindMonsterID = {}
    ---第一次遍历： 找到空闲炸弹
    ---@type SortedArray
    local sortFreeBomb = self:_FindBombAllFree(listBindMonsterID, nRoundData, posPlayer)
    ---计算各炸弹到各怪物的距离
    local sortArrayByBomb, sortArrayByMonster = self:_ComputeDistance_BombToMonster(sortFreeBomb)
    ---第二次遍历： 为每一个空闲炸弹找对象
    for i = 1, sortFreeBomb:Size() do
        ---@type AiSortByDistance
        local sortBombData = sortFreeBomb:GetAt(i)
        ---@type Entity
        local entityBomb = self._world:GetEntityByID(sortBombData.m_nIndex)
        ---@type Entity
        local entityBindMonster =
            self:_FindBindMonsterByBomb(sortArrayByBomb, sortArrayByMonster, listBindMonsterID, sortBombData, posPlayer)
        if entityBindMonster then
            self:_BindBombAndMonster(nRoundData, entityBomb, entityBindMonster)
            table.insert(listBindMonsterID, entityBindMonster:GetID())
        end
    end
    return sortFreeBomb
end

---@param sortArray SortedArray
function ActionTarget_SelectBomb:_FindSortArray(sortArrayList, nKeyID)
    local sortArray = sortArrayList[nKeyID]
    if nil == sortArray then
        sortArray = SortedArray:New(Algorithm.COMPARE_CUSTOM, AiSortByDistance._ComparerByNear)
        sortArrayList[nKeyID] = sortArray
    end
    return sortArray
end
---计算各炸弹到各怪物的距离
---@param listFreeBomb SortedArray
function ActionTarget_SelectBomb:_ComputeDistance_BombToMonster(listFreeBomb)
    local listDistanceByBomb = {}
    local listDistanceByMonster = {}
    local listMonster = self._world:GetGroup(self._world.BW_WEMatchers.MonsterID):GetEntities()
    for j = 1, #listMonster do
        ---@type Entity
        local entityMonster = listMonster[j]
        local nMonsterType = entityMonster:MonsterID():GetMonsterType()
        if MonsterType.HitFly == nMonsterType then
            local posMonster = entityMonster:GetGridPosition()
            local nMonsterID = entityMonster:GetID()
            local sortByMonster = self:_FindSortArray(listDistanceByMonster, nMonsterID)
            for i = 1, listFreeBomb:Size() do
                ---@type AiSortByDistance
                local sortData = listFreeBomb:GetAt(i)
                local posBomb = sortData:GetPosData()
                local nBombID = sortData.m_nIndex
                ---@type SortedArray
                local sortByBomb = self:_FindSortArray(listDistanceByBomb, nBombID)
                sortByBomb:Insert(AiSortByDistance:New(posBomb, posMonster, nMonsterID))
                sortByMonster:Insert(AiSortByDistance:New(posMonster, posBomb, nBombID))
            end
        end
    end
    return listDistanceByBomb, listDistanceByMonster
end
---给炸弹分配小怪
---@param sortBombData AiSortByDistance
function ActionTarget_SelectBomb:_FindBindMonsterByBomb(
    listDistanceByBomb,
    listDistanceByMonster,
    listBindID,
    sortBombData,
    posPlayer)
    local posBomb = sortBombData:GetPosData()

    local nBombEntityID = sortBombData.m_nIndex
    ---@type SortedArray
    local sortDistanceByMonsterID = self:_FindSortArray(listDistanceByBomb, nBombEntityID)
    if nil == sortDistanceByMonsterID then
        return nil
    end
    local listFindMonsterID = {}
    for i = 1, sortDistanceByMonsterID:Size() do
        ---@type AiSortByDistance
        local sortData_Monster = sortDistanceByMonsterID:GetAt(i)
        local nMonsterID = sortData_Monster.m_nIndex
        if not table.icontains(listBindID, nMonsterID) then
            ---对每一个怪物，查找怪物的最佳选择里是否有自己
            local nDistance = sortData_Monster:GetDistance()
            local nFindBombID = self:_FindNearBombByMonster(listDistanceByMonster, nMonsterID, nDistance, posPlayer)
            if nil == nFindBombID or nFindBombID == nBombEntityID then
                table.insert(listFindMonsterID, nMonsterID)
                break
            end
        end
    end
    local entityFind = nil
    local nFindCount = table.count(listFindMonsterID)
    for i = 1, nFindCount do
        local entityWork = self._world:GetEntityByID(listFindMonsterID[i])
        local posMonster = entityWork:GetGridPosition()
        if self:_IsOneLine(posMonster, posBomb, posPlayer) then
            entityFind = entityWork
            break
        end
    end
    if nil == entityFind and nFindCount > 0 then
        entityFind = self._world:GetEntityByID(listFindMonsterID[1])
    end
    return entityFind
end
---查找怪物的最佳选择
function ActionTarget_SelectBomb:_FindNearBombByMonster(listDistanceByMonster, nMonsterID, nDistance, posPlayer)
    local nFindBombID = nil
    ---@type SortedArray
    local sortDistanceByBombID = self:_FindSortArray(listDistanceByMonster, nMonsterID)
    for j = 1, sortDistanceByBombID:Size() do
        ---@type AiSortByDistance
        local sortData_Bomb = sortDistanceByBombID:GetAt(j)
        local nDistanceTemp = sortData_Bomb:GetDistance()
        if nDistanceTemp < nDistance then
            nFindBombID = sortData_Bomb.m_nIndex
            break
        elseif nDistanceTemp == nDistance then
            if self:_IsHaveValidWalkPos(nMonsterID, sortData_Bomb.m_nIndex, posPlayer) then
                -- if self:_IsCanHitBombToPlayer(posMonster, posBombTemp, posPlayer ) then
                nFindBombID = sortData_Bomb.m_nIndex
            end
        end
    end
    return nFindBombID
end
---判断怪物可达的周围是否有可以击退的位置
function ActionTarget_SelectBomb:_IsHaveValidWalkPos(nMonsterID, nBombID, posPlayer)
    ---@type Entity
    local entityMonster = self._world:GetEntityByID(nMonsterID)
    ---@type AIComponentNew
    local aiCmpt = entityMonster:AI()
    local posMonster = entityMonster:GetGridPosition()
    local posBomb = self._world:GetEntityByID(nBombID):GetGridPosition()
    local listBombAround = ComputeScopeRange.ComputeRange_CrossScope(posBomb, 1, 1)
    local nWalkStep = aiCmpt:GetMobilityValid()

    for i = 1, #listBombAround do
        local posWork = listBombAround[i]
        local nStep = GameHelper.ComputeLogicStep(posMonster, posWork)
        if nStep <= nWalkStep and self:_IsOneLine(posWork, posBomb, posPlayer) then
            return nBombID
        end
    end

    return nil
end
---查找自己行动范围内的有效炸弹（能击退到玩家位置）
function ActionTarget_SelectBomb:_FindValidBomb(posPlayer, nStep)
    ---@type Entity
    local entitySelf = self.m_entityOwn
    ---@type AIComponentNew
    local cmptAI = entitySelf:AI()
    local posSelf = entitySelf:GetGridPosition()
    local selfBodyArea = entitySelf:BodyArea():GetArea()
    local listWalkRange = ComputeScopeRange.ComputeRange_WalkMathPos(posSelf, #selfBodyArea, nStep, nil)
    ---@type UtilDataServiceShare
    local utilDataSvc = self._world:GetService("UtilData")
    for i = 1, #listWalkRange do
        local posWork = listWalkRange[i]:GetPos()
        local listBomb = utilDataSvc:FindEntityByPosAndType(posWork, EnumTargetEntity.Trap, TrapType.BombByHitBack)
        if table.count(listBomb) > 0 then
            for k = 1, #listBomb do
                ---@type Entity
                local entityBombID = listBomb[k]
                if self:_IsOneLine(posSelf, posWork, posPlayer) then
                    local entity = self._world:GetEntityByID(entityBombID)
                    if not entity:HasDeadMark() then
                        return entity
                    end
                end
            end
        end
    end

    return nil
end
--------------------------------
---对炸弹的候选绑定对象做排序
_class("BombSortByDistance", AiSortByDistance)
---@class BombSortByDistance : AiSortByDistance
BombSortByDistance = BombSortByDistance
function BombSortByDistance:Constructor(centrePos, dataPos, nIndex, posPlayer, entityBind)
    self.m_posPlayer = posPlayer
    self.m_entityBind = entityBind
    self.m_nDisPlayer = self:Distance(self.centre, self.m_posPlayer)
end
function BombSortByDistance:GetEntityBind()
    return self.m_entityBind
end
---@param dataNew BombSortByDistance
---@param dataOld BombSortByDistance
BombSortByDistance._ComparerByBomb = function(dataNew, dataOld)
    local nDistanceA = dataNew:GetDistance()
    local nDistanceB = dataOld:GetDistance()
    if nDistanceA > nDistanceB then
        return -1
    elseif nDistanceA < nDistanceB then
        return 1 ---返回值为正表示A排在B前面
    else ---m_nIndex小的在前面
        local nDis = dataNew.m_nDisPlayer - dataOld.m_nDisPlayer
        if 0 == nDis then
            return dataOld.m_nIndex - dataNew.m_nIndex
        else
            return nDis
        end
    end
end
