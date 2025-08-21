---@class UIActivityN34TaskInfomationItem: UICustomWidget
_class("UIActivityN34TaskInfomationItem", UICustomWidget)
UIActivityN34TaskInfomationItem = UIActivityN34TaskInfomationItem

function UIActivityN34TaskInfomationItem:OnShow()
    self:GetComponents()

end


function UIActivityN34TaskInfomationItem:OnHide()

end

function UIActivityN34TaskInfomationItem:GetComponents()
    self._headImg = self:GetUIComponent("Image", "head")
    self._titleLabel = self:GetUIComponent("UILocalizationText", "processTitle")
    self._processLabel = self:GetUIComponent("UILocalizationText", "processCount")
    self._processSlider = self:GetUIComponent("Slider", "process")
    self._consignorLabel = self:GetUIComponent("UILocalizationText", "consignor")
    self._evaluate = self:GetGameObject("evaluate")
    self._evaluated = self:GetGameObject("evaluated")
    self._redPoint = self:GetGameObject("redPoint")
end

function UIActivityN34TaskInfomationItem:SetData(cfg,itemModule,component,componentInfo)
    self._cfg = cfg
    self._itemModule = itemModule
    self._component = component
    self._componentInfo = componentInfo
    self:Refresh()
end

function UIActivityN34TaskInfomationItem:Init()
    --self._headIm.sprite = ""
   
end

function UIActivityN34TaskInfomationItem:Refresh()
    self._titleLabel:SetText(StringTable.Get(self._cfg.Name))
    self._consignorLabel:SetText(self._cfg.Consignor)
    local num = self._itemModule:GetItemCount(self._cfg.TrustItem)
    self._processSlider.value = num/self._cfg.TrustTotal

    self._processLabel:SetText((num/self._cfg.TrustTotal*100).."%")
    self._evaluate:SetActive(self:CheckShowEvaluateBtn())
    self._evaluated:SetActive(self:GetHadEvaluated())
    self._redPoint:SetActive(self:CheckItemRed())
end

function UIActivityN34TaskInfomationItem:EvaluateOnClick()
    if self._component then 
            self:StartTask(function(TT) 
                local asyncRes = AsyncRequestRes:New()
                self._component:HandleSurveyClientDataReq(TT, asyncRes, SurveyOperateType.SurveyOperateType_UnLock)
                if asyncRes:GetSucc() then 
                    self:Refresh()
                end 
            end )
    end 
end

function UIActivityN34TaskInfomationItem:HeadOnClick()
    self:ShowDialog("UIActivityN34TaskInfomationRewardPreview",self._cfg,true,self:GetHadEvaluated())  
end

function UIActivityN34TaskInfomationItem:GetHadEvaluated()
    if not self._componentInfo then 
        return false 
    end 
    if not self._componentInfo.info then 
        return false 
    end 
    for index, value in ipairs(self._componentInfo.info.pet_unlock) do
        if value == self._cfg.PetID then 
           return true
        end 
    end
    return false 
end

function UIActivityN34TaskInfomationItem:CheckShowEvaluateBtn()
    local count = self._itemModule:GetItemCount(self._cfg.TrustItem)
    return count >= self._cfg.TrustTotal and (not self:GetHadEvaluated())
end
-- 
function UIActivityN34TaskInfomationItem:CheckItemRed()
    return self:CheckShowEvaluateBtn()
end
