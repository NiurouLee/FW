---@class UIN29ChessMapNode : UICustomWidget
_class("UIN29ChessMapNode", UICustomWidget)
UIN29ChessMapNode = UIN29ChessMapNode
-- onshow
function UIN29ChessMapNode:OnShow(uiParams)
    self:_InitWidget()
    self._isonClick = false
end
-- component
function UIN29ChessMapNode:_InitWidget()
    self.bg = self:GetUIComponent("Image", "bg")

    self.name = self:GetUIComponent("UILocalizationText", "name")
    self.name2 = self:GetUIComponent("UILocalizationText", "name_boss")
    self.star = self:GetGameObject("star")

    self.mask = self:GetUIComponent("Image", "mask")
    self.lock = self:GetUIComponent("Image", "lock")

    self.star1 = self:GetUIComponent("Image", "Star1")
    self.star2 = self:GetUIComponent("Image", "Star2")
    self.star3 = self:GetUIComponent("Image", "Star3")

    self._rectTransform = self:GetGameObject():GetComponent("RectTransform")
    self._stars = {
        self.star1,
        self.star2,
        self.star3
    }

    self._atlas = self:GetAsset("UIChess.spriteatlas", LoadType.SpriteAtlas)
    ---@type UnityEngine.UI.Shadow
    -- self.shadow = self:GetUIComponent("Shadow", "name")
    self._anim = self:GetGameObject():GetComponent("Animation")
    self._btn = self:GetGameObject("btn")
end

---@param passInfo cam_mission_info
function UIN29ChessMapNode:SetData(lineCfg, passInfo, cb, last, last2)
    self._missionID = lineCfg.MissionID
    self._onClick = cb
    self._rectTransform.anchorMax = Vector2(0.5, 0)
    self._rectTransform.anchorMin = Vector2(0.5, 0)
    self._rectTransform.sizeDelta = Vector2.zero
    self._rectTransform.anchoredPosition = Vector2(lineCfg.MapPosX, lineCfg.MapPosY)
    local missionCfg = Cfg.cfg_chess_mission[self._missionID]
    if not missionCfg then
        Log.exception("cfg_chess_mission中找不到配置:", self._missionID)
    end

    self.name:SetText(StringTable.Get(missionCfg.Name))
    self.name2:SetText(StringTable.Get(missionCfg.Name))
    self.name.gameObject:SetActive(true)
    self.name2.gameObject:SetActive(false)

    --1是普通关
    local hardParam = 1
    local typeCfg = UIN29ChessController.NodeCfg[MatchType.MT_Chess]
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
            local url = pass and typeCfg[hardParam].passStar or typeCfg[hardParam].normalStar
            self._stars[i].sprite = self._atlas:GetSprite(url)
            self._stars[i].gameObject:SetActive(not string.isnullorempty(url))
        end
        self.lock.gameObject:SetActive(false)
    else
        --没有通关数据则视为当前关
        textColor = typeCfg[hardParam].textColor
        shadowColor = typeCfg[hardParam].textShadow
        bg = typeCfg[hardParam].normal
        local stars = 0
        for i = 1, 3 do
            local pass = i <= stars
            local url = pass and typeCfg[hardParam].passStar or typeCfg[hardParam].normalStar
            self._stars[i].sprite = self._atlas:GetSprite(url)
            self._stars[i].gameObject:SetActive(not string.isnullorempty(url))
        end
        self.lock.gameObject:SetActive(false)
    end
    self:_SetRed(false)
    self.bg.sprite = self._atlas:GetSprite(bg)
    self.mask.sprite = self._atlas:GetSprite(mask)
    -- self.lock.sprite = self._atlas:GetSprite(lock)

    -- self.name.color = textColor
    -- self.name2.color = textColor
    -- self.shadow.effectColor = shadowColor

    if last2 then
        local cfg = Cfg.cfg_component_chess {MissionID = self._missionID}
        if cfg[1] and cfg[1].NeedMissionId then
            self.lock.gameObject:SetActive(true)
            local roleModule = GameGlobal.GetModule(RoleModule)
            local pstid = roleModule:GetPstId()
            local dbStr = "chess" .. cfg[1].NeedMissionId .. pstid
            local dbHas = LocalDB.GetInt(dbStr, 0)
            self.star:SetActive(true)
            self._btn:SetActive(true)
            if dbHas and dbHas == 1 then
                dbHas = dbHas + 1
                LocalDB.SetInt(dbStr, dbHas)
                local lockName = "UIN29ChessMapNode:_anim"
                self:StartTask(
                    function(TT)
                        self:Lock(lockName)
                        YIELD(TT, 666)
                        self._anim:Play("uieffanim_N15_UIN15ChessMapNode_open01")
                        YIELD(TT, 1100)
                        self._isonClick = true
                        self:UnLock(lockName)
                    end
                )
            else
                self._isonClick = true
                self.lock.gameObject:SetActive(false)
            end
        end
    elseif last then
        self.lock.gameObject:SetActive(true)
        self.star:SetActive(false)
        -- self.bg.sprite = self._atlas:GetSprite(lock)
        self._btn:SetActive(false)
        self.mask.gameObject:SetActive(false)
        self.name:SetText("<color=#bfbfbf>".. StringTable.Get("str_toast_manager_not_open").. "</color>")
    else
        self.star:SetActive(true)
        self._btn:SetActive(true)
        self.lock.gameObject:SetActive(false)
        self._isonClick = true
    end

    -- if lineCfg.MapPosY >= 0 then
    --     self._anim:Play("uieff_UIXH1MissionNode_belowin")
    -- else
    --     self._anim:Play("uieff_UIXH1MissionNode_topin")
    -- end
end
-- 设置红点
function UIN29ChessMapNode:_SetRed(isShow)
    local redObj = self:GetGameObject("red")
    redObj:SetActive(isShow)
end
-- 按钮
function UIN29ChessMapNode:BtnOnClick(go)
    if self._onClick and self._isonClick then
        self._onClick(self._missionID, self._rectTransform)
    end
end
