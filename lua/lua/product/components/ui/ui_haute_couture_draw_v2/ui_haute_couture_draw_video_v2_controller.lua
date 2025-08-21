---@class UIHauteCoutureDrawVideoV2Controller:UIController
_class("UIHauteCoutureDrawVideoV2Controller", UIController)
UIHauteCoutureDrawVideoV2Controller = UIHauteCoutureDrawVideoV2Controller

function UIHauteCoutureDrawVideoV2Controller:Constructor()
    ---@type UIHauteCoutureDrawVideoBase
    self.main = nil
    self.bg = nil
end

function UIHauteCoutureDrawVideoV2Controller:OnShow(uiParams)
    local main = self:GetUIComponent("UISelectObjectPath", "uiRoot")
    -- self.hcType = uiParams[1]
    -- self._cfg = uiParams[2]

    ---@type UIHauteCoutureDataBase
    self._ctx = uiParams[1]
    self.hcType = self._ctx:HC_Type()

    if self.hcType == HauteCoutureType.HC_GL then
        main.dynamicInfoOfEngine:SetObjectName("UIHauteCoutureDrawVideoMainGL.prefab")
        self.main = main:SpawnObject("UIHauteCoutureDrawVideoMainGL")
    elseif self.hcType == HauteCoutureType.HC_KR then
        main.dynamicInfoOfEngine:SetObjectName("UIHauteCoutureDrawVideoMainKR.prefab")
        self.main = main:SpawnObject("UIHauteCoutureDrawVideoMainKR")
    else
        local prefab, class = self._ctx:GetVideoUIInfo()
        main.dynamicInfoOfEngine:SetObjectName(prefab)
        self.main = main:SpawnObject(class._className)
    end
end
