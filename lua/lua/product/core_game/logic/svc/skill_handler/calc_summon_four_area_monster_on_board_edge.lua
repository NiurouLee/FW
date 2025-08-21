--[[

]]
require("calc_base")

---@class SkillEffectCalc_SummonFourAreaMonsterOnBoardEdge: SkillEffectCalc_Base
_class("SkillEffectCalc_SummonFourAreaMonsterOnBoardEdge", SkillEffectCalc_Base)
SkillEffectCalc_SummonFourAreaMonsterOnBoardEdge = SkillEffectCalc_SummonFourAreaMonsterOnBoardEdge

function SkillEffectCalc_SummonFourAreaMonsterOnBoardEdge:Constructor(world)
    ---@type MainWorld
    self._world = world
end

---@param skillEffectCalcParam SkillEffectCalcParam
function SkillEffectCalc_SummonFourAreaMonsterOnBoardEdge:DoSkillEffectCalculator(skillEffectCalcParam)
    ---@type SkillEffectCalcService
    local skillEffectService = self._world:GetService("SkillEffectCalc")
    ---@type RandomServiceLogic
    local randomSvc = self._world:GetService("RandomLogic")

    ---@type Entity
    local casterEntity = self._world:GetEntityByID(skillEffectCalcParam.casterEntityID)
    local posCaster = casterEntity:GetGridPosition()

    ---@type SkillEffectParamSummonFourAreaMonsterOnBoardEdge
    local skillEffectParam = skillEffectCalcParam.skillEffectParam

    local summonList = skillEffectParam:GetSummonList()
    local summonCount = skillEffectParam:GetSummonCount()
    local summonType = SkillEffectEnum_SummonType.Monster

    local hadSelectPosList = {}
    local boardEdgePosList = self:_OnCalcBoardEdgePosList(hadSelectPosList)
    table.appendArray(hadSelectPosList, boardEdgePosList)

    local results = {}

    for i = 1, summonCount do
        local curRandomIndex = randomSvc:LogicRand(1, #summonList)
        local curSummonID = summonList[curRandomIndex]

        local posSummon = self:_OnCalcSummonPos(boardEdgePosList, curSummonID)

        --如果没找到往里面找一圈，只一圈
        if not posSummon then
            boardEdgePosList = self:_OnCalcBoardEdgePosList(hadSelectPosList)
        end

        if posSummon then
            table.insert(hadSelectPosList, posSummon)

            local skillResultSummon =
                SkillEffectResult_SummonEverything:New(summonType, curSummonID, posCaster, posSummon)
            table.insert(results, skillResultSummon)
        end
    end

    return results
end

--棋盘边
function SkillEffectCalc_SummonFourAreaMonsterOnBoardEdge:_OnCalcBoardEdgePosList(hadSelectPosList)
    local boardEdgePosList = {}

    ---@type BoardServiceLogic
    local boardServiceLogic = self._world:GetService("BoardLogic")
    local boardMaxX = boardServiceLogic:GetCurBoardMaxX()
    local boardMaxY = boardServiceLogic:GetCurBoardMaxY()

    ---@type UtilDataServiceShare
    local utilData = self._world:GetService("UtilData")

    for x = 1, boardMaxX do
        local xPosList = {}
        for y = 1, boardMaxY do
            local pos = Vector2(x, y)
            if not table.icontains(hadSelectPosList, pos) and utilData:IsValidPiecePos(pos) then
                table.insert(xPosList, pos)
                break
            end
        end
        for y = boardMaxY, 1, -1 do
            local pos = Vector2(x, y)
            if not table.icontains(hadSelectPosList, pos) and utilData:IsValidPiecePos(pos) then
                table.insert(xPosList, pos)
                break
            end
        end

        table.sort(
            xPosList,
            function(a, b)
                return a.y < b.y
            end
        )

        table.insert(boardEdgePosList, xPosList[1])
        if not table.icontains(boardEdgePosList, xPosList[#xPosList]) then
            table.insert(boardEdgePosList, xPosList[#xPosList])
        end
    end

    for y = 1, boardMaxY do
        local yPosList = {}
        for x = 1, boardMaxX do
            local pos = Vector2(x, y)
            if not table.icontains(hadSelectPosList, pos) and utilData:IsValidPiecePos(pos) then
                table.insert(yPosList, pos)
                break
            end
        end
        for x = boardMaxX, 1, -1 do
            local pos = Vector2(x, y)
            if not table.icontains(hadSelectPosList, pos) and utilData:IsValidPiecePos(pos) then
                table.insert(yPosList, pos)
                break
            end
        end

        table.sort(
            yPosList,
            function(a, b)
                return a.x < b.x
            end
        )

        if not table.icontains(boardEdgePosList, yPosList[1]) then
            table.insert(boardEdgePosList, yPosList[1])
        end
        if not table.icontains(boardEdgePosList, yPosList[#yPosList]) then
            table.insert(boardEdgePosList, yPosList[#yPosList])
        end
    end

    local teamLeader = self._world:Player():GetLocalTeamEntity() --技能范围只有怪用，黑拳赛不处理
    local teamPos = teamLeader:GetGridPosition()

    table.sort(
        boardEdgePosList,
        function(a, b)
            local disA = Vector2.Distance(teamPos, a)
            local disB = Vector2.Distance(teamPos, b)
            return disA < disB
        end
    )

    return boardEdgePosList
end

--棋盘边上距离玩家最近的点
function SkillEffectCalc_SummonFourAreaMonsterOnBoardEdge:_OnCalcSummonPos(boardEdgePosList, summonID)
    local posSummon

    ---@type BoardServiceLogic
    local boardServiceLogic = self._world:GetService("BoardLogic")

    ---@type ConfigService
    local cfgService = self._world:GetService("Config")
    ---@type MonsterConfigData
    local monsterConfigData = cfgService:GetMonsterConfigData()
    local areaArray = monsterConfigData:GetMonsterArea(summonID)
    local raceType = monsterConfigData:GetMonsterRaceType(summonID)
    ---@type BlockFlag
    local blockRaceType = self._skillEffectService:_TransBlockByRaceType(raceType)

    for _, pos in ipairs(boardEdgePosList) do
        if #areaArray == 1 then
            if not boardServiceLogic:IsPosBlock(pos, blockRaceType) then
                posSummon = pos
                break
            end
        elseif #areaArray == 4 then
            --以身形的四个点为中心 计算四次 看看那个可以
            for _, area in ipairs(areaArray) do
                local blockCount = 0
                local posNewCenter = pos - area
                for _, newArea in ipairs(areaArray) do
                    local posWork = posNewCenter + newArea
                    if boardServiceLogic:IsPosBlock(posWork, blockRaceType) then
                        break
                    end

                    blockCount = blockCount + 1
                end

                if blockCount == #areaArray then
                    posSummon = posNewCenter
                    break
                end
            end

            if posSummon then
                break
            end
        end
    end

    return posSummon
end
