---@class UITacticTapeObtain : UIController
_class("UITacticTapeObtain", UIController)
UITacticTapeObtain = UITacticTapeObtain
function UITacticTapeObtain:OnShow(uiParams)
    self:InitWidget()
    ---@type RoleAsset
    self._data = uiParams[1]
    local id = self._data.assetid
    local itemCfg = Cfg.cfg_item[id]
    local name = StringTable.Get(itemCfg.Name)
    self._name:SetText(name)
    self.shadow:SetText(name)
    -- self.icon:LoadImage(itemCfg.Icon)
    self.icon.sharedMaterial:SetTexture(
        "_MainTex",
        self:GetAsset(itemCfg.Icon .. ".mat", LoadType.Mat):GetTexture("_MainTex")
    )

    local cfg = Cfg.cfg_item_cartridge[id]
    self.quality:SetText(cfg.Quality)

    self._anim = self:GetGameObject():GetComponent(typeof(UnityEngine.Animation))
    ---@type UnityEngine.AnimationState
    self._animState = self._anim:get_Item("uieff_Tape_Obtain")
    self._timeModule = self:GetModule(SvrTimeModule)
    self._endTime = self._timeModule:GetServerTime() + self._animState.length * 1000 * 0.95
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N8UnlockTape)
    AirLog("获得卡带:", id)
end
function UITacticTapeObtain:InitWidget()
    --generated--
    self.icon = self:GetUIComponent("MeshRenderer", "icon")
    ---@type UILocalizationText
    self.quality = self:GetUIComponent("UILocalizationText", "quality")
    ---@type UILocalizationText
    self._name = self:GetUIComponent("UILocalizationText", "name")
    ---@type UILocalizationText
    self.shadow = self:GetUIComponent("UILocalizationText", "shadow")
    --generated end--
end
function UITacticTapeObtain:blankOnClick(go)
    if self._timeModule:GetServerTime() < self._endTime then
        self._animState.enabled = true
        self._animState.normalizedTime = 1
        self._anim:Sample()
        self._animState.enabled = false
        self._endTime = 0
        AudioHelperController.StopUISound(CriAudioIDConst.N8UnlockTape)
    else
        self:CloseDialog()
    end
end
