---@class UIActivityN25HardLevelItem:UICustomWidget
_class("UIActivityN25HardLevelItem", UICustomWidget)
UIActivityN25HardLevelItem = UIActivityN25HardLevelItem

function UIActivityN25HardLevelItem:Constructor(uiview)
    ---@type UIView
    self._view = uiview
    self:OnShow()
   
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get( self._press ),
        UIEvent.Press,
        function(go)
          --  self._clickimg.gameObject:SetActive(true)
        end
    )
    self:AddUICustomEventListener(
        UICustomUIEventListener.Get( self._press ),
        UIEvent.Release,
        function(go)
         --   self._clickimg.gameObject:SetActive(false)
        end
    )
end
function UIActivityN25HardLevelItem:OnShow()
    self._titleImg = self._view:GetUIComponent("Image", "TitleBg")
    self._normal = self._view:GetUIComponent("Image", "normal")
    self._pass = self._view:GetUIComponent("Image", "pass")
    self._close = self._view:GetUIComponent("Image", "close")
    self._clickimg  = self._view:GetUIComponent("Image", "clickimg")
    self._press  = self._view:GetGameObject("press")
    self._name = self._view:GetUIComponent("UILocalizationText", "name")
    self._nameRoot = self._view:GetGameObject("nameRoot")
    self._animation = self._view:GetUIComponent("Animation", "anim")
    self._localPos = self._view.transform.localPosition:Clone()
end

---@protected
---隐藏的时候，这里可以处理事件的注销
function UIActivityN25HardLevelItem:OnHide()
end

---@param passInfo cam_mission_info
function UIActivityN25HardLevelItem:SetData(idx, cfg, passInfo, cur, atlas)
    local levelCfg = UIActivtiyN25HardLevelController.LevelCfg[idx]
    --self._titleImg.sprite = atlas:GetSprite(levelCfg.title)
    self._normal.sprite = atlas:GetSprite(levelCfg.normal)
    self._pass.sprite = atlas:GetSprite(levelCfg.close)
    self._close.sprite = atlas:GetSprite(levelCfg.close)
   -- self._clickimg.sprite = atlas:GetSprite(levelCfg.click)

    self._clickimg.gameObject:SetActive(false)
    if idx < cur then
        --已通关
        if not passInfo then
            Log.exception("没有通关信息：", idx)
        end
        self._pass.gameObject:SetActive(true)
        self._close.gameObject:SetActive(false)
    elseif idx > cur then
        --未通关
        self._pass.gameObject:SetActive(false)
        self._close.gameObject:SetActive(true)
    else
        --当前关
        self._normal.gameObject:SetActive(true)
        self._pass.gameObject:SetActive(false)
        self._close.gameObject:SetActive(false)
    end

    local missionCfg = Cfg.cfg_campaign_mission[cfg.CampaignMissionId]
    self._name:SetText(StringTable.Get(missionCfg.Name))

end

function UIActivityN25HardLevelItem:LocalPosition()
    return self._localPos
end

function UIActivityN25HardLevelItem:Anim_Pass()
   
end

function UIActivityN25HardLevelItem:Anim_Open()
  
end

function UIActivityN25HardLevelItem:SetActive(bShow) 
    self._view.gameObject:SetActive(bShow)
end 

