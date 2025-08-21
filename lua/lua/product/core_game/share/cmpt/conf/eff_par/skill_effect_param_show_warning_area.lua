---@class ShowWarningCenterType
local ShowWarningCenterType = {
    Self = 1, --以自己为中心
    CanUseCenterArray = 2, --目标位置集合，选中第一个不是释放者的位置
}
_enum("ShowWarningCenterType", ShowWarningCenterType)


--[[----------------------------------------------------------------
    2019-12-12 韩玉信添加
    SkillEffectParam_ShowWarningArea : 显示预览范围效果参数
--]]----------------------------------------------------------------
require("skill_effect_param_base")
----------------------------------------------------------------
---@class SkillEffectParam_ShowWarningArea: SkillEffectParamBase
_class("SkillEffectParam_ShowWarningArea", SkillEffectParamBase)
SkillEffectParam_ShowWarningArea = SkillEffectParam_ShowWarningArea

function SkillEffectParam_ShowWarningArea:Constructor(t)
    self.m_WarningCenterType = ShowWarningCenterType.Self
    if t.centerType then
        self.m_WarningCenterType = t.centerType
    end
    self.m_CanUseCenterArray = t.canUseCenters
    self.m_ContainCasterArea = t.containCasterArea
    self.m_nWarningSkillID = t.warningSkillID
    self.m_nWarningSkillID2 = t.warningSkillID2
    self.m_bValidArea = t.validArea

    self._getScopeResultFromAI = t.getScopeResultFromAI == 1
end

function SkillEffectParam_ShowWarningArea:GetEffectType()
    return SkillEffectType.ShowWarningArea
end

function SkillEffectParam_ShowWarningArea:GetWarningSkillID()
    return self.m_nWarningSkillID
end

function SkillEffectParam_ShowWarningArea:GetWarningSkillID2()
    return self.m_nWarningSkillID2
end

function SkillEffectParam_ShowWarningArea:GetValidArea()
    return self.m_bValidArea
end

function SkillEffectParam_ShowWarningArea:GetWarningCenterType()
    return self.m_WarningCenterType
end

function SkillEffectParam_ShowWarningArea:GetCanUseCenterArray()
    return self.m_CanUseCenterArray
end

function SkillEffectParam_ShowWarningArea:IsContainCasterArea()
    return self.m_ContainCasterArea
end

function SkillEffectParam_ShowWarningArea:IsGetScopeResultFromAI()
    return self._getScopeResultFromAI
end

----------------------------------------------------------------