---@class StateN29ShopSpineAnim2 : StateN29ShopBase
_class("StateN29ShopSpineAnim2", StateN29ShopBase)
StateN29ShopSpineAnim2 = StateN29ShopSpineAnim2

function StateN29ShopSpineAnim2:OnEnter(TT, ...)
    self:Init()
    self:ShowHideSpineSkip(true)
    self:SetSpineSkipClickCallback(
        function()
            self:ChangeState(StateN29Shop.GetAward)
        end
    )
    local lotteryType = table.unpack({...})
    self:PlaySpineAnim2(lotteryType)
end

function StateN29ShopSpineAnim2:OnExit(TT)
    self:ShowHideSpineSkip(false)
    self.ui:ShowSpineAnim3() --播放idle
    if self.taskId then
        GameGlobal.TaskManager():KillTask(self.taskId)
    end
end

function StateN29ShopSpineAnim2:PlaySpineAnim2(lotteryType)
    local curPageIndex = self:CurPageIndex()
    local spineAnim2 = nil
    if lotteryType == ECampaignLotteryType.E_CLT_SINGLE then
        spineAnim2 = curPageIndex .. "_2"
    elseif lotteryType == ECampaignLotteryType.E_CLT_MULTI then
        spineAnim2 = curPageIndex .. "_4"
    end
    local yieldTime = self:PlaySpineAnimation(spineAnim2, false)
    if yieldTime and yieldTime > 0 then
        self.taskId =
            GameGlobal.TaskManager():StartTask(
            function(TT)
                YIELD(TT, yieldTime)
                self.taskId = nil
                self:ChangeState(StateN29Shop.GetAward)
            end,
            self
        )
    else
        self:ChangeState(StateN29Shop.GetAward)
    end
end
