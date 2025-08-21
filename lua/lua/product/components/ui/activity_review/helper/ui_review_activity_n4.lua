--[[
    n2活动（绯）回顾信息
]]
---@class UIReviewActivityN4:UIReviewActivityBase
_class("UIReviewActivityN4", UIReviewActivityBase)
UIReviewActivityN4 = UIReviewActivityN4

function UIReviewActivityN4:Constructor(id, sample)
end

function UIReviewActivityN4:AssetPackageID()
    return 4
end

---@return boolean 是否有红点
function UIReviewActivityN4:HasRedPoint()
    if self:IsUnlock() then
        ---@type campaign_sample
        local sampleInfo = self._campObj:GetSampleInfo()
        local key = sampleInfo.m_extend_info[CampainExtendKey.E_CAMPAIGN_EXTEND_KEY_COMPLETE_COND]
        if key ~= 1 then --未开启
            return false
        end
        return sampleInfo:GetStepStatus(ECampaignStep.CAMPAIGN_STEP_REWARD) --有未领取的进度奖励
    end
    return false
end

function UIReviewActivityN4:ActivityOnOpen()
    TaskManager:GetInstance():StartTask(self.OpenActivity, self)
end

function UIReviewActivityN4:OpenActivity(TT)
    GameGlobal.UIStateManager():Lock("UIReviewActivityN4_OpenActivity")
    -- 获取活动 以及本窗口需要的组件
    local res = AsyncRequestRes:New()
    res:SetSucc(true)
    ---@type UIActivityCampaign
    local campaign = UIActivityCampaign:New()
    campaign:LoadCampaignInfo(TT, res,
        ECampaignType.CAMPAIGN_TYPE_REVIEW_N4,
        ECampaignReviewN4ComponentID.ECAMPAIGN_REVIEW_ReviewN4_STORY)

    -- 错误处理
    if res and not res:GetSucc() then
        GameGlobal.UIStateManager():ShowDialog("UIReviewUnlockTip", self, {StringTable.Get("str_summer_review_n4_open_tips"), "100%"})
        GameGlobal.UIStateManager():UnLock("UIReviewActivityN4_OpenActivity")
        return
    end

    campaign:ReLoadCampaignInfo_Force(TT, res)

    ---@type campaign_sample
    local sample = campaign:GetSample()
    local key = sample.m_extend_info[CampainExtendKey.E_CAMPAIGN_EXTEND_KEY_COMPLETE_COND]
    if key ~= 1 then --未开启
        GameGlobal.UIStateManager():ShowDialog("UIReviewUnlockTip", self, {StringTable.Get("str_summer_review_n4_open_tips"), "100%"})
        GameGlobal.UIStateManager():UnLock("UIReviewActivityN4_OpenActivity")
        return
    end

    ---@type UIActivityReview
    local controller = GameGlobal.UIStateManager():GetController("UIActivityReview")
    local rt = controller:GetShotImage()
    local cache_rt = UnityEngine.RenderTexture:New(UnityEngine.Screen.width, UnityEngine.Screen.height, 16)
    GameGlobal.TaskManager():StartTask(
        function(TT)
            YIELD(TT)
            UnityEngine.Graphics.Blit(rt, cache_rt)
            GameGlobal.UIStateManager():SwitchState(UIStateType.UISummer2MainControllerReview, cache_rt)
            GameGlobal.UIStateManager():UnLock("UIReviewActivityN4_OpenActivity")
        end
    )
end


function UIReviewActivityN4:GetBattleExitParam(comID, missionCreateInfo, isWin, battleresultRt)
    Log.error("UIReviewActivityN4:GetBattleExitParam")
end
