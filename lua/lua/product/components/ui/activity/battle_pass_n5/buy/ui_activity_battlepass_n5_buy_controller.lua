--- @class UIActivityBattlePassN5BuyController:UIController
_class("UIActivityBattlePassN5BuyController", UIController)
UIActivityBattlePassN5BuyController = UIActivityBattlePassN5BuyController

--region component help
--- @return LVRewardComponent
function UIActivityBattlePassN5BuyController:_GetLVRewardComponent()
    local cmptId = ECampaignBattlePassComponentID.ECAMPAIGN_BATTLEPASS_LV_REWARD
    return self._campaign:GetComponent(cmptId)
end

--- @return LVRewardComponentInfo
function UIActivityBattlePassN5BuyController:_GetLVRewardComponentInfo()
    local cmptId = ECampaignBattlePassComponentID.ECAMPAIGN_BATTLEPASS_LV_REWARD
    return self._campaign:GetComponentInfo(cmptId)
end

--- @return BuyGiftComponent
function UIActivityBattlePassN5BuyController:_GetBuyGiftComponent()
    local cmptId = ECampaignBattlePassComponentID.ECAMPAIGN_BATTLEPASS_BUY_GIFT
    return self._campaign:GetComponent(cmptId)
end

--- @return BuyGiftComponentInfo
function UIActivityBattlePassN5BuyController:_GetBuyGiftComponentInfo()
    local cmptId = ECampaignBattlePassComponentID.ECAMPAIGN_BATTLEPASS_BUY_GIFT
    return self._campaign:GetComponentInfo(cmptId)
end
--endregion

function UIActivityBattlePassN5BuyController:_GetComponents()
    local backBtns = self:GetUIComponent("UISelectObjectPath", "backBtns")
    ---@type UICommonTopButton
    self._backBtns = backBtns:SpawnObject("UICommonTopButton")
    ---@type UIHomelandModule
    self._homeLandModule = GameGlobal.GetUIModule(HomelandModule)
    local hideHomeBtn = self._homeLandModule:IsRunning()
    self._backBtns:SetData(
        function()
            self:_PlayAnimOut()
        end,
        nil,
        nil,
        hideHomeBtn
    )

    ---@type UICustomWidgetPool
    local eliteBoardPool = self:GetUIComponent("UISelectObjectPath", "eliteBoardPool")
    self._eliteBoard = eliteBoardPool:SpawnObject("UIActivityBattlePassN5Board")

    ---@type UICustomWidgetPool
    local deluxeBoardPool = self:GetUIComponent("UISelectObjectPath", "deluxeBoardPool")
    self._deluxeBoard = deluxeBoardPool:SpawnObject("UIActivityBattlePassN5Board")
end

--- @param TT 协程函数标识
--- @param res AsyncRequestRes 异步请求结果
function UIActivityBattlePassN5BuyController:LoadDataOnEnter(TT, res, uiParams)
    -- 获取活动 以及本窗口需要的组件
    ---@type UIActivityCampaign
    self._campaign = UIActivityCampaign:New()
    self._campaign:LoadCampaignInfo(
        TT,
        res,
        ECampaignType.CAMPAIGN_TYPE_BATTLEPASS,
        ECampaignBattlePassComponentID.ECAMPAIGN_BATTLEPASS_LV_REWARD,
        ECampaignBattlePassComponentID.ECAMPAIGN_BATTLEPASS_QUEST_1,
        ECampaignBattlePassComponentID.ECAMPAIGN_BATTLEPASS_QUEST_2,
        ECampaignBattlePassComponentID.ECAMPAIGN_BATTLEPASS_QUEST_3,
        ECampaignBattlePassComponentID.ECAMPAIGN_BATTLEPASS_BUY_GIFT
    )

    -- 错误处理
    if res and not res:GetSucc() then
        self._campaign._campaign_module:CheckErrorCode(res.m_result, self._campaign._id, nil, nil)
        return
    end

    -- 活动开启时才拉价格
    --- @type BuyGiftComponent
    local component = self:_GetBuyGiftComponent()
    component:GetAllGiftLocalPrice()
end

function UIActivityBattlePassN5BuyController:OnShow(uiParams)
    self:_AttachEvents()

    self._isOpen = true
    if uiParams then
        self.callback = uiParams[1]
    end

    self:_GetComponents()

    -- 设置立绘
    UIActivityBattlePassHelper.SetSpecialImg(
        self._campaign,
        self:GetGameObject("imgRoot"),
        self:GetUIComponent("RawImageLoader", "img"),
        self:GetName()
    )

    self:_SetBoard()

    self:_PlayAnimIn()
end

function UIActivityBattlePassN5BuyController:OnHide()
    self:_DetachEvents()
    self._isOpen = false
end

function UIActivityBattlePassN5BuyController:_SetBoard()
    --- @type BuyGiftComponent
    local component = self:_GetBuyGiftComponent()
    --- @type BuyGiftComponentInfo
    local componentInfo = self:_GetBuyGiftComponentInfo()

    ---------------------------------------------------
    ---@type CampaignGiftType
    local type = CampaignGiftType.ECGT_ADVANCED
    local giftId = component:GetFirstGiftIDByType(type)

    -- 显示用带货币符号的字符串
    local price = component:GetGiftPriceForShowById(giftId)

    self._eliteBoard:SetData(
        self._campaign,
        type,
        price,
        function(type)
            self:BuyBtnOnClick(type)
        end
    )

    ---------------------------------------------------
    type = CampaignGiftType.ECGT_LUXURY
    local buyState = componentInfo.m_buy_state
    if buyState == BuyGiftStateType.EBGST_ADVANCED then
        type = CampaignGiftType.ECGT_ADDITIONALBUY
    end

    giftId = component:GetFirstGiftIDByType(type)
    -- 显示用带货币符号的字符串
    price = component:GetGiftPriceForShowById(giftId)

    self._deluxeBoard:SetData(
        self._campaign,
        type,
        price,
        function(type)
            self:BuyBtnOnClick(type)
        end
    )
end

--region Event Callback
function UIActivityBattlePassN5BuyController:BuyBtnOnClick(type)
    --- @type BuyGiftComponent
    local component = self:_GetBuyGiftComponent()

    local giftId = component:GetFirstGiftIDByType(type)
    component:BuyGift(giftId, 1, type)
end

function UIActivityBattlePassN5BuyController:PreviewBtnOnClick(go)
    Log.info("UIActivityBattlePassN5BuyController:PreviewBtnOnClick")
    self:ShowDialog("UIActivityBattlePassN5PreviewController")
end
--endregion

--region AttachEvent
function UIActivityBattlePassN5BuyController:_AttachEvents()
    self:AttachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
    self:AttachEvent(GameEventType.ActivityCurrencyBuySuccess, self._OnCurrencyBuySuccess)
    self:AttachEvent(GameEventType.PayGetLocalPriceFinished, self._SetBoard)
end

function UIActivityBattlePassN5BuyController:_DetachEvents()
    self:DetachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
    self:DetachEvent(GameEventType.ActivityCurrencyBuySuccess, self._OnCurrencyBuySuccess)
    self:DetachEvent(GameEventType.PayGetLocalPriceFinished, self._SetBoard)
end

function UIActivityBattlePassN5BuyController:_CheckActivityClose(id)
    if self._campaign and self._campaign._id == id then
        self:SwitchState(UIStateType.UIMain)
    end
end

-- 直购的回调
function UIActivityBattlePassN5BuyController:_OnCurrencyBuySuccess(id)
    --- @type BuyGiftComponent
    local component = self:_GetBuyGiftComponent()

    local type = nil
    for t = CampaignGiftType.ECGT_ADVANCED, CampaignGiftType.ECGT_ADDITIONALBUY do
        if component:GetFirstGiftIDByType(t) == id then
            type = t
            break
        end
    end

    if type then
        self:ShowDialog(
            "UIActivityBattlePassN5AwardController",
            type,
            function()
                if self.callback then
                    self.callback(type == CampaignGiftType.ECGT_LUXURY or type == CampaignGiftType.ECGT_ADDITIONALBUY)
                end
                self:_PlayAnimOut()
            end
        )
    else
        Log.fatal("UIActivityBattlePassN5BuyController:_OnCurrencyBuySuccess(id) CampaignGiftType Wrong! id = ", id)
    end
end
--endregion

--region animation
function UIActivityBattlePassN5BuyController:_PlayAnimIn()
    local animName = "UIeff_UIActivityBattlePassN5BuyController_in"
    UIWidgetHelper.PlayAnimation(self, "animation", animName, 767)
end

function UIActivityBattlePassN5BuyController:_PlayAnimOut()
    if not self.view then -- 防止从 UIActivityBattlePassN5AwardController 调用时窗口已关闭
        return
    end
    
    local animName = "UIeff_UIActivityBattlePassN5BuyController_out"
    UIWidgetHelper.PlayAnimation(self, "animation", animName, 600, function()
        if self.callback then
            self.callback()
        end
        self:CloseDialog()
    end)
end
--endregion
