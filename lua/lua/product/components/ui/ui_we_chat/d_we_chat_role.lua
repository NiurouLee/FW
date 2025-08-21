--[[
    @we chat 数据层
]]
_class("DWeChatRole", Object)
---@class DWeChatRole:Object
DWeChatRole = DWeChatRole

local WeChatTalkType = {
    Left = 1, -- 左方说话
    Right = 2, -- 右方说话
    Voice = 3, -- 语音
    Start = 4 -- 开始横线
}
_enum("WeChatTalkType", WeChatTalkType)

--[[
    chat {
        talkType
        icon
        options
        chat
    }
    option{
        talkId
        txt
    }
]]
-- self.m_nSpeakerID = 0 --演讲人
-- self.m_stSpeakerName = "" --艺名
-- self.m_vecChatData = {}
function DWeChatRole:Constructor(serverChatsData, owner, fromStorage)
    ---@type WeChatProxy
    self.weChatProxy = owner
    self.chats = {} --所有的段落 {对话}

    --@lxs
    --table[index] = {chaiid,talks[]}
    self.talks = {} --所有的对话
    
    self.speakerId = serverChatsData.m_nSpeakerID
    self.CfgQuestChatSpeaker = Cfg.cfg_quest_chat_speaker[self.speakerId]
    self.name =
        not string.isnullorempty(serverChatsData.m_stSpeakerName) and serverChatsData.m_stSpeakerName or
        StringTable.Get(self.CfgQuestChatSpeaker.Name)
    self.petModule = GameGlobal.GetModule(PetModule)
    self:Decode(serverChatsData.m_vecChatData, fromStorage)
end

-- 将服务器数据解析成客户端使用的数据
function DWeChatRole:Decode(serverChatDatas, fromStorage)
    for _, serverChatData in ipairs(serverChatDatas) do
        self:UpdateChat(serverChatData, fromStorage)
    end
end

-- self.m_nChatID = 0 --对话ID
-- self.m_nStatus = 0 --状态
-- self.m_tmStart = 0 --发起时间：随机事件里有用
-- self.m_nCount = 0 --完成的数量：有的交互任务是可以重复进入的
-- self.m_vecTalkID = {} --聊天内容

-- 有则更新 没有则加
function DWeChatRole:UpdateChat(serverChatData, fromStorage)
    local chatId = serverChatData.m_nChatID
    local triggerIndex = serverChatData.m_nCount
    local chat = self:GetChat(chatId, triggerIndex)
    -- if self.chats[chatId] then
    if chat then
        for _, serverTalkData in ipairs(serverChatData.m_vecTalkData) do
            self:UpdateTalk(chatId, triggerIndex, serverTalkData, fromStorage)
        end
    else
        self:AddChat(serverChatData, fromStorage)
    end
    self:UpdateChatState(chatId, serverChatData, fromStorage)
end

function DWeChatRole:AddChat(serverChatData, fromStorage)
    local chatId = serverChatData.m_nChatID
    local triggerIndex = serverChatData.m_nCount
    local cfg = chatId and Cfg.cfg_quest_chat[chatId]
    -- 防止存了本地数据但是在表中找不到chat
    if cfg then
        local chat = {}
        -- self.chats[chatId] = chat
        chat.chatId = chatId
        chat.triggerIndex = triggerIndex
        chat.talks = {}
        table.insert(self.chats, chat)
        for _, serverTalkData in ipairs(serverChatData.m_vecTalkData) do
            self:UpdateTalk(chatId, triggerIndex, serverTalkData, fromStorage)
        end
    end
end

-- 当为complete存入仓库
function DWeChatRole:UpdateChatState(chatId, serverChatData, fromStorage)
    local triggerIndex = serverChatData.m_nCount
    local chat = self:GetChat(chatId, triggerIndex)
    -- -- 临时处理
    local talks = chat and chat.talks
    if talks and talks[#talks] and talks[#talks].isEnd == true then
        serverChatData.m_nStatus = QuestChatStatus.E_ChatState_Completed
    end
    -- 临时处理
    local state = serverChatData.m_nStatus
    if chat then
        if state then
            chat.state = state
        end
        if not fromStorage then
            self.weChatProxy:SaveLocalSpeaker(self.speakerId, self:GetChats())
        end
    end
end

function DWeChatRole:UpdateTalk(chatId, triggerIndex, serverTalkData, fromStorage)
    local talk = self:GetTalk(chatId,serverTalkData.m_nTalkID, triggerIndex)
    -- updateTalk
    if talk then
        talk.readed = serverTalkData.m_bReaded
    else
        --add talk
        self:AddTalk(chatId, triggerIndex, serverTalkData, not fromStorage)
    end
end

function DWeChatRole:AddTalk(chatId, triggerIdex, serverTalkData, needSave)
    local talkId = serverTalkData.m_nTalkID
    local readed = serverTalkData.m_bReaded
    local chat = self:GetChat(chatId, triggerIdex)
    if not chat then
        return
    end
    local talks = chat.talks
    local cfg = Cfg.cfg_quest_talk[talkId]
    if not cfg then
        return
    end
   
    local talk = {}
    talk.readed = readed
    talk.chatId = chatId
    talk.triggerIndex = triggerIdex
    -- isEnd 限时用
    if cfg.NextWord then
        talk.isEnd = cfg.NextWord == 0
    else
        talk.isEnd = false
    end

    --切换bgm
    ----------------------------
    local cfg_chat = Cfg.cfg_quest_chat[chatId]
    if cfg_chat then
        local talkBgm = cfg_chat.TalkBGM
        if talkBgm then
            local talkBgm_bgmid = talkBgm[1]
            local talkBgm_start_talkid = talkBgm[2]
            local talkBgm_end_talkid = talkBgm[3]

            if talkBgm_start_talkid == talkId then
                talk.startBgm = talkBgm_bgmid
            end
            if talkBgm_end_talkid == talkId then
                talk.endBgm = talkBgm_bgmid
            end
        end
    end
    ------------------------------
    local talkType

    if cfg and cfg.IsFirst == 1 then
        local startTalk = {}
        startTalk.talkId = cfg.ID - 1
        startTalk.chatId = chatId
        startTalk.talkType = WeChatTalkType.Start
        table.insert(talks, startTalk)

        --修改这个talks的接口list->map @lxs
        local inner = false
        local innerChatId
        for i = 1, #self.talks do
            local talkRoot = self.talks[i]
            if talkRoot then
                if talkRoot.chatid == chatId then
                    innerChatId = chatId
                    table.insert(talkRoot.talks,startTalk)
                    inner = true
                    break
                end
            end
        end
        if not inner then
            local talkRoot = {}
            talkRoot.chatid = chatId
            talkRoot.talks = {}
            table.insert(talkRoot.talks,startTalk)
            table.insert(self.talks,talkRoot)
        end
    end

    local txt = cfg and StringTable.Get(cfg.ChatWord) or ""

    -- 可回复的是主角
    if cfg.IsMainActorWord == 1 then
        talkType = WeChatTalkType.Right
        if cfg.AnswerID then
            talk.options = {}
            for _, talkId in ipairs(cfg.AnswerID) do
                local option = {}
                option.talkId = talkId
                local opTxt = StringTable.Get(Cfg.cfg_quest_talk[talkId].ChatWord)
                option.txt = opTxt
                table.insert(talk.options, option)
            end
        end
        talk.jumpId = cfg.JumpId
        talk.jumpDesc = cfg.JumpDesc
        talk.isClickJump = self.weChatProxy:IsConstructor()
    else
        if cfg.AnswerID then
            talk.options = {}
            for _, talkId in ipairs(cfg.AnswerID) do
                local option = {}
                option.talkId = talkId
                if not Cfg.cfg_quest_talk[talkId] then
                    Log.error("###[DWeChatRole] not Cfg.cfg_quest_talk, id --> ",talkId,"|ID-->",cfg.ID)
                end
                local opTxt = StringTable.Get(Cfg.cfg_quest_talk[talkId].ChatWord)
                option.txt = opTxt
                table.insert(talk.options, option)
            end
        end
        if cfg.VoiceID then
            talk.voiceId = cfg.VoiceID
            talkType = WeChatTalkType.Voice
        else
            talkType = WeChatTalkType.Left
            talk.jumpId = cfg.JumpId
            talk.jumpDesc = cfg.JumpDesc
            talk.isClickJump = self.weChatProxy:IsConstructor()
        end
    end
    talk.talkId = talkId
    talk.txt = txt
    talk.talkType = talkType
    table.insert(talks, talk)

    --修改这个talks的接口list->map @lxs
    local inner = false
    local innerChatId
    for i = 1, #self.talks do
        local talkRoot = self.talks[i]
        if talkRoot then
            if talkRoot.chatid == chatId then
                innerChatId = chatId
                table.insert(talkRoot.talks,talk)
                inner = true
                break
            end
        end
    end
    if not inner then
        local talkRoot = {}
        talkRoot.chatid = chatId
        talkRoot.talks = {}
        table.insert(talkRoot.talks,talk)
        table.insert(self.talks,talkRoot)
    end
    chat.talks = talks
    if needSave then
        self.weChatProxy:SaveSpeakerLastTime(self.speakerId, os.time())
    end
end

-- 所有对话段落
function DWeChatRole:GetChats()
    return self.chats
end

function DWeChatRole:GetChat(chatId, triggerIndex)
    for index, chat in ipairs(self.chats) do
        if chat.chatId == chatId and chat.triggerIndex == triggerIndex then
            return chat
        end
    end
    return nil
end

-- 所有对话段落
function DWeChatRole:GetTalks()
    local _talks = {}
    for index, chat in ipairs(self.chats) do
        local talks = chat.talks
        for index, talk in ipairs(talks) do
            table.insert(_talks, talk)
        end
    end
    return _talks
end

-- 获取talk by talkId
function DWeChatRole:GetTalk(chatId,talkId, triggerIndex)
    --修改self.talks的结构@lxs
    for i = 1, #self.talks do
        local talkRoot = self.talks[i]
        if talkRoot then
            if talkRoot.chatid == chatId then
                local talks = talkRoot.talks
                for j = 1, #talks do
                    local talk = talks[j]
                    if talk then
                        if talk.talkId == talkId and talk.triggerIndex == triggerIndex then
                            return talk
                        end
                    end
                end
            end
        end
    end
    -- for _, talk in ipairs(self.talks) do
    --     if talk.talkId == talkId and talk.triggerIndex == triggerIndex then
    --         return talk
    --     end
    -- end
    return nil
end

function DWeChatRole:SetTalkReaded(chatId,talkId, triggerIndex)
    local talk = self:GetTalk(chatId,talkId, triggerIndex)
    if talk then
        talk.readed = true
    end
end

--设置所有talk已读
function DWeChatRole:SetAllTalkReaded(readed)
    --修改self.talks的结构@lxs
    for i = 1, #self.talks do
        local talkRoot = self.talks[i]
        if talkRoot then
            local talks = talkRoot.talks
            for j = 1, #talks do
                local talk = talks[j]
                if talk then
                    talk.readed = readed
                end
            end
        end
    end

    -- for index, talk in ipairs(self.talks) do
    --     talk.readed = readed
    -- end
end
function DWeChatRole:AddChats(serverChatDatas)
    self:Decode(serverChatDatas)
end

function DWeChatRole:GetPic()
    return self.CfgQuestChatSpeaker.Icon
end

function DWeChatRole:GetSpeakerId()
    return self.speakerId
end
function DWeChatRole:SetGroupID(id)
    self._groupID = id
end
function DWeChatRole:GetGroupId()
    if self._groupID then
        return self._groupID
    else
        return self:GetSpeakerId()
    end
end
-- 可能会改名
function DWeChatRole:GetName()
    return self.name
end
function DWeChatRole:GetEnName()
    -- 宝宝才有英文名
    if self.CfgQuestChatSpeaker.SpeakerType == 1 then
        local petTemplateId = self.CfgQuestChatSpeaker.TemplateID
        return StringTable.Get(Cfg.cfg_pet[petTemplateId].EnglishName)
    else
        return ""
    end
end
-- 好感度
function DWeChatRole:GetFriendCount()
    if self.CfgQuestChatSpeaker.SpeakerType == 1 then
        local pet = self.petModule:GetPetByTemplateId(self.CfgQuestChatSpeaker.TemplateID)
        return pet and pet:GetPetAffinityLevel() or 1
    else
        return -1
    end
end

function DWeChatRole:GetFriendRate()
    if self.CfgQuestChatSpeaker.SpeakerType == 1 then
        local pet = self.petModule:GetPetByTemplateId(self.CfgQuestChatSpeaker.TemplateID)
        if pet then
            local level = pet:GetPetAffinityLevel()
            local _realExp = pet:GetPetAffinityExp()
            local _realMaxExp = pet:GetPetAffinityMaxExp(level)
            local _maxAffinityMaxLevel = pet:GetPetAffinityMaxLevel()
            if _maxAffinityMaxLevel <= level then --等级达到最大
                return 1
            else
                local cur = _realExp - Cfg.cfg_pet_affinity_exp[level].NeedAffintyExp
                return cur / _realMaxExp
            end
        else
            return 0
        end
    else
        return 0
    end
end

-- 好感度
function DWeChatRole:GetFriendMaxCount()
    if self.CfgQuestChatSpeaker.SpeakerType == 1 then
        local pet = self.petModule:GetPetByTemplateId(self.CfgQuestChatSpeaker.TemplateID)
        return pet and pet:GetPetAffinityMaxLevel() or 0
    else
        return 0
    end
end
-- 未读数量
function DWeChatRole:GetUnReadCount()
    local count = 0
    --修改self.talks的结构@lxs
    for i = 1, #self.talks do
        local talkRoot = self.talks[i]
        if talkRoot then
            local talks = talkRoot.talks
            for j = 1, #talks do
                local talk = talks[j]
                if talk then
                    if talk.readed == false then
                        count = count + 1
                    end
                end
            end
        end
    end
    -- for index, talk in ipairs(self.talks) do
    --     if talk.readed == false then
    --         count = count + 1
    --     end
    -- end
    return count
end
function DWeChatRole:GetUnReadChats()
    local tbl = {}
    for _, chat in ipairs(self.chats) do
        local talks = chat.talks
        for _, talk in ipairs(talks) do
            if talk.readed == false then
                if not table.ikey(tbl, talk.chatId) then
                    table.insert(tbl, talk.chatId)
                end
            end
        end
    end
    return tbl
end
function DWeChatRole:GetLastTalk()
    local lastTalkRoot = self.talks[#self.talks]
    if lastTalkRoot then
        local lastTalk = lastTalkRoot.talks[#lastTalkRoot.talks]
        return lastTalk
    end
    --修改self.talks的结构@lxs
    -- return self.talks[#self.talks]
end

function DWeChatRole:HasRed()
    -- local needClick = self:GetUnReadCount() > 0
    local l = self:GetLastTalk()
    local canReply = false
    if l and l.options then
        canReply = true
    end
    return canReply
end

function DWeChatRole:UpdateName(name)
    self.name = not string.isnullorempty(name) and name or StringTable.Get(self.CfgQuestChatSpeaker.Name)
end
