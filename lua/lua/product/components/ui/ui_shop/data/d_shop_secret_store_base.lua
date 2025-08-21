--[[
    商城:神秘页签商城数据基类
]]
---@class DShopSecretStoreBase
_class("DShopSecretStoreBase", Object)
---@class DShopSecretStoreBase:Object
DShopSecretStoreBase = DShopSecretStoreBase

function DShopSecretStoreBase:Constructor(subTabType)
    -- Log.error("DShopSecretStoreBase:Constructor")
    self.SubTabType2Class = {
        [MarketType.Shop_BlackMarket] = DShopBlackGood,
        [MarketType.Shop_MysteryMarket] = DShopSecretExploreGood,
        [MarketType.Shop_WorldBoss] = DShopWorldBossGood
    }

    self.subTabType = subTabType
    self.goods = {}
    -- self.discount = {}
    self.remainSecond = 0
    self.maxCount = 999
    self.costType = RoleAssetID.RoleAssetGlow
    self.refreshTime = {}
    self.today_refreshed_count = 0
end

function DShopSecretStoreBase:SetRefreshInfo(shopLevelId)
    local cfg = Cfg.cfg_shop_level[shopLevelId]
    if cfg then
        local a = string.split(cfg.RefreshPrice, "|")
        self.maxCount = cfg.RefreshMax
        self.costType = cfg.RefreshCostType
        for index = 1, self.maxCount do
            local count = index
            local consume = tonumber(a[index] or a[#a])
            self.refreshTime[count] = consume
        end
    end
end
---@class marketinfo Marketinfo
function DShopSecretStoreBase:SetData(marketinfo, goodsconfig)
    -- Log.error("DShopSecretStoreBase:SetData")
    self.goods = {}
    ---@class goodinfo GoodsInfo
    if marketinfo.goods ~= nil then
        for _, goodinfo in ipairs(marketinfo.goods) do
            -- local discount = marketinfo.discount[goodinfo.goods_id] or 0
            -- goodinfo.discount = discount
            self:AddGood(goodinfo, goodsconfig[goodinfo.goods_id])
        end
    end
    -- 都要刷新
    self.today_refreshed_count = marketinfo.today_refreshed_count or 0
    self:SetRefreshInfo(marketinfo.cur_level_id)
end
function DShopSecretStoreBase:ReSortSecretGoods(targetShopIds)
    if targetShopIds == nil then
        return
    end
    local appendArr = {}
    for i = #self.goods, 1, -1 do
        if table.iskey(targetShopIds, self.goods[i]:GetGoodId()) then
            table.insert(appendArr, self.goods[i])
            table.remove(self.goods, i)
        end
    end
    table.appendArray(appendArr, self.goods)
    self.goods = appendArr
end

function DShopSecretStoreBase:GetSecretGoods()
    return self.goods
end

function DShopSecretStoreBase:AddGood(goodinfo, goodconfig)
    -- local good = self:GetGood(goodinfo.goods_id)
    -- if not good then
    local good = self.SubTabType2Class[self.subTabType]:New()
    table.insert(self.goods, good)
    -- end
    good:Refresh(goodinfo, goodconfig)
end

function DShopSecretStoreBase:GetGood(goodId)
    for index, value in ipairs(self.goods) do
        if value:GetGoodId() == goodId then
            return value
        end
    end
    return nil
end

function DShopSecretStoreBase:SetRemainSecond(remainSecond)
    self.remainSecond = remainSecond

    local timeModule = GameGlobal.GetModule(SvrTimeModule)
    local now = timeModule:GetServerTime() / 1000
    self._refreshTime = now + remainSecond
end

function DShopSecretStoreBase:GetRemainSecond()
    if not self._refreshTime then
        return nil
    end
    local timeModule = GameGlobal.GetModule(SvrTimeModule)
    local now = timeModule:GetServerTime() / 1000
    return self._refreshTime - now
end

function DShopSecretStoreBase:GetCurCount()
    return self.today_refreshed_count
end

function DShopSecretStoreBase:GetMaxCount()
    return self.maxCount
end

function DShopSecretStoreBase:GetCostType()
    return self.costType
end
---@public
---刷新次数对应花费
function DShopSecretStoreBase:GetConsume()
    local count = self.today_refreshed_count + 1
    if count > self.maxCount then
        count = self.maxCount
    end
    return self.refreshTime[count]
end
