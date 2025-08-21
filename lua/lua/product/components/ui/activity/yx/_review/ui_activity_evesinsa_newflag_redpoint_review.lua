---@class UIActivityEveSinaNewFlagRedPoint_Review:Object
_class("UIActivityEveSinaNewFlagRedPoint_Review", Object)
UIActivityEveSinaNewFlagRedPoint_Review = UIActivityEveSinaNewFlagRedPoint_Review

function UIActivityEveSinaNewFlagRedPoint_Review:Constructor()
    self._campaignModule = GameGlobal.GetModule(CampaignModule)
    self._loginModule = GameGlobal.GetModule(LoginModule)
    self:RequestCampaign()
end
function UIActivityEveSinaNewFlagRedPoint_Review:RequestCampaign()
    -- GameGlobal.TaskManager():StartTask(self._RequestCampaign, self)
    self:_RequestCampaign()
end
function UIActivityEveSinaNewFlagRedPoint_Review:_RequestCampaign()
    ---@type UICampaignModule
    local uiModule = GameGlobal.GetUIModule(CampaignModule)
    ---@type UIReviewActivityN1
    self._reviewData = uiModule:GetReviewData():GetActivityByType(ECampaignType.CAMPAIGN_TYPE_REVIEW_N1)
    -- self._reviewData:ReqDetailInfo(TT, res)
    self._campaign = self._reviewData:GetDetailInfo()

    self._treeMissionComponentInfo =
        self._campaign:GetComponentInfo(
        ECampaignReviewEvaRescuePlanComponentID.ECAMPAIGN_REVIEW_EVARESCUEPLAN_TREE_MISSION
    )
end

--活动回顾一律不显示红点
function UIActivityEveSinaNewFlagRedPoint_Review:HaveRedPoint()
    -- return self:LoginRewardRedPoint() or self:QuestRewardRedPoint() or self:PetStageRedPoint() or
    --     self:ActionPointRedPoint()
    return false
end

--2.P2关卡解锁new
function UIActivityEveSinaNewFlagRedPoint_Review:P2StageUnLockNew()
    return self._treeMissionComponentInfo and
        self._campaign:CheckComponentOpen(
            ECampaignReviewEvaRescuePlanComponentID.ECAMPAIGN_REVIEW_EVARESCUEPLAN_TREE_MISSION
        ) and
        self._treeMissionComponentInfo.m_b_unlock and
        self:P2StageUnLockLocalRecord()
end
--3.P1S关解锁new
function UIActivityEveSinaNewFlagRedPoint_Review:P1SStageUnLockNew()
    return self:P1SStageUnLock() and
        self._campaign:CheckComponentOpen(
            ECampaignReviewEvaRescuePlanComponentID.ECAMPAIGN_REVIEW_EVARESCUEPLAN_LINE_MISSION
        ) and
        self._campaign:CheckComponentOpen(
            ECampaignReviewEvaRescuePlanComponentID.ECAMPAIGN_REVIEW_EVARESCUEPLAN_TREE_MISSION
        ) and
        self:P1StageUnLockLocalRecord()
end
function UIActivityEveSinaNewFlagRedPoint_Review:P1SStageUnLock()
    return self._campaign and UIActivityEveSinsaHelper_Review.CheckSpecialMissionCanPlay(self._campaign)
end
function UIActivityEveSinaNewFlagRedPoint_Review:P2StageUnLockLocalRecord()
    return LocalDB.GetInt("ACTIVITY_EVE_SINA_P2_NEWFLAG_REVIEW" .. self._loginModule:GetRoleShowID(), 0) <= 0
end
function UIActivityEveSinaNewFlagRedPoint_Review:P1StageUnLockLocalRecord()
    return LocalDB.GetInt("ACTIVITY_EVE_SINA_P1S_NEWFLAG_REVIEW" .. self._loginModule:GetRoleShowID(), 0) <= 0
end
