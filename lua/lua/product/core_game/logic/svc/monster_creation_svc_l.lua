--[[------------------------------------------------------------------------------------------
    MonsterCreationServiceLogic 创建怪物的逻辑Service
]] --------------------------------------------------------------------------------------------

_class("MonsterCreationServiceLogic", BaseService)
---@class MonsterCreationServiceLogic:BaseService
MonsterCreationServiceLogic = MonsterCreationServiceLogic

---根据传入的Entity列表生成表现层需要的
function MonsterCreationServiceLogic:GenerateMonsterCreationResult()
    local group = self._world:GetGroup(self._world.BW_WEMatchers.MonsterID)
    local eMonsters = group:GetEntities()

    local creationResultList = {}
    for _, v in ipairs(eMonsters) do
        local res = self:GenerateOneMonsterResult(v)
        creationResultList[#creationResultList + 1] = res
    end

    return creationResultList
end

---@param monsterEntity Entity
function MonsterCreationServiceLogic:GenerateOneMonsterResult(monsterEntity)
    ---@type ConfigService
    local cfgSvc = self._world:GetService("Config")
    ---@type MonsterConfigData
    local monsterConfigData = cfgSvc:GetMonsterConfigData()

    ---@type DataMonsterCreationResult
    local res = DataMonsterCreationResult:New()

    ---@type UtilDataServiceShare
    local utilDataSvc = self._world:GetService("UtilData")
    local appearSkillId = utilDataSvc:GetAppearSkillId(monsterEntity)
    res:SetMonsterAppearSkillID(appearSkillId)

    ---@type ElementComponent
    local elementCmpt = monsterEntity:Element()
    local elementType = elementCmpt:GetPrimaryType()
    res:SetMonsterElement(elementType)

    ---@type MonsterIDComponent
    local monsterIDCmpt = monsterEntity:MonsterID()
    local monsterTemplateID = monsterIDCmpt:GetMonsterID()
    res:SetMonsterTemplateID(monsterTemplateID)

    local hpOffset = monsterConfigData:GetMonsterHPHeightOffset(monsterTemplateID)
    res:SetMonsterHPOffset(hpOffset)

    res:SetMonsterIsBoss(monsterEntity:HasBoss())

    ---@type AttributesComponent
    local attrCmpt = monsterEntity:Attributes()
    local maxhp = attrCmpt:CalcMaxHp()
    res:SetMonsterMaxHP(maxhp)
    local curHp = attrCmpt:GetCurrentHP()
    res:SetMonsterHP(curHp)

    ---@type GridLocationResult
    local gridLocRes = self:GetMonsterCreationGridLocResult(monsterEntity)
    res:SetMonsterGridLocResult(gridLocRes)

    return res
end

---@param monsterEntity Entity
function MonsterCreationServiceLogic:GetMonsterCreationGridLocResult(monsterEntity)
    ---@type GridLocationComponent
    local gridLocCmpt = monsterEntity:GridLocation()
    ---@type DataGridLocationResult
    local gridLocRes = DataGridLocationResult:New()
    gridLocRes:SetGridLocResultBornPos(gridLocCmpt:GetGridPos())
    gridLocRes:SetGridLocResultBornDir(gridLocCmpt:GetGridDir())
    gridLocRes:SetGridLocResultBornHeight(gridLocCmpt:GetGridLocHeight())
    gridLocRes:SetGridLocResultBornOffset(gridLocCmpt:GetGridOffset())
    gridLocRes:SetGridLocResultDamageOffset(gridLocCmpt:GetDamageOffset())

    return gridLocRes
end

---获取怪物创建时的基础属性攻防血
function MonsterCreationServiceLogic:GetCreateADH(monsterID)
    ---@type ConfigService
    local cfgService = self._configService
    ---@type MonsterConfigData
    local monsterConfigData = cfgService:GetMonsterConfigData()

    local attack = monsterConfigData:GetMonsterAttack(monsterID)
    local defense = monsterConfigData:GetMonsterDefense(monsterID)
    local hp = monsterConfigData:GetMonsterHealth(monsterID)
    return attack, defense, hp
end

---根据方位信息创建一只怪物
---@param monsterTransform MonsterTransformParam
---@return Entity,number,boolean
function MonsterCreationServiceLogic:CreateMonster(monsterTransform)
    return self:_CreateMonster(monsterTransform, nil)
end

---根据方位信息创建一只怪物并初始化 攻、防、血
---@param monsterTransform MonsterTransformParam
---@param attack number
---@param defense number
---@param hp number
---@return Entity,number,boolean
function MonsterCreationServiceLogic:CreateMonsterWithInitADH(monsterTransform, initAttributes)
    initAttributes.attack = initAttributes.attack ~= nil and math.floor(initAttributes.attack) or nil
    initAttributes.defense = initAttributes.defense ~= nil and math.floor(initAttributes.defense) or nil
    initAttributes.maxhp = initAttributes.maxhp ~= nil and math.floor(initAttributes.maxhp) or nil
    initAttributes.curhp = initAttributes.curhp ~= nil and math.floor(initAttributes.curhp) or nil

    return self:_CreateMonster(monsterTransform, initAttributes)
end

---私有函数禁止外部直接调用 请使用 CreateMonster 或 CreateMonsterWithInitADH
---@return Entity,number,boolean
function MonsterCreationServiceLogic:_CreateMonster(monsterTransform, _InitMonsterAttributes)
    ---@type MonsterConfigData
    local monsterConfigData = self._configService:GetMonsterConfigData()
    local monsterID = monsterTransform:GetMonsterID()
    local monsterPosition = monsterTransform:GetPosition()
    local dir = monsterTransform:GetForward()
    local areaArray = monsterTransform:GetBodyArea()
    local positionOffset = monsterTransform:GetOffset()
    local boardIndex = monsterTransform:GetBoardIndex()

    local configMonsterObject = monsterConfigData:GetMonsterObject(monsterID)
    local configMonsterClass = monsterConfigData:GetMonsterClassByMonsterConfig(configMonsterObject)
    ---@type BattleStatComponent
    local cBattleStat = self._world:BattleStat()
    cBattleStat:AddMonsterIDCreate(monsterID)
    cBattleStat:AddMonsterClassIDCreate(configMonsterObject.ClassID)


    areaArray = areaArray or monsterConfigData:GetMonsterArea(monsterID)
    local moveSpeed = monsterConfigData:GetMonsterSpeed(monsterID)
    local monsterType = monsterConfigData:GetMonsterType(monsterID)
    positionOffset = positionOffset or monsterConfigData:GetMonsterOffset(monsterID)
    local damageOffset = monsterConfigData:GetMonsterDamageOffset(monsterID)
    local isBoss = monsterConfigData:IsBoss(monsterID)
    local isWorldBoss = monsterConfigData:IsWorldBoss(monsterID)
    local monsterName = monsterConfigData:GetMonsterName(monsterID)
    local canMove = monsterConfigData:CanMove(monsterID)
    local canTurn = monsterConfigData:CanTurn(monsterID)
    local block = monsterConfigData:Block(monsterID)
    ---@type AffixService
    local affixService = self._world:GetService("Affix")
    ---怪物的攻防血数值
    local attack = monsterConfigData:GetMonsterAttack(monsterID)
    local defense = monsterConfigData:GetMonsterDefense(monsterID)
    local nEvade = monsterConfigData:GetMonsterEvade(monsterID)
    local maxhp = monsterConfigData:GetMonsterHealth(monsterID)
    local elementType = monsterConfigData:GetMonsterElementType(monsterID)
    local isEliteMonster = monsterConfigData:IsEliteMonster(monsterID)
    local absorbNormal = monsterConfigData:GetAbsorbNormal(monsterID)
    local absorbChain = monsterConfigData:GetAbsorbChain(monsterID)
    local absorbActive = monsterConfigData:GetAbsorbActive(monsterID)
    local damageSyncMonsterID = monsterConfigData:GetMonsterDamageSyncMonsterID(monsterID)
    local snakeBodyEffectID = monsterConfigData:GetMonsterSnakeBodyEffectID(monsterID)
    local curhp = maxhp
    local airt = nil
    local bindeff = nil
    local buffrt = nil
    if _InitMonsterAttributes ~= nil and type(_InitMonsterAttributes) == "table" then
        if _InitMonsterAttributes.attack ~= nil then
            attack = _InitMonsterAttributes.attack
        end
        if _InitMonsterAttributes.defense ~= nil then
            defense = _InitMonsterAttributes.defense
        end
        if _InitMonsterAttributes.nEvade ~= nil then
            nEvade = _InitMonsterAttributes.nEvade
        end
        if _InitMonsterAttributes.maxhp ~= nil then
            maxhp = _InitMonsterAttributes.maxhp
            curhp = maxhp
        end
        if _InitMonsterAttributes.curhp ~= nil then
            curhp = _InitMonsterAttributes.curhp
        end
        if _InitMonsterAttributes.elementType ~= nil then
            elementType = _InitMonsterAttributes.elementType
        end
        if _InitMonsterAttributes.airt ~= nil then
            airt = _InitMonsterAttributes.airt
        end
        if _InitMonsterAttributes.bindeff ~= nil then
            bindeff = _InitMonsterAttributes.bindeff
        end
        if _InitMonsterAttributes.buffrt ~= nil then
            buffrt = _InitMonsterAttributes.buffrt
        end
    end

    ---@type LogicEntityService
    local sEntity = self._world:GetService("LogicEntity")
    ---@type Entity
    local monster_entity = sEntity:CreateLogicEntity(EntityConfigIDConst.Monster)

    local raceType = monsterConfigData:GetMonsterRaceType(monsterID)
    local monsterGroupID = monsterConfigData:GetMonsterGroupID(monsterID) --怪物ID
    local monsterClassID = monsterConfigData:GetMonsterClassID(monsterID)
    local monsterCampType = monsterConfigData:GetMonsterCampType(monsterID)
    monster_entity:ReplaceMonsterID(monsterID, raceType, monsterType, monsterGroupID, monsterClassID,monsterCampType)
    monster_entity:MonsterID():SetDamageSyncMonsterID(damageSyncMonsterID)
    monster_entity:MonsterID():SetSnakeBodyEffect(snakeBodyEffectID)
    --初始化AI
    local monsterStep = monsterConfigData:GetMonsterStep(monsterID)
    local aiTargetType = monsterConfigData:GetMonsterAITargetType(monsterID)
    monster_entity:InitAI(self._world, monsterID, monsterStep, aiTargetType)
    monster_entity:SetAICanMoveTurn(monsterID, canMove, canTurn)

    local monsterAIIDList = monsterConfigData:GetMonsterAIID(monsterID)
    monsterAIIDList = affixService:ChangeMonsterAI(monsterID, AILogicPeriodType.Main, monsterAIIDList)
    monster_entity:AddNewAI(monsterID, AILogicPeriodType.Main, monsterAIIDList)

    local monsterPreMoveAIIDList = monsterConfigData:GetMonsterPreMoveAIID(monsterID)
    monsterPreMoveAIIDList = affixService:ChangeMonsterAI(monsterID, AILogicPeriodType.Prev, monsterPreMoveAIIDList)
    monster_entity:AddNewAI(monsterID, AILogicPeriodType.Prev, monsterPreMoveAIIDList)

    local monsterAntiAttackAIIDList = monsterConfigData:GetMonsterAntiAttackAIID(monsterID)
    monsterAntiAttackAIIDList = affixService:ChangeMonsterAI(monsterID, AILogicPeriodType.Anti, monsterAntiAttackAIIDList)
    monster_entity:AddNewAI(monsterID, AILogicPeriodType.Anti, monsterAntiAttackAIIDList)

    ---配置预览的是哪个AI分支
    monster_entity:InitPreviewLogic(AILogicPeriodType.Main)
    --存档的AI状态
    if airt then
        monster_entity:AI():SetRuntimeDataAll(airt)
    end

    --存档特效
    if bindeff then
        monster_entity:AddArchivedEffect(bindeff)
    end

    monster_entity:ReplaceBodyArea(areaArray) --重置格子占位
    monster_entity:SetGridLocationAndOffset(monsterPosition, dir, positionOffset, damageOffset) --位置信息

    ---@type BoardServiceLogic
    local boardService = self._world:GetService("BoardLogic")
    local blockFlag = boardService:GetBlockFlagByBlockId(block)
    monster_entity:ReplaceBlockFlag(blockFlag)
    if not boardIndex then
        --在常规棋盘内
        boardService:UpdateEntityBlockFlag(monster_entity, monsterPosition, monsterPosition)
    else
        --多面棋盘
        ---@type BoardMultiServiceLogic
        local boardMultiServiceLogic = self._world:GetService("BoardMultiLogic")
        boardMultiServiceLogic:UpdateEntityBlockFlagMultiBoard(
            boardIndex,
            monster_entity,
            monsterPosition,
            monsterPosition
        )
    end

    ---攻防血还得被词条处理一次
    attack = affixService:ChangeMonsterAttr(monsterID, attack, AffixAttrType.Attack)
    defense = affixService:ChangeMonsterAttr(monsterID, defense, AffixAttrType.Defence)
    maxhp = affixService:ChangeMonsterAttr(monsterID, maxhp, AffixAttrType.HP)
    ---只有最大血量小于当前血量 再刷否则存档会有bug
    if curhp > maxhp then
        curhp = maxhp
    end

    if isWorldBoss then
        curhp = BattleConst.WorldBossHP
        maxhp = BattleConst.WorldBossHP
        ---@type BattleStatComponent
        local battleStatCmpt = self:_GetBattleStatComponent()
        if not battleStatCmpt:GetMainWorldBossID() then--第一个世界boss作为主boss，结算时只取该boss的伤害
            battleStatCmpt:SetMainWorldBossID(monster_entity:GetID())
        end
    end
    --重置数值
    local attributeCmpt = monster_entity:Attributes()
    attributeCmpt:Modify("Attack", attack)
    attributeCmpt:Modify("Defense", defense)
    attributeCmpt:Modify("Evade", nEvade)
    attributeCmpt:Modify("HP", curhp)
    attributeCmpt:Modify("MaxHP", maxhp)
    attributeCmpt:Modify("Mobility", monsterStep, 1, MultModifyOperator.PLUS)
    attributeCmpt:Modify("MaxMobility", 99)

    --设置元素类型
    monster_entity:ReplaceElement(elementType, nil)
    attributeCmpt:SetSimpleAttribute("Element", elementType)

    attributeCmpt:Modify("AbsorbNormal", absorbNormal)
    attributeCmpt:Modify("AbsorbChain", absorbChain)
    attributeCmpt:Modify("AbsorbActive", absorbActive)

    --反制AI的参数
    local antiAttackParam = monsterConfigData:GetMonsterAntiAttackParam(monsterID)
    if antiAttackParam then
        --新QA可以通过buff修改反制参数，buff添加的反制无法读取monsterClass的值，所以设置一下初始值
        attributeCmpt:Modify("OriginalWaitActiveSkillCount", antiAttackParam.WaitActiveSkillCount)
        attributeCmpt:Modify("OriginalMaxAntiSkillCountPerRound", antiAttackParam.MaxAntiSkillCountPerRound)
        attributeCmpt:Modify("WaitActiveSkillCount", antiAttackParam.WaitActiveSkillCount)
        attributeCmpt:Modify("MaxAntiSkillCountPerRound", antiAttackParam.MaxAntiSkillCountPerRound)
        attributeCmpt:Modify("AntiActiveSkillType", antiAttackParam.AntiActiveSkillType or {})
        --是否激活，不配不赋值，采用属性默认值的1
        if antiAttackParam.AntiSkillEnabled then
            attributeCmpt:Modify("AntiSkillEnabled", antiAttackParam.AntiSkillEnabled)
        end
    end
	
    if isBoss then --客户端服务器都添加Boss组件 -edit by jince
        monster_entity:ReplaceBoss()
    end

    if isWorldBoss then
        self:InitWorldBossHPData(monster_entity, monsterID)
    end
	
    self._world:GetService("Trigger"):Notify(NTMonsterShow:New(monster_entity))

    ---这种非对象化传递context的做法很不好，计划N9版本改成确定的对象化
    local monsterBornBuffContext = { isMonsterBornBuff = true }
    --怪物初始化时需要挂的buff，只给自己挂
    ---@type BuffLogicService
    local buffLogic = self._world:GetService("BuffLogic")
    local buffList = monsterConfigData:GetBornBuffList(monsterID)
    if #buffList > 0 then
        if not monster_entity:HasBuff() then
            monster_entity:AddBuffComponent()
        end
        for _, buffId in ipairs(buffList) do
            buffLogic:AddBuff(buffId, monster_entity, monsterBornBuffContext)
        end
    end

    ---@type BattleService
    local battleSvc = self._world:GetService("Battle")
    -- 添加精英化词条
    --QA：MSG52326 精英词缀随机功能，调整接口
    --local eliteIDArray = monsterConfigData:GetEliteIDArray(monsterID) or {}
    local eliteIDArray = battleSvc:CalcEliteIDArray(monsterID) or {}
    for _, eliteID in ipairs(eliteIDArray) do
        local c = Cfg.cfg_monster_elite[eliteID]
        if not c then
            Log.error("[ELITE_MSTR]", "invalid eliteID: ", eliteID)
            goto CREATE_MONSTER_ELITE_BUFF_CONTINUE
        end

        if (not c.Buff) or (#(c.Buff) == 0) then
            goto CREATE_MONSTER_ELITE_BUFF_CONTINUE
        end

        for _, buffID in ipairs(c.Buff) do
            Log.info("[ELITE_MSTR]", "entityID: ", monster_entity:GetID(), "elite ID: ", eliteID, ", buffID: ", buffID)
            buffLogic:AddBuff(buffID, monster_entity, monsterBornBuffContext)
        end

        ::CREATE_MONSTER_ELITE_BUFF_CONTINUE::
    end

    if (#eliteIDArray > 0) then
        monster_entity:MonsterID():SetEliteIDArray(eliteIDArray)
    end

    --怪物锁血状态存档恢复
    if buffrt then
        monster_entity:BuffComponent():LoadArchivedData(buffrt)
        ---@type UtilDataServiceShare
        local utilDataSvc = self._world:GetService("UtilData")
        utilDataSvc:UpdateRenderHPLockInfoByLogic(monster_entity)
    end

    ---@type TrapServiceLogic
    local trapsvc = self._world:GetService("TrapLogic")
    --loading时不计算出场技，放到waveenter中计算，防止出场技中有位移效果会导致某些格子丢失的问题
    --存档的秘境关不再显示出场技，防止出场技重复召唤怪物
    if self._world:GameFSM():CurStateID() ~= GameStateID.Loading and
        not self._world:GetService("Maze"):IsArchivedBattle()
    then
        self:CalcAppearSkill(monster_entity)
        local tEntities, tResults = trapsvc:TriggerTrapByEntity(monster_entity, TrapTriggerOrigin.Move)
        if (#tEntities > 0) and (#tResults > 0) then
            monster_entity:AddAppearTriggerTrap(tEntities, tResults)
        end
    end

    self._world:GetSyncLogger():Trace(
        {
            key = "CreateMonster",
            monsterID = monsterID,
            entityID = monster_entity:GetID(),
            elementType = elementType,
            pos = tostring(monsterPosition)
        }
    )
    return monster_entity, monsterID
end

---双端共同执行
function MonsterCreationServiceLogic:CreateInternalRefreshMonsterLogic(monsterWaveInternalTime)
    local monsterConfigDataArray = self:_GetInternalRefreshConfigData()
    if monsterConfigDataArray == nil then
        return
    end

    -- ---@type BattleService
    -- local battleService = self._world:GetService("Battle")
    -- local levelFinish = battleService:CheckLevelFinish()
    -- --检查是否到达关卡胜利条件
    -- if levelFinish then
    --     return
    -- end

    ---@type MonsterRefreshService
    local monsterRefreshService = self._world:GetService("MonsterRefresh")
    ---@type LogicEntityService
    local entityService = self._world:GetService("LogicEntity")
    local eTrapList = {}
    local eMonsterList = {}
    for _, refreshConfigData in ipairs(monsterConfigDataArray) do
        local refreshType = refreshConfigData:GetInternalRefreshType()
        local refreshParam = refreshConfigData:GetInternalRefreshParam()
        local hadRefreshRound = refreshConfigData:GetHadRefreshRound(refreshType)
        local isRefreshMonster =
        monsterRefreshService:IsRefreshMonster(refreshType, refreshParam, monsterWaveInternalTime, hadRefreshRound)
        if isRefreshMonster then
            if refreshType ~= MonsterWaveInternalRefreshType.None then
                local roundCount = self:_GetBattleStatComponent():GetCurWaveTotalRoundCount()
                refreshConfigData:AddRefreshRound(refreshType, roundCount)

                local newGapTiles = refreshConfigData:GetGapTiles()
                ---↑↑↑↑↑此处的方法索然叫获取镂空格子，但在后续刷格子时，却将这些格子填充上【配置的条目命名与实际逻辑不一致】↑↑↑↑↑
                if newGapTiles then
                    self:_DoRefreshBoardGapTiles(newGapTiles) ---刷格子
                end

                ---处理机关刷新
                local _, eTraps = entityService:CreateWaveRefreshTraps(refreshConfigData:GetInternalTrapIDDic())
                table.appendArray(eTrapList, eTraps)

                local monsterPosList = self:_CalcInternalRefreshMonsterPos(refreshConfigData) ---处理怪物刷新
                local eMonsters, monsterIds = self:CreateMonsters(monsterPosList) ---先根据位置创建出所有的怪物
                table.appendArray(eMonsterList, eMonsters)
            end
        end
    end
    return eTrapList, eMonsterList
end

---提取波次内刷怪的配置数据
---@return MonsterRefreshData[]
function MonsterCreationServiceLogic:_GetInternalRefreshConfigData()
    ---@type LevelConfigData
    local levelConfigData = self._configService:GetLevelConfigData()
    --当前波次
    ---@type number
    local waveNum = self:_GetBattleStatComponent():GetCurWaveIndex()

    local monsterConfigDataArray = levelConfigData:GetLevelWaveInternalRefreshData(waveNum)
    return monsterConfigDataArray
end

---计算波次内刷怪的怪物位置
function MonsterCreationServiceLogic:_CalcInternalRefreshMonsterPos(refreshConfigData)
    ---@type LevelMonsterRefreshParam
    local monsterRefreshParam = refreshConfigData:GetMonsterRefreshParam()

    ---@type CreateMonsterPosService
    local createMonsterPosService = self._world:GetService("CreateMonsterPos")
    ---@type MonsterRefreshPosType
    local monsterRefreshPosType = monsterRefreshParam:GetMonsterRefreshPosType()
    local monsterArray = createMonsterPosService:GetMonsterRefreshPos(monsterRefreshPosType, monsterRefreshParam)
    return monsterArray
end

---根据传进来的位置列表，创建一组怪物
---@param monsterArray MonsterTransformParam 数组
function MonsterCreationServiceLogic:CreateMonsters(monsterArray)
    local eMonsters = {}
    local monsterIds = {}
    for _, v in ipairs(monsterArray) do
        local eMonster, monsterId = self:CreateMonster(v)
        table.insert(eMonsters, eMonster)
        table.insert(monsterIds, monsterId)

        self._world:GetSyncLogger():Trace(
            {
                key = "CreateInternalMonsters",
                monsterID = monsterId,
                entityID = eMonster:GetID(),
                pos = tostring(v:GetPosition())
            }
        )
    end
    return eMonsters, monsterIds
end

---计算出场技
---@param e Entity
function MonsterCreationServiceLogic:CalcAppearSkill(e)
    ---@type SkillLogicService
    local sSkillLogic = self._world:GetService("SkillLogic")
    ---@type UtilDataServiceShare
    local utilDataSvc = self._world:GetService("UtilData")
    local appearSkillId = utilDataSvc:GetAppearSkillId(e)
    if appearSkillId and appearSkillId > 0 then
        sSkillLogic:CalcSkillEffect(e, appearSkillId)
        sSkillLogic:UpdateRenderSkillRoutine(e)
    end
end

--endregion

function MonsterCreationServiceLogic:_DoRefreshBoardGapTiles(fillPieceList)
    ---@type BoardServiceLogic
    local boardServiceLogic = self._world:GetService("BoardLogic")
    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    local oldGapTiles = boardServiceLogic:GetGapTiles()
    local newGapTiles = {}
    ---TODO 暂时支持中途添加格子
    for i = 1, #oldGapTiles do
        local bFind = false
        for j = 1, #fillPieceList do
            if fillPieceList[j][1] == oldGapTiles[i][1] and fillPieceList[j][2] == oldGapTiles[i][2] then
                bFind = true
            end
        end
        if bFind ~= true then
            table.insert(newGapTiles, { oldGapTiles[i][1], oldGapTiles[i][2] })
        end
    end
    boardServiceLogic:ChangeGapTiles(newGapTiles)
    local addPiecePos = {}
    for i = 1, #fillPieceList do
        table.insert(addPiecePos, Vector2(fillPieceList[i][1], fillPieceList[i][2]))
    end
    ---@type Entity
    local boardEntity = self._world:GetBoardEntity()
    local pieceFillTable = boardServiceLogic:SupplyPieceList(addPiecePos)
    ---@type BoardComponent
    local boardCmpt = boardEntity:Board()
    boardCmpt:FillPieces(pieceFillTable)
    for i, grid in ipairs(pieceFillTable) do
        local gridPos = Vector2(grid.x, grid.y)
        boardServiceRender:CreateGridEntity(grid.color, gridPos, false)
    end
end

--应用制造1个幻象逻辑
---@param result SkillMakePhantomEffectResult
---@return entity
function MonsterCreationServiceLogic:MakePhantomLogic(result)
    ---@type MonsterTransformParam
    local monsterTransformParam = MonsterTransformParam:New(result:GetTargetID())
    monsterTransformParam:SetPosition(result:GetBornPos())
    monsterTransformParam:SetRotation(result:GetBornRot())
    ---@type Entity
    local phantomEntity, id = self:CreateMonster(monsterTransformParam)
    phantomEntity:AddPhantomComponent(result:GetOwnerID())

    ---@type AttributesComponent
    local attributeCmpt = phantomEntity:Attributes()
    local maxHp = attributeCmpt:CalcMaxHp()
    local hp = math.floor(maxHp * result:GetHPPercent())
    --这里直接更改属性，而不modify
    attributeCmpt:SetSimpleAttribute("MaxHP", hp)
    attributeCmpt:SetSimpleAttribute("HP", hp)

    return phantomEntity
end

---@param entity Entity
function MonsterCreationServiceLogic:InitWorldBossHPData(entity, monsterID)
    ---@type MonsterConfigData
    local monsterConfigData = self._configService:GetMonsterConfigData()
    local stage = monsterConfigData:GetWorldBossConfig(monsterID)
    ---@type MonsterIDComponent
    local monsterIDCmpt = entity:MonsterID()
    monsterIDCmpt:InitWorldBossStageData(stage)
    monsterIDCmpt:SetWorldBossState(true)
    
    local newAttrData = monsterIDCmpt:GetWorldBossStageAttrData(monsterIDCmpt:GetCurStage())
    if newAttrData then
        ---@type AffixService
        local affixService = self._world:GetService("Affix")
        ---@type AttributesComponent
        local attributeCmpt = entity:Attributes()
        local newAtk = newAttrData.atk
        local newDef = newAttrData.def
        if newAtk then
            ---攻防血还得被词条处理一次
            newAtk = affixService:ChangeMonsterAttr(monsterID, newAtk, AffixAttrType.Attack)
            attributeCmpt:Modify("Attack", newAtk)
        end
        if newDef then
            newDef = affixService:ChangeMonsterAttr(monsterID, newDef, AffixAttrType.Defence)
            attributeCmpt:Modify("Defense", newDef)
        end
    end
end

--以朝向(0,-1)为默认方向，旋转oriBodyArea到现在的方向 针对异形怪的处理
function MonsterCreationServiceLogic:_RotateBodyArea(oriBodyArea,toDir)
    local rotatedOriBodyArea = {}
    if toDir == Vector2.up then
        --180度 （-x,-y)
        for index, pos in ipairs(oriBodyArea) do
            local newPos = Vector2(-pos.x,-pos.y)
            table.insert(rotatedOriBodyArea,newPos)
        end
    elseif toDir == Vector2.right then
        --逆时针90度 （-y,x)
        for index, pos in ipairs(oriBodyArea) do
            local newPos = Vector2(-pos.y,pos.x)
            table.insert(rotatedOriBodyArea,newPos)
        end
    elseif toDir == Vector2.left then
        --顺时针90度 （y,-x)
        for index, pos in ipairs(oriBodyArea) do
            local newPos = Vector2(pos.y,-pos.x)
            table.insert(rotatedOriBodyArea,newPos)
        end
    elseif toDir == Vector2.down then
        rotatedOriBodyArea = oriBodyArea
    end
    return rotatedOriBodyArea
end