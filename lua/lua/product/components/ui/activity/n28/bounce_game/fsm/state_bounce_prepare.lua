---@class StateBouncePrepare : StateBounceBase
_class("StateBouncePrepare", StateBounceBase)
StateBouncePrepare = StateBouncePrepare

function StateBouncePrepare:OnEnter(TT, ...)
    self:Init()
    --data Reset
    self.bounceData:Reset()
    self.guideModule = GameGlobal.GetModule(GuideModule)
    --reset 怪物生成器
    for k, v in pairs(self.monsterGenerator) do
        v:Reset()
    end
    --rest objMgr
    self.objMgr:Reset()
    self.objMgr:SetPlayerVisbile(true)
    local prepareView =  self.uiController:GetPrepareView()
    
    if self.bounceData.levelId == 1 then
        GameGlobal.EventDispatcher():Dispatch(GameEventType.GuideOpenUI, GuideOpenUI.UIBounceMainController)
        self.bounceData.guidingId = BounceConst.GuideFirst
    elseif self.bounceData.levelId == 2   then
        GameGlobal.EventDispatcher():Dispatch(GameEventType.GuideOpenUI, GuideOpenUI.UIBounceMainController2)
        self.bounceData.guidingId = BounceConst.GuideSecond
    end
            
    prepareView:Start(function ()
        if self.bounceData.guidingId == BounceConst.GuideFirst then
            local isGuiding = self.guideModule:IsGuideProcess(BounceConst.GuideFirst)
            self.bounceData:SetIsGuiding(isGuiding)
            if isGuiding then
                self.coreController:SetGuideStepShow("guide1180081")
            end
        elseif  self.bounceData.guidingId == BounceConst.GuideSecond then
            local isGuiding = self.guideModule:IsGuideProcess(BounceConst.GuideSecond)
            self.bounceData:SetIsGuiding(isGuiding)
            if isGuiding then
                self.coreController:SetGuideStepShow("guide1180091")
            end
        end
        self.coreController:ChgFsmState(StateBounce.Battle)
    end)
end

function StateBouncePrepare:OnExit(TT)
end