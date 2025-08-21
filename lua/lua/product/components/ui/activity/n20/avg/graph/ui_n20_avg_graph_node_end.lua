---@class UIN20AVGGraphNodeEnd:UIN20AVGGraphNodeBase
_class("UIN20AVGGraphNodeEnd", UIN20AVGGraphNodeBase)
UIN20AVGGraphNodeEnd = UIN20AVGGraphNodeEnd

function UIN20AVGGraphNodeEnd:OnHide()
    self.imgIcon:DestoryLastImage()
end
---@overload
function UIN20AVGGraphNodeEnd:InitComponent()
    ---@type RawImageLoader
    self.imgIcon = self:GetUIComponent("RawImageLoader", "imgIcon")
    ---@type UILocalizationText
    self.txtName = self:GetUIComponent("UILocalizationText", "txtName")
end
---@overload
function UIN20AVGGraphNodeEnd:FlushName()
    self.txtName:SetText(self.node.title)
end
---@overload
function UIN20AVGGraphNodeEnd:FlushState()
    local state = self.node:State()
    if state == AVGStoryNodeState.CanPlay then
        self.imgIcon:LoadImage(self.node.cgCanPlay)
    elseif state == AVGStoryNodeState.Complete then
        self.imgIcon:LoadImage(self.node.cg)
    else
        Log.warn("### invalid AVGStoryNodeState:", state)
    end
end
