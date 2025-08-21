--[[
    活动兑换商城客户端UI管理类
]]
---@class ClientCampaignShop
_class("ClientCampaignShop", Object)
ClientCampaignShop = ClientCampaignShop
function ClientCampaignShop:Constructor()
end

---------------------------------------------------------------------------------------
--UTIL --
---------------------------------------------------------------------------------------
------public 打开活动兑换商城界面唯一入口
---@param campaignType ECampaignType
function ClientCampaignShop.OpenCampaignShop(campaignType, campaignId, backFun, ...)
    local shopStateTab = {
        [ECampaignType.CAMPAIGN_TYPE_N9] = "UIActivityShopControllerN9",
        [ECampaignType.CAMPAIGN_TYPE_N11] = "UIN11Shop",
        [ECampaignType.CAMPAIGN_TYPE_N14] = "UIN14Shop",
        [ECampaignType.CAMPAIGN_TYPE_N16] = "UIActivityShopControllerN16",
        [ECampaignType.CAMPAIGN_TYPE_N18] = "UIN18Shop",
        [ECampaignType.CAMPAIGN_TYPE_N22] = "UIActivtiyN22ShopController",
        [ECampaignType.CAMPAIGN_TYPE_N23] = "UIN23Shop",
        [ECampaignType.CAMPAIGN_TYPE_N25] = "UIN25Shop",
    }
    local shopTab = {
        [ECampaignType.CAMPAIGN_TYPE_EVERESCUEPLAN] = "UICampaignShopController",
        [ECampaignType.CAMPAIGN_TYPE_N26] = "UIActivityN26Shop",
        [ECampaignType.CAMPAIGN_TYPE_N28] = "UIActivityN28Shop",
        [ECampaignType.CAMPAIGN_TYPE_N31] = "UIActivityN31Shop",
    }
    local uiName = shopStateTab[campaignType]
    if not string.isnullorempty(uiName) then
        GameGlobal.UIStateManager():SwitchState(uiName, campaignType, campaignId, backFun, ...)
    else
        uiName = shopTab[campaignType]
        if not string.isnullorempty(uiName) then
            GameGlobal.UIStateManager():ShowDialog(uiName, campaignType, campaignId,backFun, ...)
        end
    end
end

function ClientCampaignShop.CheckBuy(saleType, price, withToast)
    local showToast = withToast or false
    local result = true
    local roleModule = GameGlobal.GameLogic():GetModule(RoleModule)
    if saleType == RoleAssetID.RoleAssetGlow then
        local diamond = roleModule:GetGlow()
        if price > diamond then
            GameGlobal.UIStateManager():ShowDialog("UIShopCurrency1To2", price - diamond)
            result = false
        end
    elseif saleType == RoleAssetID.RoleAssetGold then
        local gold = roleModule:GetGold()
        if price > gold then
            if showToast then
                ToastManager.ShowToast(StringTable.Get("str_shop_buy_no_gold"))
            end
            result = false
        end
    elseif saleType == RoleAssetID.RoleAssetMazeCoin then
        local mazeCoin = roleModule:GetMazeCoin()
        if price > mazeCoin then
            if showToast then
                ToastManager.ShowToast(StringTable.Get("str_shop_buy_no_maze"))
            end
            result = false
        end
    else
        local itemMd = GameGlobal.GameLogic():GetModule(ItemModule)
        local money = itemMd:GetItemCount(saleType)
        if price > money then
            if showToast then
                ToastManager.ShowToast(StringTable.Get("str_shop_buy_no_maze"))
            end
            result = false
        end
    end
    return result
end

--- 货币类型对应图片名字
function ClientCampaignShop.GetCurrencyImageName(saleType)
    if not ClientCampaignShop.SaleType2ImageName then
        ---@type RoleAssetID
        ClientCampaignShop.SaleType2ImageName = {
            [RoleAssetID.RoleAssetGlow] = Cfg.cfg_top_tips[RoleAssetID.RoleAssetGlow].Icon,
            [RoleAssetID.RoleAssetGold] = Cfg.cfg_top_tips[RoleAssetID.RoleAssetGold].Icon,
            [RoleAssetID.RoleAssetMazeCoin] = Cfg.cfg_top_tips[RoleAssetID.RoleAssetMazeCoin].Icon
        }
    end
    local icon = ClientCampaignShop.SaleType2ImageName[saleType]
    if icon then
        return icon
    end
    local cfgItem = Cfg.cfg_item[saleType]
    if cfgItem then
        return cfgItem.Icon
    end
    return nil
end

function ClientCampaignShop.GetMoney(saleType)
    local roleModule = GameGlobal.GameLogic():GetModule(RoleModule)
    local money = 0
    if saleType == RoleAssetID.RoleAssetPhyPoint then
        money = roleModule:GetHealthPoint()
    elseif saleType == RoleAssetID.RoleAssetGlow then
        money = roleModule:GetGlow()
    elseif saleType == RoleAssetID.RoleAssetGold then
        money = roleModule:GetGold()
    elseif saleType == RoleAssetID.RoleAssetMazeCoin then
        money = roleModule:GetMazeCoin()
    else
        local itemMd = GameGlobal.GameLogic():GetModule(ItemModule)
        money = itemMd:GetItemCount(saleType)
    end
    return money
end
function ClientCampaignShop.CheckIsGoodsGroupUnlock(unlockTime, curTime)
    if unlockTime and curTime then
        return (curTime > unlockTime)
    end
    return false
end
function ClientCampaignShop.CheckIsGoodsGroupCanShow(showTime, curTime)
    if showTime and curTime then
        return (curTime > showTime)
    end
    return false
end
function ClientCampaignShop.CheckIsGoodsGroupClose(closeTime, curTime)
    if closeTime and curTime then
        return (curTime > closeTime)
    end
    return false
end
---@param goodsInfo ExchangeItemComponentItemInfo
function ClientCampaignShop.CheckGoodsShowRedPoint(goodsInfo)
    if not goodsInfo then
        return false
    end
    if goodsInfo.m_is_show_red_point then
        --检查解锁
        local svrTimeModule = GameGlobal.GameLogic():GetModule(SvrTimeModule)
        local nowTime = math.floor(svrTimeModule:GetServerTime() / 1000)
        if goodsInfo.m_unlock_time > 0 and nowTime < goodsInfo.m_unlock_time then
            return false
        end
        --检查兑换次数
        if goodsInfo.m_exchange_limit_count ~= -1 then
            if goodsInfo.m_can_exchange_count <= 0 then
                return false
            end
        end
        --检查点数
        return ClientCampaignShop.CheckBuy(goodsInfo.m_cost_item_id, goodsInfo.m_cost_count)
    end
    return false
end
