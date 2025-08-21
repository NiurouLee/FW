---@class UIN20AVGGraphNodeHide:UIN20AVGGraphNodeBase
_class("UIN20AVGGraphNodeHide", UIN20AVGGraphNodeBase)
UIN20AVGGraphNodeHide = UIN20AVGGraphNodeHide

---@overload
function UIN20AVGGraphNodeHide:InitComponent()
    UIN20AVGGraphNodeHide.super.InitComponent(self)
    self.new = self:GetGameObject("new")
    self.new:SetActive(false)
    self.lock = self:GetGameObject("lock")
    self.lock:SetActive(false)
end

---@overload
function UIN20AVGGraphNodeHide:FlushName()
    self.txtName:SetText(self.node.title)
end
---刷新隐藏结点的New
---@overload
function UIN20AVGGraphNodeHide:FlushNew()
    local isNew = self.node:IsHideNew()
    self.new:SetActive(isNew)
end

--region Anim
function UIN20AVGGraphNodeHide:PlayAnim(TT)
    local key = "UIN20AVGGraphNodeHidePlayAnim"
    self:Lock(key)
    local go = self:GetGameObject()
    ---@type UnityEngine.Animation
    local anim = go:GetComponent("Animation")
    anim:Play("uieff_UIN20AVGGraphNodeHide_jiesuo")
    YIELD(TT, 667)
    self:FlushNew()
    self:UnLock(key)
end
--endregion
