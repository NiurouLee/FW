--[[
    活动辅助类
]]
---@class UISeasonExchangeHelper : Object
_class("UISeasonExchangeHelper", Object)
UISeasonExchangeHelper = UISeasonExchangeHelper

--region Phase

function UISeasonExchangeHelper._GetCfg(component, id)
    local componentCfgId = component:GetComponentCfgId()
    local cfgs = Cfg.cfg_season_exchange_client { ComponentID = componentCfgId } or {}
    for _, v in ipairs(cfgs) do
        if v.ID == id then
            return v
        end
    end
end

function UISeasonExchangeHelper.GetPrice(component, id)
    local cfg = UISeasonExchangeHelper._GetCfg(component, id)
    local rawPrice = cfg and cfg.RawPrice or 0
    return rawPrice
end

function UISeasonExchangeHelper.GetDiscount(component, id)
    local cfg = UISeasonExchangeHelper._GetCfg(component, id)
    local discount = cfg and cfg.Discount or 0
    return discount
end

function UISeasonExchangeHelper.GetBold(component, id)
    local cfg = UISeasonExchangeHelper._GetCfg(component, id)
    local bold = cfg and cfg.Bold or false
    return bold
end

---@param component ExchangeItemComponent
function UISeasonExchangeHelper.GetExchangeItemList_Sort(component)
    local infos = component:GetExchangeItemList()

    -- sort
    -- 1. 剩余 < 售罄
    -- 2. 特殊 < 突出 < 普通
    -- 3. id
    local soldout = function(a)
        return component:IsExchangeItemSoldout(a)
    end
    local special = function(a)
        if a.m_is_special then
            return 1
        end
        local bold = UISeasonExchangeHelper.GetBold(component, a.m_id)
        return bold and 2 or 3
    end

    table.sort(infos, function(a, b)
        local soldoutA = soldout(a)
        local soldoutB = soldout(b)
        local specialA = special(a)
        local specialB = special(b)

        if soldoutA ~= soldoutB then
            return soldoutB
        elseif specialA ~= specialB then
            return specialA < specialB
        else
            return a.m_id < b.m_id
        end
    end)

    return infos
end