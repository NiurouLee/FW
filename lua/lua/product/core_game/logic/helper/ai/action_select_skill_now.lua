require "ai_node_new"

---@class ActionSelectSkillNow:AINewNode
_class("ActionSelectSkillNow", AINewNode)
ActionSelectSkillNow = ActionSelectSkillNow

function ActionSelectSkillNow:Constructor()
    self._skillListIndex = 1
    self._skillID = 0
    self.m_nDefaultSkillIndex = 0
    self.m_nSkillListCount = 0
end

function ActionSelectSkillNow:InitializeNode(cfg, context, parentNode, configData)
    ActionSelectSkillNow.super.InitializeNode(self, cfg, context, parentNode, configData)
    if type(configData) == "number" then
        self._skillListIndex = configData
        self.m_nDefaultSkillIndex = 1
    elseif type(configData) == "table" then
        self._skillListIndex = configData[1]
        self.m_nDefaultSkillIndex = configData[2]
    end
end

function ActionSelectSkillNow:OnUpdate()
    local configData = self.m_configData
    if type(configData) ~= "table" or #configData < 2 then
        Log.error(self._className, "configData invalid: {skillListIndex, skillIndex} required. ")
        return AINewNodeStatus.Failure
    end

    local listIndex = configData[1]
    local skillIndex = configData[2]

    local vecSkillLists = self:GetConfigSkillList()
    local skillList = vecSkillLists[listIndex]
    if skillList then
        self._skillID = skillList[skillIndex]
        self:PrintLog("按回合选技能<强行修改>, skillID = " ,self._skillID)
        -- TODO 下面这段是贴过来的，版本稳了之后看能不能删掉，其实本节点不需要这个逻辑

        ---如下代码不写在 InitializeNode 内是因为， InitializeNode 内还没有初始化 AIComponentNew
        if self.m_nSkillListCount <= 0 then
            self.m_nSkillListCount = table.count(skillList)
            if self.m_nSkillListCount > 0 then
                self:SetRuntimeData("SkillCount", self.m_nSkillListCount)
            end
        end
    end

    ---@type AIComponentNew
    local cAI = self.m_entityOwn:AI()
    cAI:SetSelectSkillID(self._skillID)

    return AINewNodeStatus.Success
end
