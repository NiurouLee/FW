----------------------------------------------------------------
_class("PreviewHitbackSystem_Render", Object)
---@class PreviewHitbackSystem_Render:Object
PreviewHitbackSystem_Render = PreviewHitbackSystem_Render

function PreviewHitbackSystem_Render:Constructor(world)
    ---@type MainWorld
    self._world = world
    ---@type TimeService
    self._timeService = self._world:GetService("Time")
    self._group = world:GetGroup(world.BW_WEMatchers.PreviewHitback)
end

function PreviewHitbackSystem_Render:Execute()
    self._group:HandleForeach(self, self.UpdateHitback)
end

---@param e Entity
function PreviewHitbackSystem_Render:UpdateHitback(e)
    ---@type HitbackComponent
    local hitbackCmpt = e:Hitback()
    if not hitbackCmpt then
        Log.debug("[HitBack] 发现非法的击退数据", e:GetID())
        return
    end

    if hitbackCmpt:IsHitbackEnd() then
        return
    end

    ---@type Vector2
    local v2Begin = hitbackCmpt:GetHitbackStartPos()
    ---@type Vector2
    local v2Dest = hitbackCmpt:GetHitbackTargetPos()
    ---@type number
    local fSpeed = hitbackCmpt:GetHitbackSpeed()

    if v2Begin == v2Dest then
        Log.debug(self._className, "eid:", e:GetID(), " - 原地击退")
        hitbackCmpt:SetHitbackEnd()
        return
    end

    local cLocation = e:Location()
    if not cLocation then
        local v2TargetPos = v2Dest:Clone()
        hitbackCmpt:SetHitbackEnd()
        return
    end

    ---@type BoardServiceRender
    local boardServiceRender = self._world:GetService("BoardRender")
    local position = boardServiceRender:GetRealEntityGridPos(e)
    local distance = Vector2.Distance(v2Dest, v2Begin)
    local fullTime = distance / fSpeed * 1000

    local deltaTimeMS = self._timeService:GetDeltaTimeMs()
    hitbackCmpt:AppendDeltaTime(deltaTimeMS)
    local time = hitbackCmpt:GetDeltaTime()
    local fProgress = time / fullTime
    local currentPos = Vector2.Lerp(v2Begin, v2Dest, fProgress)
    e:SetLocation(currentPos)
    if fProgress >= 1 then
        hitbackCmpt:SetHitbackEnd()
    end
end
