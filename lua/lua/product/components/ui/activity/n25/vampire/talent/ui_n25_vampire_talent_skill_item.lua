---@class UIN25VampireTalentSkillItem : UICustomWidget
_class("UIN25VampireTalentSkillItem", UICustomWidget)
UIN25VampireTalentSkillItem = UIN25VampireTalentSkillItem

function UIN25VampireTalentSkillItem:Constructor()
    self.mCampaign = self:GetModule(CampaignModule)
    self.data = self.mCampaign:GetN25Data()

    self.animName = "uieffanim_UIN25VampireTalentSkillItem_in"
end

function UIN25VampireTalentSkillItem:OnShow(uiParams)
    ---@type UnityEngine.Animation
    self.anim = self:GetUIComponent("Animation", "UIN25VampireTalentSkillItem")
    ---@type RawImageLoader
    self.Icon = self:GetUIComponent("RawImageLoader", "Icon")
    self.select = self:GetGameObject("select")
    self:Select(false)
    ---@type UnityEngine.UI.Image
    self.imgLock = self:GetUIComponent("Image", "imgLock")
    ---@type UILocalizationText
    self.txtTalentCount = self:GetUIComponent("UILocalizationText", "txtTalentCount")
end

function UIN25VampireTalentSkillItem:OnHide()
    self.Icon:DestoryLastImage()
end

---@param skill VampireTalentSkill
function UIN25VampireTalentSkillItem:Flush(skill, callback)
    self.skill = skill
    self.callback = callback
    local icon, name, desc = skill:IconNameDesc()
    self.Icon:LoadImage(icon)
    local curLevel, maxLevel = skill:CurMaxLevel()
    self.txtTalentCount:SetText(curLevel .. "/" .. maxLevel)
    self:FlushTier(skill)
end
---@param skill VampireTalentSkill
function UIN25VampireTalentSkillItem:FlushTier()
    local tier = self.data:GetTierBySkillId(self.skill.skillId)
    if tier:IsLock() then
        self:ShowHideLock(true)
    else
        if self.skill:IsActive() then
            self:N25VampirePlayAnimTalentSkillActive()
        else
            self:ShowHideLock(true)
        end
    end
end

function UIN25VampireTalentSkillItem:SkillId()
    return self.skill.skillId
end
function UIN25VampireTalentSkillItem:Select(isSelect)
    self.select:SetActive(isSelect)
end

function UIN25VampireTalentSkillItem:IconOnClick(go)
    if self.callback then
        self.callback()
    end
end

---播放激活动效
function UIN25VampireTalentSkillItem:PlayAnimationActive()
    self.anim:Play(self.animName)
end
---@param isShow boolean 是否显示锁
function UIN25VampireTalentSkillItem:ShowHideLock(isShow)
    if isShow then
        self.imgLock.color = Color.white
    else
        self.imgLock.color = Color(1, 1, 1, 0)
    end
end

function UIN25VampireTalentSkillItem:N25VampirePlayAnimTalentSkillActive()
    if self.data.skillIdToUnlock == self.skill.skillId then
        self.data.skillIdToUnlock = 0
        self:StartTask(
            function(TT)
                local key = "UIN25VampireTalentTreeItemN25VampirePlayAnimTalentSkillActive" .. self.skill.skillId
                self:Lock(key)
                self:PlayAnimationActive()
                YIELD(TT, 767)
                self:UnLock(key)
            end,
            self
        )
    else
        self:ShowHideLock(false)
    end
end
