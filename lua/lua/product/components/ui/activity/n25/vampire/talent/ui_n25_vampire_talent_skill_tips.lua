---@class UIN25VampireTalentSkillTips : UIController
_class("UIN25VampireTalentSkillTips", UIController)
UIN25VampireTalentSkillTips = UIN25VampireTalentSkillTips

function UIN25VampireTalentSkillTips:Constructor()
    self.mCampaign = self:GetModule(CampaignModule)
    self.data = self.mCampaign:GetN25Data()
end

function UIN25VampireTalentSkillTips:OnShow(uiParams)
    ---@type ATransitionComponent
    self.atc = self:GetGameObject():GetComponent(typeof(ATransitionComponent))
    self.atc.enabled = true
    self.atc:PlayEnterAnimation(true)
    ---@type RawImageLoader
    self.Icon = self:GetUIComponent("RawImageLoader", "Icon")
    ---@type UILocalizationText
    self.txtSkillName = self:GetUIComponent("UILocalizationText", "txtSkillName")
    ---@type UILocalizationText
    self.txtSkillLevel = self:GetUIComponent("UILocalizationText", "txtSkillLevel")
    ---@type UILocalizationText
    self.txtSkillDesc = self:GetUIComponent("UILocalizationText", "txtSkillDesc")
    self.goBtnLearn = self:GetGameObject("BtnLearn")

    self.skillId = uiParams[1]

    self:Flush()
end
function UIN25VampireTalentSkillTips:OnHide()
    self.Icon:DestoryLastImage()
end

function UIN25VampireTalentSkillTips:Flush()
    self.skill = self.data:GetSkillBySkillId(self.skillId)
    local icon, name, desc = self.skill:IconNameDesc()
    self.Icon:LoadImage(icon)
    local curLevel, maxLevel = self.skill:CurMaxLevel()
    self.txtSkillLevel:SetText(curLevel .. "/" .. maxLevel)
    self.txtSkillName:SetText(name)
    self.txtSkillDesc:SetText(desc)
    local tier = self.data:GetTierBySkillId(self.skillId)
    if tier:IsLock() then
        self.goBtnLearn:SetActive(false)
    else
        if self.skill:IsLevelMax() then
            self.goBtnLearn:SetActive(false)
        else
            self.goBtnLearn:SetActive(true)
        end
    end
end

--region OnClick
function UIN25VampireTalentSkillTips:BgOnClick(go)
    self:PlayAnimClose()
end
function UIN25VampireTalentSkillTips:BtnLearnOnClick(go)
    if self.data:GetTalentLeft() <= 0 then
        ToastManager.ShowToast(StringTable.Get("str_n25_vampire_talent_not_enough"))
        return
    end
    self:StartTask(
        function(TT)
            local key = "HandleBloodsuckerResetTalentTree"
            self:Lock(key)
            if not self.skill:IsActive() then
                self.data.skillIdToUnlock = self.skillId --暂存要解锁的技能id
            end
            local row, index = self.data:GetSkillRowIndexBySkillId(self.skillId)
            local c = self.data:GetComponentVampire()
            local res = AsyncRequestRes:New()
            c:HandleBloodsuckerUpgradeTalentPoint(TT, res, row, index) --【消息】学习
            if N25Data.CheckCode(res) then
                self:PlayAnimClose()
                YIELD(TT,10)
                GameGlobal.EventDispatcher():Dispatch(GameEventType.OnVampireTalentSkillTipsClose,self.skillId)
            end
            self:UnLock(key)
        end,
        self
    )
end
--endregion

function UIN25VampireTalentSkillTips:PlayAnimClose()
    self:StartTask(
        function(TT)
            local key = "UIN25VampireTalentSkillTipsPlayAnimClose"
            self:Lock(key)
            self.atc:PlayLeaveAnimation(true)
            YIELD(TT, 140)
            self:UnLock(key)
            self:CloseDialog()
        end,
        self
    )
end
