--高级服装购买控制
---@class UIHauteCoutureDrawChargeV2Controller:UIController
_class("UIHauteCoutureDrawChargeV2Controller", UIController)
UIHauteCoutureDrawChargeV2Controller = UIHauteCoutureDrawChargeV2Controller
function UIHauteCoutureDrawChargeV2Controller:Constructor()
    ---@type UICustomWidget
    self.bg = nil
    ---@type UIHauteCoutureDrawChargeBase
    self.main = nil
end

function UIHauteCoutureDrawChargeV2Controller:LoadDataOnEnter(TT, res, uiParams)
    self.hcType = uiParams[1]
    ---@type BuyGiftComponent
    self._buyComponet = uiParams[2]
    self._buyComponet:GetAllGiftLocalPrice()
    ---@type UIHauteCoutureDataBase
    self._ctx = uiParams[3] --从伯利恒开始的高级时装，打开此界面需要传上下文数据
end

function UIHauteCoutureDrawChargeV2Controller:OnShow(uiParams)
    local bg = self:GetUIComponent("UISelectObjectPath", "bgRoot")
    local main = self:GetUIComponent("UISelectObjectPath", "uiRoot")
    if self.hcType == HauteCoutureType.HC_GL then
        bg.dynamicInfoOfEngine:SetObjectName("UIHauteCoutureDrawChargeBgGL.prefab")
        main.dynamicInfoOfEngine:SetObjectName("UIHauteCoutureDrawChargeMainGL.prefab")
        self.bg = bg:SpawnObject("UIHauteCoutureDrawChargeBgGL")
        self.main = main:SpawnObject("UIHauteCoutureDrawChargeMainGL")
    elseif self.hcType == HauteCoutureType.HC_KR then
        bg.dynamicInfoOfEngine:SetObjectName("UIHauteCoutureDrawChargeBgKR.prefab")
        main.dynamicInfoOfEngine:SetObjectName("UIHauteCoutureDrawChargeMainKR.prefab")
        self.bg = bg:SpawnObject("UIHauteCoutureDrawChargeBgKR")
        self.main = main:SpawnObject("UIHauteCoutureDrawChargeMainKR")
    else
        local bgPrefab, bgClass = self._ctx:GetChargeUIBgInfo()
        local prefab, class = self._ctx:GetChargeUIInfo()
        bg.dynamicInfoOfEngine:SetObjectName(bgPrefab)
        main.dynamicInfoOfEngine:SetObjectName(prefab)
        self.bg = bg:SpawnObject(bgClass._className)
        self.main = main:SpawnObject(class._className)
    end

    if not self.bg then
        return
    end
end
