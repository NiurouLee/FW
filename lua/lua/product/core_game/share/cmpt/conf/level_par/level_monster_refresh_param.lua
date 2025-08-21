--[[------------------------------------------------------------------------------------------
    LevelMonsterRefreshParam : 关卡怪物刷新参数
]] --------------------------------------------------------------------------------------------

_class("LevelMonsterRefreshParam", Object)
---@class LevelMonsterRefreshParam: Object
LevelMonsterRefreshParam = LevelMonsterRefreshParam

---@class TrapAssembleType
local TrapAssembleType = {
    Default = 0, ---不配的话，就是默认组装方式
    CurseTower = 1 ---诅咒塔的组装机关
}
TrapAssembleType = TrapAssembleType
_enum("TrapAssembleType", TrapAssembleType)

function LevelMonsterRefreshParam:Constructor(world)
    ---@type MainWorld
    self._world = world

    ---@type TrapTransformParam[]
    self._trapArray = {}

    ---@type TrapAssembleType
    self._trapAssembleType = TrapAssembleType.Default

    --怪物位置刷新类型
    ---@type MonsterRefreshPosType
    self._monsterRefreshPosType = MonsterRefreshPosType.None
    --怪物方向集合
    ---@type Vector2[]
    self._monsterRotationArray = {}
    --怪物ID
    ---@type number[]
    self._monsterIDArray = {}
    --怪物位置集合
    ---@type Vector2[]
    self._monsterPosArray = {}
    --特殊刷新规则使用
    ---@type table<number,Vector2>
    self._monsterPosAndOffSetArray = {}

    ---ExceptionHandle
    self._exceptionType = 0

    self._chessPetIDArray = {}
    ---@type table<number,table<number,table<number,Vector2>>>
    self._exceptionData = {}
    self._refreshPosOptions = {}
end

function LevelMonsterRefreshParam:GetMonsterIDArray()
    return self._monsterIDArray
end

function LevelMonsterRefreshParam:GetMonsterRotationArray()
    return self._monsterRotationArray
end

function LevelMonsterRefreshParam:GetMonsterPosArray()
    return self._monsterPosArray
end

function LevelMonsterRefreshParam:GetMonsterPosAndOffSetArray()
    return self._monsterPosAndOffSetArray
end

function LevelMonsterRefreshParam:GetMonsterRefreshPosType()
    return self._monsterRefreshPosType
end

---获取机关信息数组
---@return TrapTransformParam[]
function LevelMonsterRefreshParam:GetTrapArray()
    return self._trapArray
end

function LevelMonsterRefreshParam:GetChessPetIDArray()
    return self._chessPetIDArray
end

function LevelMonsterRefreshParam:GetChessPetRotationArray()
    return self._chessPetRotationArray
end

function LevelMonsterRefreshParam:GetChessPetPosArray()
    return self._chessPetPosArray
end

---@return TrapAssembleType
function LevelMonsterRefreshParam:GetTrapAssembleType()
    return self._trapAssembleType
end

function LevelMonsterRefreshParam:ParseMonsterRefreshParam(monsterRefreshConfig)
    if (monsterRefreshConfig.MonsterIDList or monsterRefreshConfig.RandomMonsterIDList)
        and monsterRefreshConfig.MonsterPosition
    then
        self._monsterRefreshPosType = monsterRefreshConfig.MonsterRefreshType
        --所有怪物的位置,需要与怪物ID一一对应
        if self._monsterRefreshPosType == MonsterRefreshPosType.SelectFirstCanUse then
            self._monsterPosArray = self:_ParsePositionArray(monsterRefreshConfig.MonsterPosition)
        elseif self._monsterRefreshPosType ~= MonsterRefreshPosType.PositionAndOffSet and
            self._monsterRefreshPosType ~= MonsterRefreshPosType.PositionTable and
            self._monsterRefreshPosType ~= MonsterRefreshPosType.PositionAndOffSetMultiBoard then
            self._monsterPosArray = self:_ParsePosition(monsterRefreshConfig.MonsterPosition)
        else
            self._monsterPosAndOffSetArray = self:_ParsePositionAndOffSet(monsterRefreshConfig.MonsterPosition)
        end
        --位置集合刷新怪物时使用的位置合集
        ---type Vector2[]
        --self._monsterRandomPosArray = self:_ParsePosition(monsterRefreshConfig.MonsterRandomPosition)
        self._exceptionType = monsterRefreshConfig.ExceptionHandle
        if self._exceptionType == MonsterRefreshExceptionType.BackupTable then
            self._exceptionData = self:_ParseExceptionData(monsterRefreshConfig.ExceptionData)
        end
        --所有怪物的朝向
        if self._monsterRefreshPosType == MonsterRefreshPosType.SelectFirstCanUse then
            self._monsterRotationArray = self:_ParseRotationArray(monsterRefreshConfig.MonsterRotation)
        else
            self._monsterRotationArray = self:_ParseRotation(monsterRefreshConfig.MonsterRotation)
        end

        --解析怪物列表
        if monsterRefreshConfig.RandomMonsterIDList then
            local monsterList = table.cloneconf(monsterRefreshConfig.RandomMonsterIDList)
            local weightList = table.cloneconf(monsterRefreshConfig.RandomWeightList)
            self._monsterIDArray = self:_ParseRandomMonsterID(monsterList, weightList)
        else
            self._monsterIDArray = table.cloneconf(monsterRefreshConfig.MonsterIDList)
        end

        if monsterRefreshConfig.MonsterRefreshPosOptions then
            for k, v in pairs(monsterRefreshConfig.MonsterRefreshPosOptions) do
                self._refreshPosOptions[k] = v
            end
        end
    end

    return self._monsterIDArray
end

function LevelMonsterRefreshParam:ParseTrapRefreshParam(trapRefreshConfig)
    if trapRefreshConfig.TrapIDList and trapRefreshConfig.TrapPosition and trapRefreshConfig.TrapRotation then
        --机关位置
        local trapPosVec2Array = self:_ParsePositionArray(trapRefreshConfig.TrapPosition)
        --机关朝向
        local trapRotationArray = self:_ParseRotationArray(trapRefreshConfig.TrapRotation)
        --机关阻挡
        local trapCheckBlock = self:_ParseCheckBlockArray(trapRefreshConfig.TrapCheckBlock)

        self._trapAssembleType = trapRefreshConfig.TrapAssembleType

        --解析机关列表
        local trapIDArray = trapRefreshConfig.TrapIDList
        for k, trapID in ipairs(trapIDArray) do
            local trapTransformParam = TrapTransformParam:New(trapID)
            local trapPosition = trapPosVec2Array[k]
            local trapRotation = trapRotationArray[k]
            local trapCheckBlock = trapCheckBlock[k] == 1

            trapTransformParam:SetPositionList(trapPosition)
            trapTransformParam:SetRotationList(trapRotation)
            trapTransformParam:SetTrapCheckBlock(trapCheckBlock)
            --Log.fatal("trapid ",trapID)
            self._trapArray[#self._trapArray + 1] = trapTransformParam
        end
    end
    return self._trapArray
end

function LevelMonsterRefreshParam:ParseChessPetRefreshParam(chessPetRefreshConfig)
    if chessPetRefreshConfig.ChessPetIDList and chessPetRefreshConfig.ChessPetPosition then
        self._monsterRefreshPosType = chessPetRefreshConfig.MonsterRefreshType
        --所有怪物的位置,需要与怪物ID一一对应
        if self._monsterRefreshPosType == MonsterRefreshPosType.SelectFirstCanUse then
            self._chessPetPosArray = self:_ParsePositionArray(chessPetRefreshConfig.ChessPetPosition)
        elseif self._monsterRefreshPosType ~= MonsterRefreshPosType.PositionAndOffSet and
            self._monsterRefreshPosType ~= MonsterRefreshPosType.PositionAndOffSetMultiBoard
        then
            self._chessPetPosArray = self:_ParsePosition(chessPetRefreshConfig.ChessPetPosition)
        else
            self._monsterPosAndOffSetArray = self:_ParsePositionAndOffSet(chessPetRefreshConfig.ChessPetPosition)
        end
        --位置集合刷新怪物时使用的位置合集
        self._exceptionType = chessPetRefreshConfig.ExceptionHandle
        --所有怪物的朝向
        if self._monsterRefreshPosType == MonsterRefreshPosType.SelectFirstCanUse then
            self._chessPetRotationArray = self:_ParseRotationArray(chessPetRefreshConfig.ChessPetRotation)
        else
            self._chessPetRotationArray = self:_ParseRotation(chessPetRefreshConfig.ChessPetRotation)
        end

        --解析怪物列表
        self._chessPetIDArray = table.cloneconf(chessPetRefreshConfig.ChessPetIDList)
    end

    return self._chessPetIDArray
end

function LevelMonsterRefreshParam:_ParsePositionAndOffSet(posStrArray)
    local posVec2Array = {}
    for k, posStr in ipairs(posStrArray) do
        local posNumArray = string.split(posStr, ",")
        ---固定坐标
        if #posNumArray == 2 then
            local posVec2 = Vector2(tonumber(posNumArray[1]), tonumber(posNumArray[2]))
            posVec2Array[#posVec2Array + 1] = { MonsterPosType.Position, posVec2 }
        else
            local appoint = posNumArray[1]
            if appoint ~= "F" then
                Log.fatal("ParsePositionAndOffSet No Find appoint word")
            end
            ---相对玩家偏移量
            local posVec2 = Vector2(tonumber(posNumArray[2]), tonumber(posNumArray[3]))
            posVec2Array[#posVec2Array + 1] = { MonsterPosType.OffSet, posVec2 }
        end
    end

    return posVec2Array
end

function LevelMonsterRefreshParam:_ParsePosition(posStrArray)
    local posVec2Array = {}
    for k, posStr in ipairs(posStrArray) do
        local posNumArray = string.split(posStr, ",")
        local posVec2 = Vector2(tonumber(posNumArray[1]), tonumber(posNumArray[2]))
        posVec2Array[#posVec2Array + 1] = posVec2
    end

    return posVec2Array
end

function LevelMonsterRefreshParam:_ParsePositionArray(posStrArray)
    local posVec2Array = {}
    for k, posStr in ipairs(posStrArray) do
        local posNumArray = string.split(posStr, ",")
        local count = #posNumArray
        local posArra = {}
        for i = 1, count, 2 do
            local posVec2 = Vector2(tonumber(posNumArray[i]), tonumber(posNumArray[i + 1]))
            posArra[#posArra + 1] = posVec2
        end
        posVec2Array[#posVec2Array + 1] = posArra
    end
    return posVec2Array
end

function LevelMonsterRefreshParam:_ParseRotationArray(rotationStrArray)
    local posVec2Array = {}
    if rotationStrArray then
        for k, posStr in ipairs(rotationStrArray) do
            local posNumArray = string.split(posStr, ",")
            local count = #posNumArray
            local posArra = {}
            for i = 1, count, 2 do
                local posVec2 = Vector2(tonumber(posNumArray[i]), tonumber(posNumArray[i + 1]))
                posArra[#posArra + 1] = posVec2
            end
            posVec2Array[#posVec2Array + 1] = posArra
        end
    end
    return posVec2Array
end

function LevelMonsterRefreshParam:_ParseRotation(rotationStrArray)
    if rotationStrArray then
        local rotationArray = {}
        for k, rotationStr in ipairs(rotationStrArray) do
            local rotationNumArray = string.split(rotationStr, ",")
            local monsterRotation = Vector2(tonumber(rotationNumArray[1]), tonumber(rotationNumArray[2]))
            rotationArray[#rotationArray + 1] = monsterRotation
        end

        return rotationArray
    else
        return nil
    end
end

function LevelMonsterRefreshParam:_ParseCheckBlockArray(checkBlockStrArray)
    local checkBlockArray = {}
    if checkBlockStrArray then
        for k, str in ipairs(checkBlockStrArray) do
            local checkBlock = tonumber(str)
            checkBlockArray[#checkBlockArray + 1] = checkBlock
        end
    end

    return checkBlockArray
end

function LevelMonsterRefreshParam:GetExceptionType()
    return self._exceptionType
end

function LevelMonsterRefreshParam:_ParseExceptionData(posStrArray)
    if not posStrArray then
        return {}
    end
    local posVec2Array = {}
    for index, posStr in ipairs(posStrArray) do
        local posNumArray = string.split(posStr, ",")
        posVec2Array[index] = {}
        local count = #posNumArray
        local i = 1
        while i < count do
            local x = posNumArray[i]
            local type = MonsterPosType.Position
            if x == "F" then
                i = i + 1
                type = MonsterPosType.OffSet
            end
            local pos = Vector2(tonumber(posNumArray[i]), tonumber(posNumArray[i + 1]))
            local tCount = table.count(posVec2Array[index])
            posVec2Array[index][tCount + 1] = { type, pos }
            i = i + 2
        end
    end
    return posVec2Array
end

function LevelMonsterRefreshParam:GetExceptionData()
    return self._exceptionData
end

function LevelMonsterRefreshParam:GetRefreshPosOptions()
    return self._refreshPosOptions
end

---多面棋盘
function LevelMonsterRefreshParam:SetBoardIndex(boardIndex)
    self._boardIndex = boardIndex
end

function LevelMonsterRefreshParam:GetBoardIndex()
    return self._boardIndex
end

function LevelMonsterRefreshParam:_RandomMonsterID(monsterGroup, weightGroup)
    if #monsterGroup ~= #weightGroup or #monsterGroup < 1 then
        return
    end

    local totalWeight = 0
    for _, w in ipairs(weightGroup) do
        totalWeight = totalWeight + w
    end

    ---@type RandomServiceLogic
    local randomSvc = self._world:GetService("RandomLogic")
    local rand = randomSvc:LogicRand()

    local curWeight = rand * totalWeight
    for i, w in ipairs(weightGroup) do
        curWeight = curWeight - w
        if curWeight <= 0 then
            return monsterGroup[i]
        end
    end
end

function LevelMonsterRefreshParam:_ParseRandomMonsterID(monsterList, weightList)
    local monsterIDList = {}
    if #monsterList ~= #weightList then
        return monsterIDList
    end

    for i = 1, #monsterList do
        local monsterGroup = monsterList[i]
        local weightGroup = weightList[i]

        local monsterID = self:_RandomMonsterID(monsterGroup, weightGroup)
        if monsterID then
            table.insert(monsterIDList, monsterID)
        end
    end

    return monsterIDList
end
