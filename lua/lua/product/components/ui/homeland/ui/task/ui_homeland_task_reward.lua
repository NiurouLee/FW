--
---@class UIHomelandTaskReward : UICustomWidget
_class("UIHomelandTaskReward", UICustomWidget)
UIHomelandTaskReward = UIHomelandTaskReward

function UIHomelandTaskReward:Constructor()
    self._atlas = self:GetAsset("UIHomelandTask.spriteatlas", LoadType.SpriteAtlas)
end

--初始化
function UIHomelandTaskReward:OnShow(uiParams)
    self:_GetComponents()
end

--获取ui组件
function UIHomelandTaskReward:_GetComponents()
    self._done = self:GetGameObject("Done")
    self._item = self:GetUIComponent("UISelectObjectPath", "Item")
    self._valueBg = self:GetUIComponent("Image", "ValueBg")
    self._value = self:GetUIComponent("UILocalizationText", "Value")
end

--设置数据
---@param quest Quest
---@param totalCount number
---@param callBack function
function UIHomelandTaskReward:SetData(quest, totalCount, callBack)
    self._quest = quest
    self._callBack = callBack
    local questInfo = quest:QuestInfo()
    local valueBgSprite = "N17_task_kuang03"
    if questInfo.status == QuestStatus.QUEST_Completed then
        valueBgSprite = "N17_task_kuang02"
    elseif questInfo.status == QuestStatus.QUEST_Taken then
        valueBgSprite = "N17_task_kuang01"
    end
    self._done:SetActive(questInfo.status == QuestStatus.QUEST_Taken)
    ---@type UIItemHomeland
    self._itemWidget = self._item:SpawnObject("UIItemHomeland")
    self._itemWidget:Flush(
        questInfo.rewards[1],
     function ()
            self:ItemOnClick()
        end
    )
    self._valueBg.sprite = self._atlas:GetSprite(valueBgSprite)
    local count = quest:ParseParams(questInfo.Cond)[2]
    self._value:SetText(count)
    self.view.gameObject.transform.localPosition = Vector3((count/totalCount) * 900, 0, 0)
end

--按钮点击
function UIHomelandTaskReward:ItemOnClick()
    local questInfo = self._quest:QuestInfo()
    if questInfo.status <= QuestStatus.QUEST_Accepted then
        self:ShowDialog("UIItemTipsHomeland", questInfo.rewards[1].assetid, self.view.gameObject)
    elseif questInfo.status == QuestStatus.QUEST_Completed then
        if self._callBack then
            self._callBack(questInfo.quest_id)
        end
    end
end
