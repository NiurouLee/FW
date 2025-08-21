---@class UIFindTreasureGameData:Object
_class("UIFindTreasureGameData", Object)
UIFindTreasureGameData = UIFindTreasureGameData

function UIFindTreasureGameData:Constructor()
    local primaryId = nil
    local seniorId = nil
    
    local singleCfg = HomelandFindTreasureConst.GetSingleCfg()
    if singleCfg then
        primaryId = singleCfg.PrimaryEquipID
        seniorId = singleCfg.SeniorEquipID
    end

    self._isSpecialSingle = false

    local cfg = nil
    local normalCount, specialCount = HomelandFindTreasureConst.GetHasCostSingle()
    local primaryCount, seniorCount = HomelandFindTreasureConst.GetSingleCount()
    local hasSingle = true
    if seniorCount > 0 then
        local cfgs = Cfg.cfg_component_minigame_explore_reward{EquipID = seniorId}
        local maxValue = -1
        for _, v in pairs(cfgs) do
            if maxValue < v.EquipNum then
                maxValue = v.EquipNum
            end
        end
        local count = specialCount + 1
        if count > maxValue then
            count = maxValue
        end
        cfg = Cfg.cfg_component_minigame_explore_reward{EquipID = seniorId, EquipNum = count}
        self._isSpecialSingle = true
    elseif primaryCount > 0 then
        local cfgs = Cfg.cfg_component_minigame_explore_reward{EquipID = primaryId}
        local maxValue = -1
        for _, v in pairs(cfgs) do
            if maxValue < v.EquipNum then
                maxValue = v.EquipNum
            end
        end
        local count = normalCount + 1
        if count > maxValue then
            count = maxValue
        end
        cfg = Cfg.cfg_component_minigame_explore_reward{EquipID = primaryId, EquipNum = count}
    else
        hasSingle = false
        local tmpCfgs = {}
        for k, v in pairs(Cfg.cfg_component_minigame_explore_reward{}) do
            tmpCfgs[#tmpCfgs + 1] = v
        end
        cfg = {}
        cfg[1] = tmpCfgs[math.random(1, #tmpCfgs)]
    end
    
    self._id = cfg[1].ID
    self._rewards = cfg[1].ScoreBReward
    if not hasSingle then
        self._rewards = {}
    end
    self._model = cfg[1].Model
    self._totalTime = cfg[1].GameTime
    self._gameTime = 0
end

function UIFindTreasureGameData:GetId()
    return self._id
end

function UIFindTreasureGameData:IsSpecialSingle()
    return self._isSpecialSingle
end

--探宝奖励
function UIFindTreasureGameData:GetRewards()
    return self._rewards
end

--宝物的模型
function UIFindTreasureGameData:GetModel()
    return self._model
end

--增加游戏时长
function UIFindTreasureGameData:AddGameTime(time)
    self._gameTime = self._gameTime + time
    if self._gameTime > self:GetGameTotalTime() then
        self._gameTime = self:GetGameTotalTime()
    end
end

--游戏进行了多久
function UIFindTreasureGameData:GetGameTime()
    return self._gameTime
end

--游戏总的时间长度
function UIFindTreasureGameData:GetGameTotalTime()
    return self._totalTime
end

--寻宝技能CD,单位秒
function UIFindTreasureGameData:SkillCD()
    local cfg = Cfg.cfg_homeland_find_treasure_const[1]
    return cfg.SkillCD / 1000
end
