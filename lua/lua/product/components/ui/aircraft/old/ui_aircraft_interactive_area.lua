---房间内的交互区对象
---@class UIAircraftInteractiveArea:Object 
_class("UIAircraftInteractiveArea", Object)
UIAircraftInteractiveArea = UIAircraftInteractiveArea

---@param areaGameObject UnityEngine.GameObject
function UIAircraftInteractiveArea:Constructor(areaGameObject)
    ---@type table<number, UIAircraftInteractivePoint> 交互点列表
    self._pointList = {}
    ---@type table<number, boolean> 交互点占据情况
    self._pointOccupyList = {}
    ---@type number 被占据的交互点数量
    self._occupiedPointCount = 0
    ---@type boolean 是否全部交互点都被占据
    self._allOccupied = false
    
    local pointsRoot = areaGameObject.transform:Find("Points")
    if not pointsRoot or pointsRoot.childCount == 0 then
        self._allOccupied = true
        return
    end

    local targetRoot = areaGameObject.transform:Find("TargetPoints")
    local targetPosList = {}
    if targetRoot  then
        for i = 0, targetRoot.childCount - 1 do
            targetPosList[#targetPosList + 1] = targetRoot:GetChild(i).position
        end
    end

    local pointCount = pointsRoot.childCount
    for i = 0, pointCount - 1 do
        local pointPos = pointsRoot:GetChild(i).position
        local closetIndex = 0
        local closetDistance = 0
        for j = 1, #targetPosList do
            if j == 1 then
                closetIndex = j
                closetDistance = Vector3.Distance(pointPos, targetPosList[j])
            else
                local distance = Vector3.Distance(pointPos, targetPosList[j])
                if distance < closetDistance then
                    closetIndex = j
                    closetDistance = distance
                end
            end
        end

        local faceIDStrList = string.split(pointsRoot:GetChild(i).gameObject.name, "|")
        local faceIDList = {}
        for i = 1, #faceIDStrList do
            faceIDList[i] = tonumber(faceIDStrList[i])
        end

        local point = nil
        if closetIndex > 0 then
            point = UIAircraftInteractivePoint:New(pointPos, targetPosList[closetIndex], faceIDList)
        else
            point = UIAircraftInteractivePoint:New(pointPos, nil, faceIDList)
        end
        local index = #self._pointList + 1
        point:SetIndex(index)
        self._pointList[index] = point
    end
end

function UIAircraftInteractiveArea:IsFull()
    return self._allOccupied
end

function UIAircraftInteractiveArea:GetAndOccupyAvailablePoint()
    local indexList = {}
    for i = 1, #self._pointList do
        if not self._pointOccupyList[i] then
            indexList[#indexList + 1] = i
        end
    end
    local res = math.random(1, #indexList)
    local index = indexList[res]
    self._pointOccupyList[index] = true
    if #indexList == 1 then
        self._allOccupied = true
    end
    return self._pointList[index]
end

function UIAircraftInteractiveArea:ReleasePoint(index)
    self._pointOccupyList[index] = false
    self._allOccupied = false
end