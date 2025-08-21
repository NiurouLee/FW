--
---@class UIFeatureScanController : UIController
_class("UIFeatureScanController", UIController)
UIFeatureScanController = UIFeatureScanController

---@param res AsyncRequestRes
function UIFeatureScanController:LoadDataOnEnter(TT, res)
    res:SetSucc(true)
end
--初始化
function UIFeatureScanController:OnShow(uiParams)
    self:InitWidget()

    self._lastTimeSelection = FeatureServiceHelper.FeatureScanGetCurrentSelection()
    self._dataActiveSkillType = self._lastTimeSelection.skillType
    self._dataTrapID = self._lastTimeSelection.trapID

    ---@type FeatureEffectParamScan
    local featureData = FeatureServiceHelper.GetFeatureData(FeatureType.Scan)

    self.activeSkill1Desc:SetText(StringTable.Get(featureData:GetFeatureSummonTrapDescKey() or ""))

    if self._dataActiveSkillType then
        local skillType = self._lastTimeSelection.skillType
        self.activeSkill1Selected:SetActive(skillType == ScanFeatureActiveSkillType.SummonTrap)
    end

    self._scanResult = FeatureServiceHelper.FeatureScanGetScanTrapIDList()
    self.trapListEmpty:SetActive(#self._scanResult == 0)
    if #self._scanResult > 0 then
        table.sort(self._scanResult, function (a, b)
            local cfgTrapScanA = Cfg.cfg_trap_scan[a]
            local cfgTrapScanB = Cfg.cfg_trap_scan[b]
            return cfgTrapScanA.SortOrder < cfgTrapScanB.SortOrder
        end)

        self.trapListContent:SpawnObjects("UIFeatureScanTrapElement", #self._scanResult)
        ---@type UIFeatureScanTrapElement[]
        local spawnItems = self.trapListContent:GetAllSpawnList()
        for index, element in ipairs(spawnItems) do
            local id = self._scanResult[index]
            local isSelected = (self._dataActiveSkillType == ScanFeatureActiveSkillType.SummonScanTrap) and (self._dataTrapID == id)
            element:SetData(index, id, isSelected, nil)
            element:SetElementSelectedCallback(function (i)
                self:_TrapElementSelectedCallback(i)
            end)
            if isSelected then
                ---@type CfgTrapScan
                local cfgTrapScan = Cfg.cfg_trap_scan[self._dataTrapID]
                self.trapText:SetText(StringTable.Get(cfgTrapScan.Desc))
            end
        end
    end
end

function UIFeatureScanController:_TrapElementSelectedCallback(index)
    self._dataTrapID = self._scanResult[index]
    self._dataActiveSkillType = ScanFeatureActiveSkillType.SummonScanTrap

    self.activeSkill1Selected:SetActive(false)

    ---@type UIFeatureScanTrapElement[]
    local spawnItems = self.trapListContent:GetAllSpawnList()
    for i, element in ipairs(spawnItems) do
        element:SetSelected(i == index)
    end

    ---@type CfgTrapScan
    local cfgTrapScan = Cfg.cfg_trap_scan[self._dataTrapID]
    self.trapText:SetText(StringTable.Get(cfgTrapScan.Desc))
end

function UIFeatureScanController:OnHide()
    self._dataActiveSkillType = nil
    self._dataTrapID = nil

    self._dataForceMovementDisabled = nil
end

--获取ui组件
function UIFeatureScanController:InitWidget()
    --允许模拟输入
    self.enableFakeInput = true
    --generated--
    ---@type UICustomWidgetPool
    self.commonBtnsContainer = self:GetUIComponent("UISelectObjectPath", "commonBtnsContainer")
    ---@type UICustomWidgetPool
    self.trapListContent = self:GetUIComponent("UISelectObjectPath", "trapListContent")
    ---@type UILocalizationText
    self.trapText = self:GetUIComponent("UILocalizationText", "trapText")
    ---@type UnityEngine.UI.Image
    self.activeSkill1Selected = self:GetGameObject("activeSkill1Selected")
    ---@type UnityEngine.UI.Image
    self.tachie = self:GetUIComponent("Image", "tachie")
    self.trapListEmpty = self:GetGameObject("trapListEmpty")
    self.activeSkill1Desc = self:GetUIComponent("UILocalizationText", "activeSkill1Desc")
    --generated end--

    self.activeSkill1Selected:SetActive(false)

    self._commonBtns = self:GetUIComponent("UISelectObjectPath", "commonBtnsContainer"):SpawnObject("UICommonTopButton")
    self._commonBtns:SetData(function ()
        self:SaveScanResultAndExit()
    end)
    self._commonBtns:HideHomeBtn()
end

function UIFeatureScanController:SaveScanResultAndExit()
    if self._dataActiveSkillType then
        GameGlobal.EventDispatcher():Dispatch(GameEventType.ScanFeatureSaveInfo, {
            skillType = self._dataActiveSkillType,
            trapID = self._dataTrapID
        })
    end
    self:CloseDialog()
end

--按钮点击
function UIFeatureScanController:ButtonActiveSkill1OnClick(go)
    self.activeSkill1Selected:SetActive(true)

    ---@type UIFeatureScanTrapElement[]
    local spawnItems = self.trapListContent:GetAllSpawnList()
    for i, element in ipairs(spawnItems) do
        element:SetSelected(false)
    end

    self._dataActiveSkillType = ScanFeatureActiveSkillType.SummonTrap
    self.trapText:SetText("")
end

function UIFeatureScanController:SafeAreaOnClick(go)
    self:SaveScanResultAndExit()
end

--底下这几个是防上面SafeArea关闭用的
function UIFeatureScanController:EmptyOnClick(go)

end

function UIFeatureScanController:TrapDescOnClick(go)

end

function UIFeatureScanController:TrapListOnClick(go)

end

function UIFeatureScanController:GuideStepGetElement1()
    ---@type UIFeatureScanTrapElement[]
    local spawnItems = self.trapListContent:GetAllSpawnList()
    return spawnItems[1]:GetGameObject()
end

function UIFeatureScanController:GuideStepGetElement2()
    ---@type UIFeatureScanTrapElement[]
    local spawnItems = self.trapListContent:GetAllSpawnList()
    return spawnItems[2]:GetGameObject()
end

--按钮点击
--function UIFeatureScanController:ButtonActiveSkill2OnClick(go)
--    if self._dataForceMovementDisabled then
--        return
--    end
--
--    self.activeSkill1Selected:SetActive(false)
--
--    ---@type UIFeatureScanTrapElement[]
--    local spawnItems = self.trapListContent:GetAllSpawnList()
--    for i, element in ipairs(spawnItems) do
--        element:SetSelected(false)
--    end
--
--    self._dataActiveSkillType = ScanFeatureActiveSkillType.ForceMovement
--    self.trapText:SetText("")
--end
