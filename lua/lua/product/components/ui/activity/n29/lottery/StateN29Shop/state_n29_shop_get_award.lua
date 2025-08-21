---@class StateN29ShopGetAward : StateN29ShopBase
_class("StateN29ShopGetAward", StateN29ShopBase)
StateN29ShopGetAward = StateN29ShopGetAward

function StateN29ShopGetAward:OnEnter(TT, ...)
    self:Init()
    local rewardRecord = self:GetRewardRecord()
    self:_ShowGetReward(rewardRecord)
end

function StateN29ShopGetAward:OnExit(TT)
    self._uiModule:LockAchievementFinishPanel(false)
end

---@param record DCampaignDrawShopDrawResultRecord
function StateN29ShopGetAward:_ShowGetReward(record)
    ---@type AwardInfo[]
    local rewards = record.m_getRewards
    -- local lotteryType = record.m_lotteryType
    -- local curBoxHasRest = record.m_curBoxHasRest
    local isOpenNew = record.m_isOpenNew
    -- local canDrawOnceMore = record.m_canDrawOnceMore
    self:Sort(rewards)
    local tempPets, assetAwards, hasBig = self:GetPetAssetBig(rewards)
    --[[
        如果 下一个奖池解锁
    ]]
    local cbFunc = function()
        if isOpenNew then --开启新奖池
            local curPageIndex = self:CurPageIndex()
            PopupManager.Alert(
                "UICommonMessageBox",
                PopupPriority.Normal,
                PopupMsgBoxType.Ok,
                StringTable.Get("str_n29_shop_new_box_unlock_title"),
                StringTable.Get("str_n29_shop_open_next_text", curPageIndex, curPageIndex + 1),
                function()
                    self:ForceRefresh(true)
                end,
                nil
            )
        else
            if hasBig and self.data:GotAllBigAward() then
                PopupManager.Alert(
                    "UICommonMessageBox",
                    PopupPriority.Normal,
                    PopupMsgBoxType.Ok,
                    "",
                    StringTable.Get("str_n29_shop_loop_box_reset_tips"), --已获得全部特殊奖励
                    function()
                        self:ForceRefresh(true)
                    end,
                    nil
                )
            else
                self:ForceRefresh(false)
            end
        end
    end

    local getItemCtrl = "UIGetItemController"
    if #tempPets > 0 then
        GameGlobal.UIStateManager():ShowDialog(
            "UIPetObtain",
            tempPets,
            function()
                GameGlobal.UIStateManager():CloseDialog("UIPetObtain")
                GameGlobal.UIStateManager():ShowDialog(getItemCtrl, assetAwards, cbFunc, true)
            end
        )
    else
        GameGlobal.UIStateManager():ShowDialog(getItemCtrl, assetAwards, cbFunc, true)
    end
end

function StateN29ShopGetAward:Sort(rewards)
    table.sort(
        rewards,
        function(a, b)
            local isBigA = a.m_is_big_reward and 1 or 0
            local isBigB = b.m_is_big_reward and 1 or 0
            return isBigA > isBigB --大奖普通降序
        end
    )
end
---@return RoleAsset[], RoleAsset[], boolean 宝宝列表，资源列表，是否有大奖
function StateN29ShopGetAward:GetPetAssetBig(rewards)
    local tempPets = {}
    local assetAwards = {}
    local hasBig = false
    if #rewards > 0 then
        for i = 1, #rewards do
            local roleAsset = RoleAsset:New()
            roleAsset.assetid = rewards[i].m_item_id
            roleAsset.count = rewards[i].m_count
            local ispet = self.mPet:IsPetID(roleAsset.assetid)
            if ispet then
                table.insert(tempPets, roleAsset)
            end
            table.insert(assetAwards, roleAsset)
            if rewards[i].m_is_big_reward then
                hasBig = true
            end
        end
    end
    return tempPets, assetAwards, hasBig
end

function StateN29ShopGetAward:ForceRefresh(b)
    local dontPlaySpine = nil
    if not b then
        dontPlaySpine = true
    end
    self:_ForceRefresh(b, dontPlaySpine)
    self:ChangeState(StateN29Shop.Init)
end
