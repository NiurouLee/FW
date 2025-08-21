--
---@class UIHomelandTaskItem : UICustomWidget
_class("UIHomelandTaskItem", UICustomWidget)
UIHomelandTaskItem = UIHomelandTaskItem

function UIHomelandTaskItem:Constructor()
    self._atlas = self:GetAsset("UIHomelandTask.spriteatlas", LoadType.SpriteAtlas)
end

--初始化
function UIHomelandTaskItem:OnShow(uiParams)
    self:_GetComponents()
end

--获取ui组件
function UIHomelandTaskItem:_GetComponents()
    self._stateLeft = self:GetUIComponent("Image", "StateLeft")
    self._stateTag = self:GetUIComponent("Image", "StateTag")
    self._title = self:GetUIComponent("UILocalizationText", "Title")
    ---@type RollingText
    self._titleRolling = self:GetUIComponent("RollingText", "Title")
    self._value = self:GetUIComponent("UILocalizationText", "Value")
    self._rewards = self:GetUIComponent("UISelectObjectPath", "Rewards")
    self._stateText = self:GetGameObject("StateText")
    self._getRewardBtn = self:GetGameObject("GetRewardBtn")
    self._gray = self:GetGameObject("Gray")
    self._background = self:GetUIComponent("RawImageLoader", "Background")
end

--设置数据
---@param quest Quest
---@param callBack function
function UIHomelandTaskItem:SetData(quest, callBack)
    ---@type Quest
    self._quest = quest
    self._callBack = callBack
    ---@type MobileQuestInfo
    local questInfo = self._quest:QuestInfo()
    local leftSprite = "N17_task_kuang04"
    local tagSprite = "N17_task_icon06"
    local titleColor = Color(92 / 255, 92 / 255, 92 / 255)
    local valueStr = string.format("<color=#808080>(%d/%d)</color>", questInfo.cur_progress, questInfo.total_progress)
    local background = "N17_task_di04"
    if questInfo.status == QuestStatus.QUEST_Accepted then
    elseif questInfo.status == QuestStatus.QUEST_Completed then
        leftSprite = "N17_task_kuang05"
        tagSprite = "N17_task_icon07"
        valueStr =
            string.format(
            "<color=#808080>(</color><color=#faaa28>%s</color><color=#808080>/%s)</color>",
            questInfo.cur_progress,
            questInfo.total_progress
        )
    elseif questInfo.status == QuestStatus.QUEST_Taken then
        leftSprite = "N17_task_kuang06"
        tagSprite = "N17_task_icon08"
        titleColor = Color(178 / 255, 178 / 255, 178 / 255)
        --valueStr = string.format("<color=#808080>(</color><color=#faaa28>%s</color><color=#808080>/%s)</color>", questInfo.cur_progress, questInfo.total_progress)
        background = "N17_task_di05"
    end
    self._stateLeft.sprite = self._atlas:GetSprite(leftSprite)
    self._stateTag.sprite = self._atlas:GetSprite(tagSprite)
    --self._title:SetText(StringTable.Get(questInfo.QuestDesc))
    self._titleRolling:RefreshText(StringTable.Get(questInfo.QuestDesc))
    self._title.color = titleColor
    self._value:SetText(valueStr)
    self._stateText:SetActive(questInfo.status <= QuestStatus.QUEST_Accepted)
    self._getRewardBtn:SetActive(questInfo.status == QuestStatus.QUEST_Completed)
    self._gray:SetActive(questInfo.status == QuestStatus.QUEST_Taken)
    self._background:LoadImage(background)
    self:_SetRewardItem(questInfo)
end

---@param questinfo MobileQuestInfo
function UIHomelandTaskItem:_SetRewardItem(questinfo)
    local count = #questinfo.rewards
    if count <= 0 then
        return
    end
    self._rewards:SpawnObjects("UIItemHomeland", count)
    ---@type table <number, UIItemHomeland>
    local items = self._rewards:GetAllSpawnList()
    for i = 1, count do
        local cfg = Cfg.cfg_item[questinfo.rewards[i].assetid]
        if cfg then
            items[i]:Flush(questinfo.rewards[i])
        end
    end
end

--领取奖励
function UIHomelandTaskItem:GetRewardBtnOnClick(go)
    local cb = function()
        if self._callBack then
            self._callBack(self._quest:QuestInfo().quest_id)
        end
    end
    --领奖之前检查家园币是否超上限
    ---@type MobileQuestInfo
    local questInfo = self._quest:QuestInfo()
    for index, reward in ipairs(questInfo.rewards) do
        if reward.assetid == UIHomelandShopHelper.GetCoinItemId() then
            UIHomelandShopHelper.CheckCoinOverflow(reward.count, cb)
            return
        end
    end

    cb()
end
