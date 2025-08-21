--region NoticeData 公告信息类
---@class NoticeData:Object
_class("NoticeData", Object)
NoticeData = NoticeData

---任務类型
---@class NoticeType
local NoticeType = {
    --系统
    System = 1003,
    --活动
    Active = 1004
}
_enum("NoticeType", NoticeType)

---任務佈局類型
---@class NoticeLayout
local NoticeLayout = {
    TextureText = 1,
    Texture = 2,
    Text = 3
}
_enum("NoticeLayout", NoticeLayout)

local logKey = "###[公告Log] "
function NoticeData:Constructor()
    Log.debug("[notice] ### NoticeData:Constructor")
    self.m_reqid = -1

    self._firstLogin = false

    --存本地信息拼接标识
    self._keyAppendValueSystem = "SystemNotice"
    self._keyAppendValueActive = "ActiveNotice"

    --分组,海外版没用到
    self.m_group = "afterEnter"

    --语言
    --self.m_language = Cfg.cfg_global["NoticeLanguage"].StrValue
    self.m_language = SDKProxy:GetInstance():GetStandardLangType()
    self.m_region = "392"
    --国家
    if EDITOR then
        self.m_region = "392" --Cfg.cfg_global["NoticeCountryRegion"].IntValue or 392
    else
        self.m_region = GameGlobal.GameLogic().msdkAuthorityInfo.state_numeric
        Log.debug("###[NoticeData] 正常获取国家")
    end
    if self.m_region then
        Log.debug("###[NoticeData] 获取国家 --> ", self.m_region)
    else
        self.m_region = "392"
    end
    Log.debug("###[NoticeData] 获取国家结果 --> ", self.m_region)

    self.m_partition = 0
    --大区
    if EDITOR then
        self.m_partition = 0 --Cfg.cfg_global["NoticePartition"].StrValue or 0
    else
        self.m_partition = GameGlobal.GameLogic():GetZoneID()
        Log.debug("###[NoticeData] 正常获取")
    end
    if self.m_partition then
        Log.debug("###[NoticeData] 获取大区 --> ", self.m_partition)
    else
        self.m_partition = 81
    end

    Log.debug("###[NoticeData] 获取大区结果 --> ", self.m_partition)

    --平台
    local platformNum = GetPlatformOS()
    ---@type NoticeClientPlatform
    self._thisPlatform = self:PlatformNumber2String(platformNum)
    Log.debug("###[NoticeData] get platform succ ! platform --> ",self._thisPlatform)

    --extraJson
    self.m_extraJson = ""

    self:DebugLog("国家：",self.m_region)
    self:DebugLog("语言：",self.m_language)
    self:DebugLog("大区：",self.m_partition)
    self:DebugLog("平台：",self._thisPlatform)

    --注册回调
    self.onNoticeRetEvent = function(ret)
        if SDKProxy:GetInstance():IsInlandSDK() then
            self:OnInlandNoticeRetEvent(ret)
        else
            self:OnOverSeaNoticeRetEvent(ret)
        end
    end
    SDKProxy:GetInstance():NoticeRetEvent(self.onNoticeRetEvent, true)

    --请求公告时间间隔
    self._deltaTime = 1000 * 300

    --缓存
    self._noticeDic = {}
    self._noticeDic[NoticeType.System] = {}
    self._noticeDic[NoticeType.Active] = {}

    self._noticeNewDic = {}
    self._noticeNewDic[NoticeType.System] = false
    self._noticeNewDic[NoticeType.Active] = false

    self._noticeCountDic = {}
    self._noticeCountDic[NoticeType.System] = 0
    self._noticeCountDic[NoticeType.Active] = 0

    self._StartGetNoticeNextEvent = nil
    GameGlobal.Timer():AddEvent(10, self.StartGetNoticeNext, self)
    --self:StartGetNoticeNext()
end
function NoticeData:DebugLog(log,...)
    Log.debug(logKey,log,...)
end
function NoticeData:StartGetNoticeNext()
    self._StartGetNoticeNextEvent = nil

    self:RequestNoticeData()

    self._requestEventLoop =
        GameGlobal.Timer():AddEventTimes(
        self._deltaTime,
        TimerTriggerCount.Infinite,
        function()
            self:RequestNoticeData()
        end
    )
end

--首次进入主界面
function NoticeData:ChangeFirstLogin()
    self._firstLogin = true
end

--取消公告new状态
function NoticeData:CancelNoticeNew(noticeid, type)
    self:SetNoticeNew(noticeid, type, true)
    GameGlobal.EventDispatcher():Dispatch(GameEventType.OnNoticeDataCheckNew)
end

---#国内请求公告数据
function NoticeData:RequestNoticeData()
    self:_LoadNotice()
end

--请求
function NoticeData:_LoadNotice()
    Log.debug("[notice] ### start request notice data")

    if EDITOR then
        self.m_reqid = "27780-735C25EE-C506-43A2-A2DB-548C6D48D8FE-1596594433-18"
        SDKProxy:GetInstance():LoadNoticeData(self.m_group, self.m_language, self.m_region, self.m_partition)
    else
        self.m_reqid =
            SDKProxy:GetInstance():LoadNoticeData(self.m_group, self.m_language, self.m_region, self.m_partition)
    end
end

---#主动根据group请求公告
---@param group string 分组
---@param callback function 回调
function NoticeData:RequestNoticeDataWithGroup(group, callback)
    self._callback = callback

    Log.fatal("###[self.m_region]", self.m_region)

    if EDITOR then
        self.m_reqid_cb = "27780-735C25EE-C506-43A2-A2DB-548C6D48D8FE-1596594433-17"
        SDKProxy:GetInstance():LoadNoticeData(group, self.m_language, self.m_region, self.m_partition)
    else
        self.m_reqid_cb = SDKProxy:GetInstance():LoadNoticeData(group, self.m_language, self.m_region, self.m_partition)
    end
end
---#国内请求公告的回调
---@param ret MSDKNoticeRet
function NoticeData:OnInlandNoticeRetEvent(ret)
    if ret == nil then
        self:DebugLog("MSDKNoticeRet是空的")
        return
    end
    if ret.ReqID == self.m_reqid then
        Log.debug("[notice] ### request notice data finish")
        if ret.NoticeInfoList.Count > 0 then
            --Log.debug("[notice] ### ret ~= nil and ret.NoticeInfoList.Count - ", ret.NoticeInfoList.Count)

            --清空缓存
            self._noticeDic = {}
            self._noticeDic[NoticeType.System] = {}
            self._noticeDic[NoticeType.Active] = {}

            local systemList_temp = {}
            local activeList_temp = {}

            for i = 0, ret.NoticeInfoList.Count - 1 do
                ---@type UINoticeCls
                local noticeInfo = self:MaskNotice2NoticeCls(ret.NoticeInfoList[i])

                if noticeInfo then
                    --Log.debug("###公告获取id测试:start -->")
                    --Log.debug("###id-->", noticeInfo.NoticeId)
                    if noticeInfo.NoticeType == NoticeType.Active then
                        table.insert(activeList_temp, noticeInfo)
                    else
                        table.insert(systemList_temp, noticeInfo)
                    end
                end
            end

            --数量
            local systemCount = table.count(systemList_temp)
            local activeCount = table.count(activeList_temp)
            self._noticeCountDic[NoticeType.System] = systemCount
            self._noticeCountDic[NoticeType.Active] = activeCount

            --Log.debug("[notice] ### request notice count active-", activeCount, " system-", systemCount)

            --排序
            if table.count(systemList_temp) > 0 then
                table.sort(
                    systemList_temp,
                    function(a, b)
                        return a.Order > b.Order
                    end
                )
            end
            if table.count(activeList_temp) > 0 then
                table.sort(
                    activeList_temp,
                    function(a, b)
                        return a.Order > b.Order
                    end
                )
            end

            --存储
            for i = 1, #activeList_temp do
                table.insert(self._noticeDic[NoticeType.Active], activeList_temp[i])
            end
            for i = 1, #systemList_temp do
                table.insert(self._noticeDic[NoticeType.System], systemList_temp[i])
            end

            --检查new
            self._noticeNewDic[NoticeType.Active] = false
            for i = 1, #self._noticeDic[NoticeType.Active] do
                if self:CheckNoticeNew(self._noticeDic[NoticeType.Active][i].NoticeId, NoticeType.Active) then
                    self._noticeNewDic[NoticeType.Active] = true
                    break
                end
            end
            self._noticeNewDic[NoticeType.System] = false
            for i = 1, #self._noticeDic[NoticeType.System] do
                if self:CheckNoticeNew(self._noticeDic[NoticeType.System][i].NoticeId, NoticeType.System) then
                    self._noticeNewDic[NoticeType.System] = true
                    break
                end
            end
        end
        GameGlobal.EventDispatcher():Dispatch(GameEventType.OnNoticeDataCheckNew)
    elseif ret.ReqID == self.m_reqid_cb then
        if self._callback then
            local noticeTab = {}
            if ret.NoticeInfoList.Count > 0 then
                for i = 0, ret.NoticeInfoList.Count - 1 do
                    ---@type UINoticeCls
                    local noticeInfo = self:MaskNotice2NoticeCls(ret.NoticeInfoList[i])
                    table.insert(noticeTab, noticeInfo)
                end
            end
            self._callback(noticeTab)
            self._callback = nil
        end
    end
end

---@param noticeInfo GCloud.MSDK.MSDKNoticeInfo
function NoticeData:MaskNotice2NoticeCls(noticeInfo)
    local noticeCls = UINoticeCls:New()
    noticeCls.NoticeId = noticeInfo.NoticeId
    noticeCls.NoticeGroup = noticeInfo.NoticeGroup
    noticeCls.NoticeType = noticeInfo.NoticeType
    noticeCls.Order = noticeInfo.Order
    noticeCls.Text_NoticeTitle = noticeInfo.TextInfo.NoticeTitle
    noticeCls.Text_NoticeContent = noticeInfo.TextInfo.NoticeContent
    
    --平台筛选
    if not self._thisPlatform then
        Log.error("###[NoticeData] get platform fail !")
        return nil
    end
    
    local json = cjson.decode(noticeInfo.ExtraJson)
    if json then
        noticeCls.UniqID = json.UniqID

        --平台筛选
        local platform = json.platform
        if not platform then
            Log.debug("###[NoticeData] notice platform is nil !")
            
            -- 如果没配就只在手机上显示
            if self._thisPlatform ~= NoticeClientPlatform.Mobile then
                self:DebugLog("公告没配平台而且当前不是手机平台,NoticeId[",noticeCls.NoticeId,"]")
                return nil
            end
        else
            Log.debug("###[NoticeData] notice platform is --> ",platform)

            if platform == NoticeClientPlatform.All then
                --全平台
            else
                -- 如果配了，检查平台
                if self._thisPlatform ~= platform then
                    self:DebugLog("公告没有通过平台筛选,NoticeId[",noticeCls.NoticeId,"]")
                    return nil
                end
            end
        end
    else
        -- 如果没配就只在手机上显示
        if self._thisPlatform ~= NoticeClientPlatform.Mobile then
            self:DebugLog("公告没配平台而且当前不是手机平台,NoticeId[",noticeCls.NoticeId,"]")
            return nil
        end
    end
    return noticeCls
end
---@param num ClientRuntimeOS
---@return NoticeClientPlatform
function NoticeData:PlatformNumber2String(num)
    if num == ClientRuntimeOS.CRO_ANDROID then
        return NoticeClientPlatform.Mobile
    elseif num == ClientRuntimeOS.CRO_IOS then
        return NoticeClientPlatform.Mobile
    elseif num == ClientRuntimeOS.CRO_PC then
        return NoticeClientPlatform.Pc
    end
end

function NoticeData:_ConvertINTLNoticeInfo2NoticeCls(INTL_noticeInfo)
    local UINoticeCls = UINoticeCls:New()

    if INTL_noticeInfo.ContentList.Count <= 0 then
        return
    end

    --大区筛选
    local areaListStr = INTL_noticeInfo.AreaList
    Log.debug("###[NoticeData] INTL_noticeInfo.AreaList --> ", INTL_noticeInfo.AreaList)
    local areajson = cjson.decode(areaListStr)
    if areajson and table.count(areajson) > 0 then
        Log.debug("###[NoticeData] 配置了大区id,数量-->", table.count(areajson))
        local inAreaList = false
        local h3dAreaStr = tostring(self.m_partition)
        for key, value in pairs(areajson) do
            Log.debug("###[NoticeData] 大区匹配 intl.area：", value, " -- h3d.area", h3dAreaStr)
            if value == h3dAreaStr then
                Log.debug("###[NoticeData] 大区匹配成功")
                inAreaList = true
                break
            end
        end
        if not inAreaList then
            Log.debug("###[NoticeData] 大区匹配失败")
            self:DebugLog("大区匹配失败,NoticeId[",INTL_noticeInfo.NoticeId,"]")
            return nil
        end
    else
        --如果不配的话，return表示不配不显示，不return表示不配默认全大区显示
        --return nil
        Log.debug("###[NoticeData] 没有配置大区")
    end

    local curContent = INTL_noticeInfo.ContentList[0]
    --先转MSDK和INTL共有的成员
    UINoticeCls.NoticeId = INTL_noticeInfo.NoticeId
    local jsonTable = cjson.decode(INTL_noticeInfo.ExtraData)
    if jsonTable == nil then
        Log.error("###[NoticeData] notice jsonTable is nil ! id --> ",INTL_noticeInfo.NoticeId)

         -- 如果没配json,当做没配平台处理,就只在手机上显示
         if self._thisPlatform ~= NoticeClientPlatform.Mobile then
            self:DebugLog("公告没配平台而且当前不是手机平台,NoticeId[",INTL_noticeInfo.NoticeId,"]")
            return nil
        end
    else
        --平台筛选
        local platform = jsonTable.platform
        if not self._thisPlatform then
            Log.error("###[NoticeData] get platform fail !")
            self:DebugLog("当前平台获取失败")
            return nil
        end
        if not platform then
            Log.debug("###[NoticeData] notice platform is nil !")
            
            -- 如果没配就只在手机上显示
            if self._thisPlatform ~= NoticeClientPlatform.Mobile then
                self:DebugLog("公告没配平台而且当前不是手机平台,NoticeId[",INTL_noticeInfo.NoticeId,"]")
                return nil
            end
        else
            Log.debug("###[NoticeData] notice platform is --> ",platform)
            
            -- 如果配了，检查平台
            if platform == NoticeClientPlatform.All then
                --全平台
            else
                -- 如果配了，检查平台
                if self._thisPlatform ~= platform then
                    self:DebugLog("公告没有通过平台筛选,NoticeId[",INTL_noticeInfo.NoticeId,"]")
                    return nil
                end
            end
        end
    end
    
    UINoticeCls.Text_NoticeTitle = curContent.Title
    UINoticeCls.Text_NoticeContent = curContent.Content

    UINoticeCls.NoticeGroup = jsonTable.noticeGroup
    UINoticeCls.NoticeType = tonumber(jsonTable.noticeType)
    UINoticeCls.Order = tonumber(jsonTable.order)
    UINoticeCls.UniqID = tonumber(jsonTable.uniqID)

    return UINoticeCls
end

---海外请求公告的回调
function NoticeData:OnOverSeaNoticeRetEvent(ret)
    if ret == nil then
        Log.debug("[notice] ### ret is nil !")
        return
    else
        Log.debug("[notice] ### ret is not nil ! ")
        Log.debug("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        Log.debug(ret)
        Log.debug(ret.SeqID)
    end
    if ret.SeqID == self.m_reqid then
        Log.debug("[notice] ### On Oversea request notice data finish")
        if ret.NoticeInfoList.Count > 0 then
            Log.debug("[notice] ### ret ~= nil and ret.NoticeInfoList.Count - ", ret.NoticeInfoList.Count)

            --清空缓存
            self._noticeDic = {}
            self._noticeDic[NoticeType.System] = {}
            self._noticeDic[NoticeType.Active] = {}

            local systemList_temp = {}
            local activeList_temp = {}

            for i = 0, ret.NoticeInfoList.Count - 1 do
                ---@type INTL.INTLNoticeInfo
                local tempNoticeInfo = ret.NoticeInfoList[i]

                ---@type UINoticeCls
                local noticeInfo = self:_ConvertINTLNoticeInfo2NoticeCls(tempNoticeInfo)
                if noticeInfo then
                    --Log.debug("###公告获取id测试:start -->")
                    --Log.debug("###id-->", noticeInfo.NoticeId)
                    if noticeInfo.NoticeType == NoticeType.Active then
                        Log.debug("noticeInfo.NoticeType == NoticeType.Active")
                        table.insert(activeList_temp, noticeInfo)
                    elseif noticeInfo.NoticeType == NoticeType.System then
                        Log.debug("noticeInfo.NoticeType == NoticeType.System")
                        table.insert(systemList_temp, noticeInfo)
                    end
                end
            end
            --数量
            local systemCount = table.count(systemList_temp)
            local activeCount = table.count(activeList_temp)
            self._noticeCountDic[NoticeType.System] = systemCount
            self._noticeCountDic[NoticeType.Active] = activeCount

            Log.debug("activeList_temp size(): ", activeCount)
            Log.debug("systemList_temp size(): ", systemCount)

            --Log.debug("[notice] ### request notice count active-", activeCount, " system-", systemCount)

            --排序
            if table.count(systemList_temp) > 0 then
                table.sort(
                    systemList_temp,
                    function(a, b)
                        return a.Order > b.Order
                    end
                )
            end
            if table.count(activeList_temp) > 0 then
                table.sort(
                    activeList_temp,
                    function(a, b)
                        return a.Order > b.Order
                    end
                )
            end

            --存储
            for i = 1, #activeList_temp do
                table.insert(self._noticeDic[NoticeType.Active], activeList_temp[i])
            end
            for i = 1, #systemList_temp do
                table.insert(self._noticeDic[NoticeType.System], systemList_temp[i])
            end

            --检查new
            self._noticeNewDic[NoticeType.Active] = false
            for i = 1, #self._noticeDic[NoticeType.Active] do
                if self:CheckNoticeNew(self._noticeDic[NoticeType.Active][i].NoticeId, NoticeType.Active) then
                    self._noticeNewDic[NoticeType.Active] = true
                    break
                end
            end
            self._noticeNewDic[NoticeType.System] = false
            for i = 1, #self._noticeDic[NoticeType.System] do
                if self:CheckNoticeNew(self._noticeDic[NoticeType.System][i].NoticeId, NoticeType.System) then
                    self._noticeNewDic[NoticeType.System] = true
                    break
                end
            end
        end
        GameGlobal.EventDispatcher():Dispatch(GameEventType.OnNoticeDataCheckNew)
    elseif ret.SeqID == self.m_reqid_cb then
        if self._callback then
            local noticeTab = {}
            if ret.NoticeInfoList.Count > 0 then
                for i = 0, ret.NoticeInfoList.Count - 1 do
                    ---@type UINoticeCls
                    local noticeInfo = self:_ConvertINTLNoticeInfo2MSDK(ret.NoticeInfoList[i])
                    table.insert(noticeTab, noticeInfo)
                end
            end
            self._callback(noticeTab)
            self._callback = nil
        end
    end
end

---#设置公告new状态
---@param insertOrRemove boolean true-insert,false-remove
function NoticeData:SetNoticeNew(noticeid, type, insertOrRemove)
    local openIds = GameGlobal.GameLogic():GetOpenId()
    local appendValue = ""
    if type == NoticeType.Active then
        appendValue = self._keyAppendValueActive
    elseif type == NoticeType.System then
        appendValue = self._keyAppendValueSystem
    end
    local openid = ""
    if (openIds ~= nil) then
        openid = openIds
    end
    local key = openid .. appendValue
    local value = nil
    if UnityEngine.PlayerPrefs.HasKey(key) then
        value = UnityEngine.PlayerPrefs.GetString(key)
    end

    if insertOrRemove then
        if value then
            value = value .. "|" .. noticeid
        else
            value = tostring(noticeid)
        end

        UnityEngine.PlayerPrefs.SetString(key, value)
    else
        if value then
            local idtab = string.split(value, "|")
            for i = 1, table.count(idtab) do
                local id1 = idtab[i]
                if id1 == noticeid then
                    table.remove(idtab, i)
                    local idstr = ""
                    for j = 1, table.count(idtab) do
                        local id2 = idtab[j]
                        if j ~= table.count(idtab) then
                            idstr = idstr .. idtab[j] .. "|"
                        else
                            idstr = idstr .. idtab[j]
                        end
                    end
                    UnityEngine.PlayerPrefs.SetString(key, idstr)
                    return
                end
            end
        end
    end

    --检查new
    self._noticeNewDic[type] = false
    for i = 1, #self._noticeDic[type] do
        if self:CheckNoticeNew(self._noticeDic[type][i].NoticeId, type) then
            self._noticeNewDic[type] = true
            break
        end
    end
end

---#检查公告new状态
function NoticeData:CheckNoticeNew(noticeid, type)
    local openIds = GameGlobal.GameLogic():GetOpenId()
    local appendValue = ""
    if type == NoticeType.Active then
        appendValue = self._keyAppendValueActive
    elseif type == NoticeType.System then
        appendValue = self._keyAppendValueSystem
    end
    local openid = ""
    if (openIds ~= nil) then
        openid = openIds
    end

    local key = openid .. appendValue

    local value = nil
    if UnityEngine.PlayerPrefs.HasKey(key) then
        value = UnityEngine.PlayerPrefs.GetString(key)
    else
    end
    if value then
        --切割，检查
        local idtab = string.split(value, "|")
        for i = 1, table.count(idtab) do
            local id = tonumber(idtab[i])
            if id == noticeid then
                return false
            end
        end
    end

    return true
end

---#本地获取公告数据
---@param group string 分组
---@return UINoticeCls[]
function NoticeData:GetNoticeDataWithGroup(type)
    return self._noticeDic[type]
end

---#本地获取新公告的状态
---@param group string 分组
function NoticeData:GetNoticeNewStateWithGroup(type)
    if self._noticeNewDic[type] ~= nil then
        return self._noticeNewDic[type]
    end
    return nil
end
---#本地获取公告的数量
---@param group string 分组
function NoticeData:GetNoticeCountStateWithGroup(type)
    return self._noticeCountDic[type]
end

function NoticeData:Dispose()
    Log.debug("[notice] ### NoticeData:Dispose")

    SDKProxy:GetInstance():NoticeRetEvent(self.onNoticeRetEvent, false)

    self.m_ret = nil

    self.m_reqid = nil

    self.m_group = nil
    self.m_language = nil
    self.m_region = nil
    self.m_partition = nil
    self.m_extraJson = nil

    if (self._StartGetNoticeNextEvent ~= nil) then
        GameGlobal.Timer():CancelEvent(self._StartGetNoticeNextEvent)
        self._StartGetNoticeNextEvent = nil
    end

    if self._requestEventLoop ~= nil then
        GameGlobal.Timer():CancelEvent(self._requestEventLoop)
        self._requestEventLoop = nil
    end
    self.onNoticeRetEvent = nil
end

--region NoticeData 公告对象
---@class UINoticeCls:Object
_class("UINoticeCls", Object)
UINoticeCls = UINoticeCls

function UINoticeCls:Constructor()
    self.NoticeId = 0
    self.NoticeGroup = ""
    self.NoticeType = 0
    self.Order = 0
    self.Text_NoticeTitle = ""
    self.Text_NoticeContent = ""
    self.UniqID = 0
end

--客户端公告运行操作系统
--- @class NoticeClientPlatform
local NoticeClientPlatform = {
    All = "all",
    Mobile = "mobile",
    Pc = "pc",
}
_enum("NoticeClientPlatform", NoticeClientPlatform)