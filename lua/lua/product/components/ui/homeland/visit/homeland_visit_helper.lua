---@class HomelandVisitHelper:Object
_class("HomelandVisitHelper", Object)
HomelandVisitHelper = HomelandVisitHelper

function HomelandVisitHelper:Constructor()
end

--拜访好友许愿池饲养鱼
function HomelandVisitHelper.GetRaiseFishList()
    local fish_in_wishing = {}
    local uiHomeModule = GameGlobal.GetUIModule(HomelandModule)
    local poolInfo = uiHomeModule:GetVisitPoolInfo()
    if not poolInfo then
        return fish_in_wishing
    end

    local items = poolInfo.item_count
    local result = {}
    for k, v in pairs(items) do
        local tmpCfg = Cfg.cfg_item[k]
        if tmpCfg then
            if tmpCfg.ItemSubType == ItemSubType.ItemSubType_Fish then
                local cfg = Cfg.cfg_item_homeland_fish[k]
                if cfg then
                    if cfg.Type == 2 then
                        result[k] = v
                    end
                end
            end
        end
    end

    for k, v in pairs(result) do
        for i = 1, v do
            local t1 = {}
            t1.ID = k
            t1.InstanceId = HomelandVisitHelper.GenFishInstanceId()
            fish_in_wishing[#fish_in_wishing + 1] = t1
        end
    end

    return fish_in_wishing
end

--刷新好友水族箱鱼类信息
function HomelandVisitHelper.RefreshVistAquariumFish()
    local result = {}
    HomelandVisitHelper.fish_in_aquarium = result

    local uiHomeModule = GameGlobal.GetUIModule(HomelandModule)
    local poolInfo = uiHomeModule:GetVisitPoolInfo()
    if not poolInfo then
        return
    end

    local fishMapList = poolInfo.fish_tank_item_count
    for buildPstId, items in pairs(fishMapList) do
        result[buildPstId] = {}
        for fishId, fishCount in pairs(items) do
            local tmpCfg = Cfg.cfg_item[fishId]
            if tmpCfg then
                local cfg = Cfg.cfg_item_homeland_fish[fishId]
                if cfg then
                    for i = 1, fishCount do
                        local fish = {}
                        fish.ID = fishId
                        fish.InstanceId = HomelandVisitHelper.GenFishInstanceId()
                        result[buildPstId][#result[buildPstId] + 1] = fish
                    end
                end
            end
        end
    end
end

--拜访好友水族箱饲养鱼
function HomelandVisitHelper.GetAquariumFishList(buildPstID)
    return HomelandVisitHelper.fish_in_aquarium and HomelandVisitHelper.fish_in_aquarium[buildPstID] or {}
end

--生成拜访好友 Fish实列Id
function HomelandVisitHelper.GenFishInstanceId()
    if not HomelandVisitHelper.FishInstanceId then
        HomelandVisitHelper.FishInstanceId = 1
        return HomelandVisitHelper.FishInstanceId
    end

    HomelandVisitHelper.FishInstanceId = HomelandVisitHelper.FishInstanceId + 1
    return HomelandVisitHelper.FishInstanceId
end