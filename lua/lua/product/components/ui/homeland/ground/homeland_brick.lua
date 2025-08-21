---@class HomelandBrick:Object
_class("HomelandBrick", Object)
HomelandBrick = HomelandBrick

function HomelandBrick:Constructor(build, forward, after, left, right)
    self._build = build
    ---@type HomelandBrickEdge
    self._forwardEdge = forward
    ---@type HomelandBrickEdge
    self._afterEdge = after
    ---@type HomelandBrickEdge
    self._leftEdge = left
    ---@type HomelandBrickEdge
    self._rightEdig = right
end

function HomelandBrick:GetEdge(direction)
    if direction == HomelandBrickDirection.Forward then
        return self._forwardEdge
    end
    if direction == HomelandBrickDirection.AFTER then
        return self._afterEdge
    end
    if direction == HomelandBrickDirection.LEFT then
        return self._leftEdge
    end
    if direction == HomelandBrickDirection.RIGHT then
        return self._rightEdig
    end 
end

function HomelandBrick:Destroy()
end

function HomelandBrick:SetEdgeVisible(direction, status)
    if direction == HomelandBrickDirection.Forward then
        self._forwardEdge:SetVisible(status)
    end
    if direction == HomelandBrickDirection.AFTER then
        self._afterEdge:SetVisible(status)
    end
    if direction == HomelandBrickDirection.LEFT then
        self._leftEdge:SetVisible(status)
    end
    if direction == HomelandBrickDirection.RIGHT then
        self._rightEdig:SetVisible(status)
    end 
end

function HomelandBrick:GetBuild()
    return self._build
end

function HomelandBrick:Equal(brick)
    return self == brick or brick:GetBuild() == self._build
end

function HomelandBrick:GetAngleY()
    return self._build.transform.eulerAngles.y
end

function HomelandBrick:GetPosition()
    return self._build.transform.position
end

function HomelandBrick:GetDirectionPosition(direction)
    local pos
    if direction == HomelandBrickDirection.Forward then
        pos = self._build.transform:TransformPoint(Vector3(0, 0, self:GetHeight()))
    elseif direction == HomelandBrickDirection.AFTER then
        pos = self._build.transform:TransformPoint(Vector3(0, 0, -self:GetHeight()))
    elseif direction == HomelandBrickDirection.LEFT then
        pos = self._build.transform:TransformPoint(Vector3(-self:GetWidth(), 0, 0))
    elseif direction == HomelandBrickDirection.RIGHT then
        pos = self._build.transform:TransformPoint(Vector3(self:GetWidth(), 0, 0))
    end
    return Vector2(pos.x, pos.z)
end

function HomelandBrick:GetWidth()
    return 1
end

function HomelandBrick:GetHeight()
    return 1
end

---@param brick HomelandBrick
function HomelandBrick:IsSameType(brick)
    return true
end

--[[
    return 是否连通, 自己连通的边, 传入砖块的连通的边
]]
---@param brick HomelandBrick
function HomelandBrick:IsConnect(brick)
    --判断是否是同一类型的砖块
    if not self:IsSameType(brick) then
        return false
    end
    --判断角度是否相同
    local angle = brick:GetAngleY()
    local angleDiff = math.abs(angle - self:GetAngleY())
    if self:GetWidth() == self:GetHeight() then
        local int, float = math.modf(angleDiff / 90)
        if float > 0 then
            return false
        end
    else
        local int, float = math.modf(angleDiff / 180)
        if float > 0 then
            return false
        end
    end
    
    local result, firstDirection = self:GetAdjacentEdgeDirection(brick)
    if result then
        local _, secondDirection = brick:GetAdjacentEdgeDirection(self)
        return true, firstDirection, secondDirection
    end
    
    return false
end

---@param brick HomelandBrick
function HomelandBrick:GetAdjacentEdgeDirection(brick)
    local position = brick:GetPosition()
    local pos = Vector2(position.x, position.z)
    --判断四个方向, 前后左右
    local forwardPos = self:GetDirectionPosition(HomelandBrickDirection.Forward)
    if Vector2.Distance(pos, forwardPos) == 0 then
        return true, HomelandBrickDirection.Forward
    end
    local afterPos = self:GetDirectionPosition(HomelandBrickDirection.AFTER)
    if Vector2.Distance(pos, afterPos) == 0 then
        return true, HomelandBrickDirection.AFTER
    end
    local leftPos = self:GetDirectionPosition(HomelandBrickDirection.LEFT)
    if Vector2.Distance(pos, leftPos) == 0 then
        return true, HomelandBrickDirection.LEFT
    end
    local rightPos = self:GetDirectionPosition(HomelandBrickDirection.RIGHT)
    if Vector2.Distance(pos, rightPos) == 0 then
        return true, HomelandBrickDirection.RIGHT
    end
end
