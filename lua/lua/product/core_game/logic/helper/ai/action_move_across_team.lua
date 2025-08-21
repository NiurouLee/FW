--[[-------------------------------------

--]] -------------------------------------
require "action_move_base"
---@class ActionMoveAcrossTeam:ActionMoveBase
_class("ActionMoveAcrossTeam", ActionMoveBase)
ActionMoveAcrossTeam = ActionMoveAcrossTeam

--------------------------------
function ActionMoveAcrossTeam:Constructor()
    self:_Reset()
end
function ActionMoveAcrossTeam:Reset()
    ActionMoveAcrossTeam.super.Reset(self)
    self:_Reset()
end
function ActionMoveAcrossTeam:_Reset()
    self._targetMoveOffsetList = {Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)}
    self._targetPos = nil
end

function ActionMoveAcrossTeam:InitTargetPosList(listPosTarget)
    ---@type Vector2
    local posSelf = self.m_entityOwn:GetGridPosition()

    ---@type AIComponentNew
    local aiCmpt = self.m_entityOwn:AI()
    local remainMobility = aiCmpt:GetMobilityValid()
    if remainMobility <= 0 then
        self._targetPos = posSelf
        return
    end

    local canMoveAndAcrossPosList = {}
    local canAcrossPosList = {}
    local canMovePosList = {}
    local targetPos = listPosTarget[1]

    ---@type BoardServiceLogic
    local boardServiceLogic = self._world:GetService("BoardLogic")
    --找玩家周围的四个点
    for _, pos in ipairs(self._targetMoveOffsetList) do
        --穿越后的点
        local posAcross = targetPos - pos
        if not boardServiceLogic:IsPosBlock(posAcross, BlockFlag.MonsterLand) then
            --穿越前移动的点
            local posMoveAndAcross = targetPos + pos
            --必须移动的点可以走，才能添加穿越点
            if not boardServiceLogic:IsPosBlock(posMoveAndAcross, BlockFlag.MonsterLand) or posMoveAndAcross == posSelf then
                table.insert(canAcrossPosList, posAcross)
                table.insert(canMoveAndAcrossPosList, posMoveAndAcross)
            end
        end

        local posMove = targetPos + pos
        if not boardServiceLogic:IsPosBlock(posMove, BlockFlag.MonsterLand) or posMove == posSelf then
            table.insert(canMovePosList, posMove)
        end
    end

    --不移动就可以穿越，不需要移动
    if table.intable(canAcrossPosList, posSelf) then
        self._targetPos = posSelf
        return
    end

    if table.count(canAcrossPosList) == 0 then
        --如果四个点都不能穿越，就移动到距离玩家最近的点

        if table.count(canMovePosList) == 0 then
            --玩家周围不能穿 但是可以走的点也没有，使用传进来的玩家坐标
            self._targetPos = targetPos
        else
            --虽然不可以穿，但是可以走。对比距离，移动到距离自己最近的点上
            self._targetPos = canMovePosList[1]
            for _, pos in ipairs(canMovePosList) do
                local nearestPosToTargetDis = Vector2.Distance(self._targetPos, posSelf)
                local workPosToTargetDis = Vector2.Distance(pos, posSelf)

                if workPosToTargetDis < nearestPosToTargetDis then
                    self._targetPos = pos
                end
            end
        end
    else
        --如果四个点有空位置，先找可以穿越队伍的

        --对比距离，移动到距离自己最近的点上
        self._targetPos = canMoveAndAcrossPosList[1]
        for _, pos in ipairs(canMoveAndAcrossPosList) do
            local nearestPosToTargetDis = Vector2.Distance(self._targetPos, posSelf)
            local workPosToTargetDis = Vector2.Distance(pos, posSelf)

            if workPosToTargetDis < nearestPosToTargetDis then
                self._targetPos = pos
            end
        end
    end
end

function ActionMoveAcrossTeam:FindNewTargetPos()
    return self._targetPos
end
