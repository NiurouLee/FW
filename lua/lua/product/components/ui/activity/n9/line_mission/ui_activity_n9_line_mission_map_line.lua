---@class UIActivityN9LineMissionMapLine:UICustomWidget
_class("UIActivityN9LineMissionMapLine", UICustomWidget)
UIActivityN9LineMissionMapLine = UIActivityN9LineMissionMapLine

function UIActivityN9LineMissionMapLine:OnShow()
    ---@type UnityEngine.RectTransform
    self._rect = self:GetUIComponent("RectTransform", "shape")
end

function UIActivityN9LineMissionMapLine:OnHide()
end

function UIActivityN9LineMissionMapLine:Flush(from, to)
    local dis = Vector2.Distance(from, to)
    self._rect.sizeDelta = Vector2(dis, self._rect.sizeDelta.y)
    self._rect.anchoredPosition = from
    local v = to - from
    self._rect.localRotation = Quaternion.FromToRotation(Vector3.right, Vector3(v.x, v.y, 0))
end
