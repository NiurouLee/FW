---@class UIActivityN27DiffLevelCupData:Object
_class("UIActivityN27DiffLevelCupData", Object)
UIActivityN27DiffLevelCupData = UIActivityN27DiffLevelCupData

function UIActivityN27DiffLevelCupData:Constructor(complete, id)
    self._isComplete = complete
    local cfg = Cfg.cfg_difficulty_mission_enties[id]
    if not cfg then
        Log.error("###[UIDiffStageCupItem] cfg is nil ! id --> ", id)
    end
    
    self._des = ""
    local cond = cfg.Cond
    if cond then
        local desc = cfg.Desc
        if desc then
            self._des = UIActivityN27DiffLevelCupData.GetDiffMissionEnties(desc)
        end
    end

    self._rewardCount = 0
    self._rewardIcon = ""
    local awards = cfg.Rewards
    if awards then
        self._rewardCount = awards[1][2]
        local itemId = awards[1][1]
        local cfg_item = Cfg.cfg_item[itemId]
        if not cfg_item then
            Log.error("###[UIDiffStageCupItem] cfg_item is nil ! id --> ",self._award.id)
        end
        self._rewardIcon = cfg_item.Icon
    end
end

function UIActivityN27DiffLevelCupData:IsComplete()
    return self._isComplete
end

function UIActivityN27DiffLevelCupData:GetDes()
    return self._des
end

function UIActivityN27DiffLevelCupData:GetRewardIcon()
    return self._rewardIcon
end

function UIActivityN27DiffLevelCupData:GetRewardCount()
    return self._rewardCount
end

function UIActivityN27DiffLevelCupData.CreateEntiesDesc()
    UIActivityN27DiffLevelCupData._entiesType2paramTex = {
        [EntiesType.ElementType_Prof] = {
            [PetProfType.PetProf_Color] = "str_pet_tag_job_name_color_change",
            [PetProfType.PetProf_Blood] = "str_pet_tag_job_name_return_blood",
            [PetProfType.PetProf_Attack] = "str_pet_tag_job_name_attack",
            [PetProfType.PetProf_Function] = "str_pet_tag_job_name_function",
        },
        [EntiesType.ElementType_Force] = {
            [PetForceType.PetForce_BaiYeCheng] = "str_pet_tag_faction_name_1",
            [PetForceType.PetForce_BaiYeXiaCheng] = "str_pet_tag_faction_name_2",
            [PetForceType.PetForce_QiGuang] = "str_pet_tag_faction_name_3",
            [PetForceType.PetForce_BeiJing] = "str_pet_tag_faction_name_4",
            [PetForceType.PetForce_HongYouBanShou] = "str_pet_tag_faction_name_5",
            [PetForceType.PetForce_TaiYangJiaoTuan] = "str_pet_tag_faction_name_6",
            [PetForceType.PetForce_YouMin] = "str_pet_tag_faction_name_7",
            [PetForceType.PetForce_RiShi] = "str_pet_tag_faction_name_8",
        },
        [EntiesType.ElementType_Elem] = {
            [ElementType.ElementType_Blue] = "str_pet_filter_water_element",
            [ElementType.ElementType_Red] = "str_pet_filter_fire_element",
            [ElementType.ElementType_Green] = "str_pet_filter_sen_element",
            [ElementType.ElementType_Yellow] = "str_pet_filter_electricity_element",
        },
    }
    UIActivityN27DiffLevelCupData._entiesType2tex = {
        [EntiesType.ElementType_None] = "str_diff_mission_enties_desc_3001",
        [EntiesType.ElementType_Level_Count] = "str_diff_mission_enties_desc_3007",
        [EntiesType.ElementType_Prof] = {
            [EntiesCompareType.ElementCompareType_All] = "str_diff_mission_enties_desc_3002_1",
            [EntiesCompareType.ElementCompareType_No] = "str_diff_mission_enties_desc_3002_2",
            [EntiesCompareType.ElementCompareType_Less] = "str_diff_mission_enties_desc_3002_3",
            [EntiesCompareType.ElementCompareType_More] = "str_diff_mission_enties_desc_3002_4",
            [EntiesCompareType.ElementCompareType_Equal] = "str_diff_mission_enties_desc_3002_5",
        },
        [EntiesType.ElementType_Force] = {
            [EntiesCompareType.ElementCompareType_All] = "str_diff_mission_enties_desc_3004_1",
            [EntiesCompareType.ElementCompareType_No] = "str_diff_mission_enties_desc_3004_2",
            [EntiesCompareType.ElementCompareType_Less] = "str_diff_mission_enties_desc_3004_3",
            [EntiesCompareType.ElementCompareType_More] = "str_diff_mission_enties_desc_3004_4",
            [EntiesCompareType.ElementCompareType_Equal] = "str_diff_mission_enties_desc_3004_5",
        },
        [EntiesType.ElementType_Star] = {
            [EntiesCompareType.ElementCompareType_All] = "str_diff_mission_enties_desc_3005_1",
            [EntiesCompareType.ElementCompareType_No] = "str_diff_mission_enties_desc_3005_2",
            [EntiesCompareType.ElementCompareType_Less] = "str_diff_mission_enties_desc_3005_3",
            [EntiesCompareType.ElementCompareType_More] = "str_diff_mission_enties_desc_3005_4",
            [EntiesCompareType.ElementCompareType_Equal] = "str_diff_mission_enties_desc_3005_5",
        },
        [EntiesType.ElementType_Elem] = {
            [EntiesCompareType.ElementCompareType_All] = "str_diff_mission_enties_desc_3006_1",
            [EntiesCompareType.ElementCompareType_No] = "str_diff_mission_enties_desc_3006_2",
            [EntiesCompareType.ElementCompareType_Less] = "str_diff_mission_enties_desc_3006_3",
            [EntiesCompareType.ElementCompareType_More] = "str_diff_mission_enties_desc_3006_4",
            [EntiesCompareType.ElementCompareType_Equal] = "str_diff_mission_enties_desc_3006_6",
        },
    }
end

function UIActivityN27DiffLevelCupData.GetDiffMissionEnties(enties)
    if not enties or not next(enties) then
        return ""
    end
    local entiesType = enties[1]
    if entiesType == EntiesType.ElementType_None then
        return StringTable.Get(UIActivityN27DiffLevelCupData._entiesType2tex[entiesType])
    elseif entiesType == EntiesType.ElementType_Level_Count then
        return StringTable.Get(UIActivityN27DiffLevelCupData._entiesType2tex[entiesType], enties[2])
    else
        local paramType = enties[2]
        local compareType = enties[3]
        local paramNum = enties[4]

        local typeStr = UIActivityN27DiffLevelCupData._entiesType2tex[entiesType][compareType]
        local paramStr
        if entiesType == EntiesType.ElementType_Star then
            paramStr = paramType
        else
            paramStr = StringTable.Get(UIActivityN27DiffLevelCupData._entiesType2paramTex[entiesType][paramType])
        end
       local desc = StringTable.Get(typeStr,paramStr,paramNum)
       return desc
    end
    return ""
end

---@class UIActivityN27DiffLevelData:Object
_class("UIActivityN27DiffLevelData", Object)
UIActivityN27DiffLevelData = UIActivityN27DiffLevelData

function UIActivityN27DiffLevelData:Constructor()
    self._name = ""
    self._nodeName = ""
    self._position = Vector2(0, 0)
    self._isParentLevel = false
    self._childLevels = {}
    self._isComplete = false
    self._isOpen = false
    self._cupDatas = {}
    self._team = {}
    self._recommendAwaken = 0
    self._recommendLV = 0
    self._levelId = nil
    self._missionId = 0
    self._levelType = 0
    self._openIcon = ""
    self._unOpenIcon = ""
    self._lockTips = ""
end

---@param component DifficultyMissionComponent
---@param componentInfo ClientCampaignDifficultyMissionInfo
---@param cfg cfg_difficulty_parent_mission
function UIActivityN27DiffLevelData:InitParentLevel(component, componentInfo, cfg)
    self._cfg = cfg
    self._missionId = cfg.ID
    self._levelId = 0
    self._name = StringTable.Get("str_n27_level_chapter_name")
    self._nodeName = StringTable.Get(cfg.Name)
    self._isParentLevel = true
    self._recommendAwaken = 0
    self._recommendLV = 0
    self._team = {}
    self._position = Vector2(0, 0)
    local pointId = cfg.WayPointId
    if pointId then
        local pointCfg = Cfg.cfg_diff_mission_way_point[pointId]
        if pointCfg then
            self._position = Vector2(pointCfg.Pos[1],pointCfg.Pos[2])
        end
    end

    self._childLevels = {}
    local subMissionList = cfg.SubMissionList
    if subMissionList then
        for i = 1, #subMissionList do
            local level = UIActivityN27DiffLevelData:New()
            level:InitChildLevel(component, componentInfo, self._missionId, subMissionList[i])
            self._childLevels[#self._childLevels + 1] = level
        end
    end
    self:RefreshParentLevel(component, componentInfo)
end

---@param component DifficultyMissionComponent
---@param componentInfo ClientCampaignDifficultyMissionInfo
function UIActivityN27DiffLevelData:RefreshParentLevel(component, componentInfo)
    for i = 1, #self._childLevels do
        self._childLevels[i]:RefreshChildLevel(component, componentInfo, self._missionId)
    end
    
    self._cupDatas = {}
    ---@type ParentMissionInfo
    local parentMissionInfo = componentInfo.infos[self._missionId]
    local enties = self._cfg.Enties
    for i = 1, #enties do
        local complete = false
        if parentMissionInfo then
            local completeEnties = parentMissionInfo.complete_enties
            if completeEnties then
                for j = 1, #completeEnties do
                    if completeEnties[j] == enties[i] then
                        complete = true
                        break
                    end
                end
            end
        end
        local cup = UIActivityN27DiffLevelCupData:New(complete, enties[i])
        self._cupDatas[#self._cupDatas + 1] = cup
    end

    if parentMissionInfo and parentMissionInfo.status == 1 then
        self._isComplete = true
    else
        self._isComplete = false
    end

    self._isOpen = false
    local diffCfg = Cfg.cfg_component_difficulty_mission{ ComponentID = component:GetComponentCfgId(), CampaignMissionId = self._missionId }
    if diffCfg then
        for k, v in pairs(diffCfg) do
            if v.NeedMissionId and v.NeedMissionId > 0 then
                ---@type ParentMissionInfo
                local preMissionInfo = componentInfo.infos[v.NeedMissionId]
                if preMissionInfo then
                    if preMissionInfo.status and preMissionInfo.status > 0 then
                        self._isOpen = true
                    end
                end
            else
                self._isOpen = true
            end
            self._openIcon = v.OpenIcon
            self._unOpenIcon = v.UnOpenIcon
            self._lockTips = StringTable.Get(v.LockTips)
            break
        end
    end
end

---@param component DifficultyMissionComponent
---@param componentInfo ClientCampaignDifficultyMissionInfo
function UIActivityN27DiffLevelData:InitChildLevel(component, componentInfo, parentMissionid, missionId)
    self._missionId = missionId
    local cfg = Cfg.cfg_difficulty_sub_mission[missionId] 

    self._name = StringTable.Get(cfg.MissionName)
    self._nodeName = self._name
    self._isParentLevel = false
    self._childLevels = {}
    self._cupDatas = {}
    self._recommendAwaken = cfg.RecommendAwaken
    self._recommendLV = cfg.RecommendLV
    self._levelId = cfg.FightLevel
    self._position = Vector2(0, 0)
    if cfg.Position then
        self._position = Vector2(cfg.Position[1], cfg.Position[2])
    end
    if cfg.type == 1 then
        self._levelType = DiffMissionType.Normal
    else
        self._levelType = DiffMissionType.Boss
    end
    --子关卡默认解锁
    self._isOpen = false
    self._isComplete = false
    self._team = {}
    self:RefreshChildLevel(component, componentInfo, parentMissionid)
end

---@param component DifficultyMissionComponent
---@param componentInfo ClientCampaignDifficultyMissionInfo
function UIActivityN27DiffLevelData:RefreshChildLevel(component, componentInfo, parentMissionid)
    ---@type SubMissionInfo
    local subMissionInfo = UIActivityN27DiffLevelData.SubLevelInfo(componentInfo, parentMissionid, self._missionId)
    if subMissionInfo then
        self._isComplete = true
        self._team = subMissionInfo.pet_list
    else
        self._isComplete = false
        self._team = {}
    end
end

function UIActivityN27DiffLevelData:GetOpenIcon()
    return self._openIcon
end

function UIActivityN27DiffLevelData:GetUnOpenIcon()
    return self._unOpenIcon
end

function UIActivityN27DiffLevelData:GetLockTips()
    return self._lockTips
end

function UIActivityN27DiffLevelData:GetLevelType()
    return self._levelType
end

function UIActivityN27DiffLevelData:GetMissionId()
    return self._missionId
end

function UIActivityN27DiffLevelData:GetName()
    return self._name
end

function UIActivityN27DiffLevelData:GetNodeName()
    return self._nodeName
end

function UIActivityN27DiffLevelData:GetPosition()
    return self._position
end

function UIActivityN27DiffLevelData:IsParentLevel()
    return self._isParentLevel
end

function UIActivityN27DiffLevelData:GetChildLevels()
    return self._childLevels
end

function UIActivityN27DiffLevelData:GetCompleteLevelCount()
    local count = 0
    for k, v in pairs(self._childLevels) do
        if v:IsComplete() then
            count = count + 1
        end
    end
    return count
end

function UIActivityN27DiffLevelData:IsComplete()
    return self._isComplete
end

function UIActivityN27DiffLevelData:IsOpen()
    return self._isOpen
end

function UIActivityN27DiffLevelData:GetCupDatas()
    return self._cupDatas
end

function UIActivityN27DiffLevelData:GetCompleteCupCount()
    local count = 0
    for k, v in pairs(self._cupDatas) do
        if v:IsComplete() then
            count = count + 1
        end
    end
    return count
end

function UIActivityN27DiffLevelData:GetTeam()
    return self._team
end

function UIActivityN27DiffLevelData:RecommendAwaken()
    return self._recommendAwaken
end

function UIActivityN27DiffLevelData:RecommendLV()
    return self._recommendLV
end

function UIActivityN27DiffLevelData:GetLevelId()
    return self._levelId
end

---@param componentInfo ClientCampaignDifficultyMissionInfo
function UIActivityN27DiffLevelData.SubLevelInfo(componentInfo, parentMissionId, missionId)
    ---@type ParentMissionInfo
    local parentMissionInfo = componentInfo.infos[parentMissionId]
    if not parentMissionInfo then
        return nil
    end

    for i = 1, #parentMissionInfo.sub_mission_infos do
        ---@type SubMissionInfo
        local missionInfo = parentMissionInfo.sub_mission_infos[i]
        if missionInfo.mission_id == missionId then
            return missionInfo
        end
    end
    return nil
end
