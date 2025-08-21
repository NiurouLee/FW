---@class UIHomeDomitoryMember : UICustomWidget
_class("UIHomeDomitoryMember", UICustomWidget)
UIHomeDomitoryMember = UIHomeDomitoryMember
function UIHomeDomitoryMember:OnShow(uiParams)
    self:InitWidget()
end
function UIHomeDomitoryMember:InitWidget()
    --generated--
    ---@type UILocalizationText
    self.petName = self:GetUIComponent("UILocalizationText", "petName")
    ---@type RawImageLoader
    self.petIcon = self:GetUIComponent("RawImageLoader", "petIcon")
    --generated end--
    self.pet = self:GetGameObject("pet")
    self.add = self:GetGameObject("add")
    self._nickName = self:GetUIComponent("UILocalizationText", "petNickName")
    self._logo = self:GetUIComponent("RawImageLoader", "petLogo")
    self.affinityLoader = self:GetUIComponent("UISelectObjectPath", "affinity")
end
---@param data number 星灵pstid
function UIHomeDomitoryMember:SetData(petpstID, idx, onClick)
    self._index = idx
    self._onClick = onClick
    if petpstID and petpstID ~= 0 then
        self._isEmpty = false
        local pet = self:GetModule(PetModule):GetPet(petpstID)
        self._petID = pet:GetTemplateID()
        -- self._petID = petpstID
        local cfg = Cfg.cfg_pet[self._petID]
        self.petName:SetText(StringTable.Get(cfg.Name))
        self._nickName:SetText(StringTable.Get(cfg.ChinaTag))
        local icon = pet:GetPetTeamBody(PetSkinEffectPath.CARD_TEAM)
        self.petIcon:LoadImage(icon)
        self._logo:LoadImage(cfg.Logo)

        if not self._affinity then
            ---@type UIHomePetAffinityItem
            self._affinity = self.affinityLoader:SpawnObject("UIHomePetAffinityItem")
        end
        self._affinity:SetData(pet)
    else
        self._isEmpty = true
        self._petID = nil
    end
    self.pet:SetActive(not self._isEmpty)
    self.add:SetActive(self._isEmpty)
end
function UIHomeDomitoryMember:areaOnClick(go)
    self._onClick(self._index)
end
