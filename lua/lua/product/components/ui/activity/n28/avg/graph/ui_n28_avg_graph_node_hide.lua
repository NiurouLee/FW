---@class UIN28AVGGraphNodeHide:UIN28AVGGraphNodeBase
_class("UIN28AVGGraphNodeHide", UIN28AVGGraphNodeBase)
UIN28AVGGraphNodeHide = UIN28AVGGraphNodeHide

---@overload
function UIN28AVGGraphNodeHide:InitComponent()
    UIN28AVGGraphNodeHide.super.InitComponent(self)
    self.new = self:GetGameObject("new")
    self.glowEff = self:GetGameObject("glowEff")
    self.new:SetActive(false)
    self.lock = self:GetGameObject("lock")
    self.lock:SetActive(false)
end

---@overload
function UIN28AVGGraphNodeHide:FlushName()
    self.txtName:SetText(self.node.title)
    self.txtName1:SetText(self.node.title)
end
---刷新隐藏结点的New
---@overload
function UIN28AVGGraphNodeHide:FlushNew()
    local isNew = self.node:IsHideNew()
    self.new:SetActive(isNew)
    self.glowEff:SetActive(isNew)
end

--region Anim
function UIN28AVGGraphNodeHide:PlayAnim(TT)
    local key = "UIN28AVGGraphNodeHidePlayAnim"
    self:Lock(key)
    local go = self:GetGameObject()
    ---@type UnityEngine.Animation
    local anim = go:GetComponent("Animation")
    YIELD(TT, 100)
    anim:Play("uieff_UIN28AVGGraphNodeHide_lock")
    YIELD(TT, 600)
    --anim:Play("uieff_UIN28AVGGraphNodeHide_dian")
    self:FlushNew()
    self:UnLock(key)
end
--endregion
