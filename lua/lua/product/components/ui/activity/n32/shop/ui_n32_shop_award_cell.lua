---@class UIN32ShopAwardCell : UICustomWidget
_class("UIN32ShopAwardCell", UICustomWidget)
UIN32ShopAwardCell = UIN32ShopAwardCell
function UIN32ShopAwardCell:OnShow(uiParams)
    self._animCfg = 
    {
        [1] = {"uieff_UIN32ShopAwardCell_big",700},
        [2] = {"uieff_UIN32ShopAwardCell_small",700},
        [3] = {"uieff_UIN30ShopAwardCell_out",167},
    }
    self:_GetComponents()
end
function UIN32ShopAwardCell:_GetComponents()
    self._big = self:GetGameObject("Big")
    self._small = self:GetGameObject("Small")

    self._animation = self.view.gameObject:GetComponent("Animation")
    self._canvasGroup = self:GetUIComponent("CanvasGroup","Animation")

    self._itemIcon = self:GetUIComponent("RawImageLoader", "ItemIcon")
    self._itemNumText = self:GetUIComponent("UILocalizationText", "ItemNumText")
    self._itemNumArea = self:GetGameObject("ItemNumArea")
    self._restNumText = self:GetUIComponent("UILocalizationText", "RestNumText")
    self._mask = self:GetGameObject("Mask")
    self._itemIconSm = self:GetUIComponent("RawImageLoader", "ItemIconSm")
    self._itemNumTextSm = self:GetUIComponent("UILocalizationText", "ItemNumTextSm")
    self._itemNumAreaSm = self:GetGameObject("ItemNumAreaSm")
    self._restNumTextSm = self:GetUIComponent("UILocalizationText", "RestNumTextSm")
    self._maskSm = self:GetGameObject("MaskSm")

    self._nodes = 
    {
        [1] = { self._itemIcon, self._itemNumText,self._restNumText,self._mask},
        [2] = { self._itemIconSm, self._itemNumTextSm,self._restNumTextSm,self._maskSm},
    }
    self.go = self:GetGameObject()
end
---@param data AwardInfo
function UIN32ShopAwardCell:InitData(data, itemInfoCallback,unlock,needShowAnim)
    self._data = data

    self._unlock = unlock
    self._itemId = self._data.m_item_id
    self._itemCount = self._data.m_lottery_limit_count
    self._itemRestCount = self._data.m_lottery_count
    self._itemInfoCallback = itemInfoCallback
    self:FillUi()
    if needShowAnim then
        self:ShowAnim(self._data.m_is_big_reward and 1 or 2)
    end 
end
function UIN32ShopAwardCell:FillUi()
    self._big:SetActive(self._data.m_is_big_reward)
    self._small:SetActive(not self._data.m_is_big_reward)
    local itemCfg = Cfg.cfg_item[self._itemId]
    self._mask:SetActive(self._itemRestCount <=0 or (not self._unlock)) 
    self._maskSm:SetActive(self._itemRestCount <=0 or (not self._unlock)) 
    if itemCfg then
        --上锁和抽完
        local itemCount = self._data.m_count
        local showNumberTex
        local showTimesTex
        showNumberTex = "<color=#efede7>".."x"..itemCount.."</color>"
        showTimesTex = "<color=#efede7>"..self._itemRestCount.."</color>".."<color=#8c887a>".."/"..self._itemCount.."</color>"
        if self._unlock and self._itemRestCount>0 then    

        end
        local index = self._data.m_is_big_reward and 1 or 2
        local node = self._nodes[index]
        local res = itemCfg.Icon
  
        node[1]:LoadImage(res)
        node[2]:SetText(showNumberTex)
        node[3]:SetText(showTimesTex)
    end
end
function UIN32ShopAwardCell:OnHide()
    if self._timer then
        GameGlobal.Timer():CancelEvent(self._timer)
        self._timer = nil    
    end
end
function UIN32ShopAwardCell:BgOnClick(go)
    if self._itemInfoCallback then
        self._itemInfoCallback(self._data.m_item_id,go.transform.position)
    end
end

function UIN32ShopAwardCell:SmallOnClick(go)
    if self._itemInfoCallback then
        self._itemInfoCallback(self._data.m_item_id,go.transform.position)
    end
end

function UIN32ShopAwardCell:ShowAnim(id,callback)
    local data =  self._animCfg[id]
    self:StartTask(function (TT) 
        self:Lock("UIN32ShopAwardCell:ShowAnim")
        self._animation:Play(data[1])
        YIELD(TT,data[2])
        self:UnLock("UIN32ShopAwardCell:ShowAnim")
        if callback then  
            callback()
        end 
    end)
end