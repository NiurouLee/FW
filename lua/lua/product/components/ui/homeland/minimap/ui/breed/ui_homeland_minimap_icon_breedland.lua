--
---@class UIHomelandMinimapIconBreedLand : UIHomelandMinimapIconBase
_class("UIHomelandMinimapIconBreedLand", UIHomelandMinimapIconBase)
UIHomelandMinimapIconBreedLand = UIHomelandMinimapIconBreedLand

--初始化
function UIHomelandMinimapIconBreedLand:OnShow(uiParams)
    self:_GetComponents()
    self:AttachEvent(GameEventType.HomelandBreedPhasesChange, self.OnHomelandBreedPhasesChange)
end

--获取ui组件
function UIHomelandMinimapIconBreedLand:_GetComponents()
    self._selected = self:GetGameObject("Selected")
    self._state = self:GetGameObject("State")
end

function UIHomelandMinimapIconBreedLand:OnInitDone()
    ---@type HomelandBreedLand
    local breedLand = self._iconData:GetParam()
    local curPhases = breedLand:GetCurPhases()
    if curPhases and curPhases > 0 then
        local remainTime = breedLand:GetRemainTime()
        self._state:SetActive(remainTime <= 0)
    else
        self._state:SetActive(false)
    end
end

function UIHomelandMinimapIconBreedLand:OnSelected()
    self._selected:SetActive(true)
end

function UIHomelandMinimapIconBreedLand:OnUnSelected()
    self._selected:SetActive(false)
end

function UIHomelandMinimapIconBreedLand:GetShowName()
    ---@type HomelandBreedLand
    local breedLand = self._iconData:GetParam()
    local itemID = breedLand:GetBuildId()
    local cfg = Cfg.cfg_item[itemID]

    return StringTable.Get(cfg.Name)
end

function UIHomelandMinimapIconBreedLand:GetAnimationName(animType)
    if not self._animationNames then
        self._animationNames = {}
        self._animationNames[MinimapIconAnimationType.IN] = "UIHomelandMinimapIconBreedLand_in"
        self._animationNames[MinimapIconAnimationType.OUT] = "UIHomelandMinimapIconBreedLand_out"
        self._animationNames[MinimapIconAnimationType.SELECT] = "UIHomelandMinimapIconBreedLand_Selected_in"
        self._animationNames[MinimapIconAnimationType.UNSELECT] = "UIHomelandMinimapIconBreedLand_Selected_out"
        self._animationNames[MinimapIconAnimationType.EXPANSION] = "UIHomelandMinimapIconBreedLand_expansion"
    end
    
    return self._animationNames[animType]
end

function UIHomelandMinimapIconBreedLand:OnHomelandBreedPhasesChange()
    self:OnInitDone()
end