---@class UIReviewProgressAwardDetailItem_N9 : UIReviewProgressAwardDetailItem
_class("UIReviewProgressAwardDetailItem_N9", UIReviewProgressAwardDetailItem)
UIReviewProgressAwardDetailItem_N9 = UIReviewProgressAwardDetailItem_N9

-- function UIReviewProgressAwardDetailItem_N9:SetData(id, count, progress, collected, canCollect, onClick)
-- end

-- function UIReviewProgressAwardDetailItem_N9:_SetAwardIcon(id)
-- end

function UIReviewProgressAwardDetailItem_N9:_SetAwardCount(count)
    UIWidgetHelper.SetLocalizationText(self, "count", count)
end

function UIReviewProgressAwardDetailItem_N9:_SetProgress(num)
    local tb = {"progress1", "progress2", "progress3"}
    for _, w in ipairs(tb) do
        UIWidgetHelper.SetLocalizationText(self, w, num .. "%")
    end
end

function UIReviewProgressAwardDetailItem_N9:_SetState(state)
    self._stateObj = UIWidgetHelper.GetObjGroupByWidgetName(self,
        {
            {"pg_cantCollect", "cantCollect"},
            {"pg_canCollect", "canCollect"},
            {"pg_collected", "collected"}
        },
        self._stateObj
    )
    UIWidgetHelper.SetObjGroupShow(self._stateObj, state)
end

-- function UIReviewProgressAwardDetailItem_N9:PlayEnterAni(index)
-- end

-- function UIReviewProgressAwardDetailItem_N9:IconOnClick(go)
-- end

-- function UIReviewProgressAwardDetailItem_N9:CollectBtnOnClick(go)
-- end