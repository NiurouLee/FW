---@class UITacticTapeInfo : UIController
_class("UITacticTapeInfo", UIController)
UITacticTapeInfo = UITacticTapeInfo
function UITacticTapeInfo:OnShow(uiParams)
    self:InitWidget()

    ---@type Item
    self._item = uiParams[1]
    self._activityN8 = uiParams[2]

    self._module = self:GetModule(AircraftModule)
    ---@type AircraftTacticRoom
    self._tacticRoom = self._module:GetRoomByRoomType(AirRoomType.TacticRoom)

    if self._activityN8 then
        -- 获取活动 以及本窗口需要的组件
        ---@type UIActivityCampaign
        self._campaign = UIActivityCampaign:New()
        self._campaign:LoadCampaignInfo_Local(ECampaignType.CAMPAIGN_TYPE_N8)
    end

    if self._item == nil then
        AirError("传入的卡带数据为空")
        return
    end
    AirLog("打开卡带详情:", self._item:GetTemplateID(), "，pstid:", self._item:GetID())

    self._cfg = Cfg.cfg_item_cartridge[self._item:GetTemplateID()]

    self._isBlackFist =
        self._cfg.MatchComId == ECampaignMissionComponentId.ECampaignMissionComponentId_AircraftBlackfist or
        self._cfg.MatchComId == ECampaignMissionComponentId.ECampaignMissionComponentId_SimulatorBlackfist

    self.title:SetText(StringTable.Get(self._item:GetTemplate().Name))
    self._titleOutline:SetText(StringTable.Get(self._item:GetTemplate().Name))
    self.des:SetText(StringTable.Get(self._item:GetTemplate().Intro))
    self.icon:LoadImage(self._item:GetTemplate().Icon)
    self._quality:SetText(self._cfg.Quality)

    ---@type UIEnemyMsg
    self._enemyMsg = self.enemyMsg:SpawnObject("UIEnemyMsg")

    self._difficulty = 1
    self:refreshDiff()

    if self._item:IsNewOverlay() then
        self:StartTask(self.cancelNew, self)
    end

    local anim = self:GetGameObject():GetComponent(typeof(UnityEngine.Animation))
    self._player = EZTL_Player:New()
    self._tl =
        EZTL_Sequence:New(
        {
            EZTL_Callback:New(
                function()
                    self:Lock("PlaySwitchDiffAnim")
                end
            ),
            EZTL_PlayAnimation:New(anim, "uieff_TapeInfo_Switch1"),
            EZTL_Callback:New(
                function()
                    self:refreshDiff()
                end
            ),
            EZTL_PlayAnimation:New(anim, "uieff_TapeInfo_Switch2"),
            EZTL_Callback:New(
                function()
                    self:UnLock("PlaySwitchDiffAnim")
                end
            )
        },
        "难度切换动画"
    )
    self:_TriggerGuide()
end

function UITacticTapeInfo:_TriggerGuide()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.GuideOpenUI, GuideOpenUI.UITacticTapeInfo)
end

function UITacticTapeInfo:OnHide()
    if self._player:IsPlaying() then
        self._player:Stop()
    end
end

function UITacticTapeInfo:cancelNew(TT)
    self:GetModule(ItemModule):SetItemUnnewOverlay(TT, self._item:GetID())
    GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftTacticTapeCancelNew, self._item:GetID())
end

function UITacticTapeInfo:changeDiff(diff)
    if self._difficulty == diff then
        return
    end
    AirLog("切换卡带难度:", self._difficulty, "->", diff)
    if self._difficulty then
        self._btns[self._difficulty]:OnSelect(false)
    end
    self._difficulty = diff

    self._player:Play(self._tl)
end

function UITacticTapeInfo:refreshDiff()
    self._btns[self._difficulty]:OnSelect(true)

    --怪物列表和词缀
    if self._isBlackFist then
        self._enemyInfo:SetActive(false)
        self._blackFistEnemy:SetActive(true)

        local hardCfg = Cfg.cfg_blackfist_hard[self._cfg.HardProID[self._difficulty]]
        local squadCfg = Cfg.cfg_blackfist_squads[self._cfg.SquadsID[self._difficulty]]
        local atlasProperty = self:GetAsset("Property.spriteatlas", LoadType.SpriteAtlas)
        self._blackFistEnemyInfo:SpawnObjects("UIBlackfistEnemyItem", 5)
        ---@type table<number,UIBlackfistEnemyItem>
        local ememies = self._blackFistEnemyInfo:GetAllSpawnList()
        local datas = {}
        for i = 1, 5 do
            local dt = {}
            local petid = squadCfg["CfgPetId" .. i]
            local petCfg = Cfg.cfg_pet[petid]
            local skinCfg = Cfg.cfg_pet_skin[petCfg.SkinId]
            dt.petid = petid
            dt.elemt1 =
                atlasProperty:GetSprite(
                UIPropertyHelper:GetInstance():GetColorBlindSprite(Cfg.cfg_pet_element[petCfg.FirstElement].Icon)
            )
            if petCfg.SecondElement > 0 then
                if hardCfg.Grade >= petCfg.Element2NeedGrade then
                    dt.elemt2 =
                        atlasProperty:GetSprite(
                        UIPropertyHelper:GetInstance():GetColorBlindSprite(
                            Cfg.cfg_pet_element[petCfg.SecondElement].Icon
                        )
                    )
                end
            end
            dt.lv = hardCfg.Lv
            dt.awakening = hardCfg.Awakening
            dt.grade = hardCfg.Grade
            dt.equip = hardCfg.Equip
            dt.skin = skinCfg.TeamBody
            dt.battleMe = skinCfg.BattleMes
            datas[i] = dt
        end
        for i = 1, 5 do
            ememies[i]:SetData(i, datas)
        end

        --黑拳推荐等级读卡带的配置
        local awake = self._cfg.RecommendAwaken[self._difficulty]
        local level = self._cfg.RecommendLV[self._difficulty]
        if awake > 0 then
            self._bf_awake.gameObject:SetActive(true)
            self._bf_awake:SetText(
                StringTable.Get("str_pet_config_common_advance") .. "<size=29>" .. awake .. "</size>"
            )
        else
            self._bf_awake.gameObject:SetActive(false)
        end
        self._bf_level:SetText("Lv." .. level)

        --黑拳没有词缀
        self._wordParent:SetActive(false)
    else
        self._enemyInfo:SetActive(true)
        self._blackFistEnemy:SetActive(false)
        local missionCfg = Cfg.cfg_campaign_mission[self._cfg.MissionID[self._difficulty]]
        if not missionCfg then
            Log.exception("cfg_campaign_mission表中找不到关卡:", self._cfg.MissionID[self._difficulty], ",卡带id:", self._cfg.ID)
        end
        self._enemyMsg:SetData(missionCfg.FightLevel)

        local wordText = nil
        local buff = missionCfg.BaseWordBuff
        if buff then
            if type(buff) == "table" then
                if #buff > 0 then
                    for _, wordId in ipairs(buff) do
                        local word = Cfg.cfg_word_buff[wordId]
                        if not word then
                            Log.exception("cfg_word_buff中找不到词缀:", wordId, "，MissionID:", missionCfg.CampaignMissionId)
                        end
                        local desc = StringTable.Get(word.Desc)
                        if wordText then
                            wordText = wordText .. "\n" .. desc
                        else
                            wordText = desc
                        end
                    end
                end
            else
                if buff > 0 then
                    local word = Cfg.cfg_word_buff[buff]
                    if not word then
                        Log.exception("cfg_word_buff中找不到词缀:", buff, "，MissionID:", missionCfg.CampaignMissionId)
                    end
                    wordText = StringTable.Get(word.Desc)
                end
            end
        end
        if wordText then
            self._wordText:SetText(wordText)
            self._wordParent:SetActive(true)
        else
            self._wordParent:SetActive(false)
        end
        --推荐等级
        local awake = self._cfg.RecommendAwaken[self._difficulty]
        local level = self._cfg.RecommendLV[self._difficulty]
        if awake > 0 then
            self.awake.gameObject:SetActive(true)
            self.awake:SetText(StringTable.Get("str_pet_config_common_advance") .. "<size=29>" .. awake .. "</size>")
        else
            self.awake.gameObject:SetActive(false)
        end
        self.level:SetText("Lv." .. level)
    end

    --奖励
    local dropItems = {}
    local fixedDrop =
        UICommonHelper:GetInstance():GetDropByAwardType(
        AwardType.Pass,
        {PassFixDropId = self._cfg.PassFixDropId[self._difficulty]},
        false
    )

    if not self._activityN8 then
        ---@type table<number,RoleAsset>
        local extraDrop = self._tacticRoom:GetCartridgeExtraAwards(self._item:GetID()) --额外掉落
        -- extraDrop = {{assetid = RoleAssetID.RoleAssetGold, count = 1}}
        if extraDrop then
            table.sort(
                extraDrop,
                function(a, b)
                    local cfga = Cfg.cfg_item[a.assetid]
                    local cfgb = Cfg.cfg_item[b.assetid]
                    if cfga.Color ~= cfgb.Color then
                        return cfga.Color > cfgb.Color
                    end
                    if cfga.BagSortIndex ~= cfgb.BagSortIndex then
                        return cfga.BagSortIndex > cfgb.BagSortIndex
                    end
                    return cfga.ID < cfgb.ID
                end
            )
            local tmp = {}
            for i, item in ipairs(extraDrop) do
                tmp[i] = {ItemID = item.assetid, Count = item.count, Type = UIItemRandomType.TeBieDiaoLuo}
            end
            table.appendArray(dropItems, tmp)
        end
    end
    table.appendArray(dropItems, fixedDrop) --固定掉落
    if self._cfg.CPassRandomAward then
        table.appendArray(dropItems, self._cfg.CPassRandomAward[self._difficulty]) --随机掉落
    end

    self.awardContent:SpawnObjects("UIItem", #dropItems)
    ---@type UIItem[]
    local items = self.awardContent:GetAllSpawnList()
    for i, item in ipairs(dropItems) do
        items[i]:SetForm(UIItemForm.Tactic, UIItemScale.Level3)
        local cfgItem = Cfg.cfg_item[item.ItemID]
        if not cfgItem then
            Log.exception("cfg_item表中找不到配置:", item.ItemID)
        end
        items[i]:SetData(
            {
                text1 = item.Count,
                icon = cfgItem.Icon,
                -- awardText = awardText,
                itemId = item.ItemID,
                quality = cfgItem.Color,
                topText = UIEnum.ItemRandomStr(item.Type),
                type = item.Type
            }
        )
        items[i]:SetClickCallBack(
            function(go)
                if self.matTipInfo == nil then
                    ---@type UISelectInfo
                    self.matTipInfo = self.matTip:SpawnObject("UISelectInfo")
                end
                self.matTipInfo:SetData(item.ItemID, go.transform.position)
            end
        )
    end
end

function UITacticTapeInfo:InitWidget()
    --generated--
    ---@type RawImageLoader
    self.icon = self:GetUIComponent("RawImageLoader", "icon")
    ---@type UILocalizationText
    self.title = self:GetUIComponent("UILocalizationText", "title")
    ---@type UILocalizationText
    self.des = self:GetUIComponent("UILocalizationText", "des")
    ---@type UICustomWidgetPool
    self.enemyMsg = self:GetUIComponent("UISelectObjectPath", "enemyMsg")
    ---@type UILocalizationText
    self.recommendLV = self:GetUIComponent("UILocalizationText", "recommendLV")
    ---@type UICustomWidgetPool
    self.awardContent = self:GetUIComponent("UISelectObjectPath", "AwardContent")
    --generated end--
    self.matTip = self:GetUIComponent("UISelectObjectPath", "matTip")
    self.awake = self:GetUIComponent("UILocalizationText", "awake")
    self.level = self:GetUIComponent("UILocalizationText", "level")

    ---@type UICustomWidgetPool
    local btns = self:GetUIComponent("UISelectObjectPath", "btns")

    btns:SpawnObjects("UITacticDiffBtn", 3)
    ---@type table<number, UITacticDiffBtn>
    self._btns = btns:GetAllSpawnList()
    for i = 1, 3 do
        self._btns[i]:SetData(
            i,
            function(diff)
                self:changeDiff(diff)
            end
        )
    end

    self._titleOutline = self:GetUIComponent("UILocalizationText", "titleoutline")

    self._wordParent = self:GetGameObject("words")
    ---@type UILocalizationText
    self._wordText = self:GetUIComponent("UILocalizationText", "word")

    self._quality = self:GetUIComponent("UILocalizationText", "quality")

    self._blackFistEnemy = self:GetGameObject("blackFistEnemy")
    ---@type UICustomWidgetPool
    self._blackFistEnemyInfo = self:GetUIComponent("UISelectObjectPath", "blackfistEnemyInfo")
    self._enemyInfo = self:GetGameObject("enemyInfo")

    self._bf_awake = self:GetUIComponent("UILocalizationText", "bf_awake")
    self._bf_level = self:GetUIComponent("UILocalizationText", "bf_level")
end

function UITacticTapeInfo:deleteTape(TT)
    if self._activityN8 then
        self:deleteTapeN8(TT)
        return
    end

    self:Lock(self:GetName())
    AirLog("删除卡带:", self._item:GetTemplateID(), "，pstid:", self._item:GetID())
    local res = self._module:RequestDeleteCartridge(TT, self._item:GetID())
    self:UnLock(self:GetName())
    if res:GetSucc() then
        self:CloseDialog()
        local room = self._module:GetRoomByRoomType(AirRoomType.TacticRoom)
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftTacticRefreshTapeList)
        --刷洗设施信息
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftTryRefreshRoomUI, room:SpaceId(), false)
        --刷新3dui
        GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftRefreshRoomUI, room:SpaceId())
    else
        ToastManager.ShowToast(self._module:GetErrorMsg(res:GetResult()))
    end
end

function UITacticTapeInfo:deleteTapeN8(TT)
    ---@type CombatSimulatorComponent
    local component = self._campaign:GetComponentByType(CampaignComType.E_CAMPAIGN_COM_CombatSimulator, 1)

    self:Lock(self:GetName() .. ":deleteTapeN8()")
    local res = AsyncRequestRes:New()
    component:HandleCombatSimulatorComponentDelCartridge(TT, res, self._item:GetID())
    self:UnLock(self:GetName() .. ":deleteTapeN8()")

    if not res:GetSucc() then
        self._campaign:CheckErrorCode(res.m_result, self._campaign._id, nil, nil)
    end

    self:CloseDialog()
    GameGlobal.EventDispatcher():Dispatch(GameEventType.AircraftTacticRefreshTapeList)
end

function UITacticTapeInfo:playBtnOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N8DefaultClick)
    if self._activityN8 then
        self:_FightN8()
        return
    end

    --关卡id
    local missionID = self._cfg.MissionID[self._difficulty]
    --卡带pstid
    local cardPstID = self._item:GetID()
    --难度id
    local hardID = self._difficulty

    AirLog("开始战斗:", self._item:GetTemplateID(), "，pstid:", self._item:GetID(), "，难度:", hardID)

    local module = GameGlobal.GetModule(MissionModule)
    ---@type TeamsContext
    local ctx = module:TeamCtx()

    local matchComID, paramKetMap = self._module:GetCartridgeMatchParam(hardID, cardPstID)
    local param = {missionID, matchComID, paramKetMap}
    ctx:Init(TeamOpenerType.Air, param)

    --请求编队信息
    self:Lock("OnplayBtnOnClick")
    GameGlobal.TaskManager():StartTask(self.OnplayBtnOnClick, self)
end
function UITacticTapeInfo:OnplayBtnOnClick(TT)
    local res, teamInfo = self._module:RequestTacticFormationInfo(TT)
    self:UnLock("OnplayBtnOnClick")
    if res:GetSucc() then
        local module = GameGlobal.GetModule(MissionModule)
        ---@type TeamsContext
        local ctx = module:TeamCtx()
        ctx:InitAirTeam(teamInfo)
        self:ShowDialog("UITeams")
    else
        local result = res:GetResult()
        Log.error("###[UITacticTapeInfo] RequestTacticFormationInfo fail ! result --> ", result)
        ToastManager.ShowToast(self._module:GetErrorMsg(res:GetResult()))
    end
end

function UITacticTapeInfo:_FightN8()
    --关卡id
    local missionID = self._cfg.MissionID[self._difficulty]
    --卡带pstid
    local cardPstID = self._item:GetID()
    --难度id
    local hardID = self._difficulty
    AirLog("开始N8战斗:", self._item:GetTemplateID(), "，pstid:", self._item:GetID(), "，难度:", hardID)

    ---@type MissionModule
    local module = self:GetModule(MissionModule)

    ---@type CombatSimulatorComponent
    local component = self._campaign:GetComponentByType(CampaignComType.E_CAMPAIGN_COM_CombatSimulator, 1)

    -- local enough = false
    -- local roleModule = self:GetModule(RoleModule)
    -- local leftPower = roleModule:GetAssetCount(self._powerID)
    -- local enough = (leftPower >= self._needPower)
    -- if not enough then
    --     if self._powerID == RoleAssetID.RoleAssetPhyPoint then
    --         self:ShowDialog("UIGetPhyPointController")
    --     else
    --         local itemName = StringTable.Get(Cfg.cfg_item[self._powerID].Name)
    --         ToastManager.ShowToast(StringTable.Get("str_mission_error_power_not_enough", itemName))
    --     end
    --     return
    -- end

    ---@type TeamsContext
    local ctx = module:TeamCtx()
    ctx:Init(
        TeamOpenerType.Campaign,
        {
            missionID,
            component:GetCampaignMissionComponentId(cardPstID),
            component:GetCampaignMissionParamKeyMap(hardID, cardPstID)
        }
    )
    self:Lock("DoEnterTeam")
    ctx:ShowDialogUITeams()
end

function UITacticTapeInfo:delBtnOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N8DefaultClick)
    PopMsgBox(
        StringTable.Get("str_aircraft_tactic_delete_tape_tip"),
        function(param)
            --确定
            self:StartTask(self.deleteTape, self)
        end
    )
end
function UITacticTapeInfo:closeBtnOnClick(go)
    AirLog("关闭卡带详情")
    self:CloseDialog()
end
function UITacticTapeInfo:restrainBtnOnClick()
    self:ShowDialog("UIRestrainTips")
end

function UITacticTapeInfo:GetGuideBtn()
    if self._btns and #self._btns >= 2 then
        return self._btns[2].btn.gameObject
    end
    return nil
end
