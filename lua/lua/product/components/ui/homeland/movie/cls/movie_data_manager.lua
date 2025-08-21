--对movie数据进行统一管理
_class("MovieDataManager", Singleton)
---@class MovieDataManager : Singleton
MovieDataManager = MovieDataManager

function MovieDataManager:Constructor()
    self._movieActorList = nil  --电影演员列表
    self._movieItemList = nil  --电影物品列表

    self._optionsData = {} --选项数据
    self._teaseData = {} --吐槽数据

    self._replyClosingData = nil --返回的评分数据

    self._homelandmodule = GameGlobal.GetModule(HomelandModule)
    
    self._requestData = MoviceRecord:New()
end

--获得所有服务器movie
---@return table
function MovieDataManager:GetAllMovieData()
    local info = self._homelandmodule:GetHomelandInfo().movice_info
    self._movieInfo = info.movices--服务端发回的电影数据
    return self._movieInfo
end

--通过id获得movie数据
---@return MoviceData
function MovieDataManager:GetMovieDataByID(id)
    local info = self:GetAllMovieData()
    return info[id]
end

--通过id获得movie历史记录
---@return XX
function MovieDataManager:GetMovieHistoryDataByID(id)
    local movie = self:GetMovieDataByID(id)
    if movie then
        local t,res = {},{}
        local records = movie.records
        for i,v in pairs(records) do
            t[#t + 1] = v.pstid
        end
        table.sort(t)
        for i, v in pairs(t) do
            table.insert(res,records[v])
        end
        return res
    end
    return {}
end



--通过id获得movie历史最高评分
---@return number
function MovieDataManager:GetMovieScoreDataByID(id)
    local movie = self:GetMovieDataByID(id)
    if movie and movie.max_score then
        return movie.max_score
    end
    return 0
end

function MovieDataManager:GetMovieHistoryOptionDataByID(id)
    local movie = self:GetMovieDataByID(id)
    if movie then
        return movie.history_chose_option
    end
    return {}
end

--通过id和星灵/道具/选项id 判断是否使用过
---@return boolean
function MovieDataManager:GetMovieHistoryUsedByID(id,useId)
    local movie = self:GetMovieDataByID(id)
    if not movie then
        return false
    end
    local actors = movie.history_chose_pets
    local items = movie.history_chose_item
    local options = movie.history_chose_option

    for i,v in pairs(actors) do
        for _,petID in pairs(v) do
            if petID == useId then
                return true
            end
        end
    end
    
    for i,v in pairs(items) do
        for _,itemID in pairs(v) do
            if itemID == useId then
                return true
            end
        end
    end
    
    for i,v in pairs(options) do
        for _,optionsID in pairs(v) do
            if optionsID == useId then
                return true
            end
        end
    end
    return false
end

--获得已经领取过的奖励id列表
function MovieDataManager:GetMovieRewardByID(id)
    local movie = self:GetMovieDataByID(id)
    if movie then
        return movie.received_reward_id
    end
    return {}
end

--通过电影id和角色id获取角色位置
function MovieDataManager:GetMoviePointByID(movieId,actorId)
    local actorPointList =  Cfg.cfg_homeland_movice[movieId].RolePosList
    for i, v in pairs(actorPointList) do
        local d = Cfg.cfg_homeland_movice_item[v]
        local selectItem = d.SelectList
        for _,itemId in pairs(selectItem) do
            if actorId == itemId[1] then
                return Cfg.cfg_homeland_movice_item[v].Name
            end
        end
    end
    return "Error not found"
end

--获得排序后的电影列表
function MovieDataManager:GetSortMovieList(movietag)
    local tb = {}
    local cfg = Cfg.cfg_homeland_movice {}
    local new,lock,normal = {},{},{}
    local tag = movietag

    for k, v in ipairs(tag) do
        
        if self:CheckMovieLock(cfg[v]) then
            table.insert(lock,v)
        elseif self:CheckMovieNew(cfg[v]) then
            table.insert(new,v)
        else
            table.insert(normal,v)
        end

        -- for i, v in pairs(cfg) do
        --     if self:CheckMovieLock(v) then
        --         table.insert(lock,i)
        --     elseif self:CheckMovieNew(v) then
        --         table.insert(new,i)
        --     else
        --         table.insert(normal,i)
        --     end
        -- end
    end
 

    table.sort(lock)
    table.sort(new)
    table.sort(normal)

    for i,v in pairs(new) do
        table.insert(tb,cfg[v])
    end
    for i,v in pairs(normal) do
        table.insert(tb,cfg[v])
    end
    for i,v in pairs(lock) do
        table.insert(tb,cfg[v])
    end

    return tb
end

--检查电影是否锁定
function MovieDataManager:CheckMovieLock(movieData)
    --解锁道具id
    local lockID = movieData.UnlockItem
    local itemModule = GameGlobal.GetModule(ItemModule)
    local itemNum = itemModule:GetItemCount(lockID)
    --需要判断是否拥有该物品
    return itemNum == 0
end

--检查电影是否新获得
function MovieDataManager:CheckMovieNew(movieData)
    local item_data,psdid = nil
    local redState = false
    local itemModule = GameGlobal.GetModule(ItemModule)
    local items = itemModule:GetItemByTempId(movieData.UnlockItem)
    if items and table.count(items)>0 then
        for key, value in pairs(items) do
            item_data = value
            break
        end
    end
    if item_data then
        redState = item_data:IsNewOverlay()
        psdid = item_data:GetID()
    end
    return redState,psdid
end

function MovieDataManager:InsertOptionsData(ID ,optionIdx)
    self._optionsData[ID] = optionIdx
end

function MovieDataManager:InsertTeaseData(randomIdx)
    table.insert(self._teaseData, randomIdx)
end

function MovieDataManager:GetReplyClosingData()
    return self._replyClosingData
end

function MovieDataManager:GetRecordData()
    return self._replyClosingData
end

function MovieDataManager:ClearRequestData()
    self._requestData = MoviceRecord:New()
end

function MovieDataManager:GetRequestData()
   return self._requestData
end

function MovieDataManager:SetRequestDataPstid(pstid)
    self._requestData.pstid = pstid
end

function MovieDataManager:SetRequestData(items,actors,options,randomchat)
    self._requestData.chose_item = items
    self._requestData.chose_pets = actors
    self._requestData.chose_option = options
    self._requestData.random_chat = randomchat
end

function MovieDataManager:SetRequestDataName(moviceid,name,data)
    self._requestData.name = name
    self._requestData.date = data
    self._requestData.movice_id = moviceid
end

function MovieDataManager:CaculateTotalScore(data)
    return (data.pet_score + data.item_score + data.option_score) / 6
end

--结算用评分标准
--返回评分边界
--左开右闭
function MovieDataManager:GetClosingCondition(conditionID)
    if conditionID == 1 then
        return 0, 2
    elseif conditionID == 2 then
        return 2, 3.5
    elseif conditionID == 3 then
        return 3.5, 4.5
    else
        return 4.5, 5
    end
end

--弹幕用评分标准
function MovieDataManager:GetBulletScreenCondition(score)
    local sc = self:TransferToStarScore(score)
    if sc <= 2 then
        return 1
    elseif sc <= 3.5 then
        return 2
    else
        return 3
    end
end

function MovieDataManager:TransferToStarScore(score)
    local integerScore = math.floor(score)
    local floatP = score - integerScore
    local star = floatP > 0.5 and  integerScore + 0.5 or integerScore
    return star
end

-- function MovieDataManager:SetTeaseData(tIndex)
--     table.insert(self._teaseData, tIndex) 
-- end

-- function MovieDataManager:SetOptionsData(tIndex)
--     table.insert(self._teaseData, tIndex) 
-- end

function MovieDataManager:SendTask(TT)
    local homeLandModule =  GameGlobal.GetModule(HomelandModule) 
    local pstid =  MoviePrepareData:GetInstance():GetPstId()
    local res, replyEvent = homeLandModule:HandleReuestScore(TT,pstid,self._requestData)
    if res:GetSucc() then 
        self._replyClosingData = replyEvent
        --清理数据
        self._optionsData = {}
        self._teaseData = {} 
       Log.fatal("MovieDataManager:SendTask")
    end 
    return res
end

function MovieDataManager:SendDataToServer(TT)
    self:SetRequestDataPstid(MoviePrepareData:GetInstance():GetPstId())
    local movieId = MoviePrepareData:GetInstance():GetMovieId()
    local cfg =  Cfg.cfg_homeland_movice {}
    local cfgItem =  cfg[movieId]
    self:SetRequestDataName(movieId,nil,nil)

    local items,actors =  HomelandMoviePrepareManager:GetInstance():GetRequestServerData()
    local options = self._optionsData
    local teases = self._teaseData
    self:SetRequestData(items,actors,options, teases)
    --GameGlobal.TaskManager():StartTask(self.SendTask, self) -- 新建重试任务
    self:SendTask(TT)
end

function MovieDataManager:GetMovieServerData(movieId)
    return self._homelandmodule.m_homeland_info.movice_info.movices[movieId]
end

--根据movieID和选择的光灵决定剧本内容
function MovieDataManager:GetMovieStoryID(movieID, petList)
    local movieStoryList = Cfg.cfg_homeland_movice_condition{MovieID = movieID}
    table.sort(petList)
    for _, story in pairs(movieStoryList) do
        if #petList == #story.Condition then
            table.sort(story.Condition)
            local equalFlag = true
            for i = 1, #petList do
                if petList[i] ~= story.Condition[i] then
                    equalFlag = false
                end
            end

            if equalFlag then
                return story.StoryID
            end
        end
    end
    Log.fatal("[MovieDataManager] Can not Find StoryID with Condition " .. #petList)
    return nil
end

function MovieDataManager:GetMovieOptionFitScoreList(oid)
    local fitOptionCfg = Cfg.cfg_homeland_movice_item{OptionID=oid}
    if fitOptionCfg then
        return fitOptionCfg[1]
    else
        Log.error("cfg_homeland_movice_item nil id=", oid)
        return nil
    end
end

function MovieDataManager:CheckHadUse(moviceid,titleType,itemId)
    local data = self:GetMovieServerData(moviceid)
    if not data then
       return false 
    end 
    if titleType == MoviePrepareType.PT_Actor then 
        if not data.history_chose_pets then
            return false 
        end 
        for key, value in pairs(data.history_chose_pets) do
            for i = 1, #value do
               if value[i] == itemId then
                  return true
               end 
            end
        end
        return false 
    elseif titleType == MoviePrepareType.PT_Prop or titleType == MoviePrepareType.PT_Scene then
        if not data.history_chose_item then
            return false 
        end 
        for key, value in pairs(data.history_chose_item) do
            for i = 1, #value do
               if value[i] == itemId then
                  return true
               end 
            end
        end
        return false 
    end 
end

function MovieDataManager:SaveRecordData(replaceMoviePstId, successCallback, fatalCallback)
    local homeLandModule =  GameGlobal.GetModule(HomelandModule) 
    local curMoviePstId = MoviePrepareData:GetInstance():GetPstId()
    GameGlobal.TaskManager():StartTask(function(TT)
        local archList = MoviePrepareData:GetInstance():GetPrepareArchList()
        local res = homeLandModule:HandleSaveRecord(TT, curMoviePstId, replaceMoviePstId, archList)
        if res:GetSucc() then 
            successCallback()
        else
            if fatalCallback then
                fatalCallback()
            end
        end 
    end, self)
end