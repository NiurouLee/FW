---@class UIWidgetMirageUI : UICustomWidget
_class("UIWidgetMirageUI", UICustomWidget)
UIWidgetMirageUI = UIWidgetMirageUI
--初始化
function UIWidgetMirageUI:OnShow(uiParams)
    self:InitWidget()
end

--获取ui组件
function UIWidgetMirageUI:InitWidget()
    --generated--
    ---@type UICustomWidgetPool
    self._chooseGridRoot = self:GetUIComponent("UISelectObjectPath", "ChooseGridRoot")
    ---@type UIWidgetMirageChooseGrid
    self._chooseGridWidget = self._chooseGridRoot:SpawnObject("UIWidgetMirageChooseGrid")

    self._countDownObj = self:GetGameObject("CountDown")
    self._countDownTimeText = self:GetUIComponent("UILocalizationText", "CountDownTime")
    self._stepObj = self:GetGameObject("Step")
    self._stepNumText = self:GetUIComponent("UILocalizationText", "RemainStep")

    self:OnReset()

    self:RegisterEvent()
    --generated end--
end

function UIWidgetMirageUI:OnReset()
    self._countDownNum = 30
    local strNum = tostring(self._countDownNum) .. "s"
    self._countDownTimeText:SetText(strNum)
    self._countDownMs = self._countDownNum * 1000

    self._remainStep = 5
    self._stepNumText:SetText(tostring(self._remainStep))
end

function UIWidgetMirageUI:RegisterEvent()
    self:AttachEvent(GameEventType.ShowMirageChooseGrid, self.ShowMirageChooseGrid)
    self:AttachEvent(GameEventType.UIMirageCancelChoose, self.HandleUICancelChoose)
    self:AttachEvent(GameEventType.UIMirageChooseGridConfirm, self.HandleUIChooseGridConfirm)
    self:AttachEvent(GameEventType.UIMirageChooseGridGray, self.HandleUIChooseGridGray)

    self:AttachEvent(GameEventType.ShowMirageEnterUI, self.ShowMirageEnterUI)
    self:AttachEvent(GameEventType.RefreshMirageStep, self.RefreshMirageStep)
end

function UIWidgetMirageUI:IsAutoFighting()
    return GameGlobal.GetUIModule(MatchModule):IsAutoFighting()
end

function UIWidgetMirageUI:ShowAutoFightForbiddenMsg()
    return GameGlobal.GetUIModule(MatchModule):ShowAutoFightForbiddenMsg()
end

function UIWidgetMirageUI:CancelActiveSkillSwitchTimer()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.UICancelActiveSkillSwitchTimer)
end

function UIWidgetMirageUI:ShowMirageChooseGrid(show)
    self._chooseGridWidget:ShowChooseGridPanel(show)
end

function UIWidgetMirageUI:ShowMirageEnterUI(show)
    self._countDownObj:SetActive(show)
    self._stepObj:SetActive(show)
    if not show then
        self:OnReset()
    end
end

function UIWidgetMirageUI:HandleUICancelChoose()
    self._chooseGridWidget:RefreshMiragePickUpGrid(false)
    self._chooseGridWidget:SetPickUpConfirmBtnState(false)

    --通知清除点选
    GameGlobal.EventDispatcher():Dispatch(GameEventType.MirageUIClearPickUp)
end

function UIWidgetMirageUI:HandleUIChooseGridConfirm(autoFight)
    --通知执行点选
    GameGlobal.EventDispatcher():Dispatch(GameEventType.MirageUIConfirmPickUp, autoFight)
end

function UIWidgetMirageUI:HandleUIChooseGridGray()
    --提示至少选择一个格子
    local text = StringTable.Get("str_battle_need_choose_one_grid")
    ToastManager.ShowToast(text)
end

function UIWidgetMirageUI:RefreshMirageStep(RemainStep)
    self._remainStep = RemainStep
    self._stepNumText:SetText(tostring(RemainStep))
    GameGlobal.EventDispatcher():Dispatch(GameEventType.MirageUIRefreshStep, self._remainStep)
end

function UIWidgetMirageUI:OnUpdate(deltaTimeMS)
    if self._countDownObj.activeSelf then
        --更新倒计时
        if self._countDownMs > 0 then
            local deltaTime = GameGlobal:GetInstance():GetUnscaledDeltaTime()
            self._countDownMs = self._countDownMs - deltaTime
            self:RefreshCountDownNum()
            if self._countDownMs <= 0 and self._remainStep > 0 then
                self._chooseGridWidget:ShowChooseGridPanel(false)
                GameGlobal.EventDispatcher():Dispatch(GameEventType.MirageUICountDownOver)
            end
        end
    end
end

function UIWidgetMirageUI:RefreshCountDownNum()
    local refreshNumSec = 0
    if self._countDownMs < 0 then
        refreshNumSec = 0
    else
        refreshNumSec = math.ceil(self._countDownMs / 1000)
    end
    if self._countDownNum ~= refreshNumSec then
        self._countDownNum = refreshNumSec
        local timeNumStr = tostring(self._countDownNum) .. "s"
        self._countDownTimeText:SetText(timeNumStr)
    end
end
