---@class UIN7LevelNode : UICustomWidget
_class("UIN7LevelNode", UICustomWidget)
UIN7LevelNode = UIN7LevelNode
function UIN7LevelNode:OnShow(uiParams)
    self:InitWidget()
end
function UIN7LevelNode:InitWidget()
    --generated--
    ---@type UnityEngine.UI.Image
    self.bg = self:GetUIComponent("Image", "bg")
    ---@type UILocalizationText
    self.name = self:GetUIComponent("UILocalizationText", "name")
    self.shadowLabel = self:GetUIComponent("UILocalizationText", "Shadow")
    ---@type CircleOutline
    self._circleOutline = self:GetUIComponent("H3D.UGUI.CircleOutline", "Shadow")
    self.star = self:GetGameObject("star")
    ---@type UnityEngine.UI.Image
    self.mask = self:GetUIComponent("Image", "mask")
    ---@type UnityEngine.UI.Image
    self.lock = self:GetUIComponent("Image", "lock")
    --generated end--
    ---@type UnityEngine.UI.Image
    self.star1 = self:GetUIComponent("Image", "Star1")
    ---@type UnityEngine.UI.Image
    self.star2 = self:GetUIComponent("Image", "Star2")
    ---@type UnityEngine.UI.Image
    self.star3 = self:GetUIComponent("Image", "Star3")

    self._rectTransform = self:GetGameObject():GetComponent("RectTransform")
    self._stars = {
        self.star1,
        self.star2,
        self.star3
    }

    self._atlas = self:GetAsset("UIN7.spriteatlas", LoadType.SpriteAtlas)
    ---@type UnityEngine.UI.Shadow
    self._anim = self:GetGameObject():GetComponent("Animation")
end

---@param passInfo cam_mission_info
function UIN7LevelNode:SetData(lineCfg, passInfo, cb)
    self._missionID = lineCfg.CampaignMissionId
    self._onClick = cb
    self._rectTransform.anchorMax = Vector2(0, 0.5)
    self._rectTransform.anchorMin = Vector2(0, 0.5)
    self._rectTransform.sizeDelta = Vector2.zero
    self._rectTransform.anchoredPosition = Vector2(lineCfg.MapPosX, lineCfg.MapPosY)
    local missionCfg = Cfg.cfg_campaign_mission[self._missionID]
    if not missionCfg then
        Log.exception("cfg_campaign_mission中找不到配置:", self._missionID)
    end

    self.name:SetText(StringTable.Get(missionCfg.Name))
    self.shadowLabel:SetText(StringTable.Get(missionCfg.Name))
    --1是普通关，2是困难关
    local hardParam = 1
    local typeCfg = nil
    if lineCfg.WayPointType == 4 then
        --S关
        typeCfg = UIN7Level.NodeCfg[UIN7Level.SLeval]
    else
        --战斗、剧情、boss
        typeCfg = UIN7Level.NodeCfg[missionCfg.Type]
    end
    local bg = nil
    local mask = typeCfg[hardParam].press
    local lock = typeCfg[hardParam].lock
    local textColor, shadowColor
    if passInfo then
        --已通关
        textColor = typeCfg[hardParam].textColor
        shadowColor = typeCfg[hardParam].textShadow
        local module = self:GetModule(MissionModule)
        local stars = module:ParseStarInfo(passInfo.star)
        bg = typeCfg[hardParam].normal
        for i = 1, 3 do
            local pass = i <= stars
            if pass then
                self._stars[i].sprite = self._atlas:GetSprite(typeCfg[hardParam].passStar)
            else
                self._stars[i].sprite = self._atlas:GetSprite(typeCfg[hardParam].normalStar)
            end
        end
        self.star:SetActive(missionCfg.Type ~= DiscoveryStageType.Plot)
        self.lock.gameObject:SetActive(false)
    else
        --没有通关数据则视为当前关
        textColor = typeCfg[hardParam].textColor
        shadowColor = typeCfg[hardParam].textShadow
        bg = typeCfg[hardParam].normal
        local stars = 0
        for i = 1, 3 do
            local pass = i <= stars
            if pass then
                self._stars[i].sprite = self._atlas:GetSprite(typeCfg[hardParam].passStar)
            else
                self._stars[i].sprite = self._atlas:GetSprite(typeCfg[hardParam].normalStar)
            end
        end
        self.star:SetActive(missionCfg.Type ~= DiscoveryStageType.Plot)
        self.lock.gameObject:SetActive(false)
    end
    self.bg.sprite = self._atlas:GetSprite(bg)
    self.mask.sprite = self._atlas:GetSprite(mask)
    self.lock.sprite = self._atlas:GetSprite(lock)

    self.name.color = textColor
    self.shadowLabel.color = shadowColor
    self._circleOutline.effectColor = shadowColor

    --剧情路点点击后为了截屏而滚动
    self._isStoryNode = missionCfg.Type == DiscoveryStageType.Plot

    if lineCfg.MapPosY >= 0 then
        self._anim:Play("uieff_UIXH1MissionNode_belowin")
    else
        self._anim:Play("uieff_UIXH1MissionNode_topin")
    end
end
function UIN7LevelNode:btnOnClick(go)
    self._onClick(self._missionID, self._isStoryNode, self._rectTransform.position)
end
