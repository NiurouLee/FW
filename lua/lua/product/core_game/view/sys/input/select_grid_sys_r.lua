--[[------------------------------------------------------------------------------------------
    点选格子system
]] --------------------------------------------------------------------------------------------

---@class SelectGridSystem_Render:UniqueReactiveSystem
_class("SelectGridSystem_Render", UniqueReactiveSystem)
SelectGridSystem_Render = SelectGridSystem_Render

function SelectGridSystem_Render:IsInterested(index, previousComponent, component)
    if (component == nil) then
        return false
    end

    if (not InputComponent:IsInstanceOfType(component)) then
        return false
    end

    if component:IsPreviewActiveSkill() then
        return false
    end

    return true
end

function SelectGridSystem_Render:ExecuteWorld(world)
	self._world = world
    ---@type GridTouchComponent
    local gridTouchComponent = world:GridTouch()
    ---@type InputComponent
    local inputComponent = world:Input()

    local gridTouchState = GridTouchStateID.Invalid
    local boardServiceRender = world:GetService("BoardRender")
    if inputComponent:IsDoubleClick() then
        gridTouchState = self:_CalcDoubleClickPos(inputComponent, boardServiceRender, gridTouchComponent)
        inputComponent:SetTouchEnd(false)
        gridTouchComponent:SetGridTouchStateID(gridTouchState)
        world:SetUniqueComponent(world.BW_UniqueComponentsEnum.GridTouch, gridTouchComponent)
    elseif inputComponent:IsTouchMoving() then
        gridTouchState = self:_CalcMultiDragPos(inputComponent, boardServiceRender, gridTouchComponent)
        inputComponent:SetTouchEnd(false)
        gridTouchComponent:SetGridTouchStateID(gridTouchState)
        world:SetUniqueComponent(world.BW_UniqueComponentsEnum.GridTouch, gridTouchComponent)
    elseif inputComponent:TouchHasBegin() then
        gridTouchState = self:_CalcDragBeginPos(inputComponent, boardServiceRender, gridTouchComponent)

        local lastGridTouchID = gridTouchComponent:GetGridTouchStateID()
        if lastGridTouchID ~= GridTouchStateID.BeginDrag then
            inputComponent:SetTouchEnd(false)
            gridTouchComponent:SetGridTouchStateID(gridTouchState)
            world:SetUniqueComponent(world.BW_UniqueComponentsEnum.GridTouch, gridTouchComponent)
        end
    elseif (inputComponent:TouchEnd()) then
        gridTouchState = self:_CalcDragEndPos(inputComponent, boardServiceRender, gridTouchComponent)
        inputComponent:SetTouchEnd(false)
        gridTouchComponent:SetGridTouchStateID(gridTouchState)
        world:SetUniqueComponent(world.BW_UniqueComponentsEnum.GridTouch, gridTouchComponent)
    end
end

function SelectGridSystem_Render:Filter(world)
    return true
end

---@param boardServiceRender BoardServiceRender
function SelectGridSystem_Render:_CalcDoubleClickPos(inputComponent, boardServiceRender, gridTouchComponent)
    local endPos = inputComponent:GetDoubleClickPosition()
    local gridPos = boardServiceRender:BoardRenderPos2GridPos(endPos)
    gridTouchComponent:SetDoubleClickPos(gridPos)
    local offset = boardServiceRender:BoardGridPosOffset(endPos)
    gridTouchComponent:SetGridTouchOffset(offset)

    inputComponent:SetDoubleClick(false)

    return GridTouchStateID.DoubleClick
end

---计算多个点的拖拽效果
---@param inputComponent InputComponent
---@param boardServiceRender BoardServiceRender
---@param gridTouchComponent GridTouchComponent
function SelectGridSystem_Render:_CalcMultiDragPos(inputComponent, boardServiceRender, gridTouchComponent)
	---@type Vector2
	local lastTouchGridPosBefore = gridTouchComponent:GetLastTouchGridPos()
    ---提取所有的输入点位置
    gridTouchComponent:ClearGridMove()
    ---@type TimeBaseService
    local timeService = self._world:GetService("Time")
    local touchMovePosArray = inputComponent:GetTouchMovePositionArray()
    for _, curTouchPos in ipairs(touchMovePosArray) do
        local gridPos = boardServiceRender:BoardRenderPos2FloatGridPos(curTouchPos)
        local offset = boardServiceRender:BoardGridPosOffset(curTouchPos)

        gridTouchComponent:AddGridMovePosition(gridPos)
        gridTouchComponent:AddGridMoveOffset(offset)
	    gridTouchComponent:SetLastTouchTime(timeService:GetCurrentTimeMs())
    end
    ---@type Vector2
    local lastTouchGridPosBeAfter = gridTouchComponent:GetLastTouchGridPos()
    if not lastTouchGridPosBefore or  lastTouchGridPosBeAfter ~= lastTouchGridPosBefore then
        gridTouchComponent:SetStayTouchGridPos(lastTouchGridPosBeAfter,timeService:GetCurrentTimeMs())
        --Log.fatal("UpdateStayTouch Pos:", tostring(lastTouchGridPosBeAfter),"Time:",timeService:GetCurrentTimeMs())
    end
    return GridTouchStateID.Drag
end

---@param boardServiceRender BoardServiceRender
function SelectGridSystem_Render:_CalcDragBeginPos(inputComponent, boardServiceRender, gridTouchComponent)
    local beginPos = inputComponent:GetTouchBeginPosition()
    local gridPos = boardServiceRender:BoardRenderPos2FloatGridPos(beginPos)
    gridTouchComponent:SetGridTouchBeginPosition(gridPos)
    local offset = boardServiceRender:BoardGridPosOffset(beginPos)
    gridTouchComponent:SetGridTouchOffset(offset)
    return GridTouchStateID.BeginDrag
end

function SelectGridSystem_Render:_CalcDragEndPos(inputComponent, boardServiceRender, gridTouchComponent)
    return GridTouchStateID.EndDrag
end
