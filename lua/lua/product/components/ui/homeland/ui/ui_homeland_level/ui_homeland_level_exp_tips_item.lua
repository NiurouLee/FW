---@class UIHomelandLevelExpTipsItem:UICustomWidget
_class("UIHomelandLevelExpTipsItem", UICustomWidget)
UIHomelandLevelExpTipsItem = UIHomelandLevelExpTipsItem

function UIHomelandLevelExpTipsItem:Constructor()
end

function UIHomelandLevelExpTipsItem:OnShow()
    ---@type UILocalizationText
    self.txtFM = self:GetUIComponent("UILocalizationText", "txtFM")
    ---@type UILocalizationText
    self.txtPT = self:GetUIComponent("UILocalizationText", "txtPT")
    ---@type UILocalizationText
    self.txtFMValue = self:GetUIComponent("UILocalizationText", "txtFMValue")
    ---@type UILocalizationText
    self.txtPTValue = self:GetUIComponent("UILocalizationText", "txtPTValue")
end

function UIHomelandLevelExpTipsItem:Flush(i)
    self.txtFM:SetText(StringTable.Get("str_homeland_level_first_manufacture_" .. i))
    self.txtFMValue:SetText(StringTable.Get("str_homeland_level_first_manufacture_val_" .. i))
    self.txtPT:SetText(StringTable.Get("str_homeland_level_first_plant_tree_" .. i))
    self.txtPTValue:SetText(StringTable.Get("str_homeland_level_first_plant_tree_val_" .. i))
end
