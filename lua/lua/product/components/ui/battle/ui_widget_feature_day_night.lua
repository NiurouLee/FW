---@class UIFeatureDayNightStyle
local UIFeatureDayNightStyle = {
    Normal = 1,
    NightKing = 2,
}
_enum("UIFeatureDayNightStyle", UIFeatureDayNightStyle)

---@class UIWidgetFeatureDayNight : UICustomWidget
_class("UIWidgetFeatureDayNight", UICustomWidget)
UIWidgetFeatureDayNight = UIWidgetFeatureDayNight
function UIWidgetFeatureDayNight:OnShow(uiParams)
    self:InitWidget()
end
function UIWidgetFeatureDayNight:InitWidget()
    --generated--
    ---@type UnityEngine.GameObject
    self._offSetGo = self:GetGameObject("OffSet")

    ---@type UILocalizationText
    self._restRoundText = self:GetUIComponent("UILocalizationText", "RestRound")
    ---@type UnityEngine.GameObject
    self._dayArea = self:GetGameObject("DayArea")
    ---@type UnityEngine.GameObject
    self._nightArea = self:GetGameObject("NightArea")
    ---@type UnityEngine.GameObject
    self._nightKingGo = self:GetGameObject("NightKing")--夜王专属ui样式
    self._nightKingGo:SetActive(false)
    ---@type UnityEngine.GameObject
    self._restRoundGo = self:GetGameObject("RestRound")
    self:RegisterEvent()
    self._offSetGo:SetActive(false)
    --generated end--
end
function UIWidgetFeatureDayNight:RegisterEvent()
    self:AttachEvent(GameEventType.FeatureListInit, self._OnFeatureListInit)
    self:AttachEvent(GameEventType.FeatureDayNightRefresh, self._OnFeatureDayNightRefresh)
    self:AttachEvent(GameEventType.FeatureDayNightChangeUIStyle, self._OnFeatureDayNightChangeUIStyle)
end
---@param initData FeatureEffectParamDayNight
function UIWidgetFeatureDayNight:SetData(initData)
    self._offSetGo:SetActive(true)
    self._initData = initData
    self._state = self._initData:GetEnterState()
    self._restRound = self._initData:GetLastRound(self._state)
    self._uiStyle = UIFeatureDayNightStyle.Normal
    self:_RefreshState()
end
function UIWidgetFeatureDayNight:_RefreshState()
    if self._uiStyle == UIFeatureDayNightStyle.Normal then
        self._nightKingGo:SetActive(false)
        if self._state == FeatureDayNightState.Day then
            self._dayArea:SetActive(true)
            self._nightArea:SetActive(false)
        elseif self._state == FeatureDayNightState.Night then
            self._dayArea:SetActive(false)
            self._nightArea:SetActive(true)
        end
        self._restRoundGo:SetActive(true)
        self._restRoundText:SetText(self._restRound)
    elseif self._uiStyle == UIFeatureDayNightStyle.NightKing then
        self._dayArea:SetActive(false)
        self._nightArea:SetActive(false)
        self._restRoundGo:SetActive(false)
        self._nightKingGo:SetActive(true)
    end
end
---San值变化
function UIWidgetFeatureDayNight:_OnFeatureDayNightRefresh(state,restRound)
    self._state = state
    self._restRound = restRound
    self:_RefreshState()
end
function UIWidgetFeatureDayNight:_OnFeatureDayNightChangeUIStyle(uiStyle)
    self._uiStyle = uiStyle
    self:_RefreshState()
end
---模块列表初始化
function UIWidgetFeatureDayNight:_OnFeatureListInit(featureListInfo)
    if self._initData then
        return
    end
    if featureListInfo then
        --昼夜模块ui独立
        for i,v in ipairs(featureListInfo) do
            local featureType = v:GetFeatureType()
            if featureType == FeatureType.DayNight then--昼夜
                ---@type UIWidgetFeatureDayNight
                self:SetData(v)
                break
            end
        end
    end
end