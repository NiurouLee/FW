--- @class UIN12EntrustLevelController:UIController
_class("UIN12EntrustLevelController", UIController)
UIN12EntrustLevelController = UIN12EntrustLevelController

--region help
function UIN12EntrustLevelController:_SpawnObject(widgetName, className)
    ---@type UICustomWidgetPool
    local pool = self:GetUIComponent("UISelectObjectPath", widgetName)
    local obj = pool:SpawnObject(className)
    return obj
end

function UIN12EntrustLevelController:_SpawnObjects(widgetName, className, count)
    ---@type UICustomWidgetPool
    local pool = self:GetUIComponent("UISelectObjectPath", widgetName)
    local objs = {}
    pool:SpawnObjects(className, count, objs)
    return objs
end

function UIN12EntrustLevelController:_PlayAnim(widgetName, animName, time, callback)
    local anim = self:GetUIComponent("Animation", widgetName)

    self:Lock(animName)
    anim:Play(animName)
    self:StartTask(
        function(TT)
            YIELD(TT, time)
            self:UnLock(animName)
            if callback then
                callback()
            end
        end,
        self
    )
end
--endregion

function UIN12EntrustLevelController:_InitWidget()
    local backBtns = self:GetUIComponent("UISelectObjectPath", "_backBtns")
    ---@type UICommonTopButton
    self._backBtns = backBtns:SpawnObject("UICommonTopButton")
    self._backBtns:SetData(
        function()
            self:ShowDialog(
                "UIN12MapCommonPopController",
                "",
                StringTable.Get("str_n12_map_exits_pop_title"),
                StringTable.Get("str_n12_map_exits_leave"),
                StringTable.Get("str_n12_map_exits_goon"),
                function()
                    self._campaign._campaign_module:CampaignSwitchState(
                        true,
                        UIStateType.UIN12EntrustStageController,
                        UIStateType.UIMain,
                        nil,
                        self._campaign._id
                    )
                end,
                function()
                    GameGlobal.UIStateManager():CloseDialog("UIN12MapCommonPopController")
                end
            )
        end,
        nil,
        nil,
        false
    )
    self._backBtns:HideHomeBtn()
end

--- @param TT 协程函数标识
--- @param res AsyncRequestRes 异步请求结果
function UIN12EntrustLevelController:LoadDataOnEnter(TT, res, uiParams)
    self._campaignType = ECampaignType.CAMPAIGN_TYPE_N12
    self._componentId = ECampaignN12ComponentID.ECAMPAIGN_N12_ENTRUST

    -- 获取活动 以及本窗口需要的组件
    ---@type UIActivityCampaign
    self._campaign = UIActivityCampaign:New()
    self._campaign:LoadCampaignInfo(TT, res, self._campaignType, self._componentId)

    ---@type EntrustComponent
    self._component = self._campaign:GetComponent(self._componentId)

    -- 错误处理
    if res and not res:GetSucc() then
        self._campaign:CheckErrorCode(res.m_result, nil, nil)
        return
    end
end

function UIN12EntrustLevelController:OnShow(uiParams)
    self:_AttachEvents()

    self._isOpen = true
    self._levelId = uiParams[1] or 0
    self._newNode = {}

    self:_InitWidget()
    self:_SetBg("bg")

    self:_Refresh()

    local showAnim = uiParams[2] or false
    if showAnim then
        local animNames = {
            [101501] = "uieff_Level_In",
            [101502] = "uieff_Level_In2",
            [101503] = "uieff_Level_In3",
            [101504] = "uieff_Level_In4",
            [101505] = "uieff_Level_In5",
            [101506] = "uieff_Level_In6"
        }
        self:_PlayAnim("root", animNames[self._levelId], 367)
    else
        self:_SetBg("bg_ori")
    end
end

function UIN12EntrustLevelController:OnHide()
    self:_DetachEvents()
    self._isOpen = false
end

function UIN12EntrustLevelController:_Refresh()
    self:_SetTreasureBox()
    self:_SetMapNode()
    self:_SetMapLine()
    self:_SetMapPlayer(self._startNode)
end

function UIN12EntrustLevelController:_SetBg(widgetName)
    local obj = self:GetUIComponent("RawImageLoader", widgetName)

    local tb = {
        [101501] = "n12_ewai_map_s1",
        [101502] = "n12_ewai_map_s2",
        [101503] = "n12_ewai_map_s3",
        [101504] = "n12_ewai_map_s4",
        [101505] = "n12_ewai_map_s5",
        [101506] = "n12_ewai_map_s6"
    }
    local url = tb[self._levelId]
    if url then
        obj:LoadImage(url)
    end
end

function UIN12EntrustLevelController:_SetTreasureBox()
    local txt = self._component:GetTreasureBoxText(self._levelId)

    ---@type UILocalizationText
    local obj = self:GetUIComponent("UILocalizationText", "_txtTreasureBox")
    obj:SetText(txt)
end

--region Map Node
function UIN12EntrustLevelController:_SetMapNode()
    -- Hack: Debug new node
    -- self:_Debug_ClearAllMapNodeAnimationKey()
    -- self:_Debug_ClearMapNodeAnimationKey({101506002, 101506003, 101506004})

    self._newNode = {}

    local tb = self._component:GetAllOpenEvents(self._levelId)
    -- local tb = {101501001, 101501002, 101501003, 101501004, 101501005, 101501006, 101501007} -- Hack: 所有需要显示的节点

    local count = table.count(tb)
    local objs = self:_SpawnObjects("Nodes", "UIN12EntrustLevelNode", count)

    for i, v in ipairs(objs) do
        v:SetData(
            self._component,
            self._levelId,
            tb[i],
            function(nodeId)
                self:_SetMapPlayer(nodeId)
            end
        )
        v:SetDebugText(tb[i])

        -- 判断新打开的节点，用来播放点和线的动效
        if self._component:GetEventType(tb[i]) ~= 1 then -- 起点除外
            local key = UIActivityN12Helper.GetMapNodeAnimationKey(tb[i])
            if LocalDB.GetInt(key, 0) == 0 then
                LocalDB.SetInt(key, 1)
                table.insert(self._newNode, tb[i])

                local cfg = Cfg.cfg_n12_entrust_anim[1]
                local delayTime = cfg.LevelNodeDelayTime
                v:PlayAnim(i, "_anim", "uieff_LevelNode_New", 300, 333) -- 间隔 300ms，播放 333ms
            end
        end
    end

    if count == 0 then
        Log.exception("UIN12EntrustLevelController:_SetMapNode() count == 0")
        return
    end

    self._startNode = tb and tb[1]
    local x = self._component:GetPlayerPos()
    if x ~= 0 then
        self._startNode = x
    end
    -- self._startNode = 101501001 -- Hack: Player 初始位置在哪个节点
end
--endregion

--region Map Line
function UIN12EntrustLevelController:_SetMapLine()
    local tb = self:_GetMapLinePos()
    local count = table.count(tb)
    local objs = self:_SpawnObjects("Lines", "UIN12EntrustLevelLine", count)

    for i, v in ipairs(objs) do
        v:SetPos(tb[i].from, tb[i].to)
        if tb[i].time then
            v:PlayAnim(i, "shape", tb[i].delayTime, tb[i].time)
        end
        v:SetDebugText(tb[i].id)
    end
end

function UIN12EntrustLevelController:_GetMapLinePos()
    local tb_out = {}

    local newLineMap = {}
    for _, v in ipairs(self._newNode) do
        local lineMap = self._component:GetOpenAdjacentLineByNode(self._levelId, v)
        for lineid, dir in pairs(lineMap) do
            if not newLineMap[lineid] then -- 防止重复的 line
                newLineMap[lineid] = true
                local posList = self._component:GetLinePosWithDirection(lineid, dir)
                for i, pos in ipairs(posList) do
                    local cfg = Cfg.cfg_n12_entrust_anim[1]
                    local sumTime = cfg.LevelLineTime -- 播放 333ms
                    local time = math.floor(sumTime / #posList)
                    local delayTime = (i - 1) * time -- 间隔时间 0ms
                    table.insert(
                        tb_out,
                        {
                            ["id"] = lineid,
                            ["from"] = pos[1],
                            ["to"] = pos[2],
                            ["delayTime"] = delayTime,
                            ["time"] = time
                        }
                    )
                end
            end
        end
    end

    local openLine = self._component:GetOpenEventLine(self._levelId)
    for _, lineid in ipairs(openLine) do
        if not newLineMap[lineid] then -- 防止重复的 line
            local posList = self._component:GetLinePosWithDirection(lineid)
            for i, pos in ipairs(posList) do
                table.insert(tb_out, {["id"] = lineid, ["from"] = pos[1], ["to"] = pos[2]})
            end
        end
    end
    return tb_out
end
--endregion

--region Map Player
function UIN12EntrustLevelController:_SetMapPlayer(nodeId)
    if not self._player then
        self._player = self:_SpawnObject("Player", "UIN12EntrustLevelPlayer")
    end

    self._player:SetData(self._component, nodeId)
    self._component:SetPlayerPos(nodeId)
end
--endregion

--region Event Callback
--活动说明
-- function UIN12EntrustLevelController:InfoBtnOnClick(go)
--     UIActivityHelper.ShowActivityIntro("UIN9Intro")
-- end
--endregion

--region AttachEvent
function UIN12EntrustLevelController:_AttachEvents()
    self:AttachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
    self:AttachEvent(GameEventType.OnN12CloseMapWindow, self._CloseMapWindow)
    self:AttachEvent(GameEventType.OnN12CloseMap, self._CloseMap)
end

function UIN12EntrustLevelController:_DetachEvents()
    self:DetachEvent(GameEventType.ActivityCloseEvent, self._CheckActivityClose)
    self:DetachEvent(GameEventType.OnN12CloseMapWindow, self._CloseMapWindow)
    self:DetachEvent(GameEventType.OnN12CloseMap, self._CloseMap)
end

function UIN12EntrustLevelController:_CheckActivityClose(id)
    if self._campaign and self._campaign._id == id then
        self:SwitchState(UIStateType.UIMain)
    end
end

function UIN12EntrustLevelController:_CloseMapWindow()
    self:_Refresh()
end

function UIN12EntrustLevelController:_CloseMap()
    self._campaign._campaign_module:CampaignSwitchState(
        true,
        UIStateType.UIN12EntrustStageController,
        UIStateType.UIMain,
        nil,
        self._campaign._id
    )
end
--endregion

--region test
function UIN12EntrustLevelController:_Debug_ClearAllMapNodeAnimationKey()
    local cfgs = Cfg.cfg_campaign_entrust_event {}
    for _, v in pairs(cfgs) do
        self:_Debug_ClearMapNodeAnimationKey(v)
    end
end

function UIN12EntrustLevelController:_Debug_ClearMapNodeAnimationKey(nodes)
    for _, v in ipairs(nodes) do
        local _key = UIActivityN12Helper.GetMapNodeAnimationKey(v)
        LocalDB.SetInt(_key, 0)
    end
end
--endregion
