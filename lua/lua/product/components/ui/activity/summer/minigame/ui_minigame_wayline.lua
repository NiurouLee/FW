---@class UIMiniGameWayLine : UICustomWidget
_class("UIMiniGameWayLine", UICustomWidget)
UIMiniGameWayLine = UIMiniGameWayLine
function UIMiniGameWayLine:OnShow(uiParams)
    self._lineImg = {
        [true] = "xiahuo_game_xian1",
        [false] = "xiahuo_game_xian2",
    }
    self:_GetComponents()
end
function UIMiniGameWayLine:_GetComponents()
    --generated--
    ---@type UnityEngine.UI.Image
    self._line = self:GetUIComponent("Image", "Line")
    self._atlas = self:GetAsset("UISummer.spriteatlas", LoadType.SpriteAtlas)
    --generated end--
end
function UIMiniGameWayLine:SetData(state)
    self._line.sprite = self._atlas:GetSprite(self._lineImg[state])
end
