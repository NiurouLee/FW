--关卡词缀和圣物

_class("MazeService", BaseService)
---@class MazeService:BaseService
MazeService = MazeService

function MazeService:Constructor(world)
    self._world = world
    self._matchType = self._world.BW_WorldInfo.matchType

    --迷宫数据
    ---@type MazeCreateInfo
    self._mazeCreateInfo = nil
    --血量
    self._mazeBlood = 0
    --灯盏数量
    self._mazeLight = 0

    --圣物触发对局次数计数
    self._relicCounters = {}
    --卡牌等级平均值
    self._avgPetLevel = 0

    ---@type BuffLogicService
    self._buffLogicSvc = self._world:GetService("BuffLogic")
end

function MazeService:Initialize()
    if self._matchType ~= MatchType.MT_Maze then
        return
    end
    ---@type MazeCreateInfo
    self._mazeCreateInfo = self._world.BW_WorldInfo.mazeCreateInfo
    self._mazeLight = self._mazeCreateInfo.maze_light
    self._relicCounters = self._mazeCreateInfo.relic_counters
    self._mazeRoomId = self._mazeCreateInfo.maze_room_id
    self._avgPetLevel = self._mazeCreateInfo.avg_pet_level
    self._mazeRoomType = Cfg.cfg_maze_room[self._mazeRoomId].MazeRoomType
    self._has_archive = self._mazeCreateInfo.has_archive
    if self._has_archive then
        self._battle_archive = ohce(self._mazeCreateInfo.battle_archive)
    end

    --注册回调
    local triggerSvc = self:GetService("Trigger")
    local triggerHandler = TriggerCallbackOwner:New(self, self.InitMazeWordAndRelic)
    local trigger =
        triggerSvc:CreateTrigger(triggerHandler, {{NotifyType.GameStart}, {TriggerType.Always}}, self._world)
    triggerSvc:Attach(trigger)
    trigger:SetActive(true)
    self._trigger = trigger
end

function MazeService:Dispose()
    if self._matchType ~= MatchType.MT_Maze then
        return
    end
    self:GetService("Trigger"):Detach(self._trigger)
end

function MazeService:IsMazeMatch()
    return self._matchType == MatchType.MT_Maze
end

function MazeService:GetAvgPetLevel()
    return self._avgPetLevel
end

function MazeService:GetLightCount()
    return self._mazeLight
end


function MazeService:AddLight(value)
    self._mazeLight = self._mazeLight + value
    
    local bs = self._world:BattleStat()
    bs:SetLevelRound(self._mazeLight)
    bs:SetCurWaveRound(self._mazeLight)
    bs:MazeAddLight(value)
end

function MazeService:UseLight()
    if self._mazeLight == 0 then
        return
    end
    self._mazeLight = self._mazeLight - 1
end
--房间类型
function MazeService:GetMazeRoomType()
    return self._mazeRoomType
end

--关卡波次随机数
function MazeService:GetMazeWaveRandoms()
    return self._mazeCreateInfo.wave_randoms
end

--圣物
function MazeService:GetMazeRelics()
    return self._mazeCreateInfo.relics
end

--圣物计数
function MazeService:GetRelicCounters()
    return self._relicCounters
end


--初始化圣物
function MazeService:InitMazeRelics()
    local my_relics = self:GetMazeRelics()
    local valid_relics = {}
    for _, relicID in ipairs(my_relics) do
        local cfg = Cfg.cfg_item_relic[relicID]
        if self:CheckRelicCounter(relicID) then
            if cfg.SuiteID > 0 and self:CheckSuite(cfg.SuiteID) then
                if not table.icontains(valid_relics, cfg.SuiteID) then
                    table.insert(valid_relics, cfg.SuiteID)
                end
                if cfg.Coexist then
                    table.insert(valid_relics, relicID)
                end
            else
                table.insert(valid_relics, relicID)
            end
        end
    end

    --表现排序
    table.sort(
        valid_relics,
        function(a, b)
            local oa = Cfg.cfg_item_relic[a].ShowOrder
            local ob = Cfg.cfg_item_relic[b].ShowOrder
            if oa == ob then
                return a < b
            else
                return oa < ob
            end
        end
    )

    --添加buff
    for _, relic in ipairs(valid_relics) do
        self:ApplyMazeRelic(relic)
    end
end

--检查圣物套装
function MazeService:CheckSuite(suiteID)
    local my_relics = self:GetMazeRelics()
    local suite_cfgs = Cfg.cfg_item_relic {SuiteID = suiteID}
    for id, cfg in pairs(suite_cfgs) do
        if not table.icontains(my_relics, cfg.ID) then
            return false
        end
        --本局不生效
        if not self:CheckRelicCounter(cfg.ID) then
            return false
        end
    end
    return true
end

--检查圣物生效对局数量
function MazeService:CheckRelicCounter(relicID)
    local cfg = Cfg.cfg_item_relic[relicID]
    local cnt = self._relicCounters[relicID]
    if not cnt or cfg.OutGameTriggerCount == 0 or cnt < cfg.OutGameTriggerCount then
        return true
    end
    return false
end

--圣物触发次数计数
function MazeService:AddRelicCounter(relicID)
    local cnt = self._relicCounters[relicID]
    if not cnt then
        self._relicCounters[relicID] = 1
    else
        self._relicCounters[relicID] = cnt + 1
    end
end

--圣物buff
function MazeService:ApplyMazeRelic(relicID)
    local cfg = Cfg.cfg_item_relic[relicID]
    if #cfg.BuffID > 0 then
        for _, buffID in ipairs(cfg.BuffID) do
            if buffID > 0 then
                Log.notice("[MazeRelic] add buff:", buffID, " relic:", relicID)
                local buffIns = self._buffLogicSvc:AddBuffByTargetType(buffID, cfg.BuffTargetType, cfg.BuffTargetParam)
                for _, buffIn in ipairs(buffIns) do
                    buffIn:SetRelicID(relicID)
                end
            end
        end
    end
end

function MazeService:InitMazeWordAndRelic()
    if self._matchType ~= MatchType.MT_Maze then
        return
    end

    self:InitMazeRelics()
end

function MazeService:GetMazeLayerFactor()
    local cfg = Cfg.cfg_maze_layer {Layer = self._mazeCreateInfo.maze_layer, Step = self._mazeCreateInfo.maze_step}
    if cfg and #cfg == 1 then
        return cfg[1].MazeMonsterParameter1, cfg[1].MazeMonsterParameter2
    end
    return 0
end

function MazeService:GetBattleArchive()
    if self._matchType ~= MatchType.MT_Maze then
        return
    end
    return self._battle_archive
end

function MazeService:IsArchivedBattle()
    if self._matchType ~= MatchType.MT_Maze then
        return false
    end
    return self._battle_archive ~= nil
end
