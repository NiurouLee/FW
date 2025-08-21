--[[------------------------------------------------------------------------------------------
    MonsterWalkResult : 怪物行走单个格子的结果
]]--------------------------------------------------------------------------------------------

---@class WalkTriggerTrapResult: Object
_class( "WalkTriggerTrapResult", Object )
WalkTriggerTrapResult = WalkTriggerTrapResult
function WalkTriggerTrapResult:Constructor()
    self._trapEntityID = -1
    ---@type AISkillResult
    self._skillResult = nil
end

function WalkTriggerTrapResult:SetTrapEntityID(id)
    self._trapEntityID = id
end

function WalkTriggerTrapResult:GetTrapEntityID()
    return self._trapEntityID
end

function WalkTriggerTrapResult:SetTrapResult(res)
    self._skillResult = res
end

function WalkTriggerTrapResult:GetTrapResult()
    return self._skillResult
end


_class( "MonsterWalkResult", Object )
---@class MonsterWalkResult: Object
MonsterWalkResult = MonsterWalkResult

function MonsterWalkResult:Constructor()
    self._walkPos = nil

    self._trapResultList = {}

    ---走过的格子
    self._passedPosList = {}
end

function MonsterWalkResult:GetWalkPos()
    return self._walkPos
end

function MonsterWalkResult:SetWalkPos(pos)
    self._walkPos = pos
end

function MonsterWalkResult:GetWalkTrapResultList()
    return self._trapResultList
end

function MonsterWalkResult:AddWalkTrap(trapEntityID,skillResult)
    ---@type WalkTriggerTrapResult
    local res = WalkTriggerTrapResult:New()
    res:SetTrapEntityID(trapEntityID)
    res:SetTrapResult(skillResult)

    self._trapResultList[#self._trapResultList + 1] = res
end

function MonsterWalkResult:SetWalkPassedGrid(grids)
    self._passedPosList = grids
end

function MonsterWalkResult:GetWalkPassedGrid()
    return self._passedPosList
end