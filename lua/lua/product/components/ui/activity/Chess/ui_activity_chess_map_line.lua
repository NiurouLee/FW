---@class UIN15ChessMapLine:UICustomWidget
_class("UIN15ChessMapLine", UICustomWidget)
UIN15ChessMapLine = UIN15ChessMapLine

-- OnShow
function UIN15ChessMapLine:OnShow()
    ---@type UnityEngine.RectTransform
    self._lineRect = self:GetUIComponent("RectTransform", "UIN15ChessMapLine")
    ---@type UnityEngine.RectTransform
    self._rect = self:GetUIComponent("RectTransform", "shape")
end

-- 刷新
function UIN15ChessMapLine:Flush(from, to)
    self._lineRect.anchorMax = Vector2(0.5, 0)
    self._lineRect.anchorMin = Vector2(0.5, 0)
    self._lineRect.pivot = Vector2(0, 0.5)
    self._lineRect.sizeDelta = Vector2.zero
    local dis = Vector2.Distance(from, to)
    self._rect.sizeDelta = Vector2(dis, self._rect.sizeDelta.y)
    self._rect.anchoredPosition = from
    local v = to - from
    self._rect.localRotation = Quaternion.FromToRotation(Vector3.right, Vector3(v.x, v.y, 0))
end
