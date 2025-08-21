---@class UIN9SubjectNormalDetailController: UIController
_class("UIN9SubjectNormalDetailController", UIController)
UIN9SubjectNormalDetailController = UIN9SubjectNormalDetailController

function UIN9SubjectNormalDetailController:OnShow(uiParams)
    ---@type UIN9SubjectLevelData
    self._levelData = uiParams[1]
    self._tittleLabel = self:GetUIComponent("UILocalizationText", "Tittle")
    self._tittleBgLabel = self:GetUIComponent("UILocalizationText", "TitleBg")
    self._desLabel = self:GetUIComponent("UILocalizationText", "Des")
    self._hasGetPanel = self:GetGameObject("HasGet")
    self._normalSelected = self:GetGameObject("NormalSelected")
    self._middleSelected = self:GetGameObject("MiddleSelected")
    self._hardSelected = self:GetGameObject("HardSelected")
    self._normalComplete = self:GetGameObject("NormalComplete")
    self._middleComplete = self:GetGameObject("MiddleComplete")
    self._hardComplete = self:GetGameObject("HardComplete")
    self._normalBtnGo = self:GetGameObject("NoramlBtn")
    self._middleBtnGo = self:GetGameObject("MiddleBtn")
    self._hardBtnGo = self:GetGameObject("HardBtn")
    self._normalTittleLabel = self:GetUIComponent("UILocalizationText", "NormalTitle")
    self._middleTittleLabel = self:GetUIComponent("UILocalizationText", "MiddleTitle")
    self._hardTittleLabel = self:GetUIComponent("UILocalizationText", "HardTitle")

    self._gradeSelectedArr = {
        [1] = self._normalSelected,
        [2] = self._middleSelected,
        [3] = self._hardSelected
    }
    self._gradeCompletedArr = {
        [1] = self._normalComplete,
        [2] = self._middleComplete,
        [3] = self._hardComplete
    }
    self._gradeBtnArr = {
        [1] = self._normalBtnGo,
        [2] = self._middleBtnGo,
        [3] = self._hardBtnGo
    }
    self._gradeTitleArr = {
        [1] = self._normalTittleLabel,
        [2] = self._middleTittleLabel,
        [3] = self._hardTittleLabel
    }
    
    local s = self:GetUIComponent("UISelectObjectPath", "itemTips")
    ---@type UISelectInfo
    self._tips = s:SpawnObject("UISelectInfo")
    self._currentGrade = nil
    self:AttachEvent(GameEventType.OnN9SubjectRewardItemClicked, self.ShowTips)

    local gradeDatas = self._levelData:GetLevelGradeList()

    for k, v in pairs(self._gradeBtnArr) do
        v:SetActive(false)
    end
    for k, v in pairs(self._gradeCompletedArr) do
        v:SetActive(false)
    end
    for k, v in pairs(self._gradeSelectedArr) do
        v:SetActive(false)
    end

    for i = 1, #gradeDatas do
        local grade = gradeDatas[i]
        if self._gradeBtnArr[grade] then
            self._gradeBtnArr[grade]:SetActive(true)
        end
        if self._gradeTitleArr[grade] then
            self._gradeTitleArr[grade]:SetText(StringTable.Get("str_activity_n9_normal_level_detail_btn_grade" .. grade))
        end
        ---@type UIN9SubjectLevelGradeData
        local gradeData = self._levelData:GetLeveGrade(grade)
        if gradeData then
            if self._gradeCompletedArr[grade] then
                self._gradeCompletedArr[grade]:SetActive(gradeData:GetHasComplete())
            end
        end
    end

    if gradeDatas and #gradeDatas > 0 then
        self:SelectGrade(gradeDatas[1], true)
    end
end

function UIN9SubjectNormalDetailController:OnHide()
    self:DetachEvent(GameEventType.OnN9SubjectRewardItemClicked, self.ShowTips)
end

function UIN9SubjectNormalDetailController:ShowTips(itemId, pos)
    self._tips:SetData(itemId, pos)
end

function UIN9SubjectNormalDetailController:SelectGrade(grade, isInit)
    if self._currentGrade == grade then
        return
    end

    if not self._levelData then
        return
    end

    ---@type UIN9SubjectLevelGradeData
    local gradeData = self._levelData:GetLeveGrade(grade)

    if not gradeData then
        return
    end

    local refreshUI = function()
        self._currentGrade = grade
        self._tittleLabel:SetText(gradeData:GetName())
        self._tittleBgLabel:SetText(gradeData:GetName())
        self._desLabel:SetText(gradeData:GetDes())
        for k, v in pairs(self._gradeSelectedArr) do
            v:SetActive(k == self._currentGrade)
        end
        self._hasGetPanel:SetActive(gradeData:GetHasComplete())
        local rewards = gradeData:GetRewards()
        self._rewardsLoader = self:GetUIComponent("UISelectObjectPath", "Rewards")
        self._rewardsLoader:SpawnObjects("UIN9SubjectRewardItem", #rewards)
        local items = self._rewardsLoader:GetAllSpawnList()
        for i = 1, #items do
            items[i]:Refresh(rewards[i], gradeData:GetHasComplete())
        end
    end

    if isInit then
        refreshUI()
        return
    end

    self:StartTask(function(TT)
                self:Lock("UIN9SubjectNormalDetailController_SelectGrade")
                local anim = self:GetUIComponent("Animation", "Anim")
                anim:Play("uieff_Subject_Switch_fade")
                YIELD(TT, 70)
                anim:Play("uieff_Subject_Switch")
                refreshUI()
                self:UnLock("UIN9SubjectNormalDetailController_SelectGrade")
            end)
end

function UIN9SubjectNormalDetailController:NoramlBtnOnClick()
    self:SelectGrade(1)
end

function UIN9SubjectNormalDetailController:MiddleBtnOnClick()
    self:SelectGrade(2)
end

function UIN9SubjectNormalDetailController:HardBtnOnClick()
    self:SelectGrade(3)
end

function UIN9SubjectNormalDetailController:MaskOnClick()
    self:CloseDialog()
end

function UIN9SubjectNormalDetailController:BtnStartTestOnClick()
    ---@type UIN9SubjectLevelGradeData
    local grade = self._levelData:GetLeveGrade(self._currentGrade)
    self:ShowDialog("UIN9AnswerController",grade,self._levelData:GetLeveGrade(self._currentGrade))
    self:CloseDialog()
end
