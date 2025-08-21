---@class UIWorldBossRecordPet : UICustomWidget
_class("UIWorldBossRecordPet", UICustomWidget)
UIWorldBossRecordPet = UIWorldBossRecordPet
function UIWorldBossRecordPet:Constructor()
    self._petModule = self:GetModule(PetModule)
    self._atlasProperty = self:GetAsset("Property.spriteatlas", LoadType.SpriteAtlas)
    self._cfg = Cfg.cfg_pet_element{}
end
function UIWorldBossRecordPet:OnShow(uiParams)
    self:_GetComponents()
end
function UIWorldBossRecordPet:_GetComponents()
    self._icon = self:GetUIComponent("RawImageLoader", "Icon")
    self._element1 = self:GetUIComponent("Image", "e1")
    self._element2 = self:GetUIComponent("Image", "e2")
end
function UIWorldBossRecordPet:SetData(pstId)
    self._pstId = pstId
    self:_SetUIInfo()
end
function UIWorldBossRecordPet:_SetUIInfo()
    self._data = self._petModule:GetPet(self._pstId)
    if self._data then
        local icon = self._data:GetPetTeamBody(PetSkinEffectPath.CARD_TEAM)
        if icon then
            self._icon:LoadImage(icon)
            self._icon.gameObject:SetActive(true)
        end
        local element1 = self._data:GetPetFirstElement()
        local element2 = self._data:GetPetSecondElement()
        self._element1.gameObject:SetActive(true)
        self._element1.sprite = self._atlasProperty:GetSprite(UIPropertyHelper:GetInstance():GetColorBlindSprite(self._cfg[element1].Icon))
        local haveElement2 = element2 and element2 > 0
        if haveElement2 then
            self._element2.sprite = self._atlasProperty:GetSprite(UIPropertyHelper:GetInstance():GetColorBlindSprite(self._cfg[element2].Icon))
        end
        self._element2.gameObject:SetActive(haveElement2)
    else
        self._icon.gameObject:SetActive(false)
        self._element1.gameObject:SetActive(false)
        self._element2.gameObject:SetActive(false)
    end
end
