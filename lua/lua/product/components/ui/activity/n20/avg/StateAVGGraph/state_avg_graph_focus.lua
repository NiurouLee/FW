---@class StateAVGGraphFocus : StateAVGGraphBase
_class("StateAVGGraphFocus", StateAVGGraphBase)
StateAVGGraphFocus = StateAVGGraphFocus

function StateAVGGraphFocus:OnEnter(TT, ...)
    self.key = "StateAVGGraphFocusOnEnter"
    GameGlobal.UIStateManager():Lock(self.key)
    self:Init()
    self.content = self:GetContent()
    self.nodeId = table.unpack({...})
    AVGLog("------------Focus start------------", self.nodeId)
    local node = self.data:GetNodeById(self.nodeId)
    local endPos = self:GetContentMoveVector(node.pos)
    local duration = Mathf.Lerp(0, 1, (self.content.anchoredPosition - endPos).magnitude / 1000)
    self.content:DOAnchorPos(endPos, duration):OnComplete(
        function()
            if node:IsHide() and node:IsHideNew() then
                self:ChangeState(StateAVGGraph.HideNodeUnlock, self.nodeId)
            else
                self:ChangeState(StateAVGGraph.Init)
            end
        end
    )
end

function StateAVGGraphFocus:OnExit(TT)
    GameGlobal.UIStateManager():UnLock(self.key)
    AVGLog("------------Focus end------------", self.nodeId)
end

function StateAVGGraphFocus:GetContentMoveVector(target)
    local sv = self:GetScrollView()
    local v2SV = Vector2(sv.rect.width, sv.rect.height)
    local endPos = Vector2(v2SV.x * 0.5, 0) - target
    local limitX = self.content.sizeDelta.x - v2SV.x
    local limitY = (self.content.sizeDelta.y - v2SV.y) * 0.5
    endPos.x = Mathf.Clamp(endPos.x, -limitX, 0)
    endPos.y = Mathf.Clamp(endPos.y, -limitY, limitY)
    return endPos
end
