---@class UIMapPathItem:UICustomWidget
_class("UIMapPathItem", UICustomWidget)
UIMapPathItem = UIMapPathItem

function UIMapPathItem:OnShow()
    ---@type UnityEngine.RectTransform
    self._rect = self:GetGameObject():GetComponent("RectTransform")
    local vec0_5 = Vector2(0.5, 0.5)
    self._rect.anchorMax = vec0_5
    self._rect.anchorMin = vec0_5
    ---@type UnityEngine.RectTransform
    self._rectRoot = self:GetGameObject("shape"):GetComponent("RectTransform")
    ---@type UnityEngine.GameObject
    self._line = self:GetGameObject("line")
    self._line:SetActive(false)
    ---@type UnityEngine.GameObject
    self._shadow = self:GetGameObject("shadow")
    self._shadow:SetActive(false)
    self._sNode = nil
    self._eNode = nil
end

function UIMapPathItem:OnHide()
end

---@param sNode DiscoveryNode 起点
---@param eNode DiscoveryNode 终点
function UIMapPathItem:Flush(sNode, eNode, isShadow)
    self._line:SetActive(not isShadow)
    self._shadow:SetActive(isShadow)
    if not sNode then
        return
    end
    if not eNode then
        return
    end
    self._sNode = sNode
    self._eNode = eNode
    local posS, posE = sNode.pos:Clone(), eNode.pos:Clone()

    if isShadow then
        local offsetY = 30
        posS.y = posS.y - offsetY
        posE.y = posE.y - offsetY
    end

    local dis = Vector2.Distance(posS, posE)
    self._rectRoot.sizeDelta = Vector2(dis, self._rectRoot.sizeDelta.y)
    self._rect.anchoredPosition = posS
    local v = posE - posS
    self._rect.localRotation = Quaternion.FromToRotation(Vector3.right, Vector3(v.x, v.y, 0))

    self:Animation()
end

function UIMapPathItem:Animation()
    if self._eNode:State() == DiscoveryStageState.CanPlay and self._eNode:IsFirstShow() then
        local targetWidth = self._rectRoot.sizeDelta.x
        self._rectRoot.sizeDelta = Vector2(0, self._rectRoot.sizeDelta.y)
        self._rectRoot:DOSizeDelta(Vector2(targetWidth, self._rectRoot.sizeDelta.y), 0.8)
    end
end
