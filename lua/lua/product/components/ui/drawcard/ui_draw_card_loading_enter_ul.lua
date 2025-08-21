---@class UIDrawCardLoadingEnterUL:LoadingHandler
_class("UIDrawCardLoadingEnterUL", LoadingHandler)
UIDrawCardLoadingEnterUL = UIDrawCardLoadingEnterUL

function UIDrawCardLoadingEnterUL:PreLoadAfterLoadLevel(TT, ...)
    AudioHelperController.RequestUISoundList(
        {
            CriAudioIDConst.DrawCard_tuijingtou,
            CriAudioIDConst.DrawCard_lagan_new,
            CriAudioIDConst.Drawcard_lagan_eft_3,
            CriAudioIDConst.Drawcard_lagan_eft_4,
            CriAudioIDConst.Drawcard_lagan_eft_5,
            CriAudioIDConst.Drawcard_lagan_eft_6,
            CriAudioIDConst.Drawcard_light_one,
            CriAudioIDConst.Drawcard_light_more,
            CriAudioIDConst.Drawcard_light_one,
            CriAudioIDConst.Drawcard_mul_show,
            CriAudioIDConst.Drawcard_lagan_once
        }
    )
end

function UIDrawCardLoadingEnterUL:OnLoadingFinish(...)
    ---@type GambleModule
    local module = GameGlobal.GetModule(GambleModule)
    module:InitContext(self.sceneResReq)
    GameGlobal.UIStateManager():SwitchState(UIStateType.UIDrawCard, ...)
end

function UIDrawCardLoadingEnterUL:LoadingType()
    return LoadingType.STATICPIC
end
