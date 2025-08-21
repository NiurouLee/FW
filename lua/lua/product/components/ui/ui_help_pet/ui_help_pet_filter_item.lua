---@class UIHelpPetFilterItem:UICustomWidget
_class("UIHelpPetFilterItem", UICustomWidget)
UIHelpPetFilterItem = UIHelpPetFilterItem

function UIHelpPetFilterItem:Constructor()
end
function UIHelpPetFilterItem:OnShow(uiParams)
end

function UIHelpPetFilterItem:GetComponents()
    self._name = self:GetUIComponent("UILocalizationText", "filterName")
    self._selectImgGo = self:GetGameObject("selectImg")
end

function UIHelpPetFilterItem:SetData(cgType, filterName, curCgType, callback)
    self:GetComponents()
    self._cgType = cgType
    self._filterName = filterName
    self._callback = callback
    self:OnValue(curCgType)
end

function UIHelpPetFilterItem:OnValue(curCgType)
    self._name:SetText(self._filterName)
    self:Flush(curCgType)
end

function UIHelpPetFilterItem:BtnOnClick()
    if self._callback then
        self._callback(self._cgType)
    end
end

function UIHelpPetFilterItem:Flush(curCgType)
    if curCgType == self._cgType then
        self._selectImgGo:SetActive(true)
        --self._name.color = Color(252 / 255, 232 / 255, 2 / 255, 1)
    else
        self._selectImgGo:SetActive(false)
        --self._name.color = Color(1, 1, 1, 1)
    end
end
