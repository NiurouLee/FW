---@class UITopRankController : UIController
_class("UITopRankController", UIController)
UITopRankController = UITopRankController
function UITopRankController:OnShow(uiParams)
    self._animPlaying = false
    ------------------------------------
    local frameTime = 1000 / 60
    --美术约定：
    self.maxLvTime_start = frameTime * 0
    self.maxLvTime_end = frameTime * 40
    self.maxLvTime_Gaps = self.maxLvTime_end - self.maxLvTime_start
    self.accTime = 0

    self._showCountMax = 5
    self._itemCountPerRow = 1
    self._petModule = GameGlobal.GetModule(PetModule)
    
    self._passList = self._module:TacticPeakRewardedList()

    self:GetComponents()
    self:OnValue()
    self:AddListeners()
end

function UITopRankController:LoadDataOnEnter(TT,res,uiParams)
    ---@type AircraftModule
    self._module = GameGlobal.GetModule(AircraftModule)

    local req = self._module:RequestRefreshTacticRoom(TT)
    if req:GetSucc() then
        res:SetSucc(true)
    else
        res:SetSucc(false)
        local result = req:GetResult()
        Log.error("###[UITopRankController] RequestRefreshTacticRoom fail ! result --> ",result)
    end
end
function UITopRankController:BackBtn()
    self:CloseDialog()
end
function UITopRankController:HelpBtn()
    --self:ShowDialog("UIHelpController","UIDataBase")
end
function UITopRankController:GetComponents()
    self._ltBtn = self:GetUIComponent("UISelectObjectPath","backBtns")
    ---@type UICommonTopButton
    self._backBtns = self._ltBtn:SpawnObject("UICommonTopButton")
    self._backBtns:SetData(
        function()
            self:BackBtn()
        end,
        nil,nil,true)
    
    ---@type UIDynamicScrollView
    self._scrollView = self:GetUIComponent("UIDynamicScrollView","scrollView")
    self._scrollViewRect = self:GetUIComponent("RectTransform","scrollView")

    self._lvTex = self:GetUIComponent("UILocalizationText","lv")
    self._lvAnim = self:GetUIComponent("Animation","lv")
    self._lvStrTex = self:GetUIComponent("UILocalizationText","lvStr")
        ---@type UnityEngine.UI.Image
    self._expImg = self:GetUIComponent("Image","valueImg")
    self._expTex = self:GetUIComponent("UILocalizationText","valueTex")

    local s = self:GetUIComponent("UISelectObjectPath", "itemTips")
    self._tips = s:SpawnObject("UISelectInfo")

    self._atlas = self:GetAsset("UIAircraftDataBase.spriteatlas", LoadType.SpriteAtlas)
    self._sp1 = self._atlas:GetSprite("n8_simulator_rank_list1")
    self._sp2 = self._atlas:GetSprite("n8_simulator_rank_list2")
end
function UITopRankController:AddListeners()
end
function UITopRankController:OnValue()
    self:Icon()
    self:Exp()
    self:Award()
end
function UITopRankController:Icon()
end
function UITopRankController:Exp()
    self._exp = self:GetExp()
    
    local cfg_top_rank = Cfg.cfg_peak{}
    local cfg_max = cfg_top_rank[#cfg_top_rank]
    if not cfg_max then
        Log.error("###[UITopRankController] cfg_max is nil !")
    end
    
    self._currentLv = self._module:GetLvByExp(self._exp)
    local open_id = GameGlobal.GameLogic():GetOpenId()
    local key = "rank_save_lv_controller_"..open_id
    --上次的经验
    local saveExp = LocalDB.GetInt(key,0)
    LocalDB.SetInt(key,self._exp)

    local lastLv = self._module:GetLvByExp(saveExp)
    --是否播经验条动画
    self._expSliderAnim = false
    self._expSliderAnimStart = false
    if lastLv < self._currentLv then
        --播等级动效
        --在In动画播放的0~666ms内做先快后慢的滚字动画；
        --滚字动画结束后，播下图节点的动画；
        --self._animPlaying = true
        self.lastMaxLv=lastLv
        self.nowMaxLv=self._currentLv
        Log.debug("###[UITopRankController] 变化的等级:start->",lastLv,"|end->",self._currentLv)

        --没有等级变化经验条也不播了，所以放在这里
        --播经验条动效
        --在In动画播放的0~1333ms内，进度条做增长动画，从旧值一直滚动到最新值；
        self._expSliderAnim = true
        self._startExp = saveExp
        self._endExp = self._exp
    end
    if saveExp < self._exp then
        Log.debug("###[UITopRankController] 变化的经验:start->",saveExp,"|end->",self._exp)
    end
    
    Log.debug("###[UITopRankController] self._currentLv --> ",self._currentLv)
    
    self._lvStrTex:SetText(StringTable.Get("str_aircraft_tactic_rank_lv")..".")
    self._lvTex:SetText(lastLv)

    local lvMax = cfg_max.ID
    Log.debug("###[UITopRankController] lvMax --> ",lvMax)

    self._isExpFull = false

    local rate
    local expTex
    if self._currentLv >= lvMax then
        self._isExpFull = true

        local lastLv = lvMax-1
        local last_cfg = cfg_top_rank[lastLv]
        if not last_cfg then
            Log.error("###[UITopRankController] cfg_top_rank is nil ! id --> ",lastLv)    
        end
        local expLast = last_cfg.Exp
        local current_cfg = cfg_top_rank[lvMax]
        if not current_cfg then
            Log.error("###[UITopRankController] cfg_top_rank is nil ! id --> ",lvMax)    
        end
        local expCurrent = current_cfg.Exp
        rate = 1
        expTex = "<color=#fddb6f><size=50>"..(expCurrent-expLast).."</size></color>/<color=#ffffff><size=40>"..(expCurrent-expLast).."</size></color>"
      else        
        local nextLv = self._currentLv+1

        local nextExp
        local next_cfg = cfg_top_rank[nextLv]
        if not next_cfg then
            Log.error("###[UITopRankController] cfg_top_rank is nil ! id --> ",nextLv)    
        end
        nextExp = next_cfg.Exp
        local currentExp
        if self._currentLv == 0 then
            currentExp = 0
        else
            local current_cfg = cfg_top_rank[self._currentLv]
            if not current_cfg then
                Log.error("###[UITopRankController] cfg_top_rank is nil ! id --> ",self._currentLv)    
            end
            currentExp = current_cfg.Exp
        end
        
        if nextExp == currentExp then
            Log.error("###[UITopRankController] nextExp == currentExp !")
        end

        rate = (self._exp-currentExp)/(nextExp-currentExp)
        expTex = "<color=#fddb6f><size=50>"..(self._exp-currentExp).."</size></color>/<color=#ffffff><size=40>"..(nextExp-currentExp).."</size></color>"
    end
    self._expTex:SetText(expTex)
    if self._expSliderAnim then
        self:PlayExpSliderTween()
    else
        self._expImg.fillAmount = rate
    end
end
function UITopRankController:GetRateByExpAndLv(exp,lv)
    local rate = 0
    local nextLv = lv+1
    local cfg_top_rank = Cfg.cfg_peak{}
    local nextExp
    local next_cfg = cfg_top_rank[nextLv]
    if not next_cfg then
        Log.error("###[UITopRankController] cfg_top_rank is nil ! id --> ",nextLv)    
    end
    nextExp = next_cfg.Exp
    local currentExp
    if lv == 0 then
        currentExp = 0
    else
        local current_cfg = cfg_top_rank[lv]
        if not current_cfg then
            Log.error("###[UITopRankController] cfg_top_rank is nil ! id --> ",lv)    
        end
        currentExp = current_cfg.Exp
    end
    
    if nextExp == currentExp then
        Log.error("###[UITopRankController] nextExp == currentExp !")
    end

    local rate = (exp-currentExp)/(nextExp-currentExp)
    return rate
end
function UITopRankController:PlayExpSliderTween()
    if self._expSliderAnim then
        self._sliderAnimTime = 1.333

        --先获取上一级的经验比例
        local lastRate = self:GetRateByExpAndLv(self._startExp,self.lastMaxLv)
        --在获取下一级的经验比例
        local nextRate
        if self._isExpFull then
            nextRate = 1
        else
            nextRate = self:GetRateByExpAndLv(self._endExp,self.nowMaxLv)
        end
        self._expImg.fillAmount = lastRate
        if self._sliderTweener then
            self._sliderTweener:Kill()
        end
        if self._event then
            GameGlobal.Timer():CancelEvent(self._event)
            self._event = nil
        end
        self._event = GameGlobal.Timer():AddEvent(500,function()
            self._animPlaying = true
            if self._isExpFull then
                --如果满了就只播从当前到1的动画
                ---@type DG.Tweening.Tweener
                self._sliderTweener = self._expImg:DOFillAmount(1,self._sliderAnimTime):SetEase(DG.Tweening.Ease.OutQuad)
            else
                --否则先播从当前比例到1（线性）,再播从0到目标比例（先快后慢）
                --两段动画的时间分配根据比例的不同来算
                local timeRate1 = (1-lastRate)/((1-lastRate)+nextRate)
                local timeRate2 = nextRate/((1-lastRate)+nextRate)
                
                local time1 = self._sliderAnimTime*timeRate1
                local time2 = self._sliderAnimTime*timeRate2
                
                self._sliderTweener = self._expImg:DOFillAmount(1,time1):SetEase(DG.Tweening.Ease.Linear):OnComplete(
                    function()
                        self._expImg.fillAmount = 0
                        self._sliderTweener = self._expImg:DOFillAmount(nextRate,time2):SetEase(DG.Tweening.Ease.OutQuad)
                    end
                    )
            end
        end)
    end
end
function UITopRankController:OnHide()
    if self._event then
        GameGlobal.Timer():CancelEvent(self._event)
        self._event = nil
    end
    if self._sliderTweener then
        self._sliderTweener:Kill()
    end
end
function UITopRankController:OnUpdate(deltaTimeMS)
    if self._animPlaying then
        self.accTime = self.accTime + deltaTimeMS

        local percent_lv = (self.accTime - self.maxLvTime_start) / self.maxLvTime_Gaps
        if self.accTime >= self.maxLvTime_end then
            percent_lv = 1
        end
        if percent_lv <= 1 and percent_lv >= 0 then
            local lvRec =
                DG.Tweening.DOVirtual.EasedValue(self.lastMaxLv, self.nowMaxLv, percent_lv, DG.Tweening.Ease.OutQuad)
            self._lvTex:SetText(math.floor(lvRec))
        end

        if self.accTime >= self.maxLvTime_end then
            self._animPlaying = false
            Log.debug("###[UITopRankController] 播放滚字动画结束,开始闪特效动画")
            self:PlayLvEff()
        end
    end
end
function UITopRankController:PlayLvEff()
    self._lvAnim:Play("uieff_TopRank_ChangeLevel")
end
function UITopRankController:GetExp()
    local expID = Cfg.cfg_aircraft_values[36].IntValue
    if expID then
        local count = GameGlobal.GetModule(RoleModule):GetAssetCount(expID)
        Log.debug("###[UITopRankController] exp --> ",count)
        return count
    end
    Log.error("###[UITopRankController] expID is nil !")
    return 0
end
--奖励列表,反序
function UITopRankController:Award()
    local cfg_top_rank = Cfg.cfg_peak{}
    local haveAwards = {}
    for key, value in pairs(cfg_top_rank) do
        local awards = value.Award
        if awards then
            table.insert(haveAwards,value)
        end
    end
    table.sort(haveAwards,function(a,b)
        return a.ID < b.ID
    end)
    local stopList = {}
    local itemHeigth = 176+7
    local scrollViewHeight = self._scrollViewRect.rect.size.y
    local showCount = math.ceil(scrollViewHeight/itemHeigth)

    Log.debug("###[UITopRankController] showCount --> ",showCount)
    
    --MSG32937	（QA_郭简宁）战斗模拟器QA_巅峰等级默认全部开启_2021.11.22	5	QA-开发制作中	李学森, 1958	11/25/2021	
    -- for i = 1, #haveAwards do
    --     local lv = haveAwards[i].ID
    --     if lv > self._currentLv and i >= showCount then
    --         table.insert(stopList,haveAwards[i])
    --         break
    --     else
    --         table.insert(stopList,haveAwards[i])
    --     end
    -- end
    --改为
    for i = 1, #haveAwards do
        table.insert(stopList,haveAwards[i])
    end

    local count = #stopList
    Log.debug("###[UITopRankController] stopList count --> ",count)

    local revertList = {}
    for i = 1, #stopList do
        local item = stopList[#stopList - i + 1]
        revertList[i] = item
    end

    self._awardList = revertList

    self:_ScrollView()

    self:MoveContentPos()
end
--移动到显示下一级
function UITopRankController:MoveContentPos()
    local gotIdx = #self._awardList
    for i = 1, #self._awardList do
        local lv = self._awardList[i].ID
        if lv <= self._currentLv then
            gotIdx = i - 1
            break
        end
    end
    if gotIdx > 0 then
        gotIdx = gotIdx - 1
    end
    self._scrollView:MovePanelToItemIndex(gotIdx,0)
end
function UITopRankController:_ScrollView()
    self._scrollView:InitListView(
       #self._awardList,
        function(scrollView, index)
            return self:_InitRowItem(scrollView, index)
        end
    )
end
function UITopRankController:_InitRowItem(scrollView, index)
    if index < 0 then
        return nil
    end
    local item = scrollView:NewListViewItem("RowItem")
    local rowPool = self:GetUIComponentDynamic("UISelectObjectPath", item.gameObject)
    if item.IsInitHandlerCalled == false then
        item.IsInitHandlerCalled = true
        rowPool:SpawnObjects("UITopRankItem", self._itemCountPerRow)
    end
    ---@type UITopRankItem[]
    local rowList = rowPool:GetAllSpawnList()
    for i = 1, self._itemCountPerRow do
        local heartItem = rowList[i]
        local itemIndex = index * self._itemCountPerRow + i
        self:_InitAwardItem(heartItem, itemIndex)
    end
    return item
end
---@param widget UITopRankItem
function UITopRankController:_InitAwardItem(widget,index)
    local awards = self._awardList[index].Award
    local lv = self._awardList[index].ID
    local got = self:GetGotStateByLv(lv)
    widget:SetData(
        index,
        lv,
        self._currentLv,
        got,
        awards,
        self._sp1,
        self._sp2,
        function(lv)
            self:itemGetBtnClick(lv)
        end,
        function(id,pos)
            self:itemIconClick(id,pos)
        end
    )
end
function UITopRankController:GetGotStateByLv(lv)
    self._passList = self._module:TacticPeakRewardedList()
    return table.icontains(self._passList,lv)
end
function UITopRankController:itemIconClick(id,pos)
    self._tips:SetData(id,pos)
end
--单个领奖
function UITopRankController:itemGetBtnClick(lv)
    local lvList = {}
    lvList[1] = lv
    Log.debug("###[UITopRankController] itemGetBtnClick lv --> ",lv)
    self:GetRewardRequest(lvList)
end
function UITopRankController:_ShowAwards(awards)
    local tempPets = {}
    if #awards > 0 then
        for i = 1, #awards do
            local ispet = self._petModule:IsPetID(awards[i].assetid)
            if ispet then
                table.insert(tempPets, awards[i])
            end
        end
    end
    if #tempPets > 0 then
        self:ShowDialog(
            "UIPetObtain",
            tempPets,
            function()
                GameGlobal.UIStateManager():CloseDialog("UIPetObtain")
                self:ShowDialog("UIGetItemController", awards)
            end
        )
    else
        self:ShowDialog("UIGetItemController", awards)
    end
end
--一键领奖
function UITopRankController:oneKeyBtnOnClick(go)
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N8DefaultClick)
    local levelList = {}
    --获取全部可领取
    for i = 1, #self._awardList do
        local lv = self._awardList[i].ID
        local got = self:GetGotStateByLv(lv)
        if not got and lv <= self._currentLv then
            table.insert(levelList,lv)
        end
    end
    if #levelList > 0 then 
        local lvStr = ""
        for i = 1, #levelList do
            lvStr = lvStr .. "|" .. i
        end
        Log.debug("###[UITopRankController] oneKeyBtnOnClick lvStr --> ",lvStr)
        self:GetRewardRequest(levelList)
    else
        Log.debug("###[UITopRankController] oneKeyBtnOnClick lvStr is nil !")
    end
end
--领奖
function UITopRankController:GetRewardRequest(levelList)
    self:Lock("UITopRankController:GetRewardRequest")
    GameGlobal.TaskManager():StartTask(self.OnGetRewardRequest,self,levelList)
end
function UITopRankController:OnGetRewardRequest(TT,lvlist)
    local res,getLvList,rewardList = self._module:TacticPeakReward(TT,lvlist)
    self:UnLock("UITopRankController:GetRewardRequest")
    if res:GetSucc() then
        ---@type RoleAsset[]
        local awards = rewardList

        -- for i = 1, #getLvList do
        --     local lv = getLvList[i]
        --     local cfg = Cfg.cfg_peak[lv]
        --     if not cfg then
        --         Log.error("###[UITopRankController] OnGetRewardRequest cfg is nil ! lv --> ",lv)
        --     else
        --         local awardList = cfg.Award
        --         for j = 1, #awardList do
        --             local award = awardList[j]
                    
        --             local roleAsset = RoleAsset:New()
        --             roleAsset.assetid = award[1]
        --             roleAsset.count = award[2]

        --             table.insert(awards,roleAsset)
        --         end
        --     end
        -- end 
        if awards ~= nil then
            if #awards > 0 then
                self:_ShowAwards(awards)
            end
        end
        self._passList = self._module:TacticPeakRewardedList()
        GameGlobal.EventDispatcher():Dispatch(GameEventType.OnTopRankGetAward,getLvList)
    else
        local result = res:GetResult()
        Log.error("###[UITopRankController] GetAward fail ! result --> ",result)
    end
end