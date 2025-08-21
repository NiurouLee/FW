---@class UIReviewProgressAwardDetailItem_N14 : UIReviewProgressAwardDetailItem
_class("UIReviewProgressAwardDetailItem_N14", UIReviewProgressAwardDetailItem)
UIReviewProgressAwardDetailItem_N14 = UIReviewProgressAwardDetailItem_N14

-- function UIReviewProgressAwardDetailItem_N14:SetData(id, count, progress, collected, canCollect, onClick)
-- end

-- function UIReviewProgressAwardDetailItem_N14:_SetAwardIcon(id)
-- end

function UIReviewProgressAwardDetailItem_N14:_SetAwardCount(count)
    UIWidgetHelper.SetLocalizationText(self, "count", count)
end

function UIReviewProgressAwardDetailItem_N14:_SetProgress(num)
    local tb = {"progress1", "progress2", "progress3"}
    for _, w in ipairs(tb) do
        UIWidgetHelper.SetLocalizationText(self, w, num .. "%")
    end
end

function UIReviewProgressAwardDetailItem_N14:_SetState(state)
    self._stateObj = UIWidgetHelper.GetObjGroupByWidgetName(self,
        {
            {"pg_collected", "cantCollect"},
            {"pg_collected", "canCollect"},
            {"pg_collected", "collected"}
        },
        self._stateObj
    )
    UIWidgetHelper.SetObjGroupShow(self._stateObj, state)
end

-- function UIReviewProgressAwardDetailItem_N14:PlayEnterAni(index)
-- end

-- function UIReviewProgressAwardDetailItem_N14:IconOnClick(go)
-- end

-- function UIReviewProgressAwardDetailItem_N14:CollectBtnOnClick(go)
-- end