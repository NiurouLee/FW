---@class N28StateAVGStoryOption : N28StateAVGStoryBase
_class("N28StateAVGStoryOption", N28StateAVGStoryBase)
N28StateAVGStoryOption = N28StateAVGStoryOption

function N28StateAVGStoryOption:OnEnter(TT, ...)
    self:Init()
    self.poolOptions = self.ui.poolOptions
    self.poolInfluence = self.ui.poolInfluence
    self:ShowHideOption(true)
    self:ShowHideButtonAuto(false)
    self:ShowHideButtonShowHideUI(false)
    self:ShowHideButtonNext(false)
    self.storyManager = self.data:StoryManager()
    local storyId = self.storyManager:GetCurStoryID()
    local paragraphId = self.storyManager:GetCurParagraphID()
    local sectionIdx = self.storyManager:GetCurSectionIndex()
    self:FlushOptions(storyId, paragraphId, sectionIdx)
end

function N28StateAVGStoryOption:OnExit(TT)
    self:ShowHideOption(false)
    self:ShowHideButtonAuto(true)
    self:ShowHideButtonShowHideUI(true)
    self:ShowHideButtonNext(true)
end

function N28StateAVGStoryOption:FlushOptions(storyId, paragraphId, sectionIdx)
    local node = self.data:GetNodeByStoryId(storyId)
    local paragraph = node:GetParagraphByParagraphId(paragraphId)
    local dialog = paragraph:GetDialogBySectionIdx(sectionIdx)
    local options = dialog:GetVisibleOptions()
    if not options or table.count(options) <= 0 then
        AVGLog(
            "Not exist visible options. [storyId = " ..
                storyId .. "] [paragraphId = " .. paragraphId .. "] [sectionIdx=" .. sectionIdx .. "]"
        )
        self.fsm:ChangeState(StateAVGStory.Play)
        return
    end
    local len = table.count(options)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N28AVGShowPanel)
    self.poolOptions:SpawnObjects("UIN28AVGStoryOption", len)
    ---@type UIN28AVGStoryOption[]
    local uis = self.poolOptions:GetAllSpawnList()
    for i, option in ipairs(options) do
        local ui = uis[i]
        ui:Flush(
            option,
            len,
            function()
                GameGlobal.TaskManager():StartTask(
                    function(TT)
                        local key = "N28StateAVGStoryOptionChooseOption"
                        GameGlobal.UIStateManager():Lock(key)
                        self.ui.goOptionsAnim:Play("uieff_UIN28AVGStory_goOption_out")
                        YIELD(TT, 333)
                        local com = self.data:GetComponentAVG()
                        local res = AsyncRequestRes:New()
                        local ret = com:HandleManualChoose(TT, res, option.id) --【请求】点击选项
                        if N28AVGData.CheckCode(res) then
                            local nextParagraphId = option:NextParagraphId()
                            self.storyManager:SetNextParagraphID(nextParagraphId)
                            self:NextNodeId(option.nextNodeId) --设置下一个结点
                            self:DialogEnd(option.paragraphId, option.sectionIdx)
                            local playerName = GameGlobal.GetModule(RoleModule):GetName()
                            self.storyManager:AddDialogRecord(playerName, option:Content(), 1, true)
                            self.ui:SetSelectedOptionId(option.id, true)
                            self.fsm:ChangeState(StateAVGStory.Play)
                        else
                            Log.fatal(
                                "### HandleManualChoose failed. ",
                                option.storyId,
                                option.paragraphId,
                                option.sectionIdx,
                                option.index
                            )
                        end
                        GameGlobal.UIStateManager():UnLock(key)
                    end,
                    self
                )
            end,
            uis
        )
    end
    self:FlushInfluence(options)
    GameGlobal.UIStateManager():Lock("N28StateAVGStoryOption_FlushOptions")
    GameGlobal.TaskManager():StartTask(
        function(TT)
            YIELD(TT, 500)
            GameGlobal.UIStateManager():UnLock("N28StateAVGStoryOption_FlushOptions")
        end,
        self
    )
end

---@param options AVGStoryOption[]
function N28StateAVGStoryOption:FlushInfluence(options)
    ---@type UIN28AVGStoryInfluence
    self.influence = self.poolInfluence:SpawnObject("UIN28AVGStoryInfluence")
    self.influence:Flush(options)
end

function N28StateAVGStoryOption:DialogEnd(paragraphId, sectionIdx)
    local storyEntity = self:GetStoryDialogEntity(paragraphId, sectionIdx)
    if storyEntity then
        storyEntity:_DialogEnd()
    end
end

---@return N28StoryEntityAVGDialog 获取对话框StoryEntity
function N28StateAVGStoryOption:GetStoryDialogEntity(paragraphId, sectionIdx)
    local node = self.data:CurNode()
    local paragraph = node:GetParagraphByParagraphId(paragraphId)
    local dialog = paragraph:GetDialogBySectionIdx(sectionIdx)
    local entityId = dialog.refEntityId
    local storyEntity = self.storyManager._storyEntityList[entityId]
    return storyEntity
end
