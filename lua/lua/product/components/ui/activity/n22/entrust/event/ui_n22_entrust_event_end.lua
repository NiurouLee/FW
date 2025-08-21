---@class UIN22EntrustEventEnd : UIN22EntrustEventBase
_class("UIN22EntrustEventEnd", UIN22EntrustEventBase)
UIN22EntrustEventEnd = UIN22EntrustEventEnd

-- 虚函数
function UIN22EntrustEventEnd:Refresh()
    self:_SetRoot(false)

    -- 先检查有没有打开过终点 banner ，打开过的话直接弹离开弹窗，否则打开 banner
    if self._component:GetBannerState() then
        self._component:SetBannerState(1)
    else
        self:CloseDialog()
        return
    end

    local cfg = self:GetCfgCampaignEntrustEvent()
    local params = cfg.Params[1]
    local bannerid = params.BannerID
    local bannerType = params.BannerType

    if bannerType == 1 then
        GameGlobal.UIStateManager():ShowDialog(
            "UIStoryController",
            bannerid,
            function()
                self:OnStoryEnd()
            end
        )
    elseif bannerType == 2 then
        GameGlobal.UIStateManager():ShowDialog("UIStoryBanner", bannerid, StoryBannerShowType.HalfPortrait, function()
            self:OnStoryEnd()
        end)
    elseif bannerType == 3 then
        self:OnStoryEnd()
    end
end

-- 虚函数
function UIN22EntrustEventEnd:OnEventFinish(rewards)
    Log.info("UIN22EntrustEventEnd:OnEventFinish()")

    local title = StringTable.Get("str_n22_entrust_event_get_rewards_title")
    self:ShowDialog("UIN22EntrustRewardsController", title, rewards,
        function()
            self:CloseDialog()
        end
    )
end

function UIN22EntrustEventEnd:OnStoryEnd()
    --检查这个路点有没有获取过奖励
    local pass = self._component:IsEventPass(self._levelId, self._eventId)

    if pass then
        self:CloseDialog()
    else
        self:RequestEvent()
    end
end

