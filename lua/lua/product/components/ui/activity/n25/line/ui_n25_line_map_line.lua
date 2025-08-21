---@class UIN25LineMapLine:UICustomWidget
_class("UIN25LineMapLine", UICustomWidget)
UIN25LineMapLine = UIN25LineMapLine

function UIN25LineMapLine:OnShow()
    ---@type UnityEngine.RectTransform
    self._rect = self:GetUIComponent("RectTransform", "shape")
end

function UIN25LineMapLine:OnHide()
end

function UIN25LineMapLine:Flush(from, to)
    local dis = Vector2.Distance(from, to)
    self._rect.sizeDelta = Vector2(dis, self._rect.sizeDelta.y)
    self._rect.anchoredPosition = from
    local v = to - from
    self._rect.localRotation = Quaternion.FromToRotation(Vector3.right, Vector3(v.x, v.y, 0))
end
