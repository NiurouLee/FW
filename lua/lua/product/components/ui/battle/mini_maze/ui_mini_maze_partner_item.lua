---@class UIMiniMazePartnerItem : UICustomWidget
_class("UIMiniMazePartnerItem", UICustomWidget)
UIMiniMazePartnerItem = UIMiniMazePartnerItem
function UIMiniMazePartnerItem:Constructor()
    ---@type Pet
    self._heartItemInfo = nil
    self._heartItemData = nil
    self._maxStarLevel = 6
    self._index = 0
    self._slotId = 0
    self._height = 0
    self._callBack = nil

    --刻度对应血量
    self._dialLine2Hp = Cfg.cfg_global["UIWidgetBattlePet_dialLine2Hp"].IntValue or 200
    self._bigDiaLine = Cfg.cfg_global["UIWidgetBattlePet_bigDiaLine"].IntValue or 5
end

function UIMiniMazePartnerItem:OnShow()
    self._rawimage = self:GetUIComponent("RawImageLoader", "drawIcon")
    self._leaderGO = self:GetGameObject("leaderIcon")
    self._lvValueText = self:GetUIComponent("UILocalizationText", "lvValue")
    ---@type UILocalizationText
    self._nameText = self:GetUIComponent("UILocalizationText", "name")
    self._imgLogo = self:GetUIComponent("RawImageLoader", "imgLogo")
    ---@type UnityEngine.UI.Image
    self._attrMain = self:GetUIComponent("Image", "attrMain")
    ---@type UnityEngine.UI.Image
    self._attrVice = self:GetUIComponent("Image", "attrVice")

    --探索能量
    self._power = self:GetGameObject("power")
    self._powerValue = self:GetUIComponent("UILocalizationText", "powerValue")
    --觉醒
    self._imgGrade = self:GetUIComponent("Image", "imgGrade")

    self._uiAtlas = self:GetAsset("UIAwake.spriteatlas", LoadType.SpriteAtlas)
    ---@type PetModule
    self._petModule = GameGlobal.GameLogic():GetModule(PetModule)
    -- 新手引导
    self.selfRect = self:GetGameObject().transform:GetComponent("RectTransform")
    self._guideWarnGO = self:GetGameObject("guidewarn")
    self._guideWarnGO:SetActive(false)
    self._guideWarnImage = self:GetUIComponent("Image", "guidewarn")
    self._guideWarnRect = self:GetUIComponent("RectTransform", "guidewarn")
    self._guideTxt1Rect = self:GetUIComponent("RectTransform", "guidetxt1")
    self._guideTxt2Rect = self:GetUIComponent("RectTransform", "guidetxt2")
    self._guideTxt1 = self:GetUIComponent("UILocalizationText", "guidetxt1")
    self._guideTxt2 = self:GetUIComponent("UILocalizationText", "guidetxt2")
    self._guideTxt1:SetText(StringTable.Get("str_guide_warn_level_speed"))
    self._guideTxt2:SetText(StringTable.Get("str_guide_warn_level_speed"))
    ---@type UnityEngine.RectTransform
    self._elementBg = self:GetUIComponent("RectTransform", "element")
    self._elementPos = self:GetUIComponent("RectTransform", "elementPos")

    self._detailBtnRect = self:GetGameObject("detailBtnRect")
    self._imgPetDetail = self:GetGameObject("imgPetDetail")
    self._imgPetDetail:SetActive(false)

    self._hp = self:GetGameObject("hp")
    self._hpvalue = self:GetUIComponent("Image", "hpvalue")
    self._hpUhp = self:GetUIComponent("UILocalizationText", "hpUhp")
    self._hpChp = self:GetUIComponent("UILocalizationText", "hpChp")
    self._hpvalueRect = self:GetUIComponent("RectTransform", "dialLines")
    self._dialLines = self:GetUIComponent("UISelectObjectPath", "dialLines")

    -- self._selectAreaGO = self:GetGameObject("SelectArea")
    -- self._notSelectGO = self:GetGameObject("NotSelect")
    -- self._selectGO = self:GetGameObject("Select")

    ---@type UnityEngine.U2D.SpriteAtlas
    self.atlasProperty = self:GetAsset("Property.spriteatlas", LoadType.SpriteAtlas)
    self:AttachEvent(GameEventType.PetDataChangeEvent, self.SetDataPet)
    self:AttachEvent(GameEventType.OnPetSkinChange, self.SetDataPet)
end

function UIMiniMazePartnerItem:OnHide()
    self._hide = true
    self._heartItemInfo = nil
    self._heartItemData = nil
    self._callBack = nil
    self._rawimage = nil
    self._lvValueText = nil
    self._nameText = nil
    self._attrMain = nil
    self._attrVice = nil
    self._imgGrade = nil
    self._uiAtlas = nil
    self:DetachEvent(GameEventType.PetDataChangeEvent, self.SetDataPet)
end

function UIMiniMazePartnerItem:SetData(partnerID, index, callBack, slotId)
    self._callBack = callBack
    self._partnerID = partnerID
    self._index = index
    self._slotId = slotId
    self:MakeTmpMatchPet()
    self:SetDataPet()
end
function UIMiniMazePartnerItem:MakeTmpMatchPet()
    local partnerCfg = Cfg.cfg_mini_maze_partner_info[self._partnerID]
    if not partnerCfg then
        return
    end
    local partnerAttrCfg = nil
    local cfgGroup = Cfg.cfg_component_bloodsucker_pet_attribute{ComponentID = UIN25VampireUtil.GetComponentConfigId(), PetId = partnerCfg.PetID}
    if cfgGroup and #cfgGroup > 0 then
        partnerAttrCfg = cfgGroup[1]
    end
    if not partnerAttrCfg then
        return
    end
    local petInfo = MatchPetInfo:New()
    petInfo.pet_pstid = 0
    petInfo.pet_power = -1 --初始能量
    petInfo.template_id = partnerCfg.PetID --配置id
    petInfo.level = 1
    petInfo.grade = partnerAttrCfg.Grade
    petInfo.awakening = partnerAttrCfg.Awakening
    petInfo.attack = partnerAttrCfg.Attack
    petInfo.defense = partnerAttrCfg.Def
    petInfo.max_hp = partnerAttrCfg.Hp
    petInfo.cur_hp = partnerAttrCfg.Hp
    petInfo.equip_lv = partnerAttrCfg.Equip
    petInfo.affinity_level = 1
    petInfo.after_damage = 0 --伤害后处理系数
    petInfo.team_slot = 6 --宝宝在星灵队伍中的位置

    -- petInfo.level = partnerCfg.Level or 1 --等级
    -- petInfo.grade = partnerCfg.GradeLevel or 0 --觉醒
    -- petInfo.awakening = partnerCfg.AwakenLevel or 0--突破
    -- petInfo.affinity_level = partnerCfg.AffinityLevel or 1 --亲密度等级
    -- petInfo.attack = partnerCfg.Attack or 0 --攻击力
    -- petInfo.defense = partnerCfg.Defence or 0 --防御力
    -- petInfo.max_hp = partnerCfg.Health or 0 --血量上限
    -- petInfo.cur_hp = partnerCfg.Health or 0 -- 当前血量
    -- petInfo.equip_lv = partnerCfg.EquipLevel or 0 --装备等级
    -- petInfo.after_damage = 0 --伤害后处理系数
    -- petInfo.team_slot = 6 --宝宝在星灵队伍中的位置

    petInfo.m_nHelpPetKey = 0 --助战标识
    ------------------
    ---@type MatchPet
    self._matchPet = MatchPet:New(petInfo)
end
---@type Pet
function UIMiniMazePartnerItem:SetDataPet()
    ---@type MatchPet
    local petInfo = self._matchPet
    if petInfo == nil then
        return
    end
    self._heartItemInfo = petInfo
    ---@type RawImageLoader
    self._rawimage:LoadImage(petInfo:GetPetTeamBody(PetSkinEffectPath.CARD_TEAM))
    self:ShowName()
    self:ShowLevel()
    self:ShowLogo()
    self:ShowElement()
    self:ShowStarLevel()
    self:ShowLeaderMask()
    --self:GetMazePower()
    --self:GetLostLandRecommend()
    --self:GetSwitchCount()
    self:ShowGrade()
    --self:CheckGuideWarn()
    self:ShowPetDetailBtn()
    --self:ShowUIDiff()
end
function UIMiniMazePartnerItem:ShowPetDetailBtn()
    self._detailBtnRect:SetActive(true)
end

function UIMiniMazePartnerItem:ShowName()
    if self._heartItemInfo == nil then
        return
    end
    self._nameText:SetText(StringTable.Get(self._heartItemInfo:GetPetName()))
end

function UIMiniMazePartnerItem:ShowLevel()
    local petLevel = self._heartItemInfo:GetPetLevel()
    self._lvValueText:SetText(StringTable.Get("str_common_LV_dot_en") .. " " .. petLevel)
end

function UIMiniMazePartnerItem:ShowLogo()
    if self._heartItemInfo == nil then
        return
    end
    self._imgLogo:LoadImage(self._heartItemInfo:GetPetLogo())
end

function UIMiniMazePartnerItem:ShowElement()
    if self._heartItemInfo == nil then
        return
    end
    local elemPosY = 0
    self._elementPos.anchoredPosition = Vector2(0, elemPosY)
    local cfg_pet_element = Cfg.cfg_pet_element {}
    if cfg_pet_element then
        local firstElement = self._heartItemInfo:GetPetFirstElement()
        if firstElement then
            self._attrMain.gameObject:SetActive(true)
            self._attrMain.sprite =
                self.atlasProperty:GetSprite(
                UIPropertyHelper:GetInstance():GetColorBlindSprite(cfg_pet_element[firstElement].Icon)
            )
        else
            self._attrMain.gameObject:SetActive(false)
        end
        local secondElement = self._heartItemInfo:GetPetSecondElement()
        if secondElement then
            self._elementBg.sizeDelta = Vector2(116, 62)
            self._attrVice.gameObject:SetActive(true)
            self._attrVice.sprite =
                self.atlasProperty:GetSprite(
                UIPropertyHelper:GetInstance():GetColorBlindSprite(cfg_pet_element[secondElement].Icon)
            )
        else
            self._elementBg.sizeDelta = Vector2(74, 62)
            self._attrVice.gameObject:SetActive(false)
        end
    end
end

function UIMiniMazePartnerItem:ShowStarLevel()
    if self._heartItemInfo == nil then
        return
    end
    local petStar = self._heartItemInfo:GetPetStar()
    for starLevel = 1, self._maxStarLevel do
        local starGo = self:GetGameObject("star" .. starLevel)
        if starLevel <= petStar then
            starGo:SetActive(true)
        else
            starGo:SetActive(false)
        end
    end
end

function UIMiniMazePartnerItem:ShowLeaderMask()
    self._leaderGO:SetActive(false)
end

function UIMiniMazePartnerItem:ShowGrade()
    local petId = self._heartItemInfo:GetTemplateID()
    local petGradeLevel = self._heartItemInfo:GetPetGrade()
    self._imgGrade.sprite = self._uiAtlas:GetSprite(UIPetModule.GetAwakeSpriteName(petId, petGradeLevel))
end

function UIMiniMazePartnerItem:BtnDetailOnClick()
    GameGlobal.TaskManager():StartTask(
        function(TT)
            self._imgPetDetail:SetActive(true)
            YIELD(TT, 200)
            if self and self._imgPetDetail then
                self._imgPetDetail:SetActive(false)
            end
        end,
        self
    )
    local petId = self._matchPet:GetTemplateID()
    --self:ShowDialog("UISpiritDetailGroupController", petId, false)
    local customPetData = UICustomPetData:New()
    customPetData:SetPetId(petId)
    customPetData:SetAttack(self._matchPet:GetPetAttack())
    customPetData:SetHP(self._matchPet:GetPetHealth())
    customPetData:SetDef(self._matchPet:GetPetDefence())
    customPetData:SetAwakeing(self._matchPet:GetPetAwakening())
    customPetData:SetGrade(self._matchPet:GetPetGrade())
    customPetData:SetEquip(self._matchPet:GetEquipLv())

    customPetData:SetShowBtnStatus(true)
    customPetData:SetBtnInfoCallback(
        function()
            GameGlobal.UIStateManager():ShowDialog("UIN25VampireTips")
        end
    )
    customPetData:SetBtnInfoName("N25_mcwf_btn6")
    customPetData:SetHideHomeBtn(true)
    UIShopPetDetailController.ShowCustomPetDetail(customPetData)
end
function UIMiniMazePartnerItem:BgOnClick()
    if self._callBack then
        self._callBack()
    end
end
-- function UIMiniMazePartnerItem:SetSelected(bSelect)
--     self._selectGO:SetActive(bSelect)
--     self._notSelectGO:SetActive(not bSelect)
-- end