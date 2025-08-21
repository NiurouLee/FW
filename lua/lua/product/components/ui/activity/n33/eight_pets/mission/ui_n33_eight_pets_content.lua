require("ui_side_enter_center_content_base")

---@class UIN33EightPetsContent : UISideEnterCenterContentBase
_class("UIN33EightPetsContent", UISideEnterCenterContentBase)
UIN33EightPetsContent = UIN33EightPetsContent

function UIN33EightPetsContent:DoInit(params)
    self._params = {}
    for k, v in pairs(params) do
        self._params[k] = v
    end

    self._inAnimationCompleted = false
    self._cdEnd = {tick = 0, period = 30000}

    ---@type UIActivityCampaign
    self._campaign = self._data
    self._eightComponent = self._campaign:GetComponent(ECampaignN33EightPetsMissionComponentID.ECAMPAIGN_N33_Eight_Pets_MISSION)

    self:EnableUpdate(true)
    self:InitWidget()
    self:CreateMission()
end

function UIN33EightPetsContent:DoShow()
    -- 清除 new
    self:StartTask(function(TT)
        self._campaign:ClearCampaignNew(TT)
    end)

    --检查活动是否开启
    if not self:InActivityTime() then
        self._campaign:CheckErrorCode(CampaignErrorType.E_CAMPAIGN_ERROR_TYPE_CAMPAIGN_FINISHED, nil, nil)
        return
    end

    self:FlushEndDuration()
    self:FlushMission()
    self:FlushPreferred()
    self:FlushDescription()
    self:InAnimation()
    self:UnlockAnimation()
end

function UIN33EightPetsContent:DoHide()
    self._inAnimationCompleted = false
end

function UIN33EightPetsContent:DoDestroy()

end

function UIN33EightPetsContent:DoUpdate(deltaTimeMS)
    self._cdEnd.tick = self._cdEnd.tick + deltaTimeMS
    if self._cdEnd.tick >= self._cdEnd.period then
        self._cdEnd.tick = 0
        self:FlushEndDuration()
    end
end

function UIN33EightPetsContent:InitWidget()
    self._descContent = self:GetUIComponent("UILocalizationText", "descContent")
    self._rmValue = self:GetUIComponent("UILocalizationText", "rmValue")
    self._missionScrollView = self:GetUIComponent("ScrollRect", "missionScrollView")
    self._missionContent = self:GetUIComponent("UISelectObjectPath", "missionContent")
    self._lineContent = self:GetUIComponent("UISelectObjectPath", "lineContent")
    self._animation = self:GetUIComponent("Animation", "animation")
end

function UIN33EightPetsContent:GetFormatTimerStr(deltaTime, txtColor)
    if self._idFormatTimer == nil then
        self._idFormatTimer =
        {
            ["day"] = "str_activity_common_day",
            ["hour"] = "str_activity_common_hour",
            ["min"] = "str_activity_common_minute",
            ["zero"] = "str_activity_common_less_minute",
            ["over"] = "str_activity_error_107",
            ["clrFormat"] = "<color=#%s>%s</color>"
        }
    end

    if txtColor == nil then
        txtColor = "171412"
    end

    local day = 0
    local hour = 0
    local min = 0
    local second = 0
    if deltaTime >= 0 then
        day, hour, min, second = UIActivityHelper.Time2Str(deltaTime)
    end

    local timeStr = nil
    local id = self._idFormatTimer
    if day > 0 and hour > 0 then
        timeStr = string.format(id.clrFormat, txtColor, day) .. StringTable.Get(id.day)
        timeStr = timeStr .. string.format(id.clrFormat, txtColor, hour) .. StringTable.Get(id.hour)
    elseif day > 0 then
        timeStr = string.format(id.clrFormat, txtColor, day) .. StringTable.Get(id.day)
    elseif hour > 0 and min > 0 then
        timeStr = string.format(id.clrFormat, txtColor, hour) .. StringTable.Get(id.hour)
        timeStr = timeStr .. string.format(id.clrFormat, txtColor, min) .. StringTable.Get(id.min)
    elseif hour > 0 then
        timeStr = string.format(id.clrFormat, txtColor, hour) .. StringTable.Get(id.hour)
    elseif min > 0 then
        timeStr = string.format(id.clrFormat, txtColor, min) .. StringTable.Get(id.min)
    else
        timeStr = string.format(id.clrFormat, txtColor, StringTable.Get(id.zero))
    end

    return timeStr
end

function UIN33EightPetsContent:FlushEndDuration()
    local endTime = self._eightComponent:GetComponentInfo().m_close_time
    local svrTimeModule = self:GetModule(SvrTimeModule)
    local curTime = math.floor(svrTimeModule:GetServerTime() * 0.001)
    local deltaTime = math.max(endTime - curTime, 0)
    local timerStr = self:GetFormatTimerStr(deltaTime)
    self._rmValue:SetText(timerStr)
end

function UIN33EightPetsContent:InActivityTime()
    local endTime = self._eightComponent:GetComponentInfo().m_close_time
    local svrTimeModule = self:GetModule(SvrTimeModule)
    local curTime = math.floor(svrTimeModule:GetServerTime() * 0.001)
    return endTime >= curTime
end

function UIN33EightPetsContent:NormalizeNode(rt, anchoredPosition)
    rt.pivot = Vector2.one * 0.5
    rt.localScale = Vector3.one
    rt.anchorMin = Vector2(0.5, 1)
    rt.anchorMax = Vector2(0.5, 1)
    rt.sizeDelta = Vector3.one * 100
    rt.anchoredPosition = anchoredPosition
end

function UIN33EightPetsContent:CreateMission()
    local componentID = self._eightComponent:GetComponentCfgId()
    local allMission = Cfg.cfg_component_eight_pets_mission{ComponentID = componentID}

    self._missions = {}
    for k, v in pairs(allMission) do
        local level =
        {
            structName = "UIN33EightPetsContent::Level",
            cfgEight = v,
            cfgMission = Cfg.cfg_eight_pets_mission[v.CampaignMissionId],
            isVisible = false,
            isLocked = false,
            nodeWidget = nil,
            lineWidget = nil,
        }

        table.insert(self._missions, level)
    end

    table.sort(self._missions, function(a, b)
        return a.cfgEight.ID < b.cfgEight.ID
    end)

    local count = #self._missions
    self._widgetNode = self._missionContent:SpawnObjects("UIN33EightPetsNode", count)
    self._widgetLine = self._lineContent:SpawnObjects("UIN33EightPetsLine", count)
    for k, v in pairs(self._missions) do
        local uiWidget = self._widgetNode[k]
        v.nodeWidget = uiWidget

        local view = uiWidget:View()
        local anchoredPosition = Vector2(v.cfgEight.NodePosX, v.cfgEight.NodePosY)
        self:NormalizeNode(view.transform, anchoredPosition)

        local uiWidget = self._widgetLine[k]
        v.lineWidget = uiWidget

        local view = uiWidget:View()
        local anchoredPosition = Vector2(v.cfgEight.LinePosX, v.cfgEight.LinePosY)
        self:NormalizeNode(view.transform, anchoredPosition)
    end

    self._widgetLine[count]:SetTail(true)
end

function UIN33EightPetsContent:FlushMission()
    local mapPass = self._eightComponent:GetComponentInfo().m_pass_mission_info

    local isVisible = true
    local isLocked = false
    for k, v in pairs(self._missions) do
        v.isVisible = isVisible
        v.isLocked = isLocked

        local widget = v.nodeWidget
        widget:SetData(self, v, isVisible, isLocked)

        local widget = v.lineWidget
        widget:SetData(self, v, isVisible, isLocked)

        isVisible = not isLocked
        isLocked = mapPass[v.cfgMission.MissionID] == nil
    end
end

function UIN33EightPetsContent:FlushPreferred()
    local theMaxY = 0
    for k, v in pairs(self._missions) do
        if v.isVisible then
            local transform = v.nodeWidget:GetGameObject().transform
            theMaxY = math.max(theMaxY, -transform.anchoredPosition.y)
        end
    end

    theMaxY = theMaxY + 200

    local content = self._missionContent:Engine().transform
    local sizeDelta = content.sizeDelta
    sizeDelta.y = theMaxY
    content.sizeDelta = sizeDelta

    self._missionScrollView.verticalNormalizedPosition = 0
end

function UIN33EightPetsContent:FlushDescription()
    local mission = nil
    for k, v in pairs(self._missions) do
        if not v.nodeWidget:IsLocked() then
            mission = v
        end
    end

    local desc = StringTable.Get(mission.cfgMission.Desc)
    self._descContent:SetText(desc)
end

function UIN33EightPetsContent:GetUnlockNode()
    if not self._eightComponent:IsPrevPassInfoValid() then
        return
    end

    local unlockMission = nil
    local prevPassInfo = self._eightComponent:GetPrevPassInfo()
    local mapPass = self._eightComponent:GetComponentInfo().m_pass_mission_info
    for k, v in pairs(mapPass) do
        if prevPassInfo[k] == nil then
            unlockMission = k
            break
        end
    end

    local unlockNode = nil
    local unlockNextNode = nil
    for k, v in pairs(self._missions) do
        if v.cfgEight.CampaignMissionId == unlockMission then
            unlockNode = self._missions[k + 1]
            unlockNextNode = self._missions[k + 2]
            break
        end
    end

    return unlockNode, unlockNextNode
end

function UIN33EightPetsContent:InAnimation()
    local lockName = "UIN33EightPetsContent:InAnimation"
    self:StartTask(function(TT)
        self:Lock(lockName)

        self._animation:Play("effanim_UIN33EightPetsContent_in")
        YIELD(TT, 333)

        self:UnLock(lockName)

        self._inAnimationCompleted = true
    end)
end

function UIN33EightPetsContent:UnlockAnimation()
    local unlockNode = nil
    local unlockNextNode = nil
    unlockNode, unlockNextNode = self:GetUnlockNode()
    if unlockNode == nil then
        return
    end

    self._eightComponent:SavePrevPassInfo()

    local lockName = "UIN33EightPetsContent:UnlockAnimation"
    self:StartTask(function(TT)
        self:Lock(lockName)

        local hideLocked = false
        unlockNode.nodeWidget:SetData(self, unlockNode, unlockNode.isVisible, true)
        if hideLocked and unlockNextNode ~= nil then
            unlockNode.lineWidget:SetData(self, unlockNode, false, true)
            unlockNextNode.nodeWidget:SetData(self, unlockNextNode, false, true)
        end

        while not self._inAnimationCompleted do
            YIELD(TT)
        end

        local openName = unlockNode.nodeWidget:GetAnimationOpenName(unlockNode)
        unlockNode.nodeWidget:Flush(true)
        unlockNode.nodeWidget:PlayAnimation(openName)

        YIELD(TT, 333)

        unlockNode.nodeWidget:SetData(self, unlockNode, unlockNode.isVisible, unlockNode.isLocked)
        if hideLocked and unlockNextNode ~= nil then
            unlockNode.lineWidget:SetData(self, unlockNode, unlockNode.isVisible, unlockNode.isLocked)
            unlockNextNode.nodeWidget:SetData(self, unlockNextNode, unlockNextNode.isVisible, unlockNextNode.isLocked)

            local inName = unlockNextNode.nodeWidget:GetAnimationInName(unlockNode)
            unlockNextNode.nodeWidget:PlayAnimation(inName)
        end

        self:UnLock(lockName)
    end)
end

function UIN33EightPetsContent:OnNodeClick(go, nodeData)
    --检查活动是否开启
    if not self:InActivityTime() then
        self._campaign:CheckErrorCode(CampaignErrorType.E_CAMPAIGN_ERROR_TYPE_CAMPAIGN_FINISHED, nil, nil)
    elseif nodeData.nodeWidget:IsLocked() then
        ToastManager.ShowToast(StringTable.Get("str_n33_ep_m_lock_prompt"))
    else
        self._eightComponent:SavePrevPassInfo()
        self:ShowDialog("UIN33EightPetsStage", nodeData)
    end
end


---@class UIN33EightPetsNode:UICustomWidget
_class("UIN33EightPetsNode", UICustomWidget)
UIN33EightPetsNode = UIN33EightPetsNode

function UIN33EightPetsNode:OnShow()
    self._uiNormal = self:GetUIComponent("Image", "uiNormal")
    self._uiBoss = self:GetUIComponent("Image", "uiBoss")
    self._uiLocked = self:GetUIComponent("Image", "uiLocked")
    self._nameNormal = self:GetUIComponent("UILocalizationText", "nameNormal")
    self._nameBoss = self:GetUIComponent("UILocalizationText", "nameBoss")
    self._animation = self:GetUIComponent("Animation", "animation")
end

function UIN33EightPetsNode:OnHide()

end

function UIN33EightPetsNode:IsVisible()
    return self._isVisible
end

function UIN33EightPetsNode:IsLocked()
    return self._isLocked
end

function UIN33EightPetsNode:SetData(eightPets, data, isVisible, isLocked)
    self._eightPets = eightPets
    self._data = data
    self._isVisible = isVisible
    self._isLocked = isLocked

    self:Flush(false)
end

function UIN33EightPetsNode:Flush(lockedCover)
    self:GetGameObject():SetActive(self._isVisible)
    self._nameNormal:SetText(StringTable.Get(self._data.cfgMission.Name))
    self._nameBoss:SetText(StringTable.Get(self._data.cfgMission.Name))

    self._uiNormal.color = Color.white
    self._uiBoss.color = Color.white
    self._uiLocked.color = Color.white

    if lockedCover then
        self._uiNormal.gameObject:SetActive(self._data.cfgMission.Type ~= 2)
        self._uiBoss.gameObject:SetActive(self._data.cfgMission.Type == 2)
        self._uiLocked.gameObject:SetActive(self._isLocked)
    else
        self._uiNormal.gameObject:SetActive(self._data.cfgMission.Type ~= 2 and not self._isLocked)
        self._uiBoss.gameObject:SetActive(self._data.cfgMission.Type == 2 and not self._isLocked)
        self._uiLocked.gameObject:SetActive(self._isLocked)
    end
end

function UIN33EightPetsNode:BtnOnClick(go)
    self._eightPets:OnNodeClick(go, self._data)
end

function UIN33EightPetsNode:GetAnimationInName(unlockNode)
    local inName = nil
    if unlockNode == self._data then
        inName = "effanim_UIN33EightPetsNode_Lock_in"
    elseif self._data.isLocked then
        inName = "effanim_UIN33EightPetsNode_Lock_in"
    elseif self._data.cfgMission.Type == 2 then
        inName = "effanim_UIN33EightPetsNode_Boss_in"
    else
        inName = "effanim_UIN33EightPetsNode_Normal_in"
    end

    return inName
end

function UIN33EightPetsNode:GetAnimationOpenName(unlockNode)
    local openName = nil
    if self._data.cfgMission.Type == 2 then
        openName = "effanim_UIN33EightPetsNode_openBoss"
    else
        openName = "effanim_UIN33EightPetsNode_openNormal"
    end

    return openName
end

function UIN33EightPetsNode:PlayAnimation(animName)
    self._animation:Play(animName)
end


---@class UIN33EightPetsLine:UICustomWidget
_class("UIN33EightPetsLine", UICustomWidget)
UIN33EightPetsLine = UIN33EightPetsLine

function UIN33EightPetsLine:Constructor()
    self._isTail = false
end

function UIN33EightPetsLine:OnShow()
    self._imgRootLoader = self:GetUIComponent("RawImageLoader", "imgRoot")
    self._animation = self:GetUIComponent("Animation", "animation")
end

function UIN33EightPetsLine:OnHide()

end

function UIN33EightPetsLine:SetTail()
    self._isTail = true
end

function UIN33EightPetsLine:SetData(eightPets, data, isVisible, isLocked)
    self._eightPets = eightPets
    self._data = data
    self._isVisible = isVisible
    self._isLocked = isLocked

    self:Flush()
end

function UIN33EightPetsLine:Flush()
    local isVisible = self._isVisible
    isVisible = isVisible and not self._isLocked
    isVisible = isVisible and not self._isTail
    self:GetGameObject():SetActive(isVisible)

    if isVisible then
        self._imgRootLoader:LoadImage(self._data.cfgEight.LineImage)
    end
end